const PIC1_COMMAND = 0x20;
const PIC1_DATA = 0x21;
const PIC2_COMMAND = 0xA0;
const PIC2_DATA = 0xA1;

const ICW1_INIT = 0x10;
const ICW1_ICW4 = 0x01;
const ICW4_8086 = 0x01;

fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[ret]"
        : [ret] "={al}" (-> u8),
        : [port] "{dx}" (port),
        : .{ .memory = true });
}

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
        : .{ .memory = true });
}

fn wait() void {
    outb(0x80, 0);
}

pub fn remap() void {
    const a1 = 0xFF;
    const a2 = 0xFF;

    // Start of initialization sequence (cascade)
    outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
    wait();
    outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
    wait();

    // ICW2: Vector offset (This is where we remap)
    // PIC Master starts at 0x20 (32)
    outb(PIC1_DATA, 0x20);
    wait();
    // Slave PIC starts at 0x28 (40)
    outb(PIC2_DATA, 0x28);
    wait();

    // ICW3: Cascade configuration
    outb(PIC1_DATA, 4);
    wait();
    outb(PIC2_DATA, 2);
    wait();

    // ICW4: 8086 mode
    outb(PIC1_DATA, ICW4_8086);
    wait();
    outb(PIC2_DATA, ICW4_8086);
    wait();

    // Restoring masks (0xFF = all hidden for now)
    outb(PIC1_DATA, a1);
    outb(PIC2_DATA, a2);
}

pub fn unmask(irq: u8) void {
    var port: u16 = PIC1_DATA;
    var line = irq;

    if (irq >= 8) {
        port = PIC2_DATA;
        line -= 8;
    }

    const value = inb(port) & ~(@as(u8, 1) << @as(u3, @intCast(line)));
    outb(port, value);
}

pub fn enableIrq(line: u8) void {
    var port: u16 = PIC1_DATA;
    var l = line;

    if (line >= 8) {
        port = PIC2_DATA;
        l -= 8;
    }

    // We must read the current mask so as not to overwrite other configurations.
    // Note: To do this properly, we would need an ‘inb’ function.
    // For now, we will assume that we can just unmask the requested IRQ abruptly,
    // or we will implement inb.
}

pub export fn pic_ack() callconv(.c) void {
    outb(PIC1_COMMAND, 0x20);
}
