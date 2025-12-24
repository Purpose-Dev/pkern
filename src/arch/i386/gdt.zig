const GdtEntry = packed struct {
    limit_low: u16,
    base_low: u16,
    base_middle: u8,
    access: u8,
    granularity: u8,
    base_high: u8,
};

const GdtPtr = packed struct {
    limit: u16,
    base: usize,
};

var gdt_entries: [3]GdtEntry = undefined;
var gdt_ptr: GdtPtr = undefined;

fn createGdtEntry(base: u32, limit: u32, access: u8, granularity: u8) GdtEntry {
    return GdtEntry{
        .limit_low = @as(u16, @intCast(limit & 0xFFFF)),
        .base_low = @as(u16, @intCast(base & 0xFFFF)),
        .base_middle = @as(u8, @intCast((base >> 16) & 0xFF)),
        .base_high = @as(u8, @intCast((base >> 24) & 0xFF)),
        .access = access,
        .granularity = @as(u8, @intCast((limit >> 16) & 0x0F)) | (granularity & 0xF0),
    };
}

pub fn init() void {
    gdt_ptr.limit = (@sizeOf(GdtEntry) * 3) - 1;
    gdt_ptr.base = @intFromPtr(&gdt_entries);

    // Entry 0: NULL (All to zero)
    gdt_entries[0] = createGdtEntry(0, 0, 0, 0);

    // Entry 1: Code Segment (Kernel)
    // Base: 0, Limit: 4GB, Access: 0x9A (Present, Ring0, Code, Readable)
    // Granularity: 0xCF (4KB blocks, 32-bit)
    gdt_entries[1] = createGdtEntry(0, 0xFFFFFFFF, 0x9A, 0xCF);

    // Entry 1: Code Segment (Kernel)
    // Base: 0, Limit: 4GB, Access: 0x92 (Present, Ring0, Code, Writable)
    // Granularity: 0xCF (4KB blocks, 32-bit)
    gdt_entries[2] = createGdtEntry(0, 0xFFFFFFFF, 0x92, 0xCF);

    loadGdt();
}

// Function for load GDT and reload segments registers
fn loadGdt() void {
    asm volatile (
        \\ lgdt (%[gdt_ptr])
        \\ jmp $0x08, $.reload_cs
        \\ .reload_cs:
        \\ mov $0x10, %ax
        \\ mov %ax, %ds
        \\ mov %ax, %es
        \\ mov %ax, %fs
        \\ mov %ax, %gs
        \\ mov %ax, %ss
        :
        : [gdt_ptr] "r" (&gdt_ptr),
        : .{ .ax = true });
}
