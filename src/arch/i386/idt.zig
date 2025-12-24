const IdtEntry = packed struct {
    base_low: u16,
    base_high: u16,
    selector: u16,
    zero: u8,
    type_attr: u8,
};

const IdtPtr = packed struct { limit: u16, base: usize };

var idt_entries: [256]IdtEntry = undefined;
var idt_ptr: IdtPtr = undefined;

extern fn isr_stub_keyboard() callconv(.c) void;

pub fn init() void {
    idt_ptr.limit = (@sizeOf(IdtEntry) * 256) - 1;
    idt_ptr.base = @intFromPtr(&idt_entries);

    for (&idt_entries) |*entry| {
        entry.base_low = 0;
        entry.base_high = 0;
        entry.selector = 0;
        entry.zero = 0;
        entry.type_attr = 0;
    }

    // IRQ 1 (Keyboard) is remapped to 32 + 1 = 33 by our PIC
    // We take the address of our assembler function
    const isr_address = @intFromPtr(&isr_stub_keyboard);

    // Selector 0x08 (Kernel Code), Flags 0x8E (Interrupt Gate 32-bit, Present, Ring0)
    setGate(33, isr_address, 0x08, 0x8E);

    loadIdt();
}

fn loadIdt() void {
    asm volatile ("lidt (%[idt_ptr])"
        :
        : [idt_ptr] "r" (&idt_ptr),
        : .{ .memory = true });
}

pub fn setGate(num: u8, base: usize, sel: u16, flags: u8) void {
    idt_entries[num].base_low = @as(u16, @intCast(base & 0xFFFF));
    idt_entries[num].base_high = @as(u16, @intCast((base >> 16) & 0xFFFF));
    idt_entries[num].selector = sel;
    idt_entries[num].zero = 0;
    idt_entries[num].type_attr = flags;
}
