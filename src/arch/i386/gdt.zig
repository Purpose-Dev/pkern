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

const GDT_BASE_ADDR: usize = 0x00000800;
const GDT_ENTRIES_COUNT = 7;

var gdt_entries: *[GDT_ENTRIES_COUNT]GdtEntry = @ptrFromInt(GDT_BASE_ADDR);
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
    gdt_ptr.limit = (@sizeOf(GdtEntry) * GDT_ENTRIES_COUNT) - 1;
    gdt_ptr.base = GDT_BASE_ADDR;

    // Entry 0: NULL (All to zero)
    gdt_entries[0] = createGdtEntry(0, 0, 0, 0);

    // Entry 1: Kernel Code
    // Base: 0, Limit: 4GB, Access: 0x9A (Present, Ring0, Code, Readable)
    // Granularity: 0xCF (4KB blocks, 32-bit)
    gdt_entries[1] = createGdtEntry(0, 0xFFFFFFFF, 0x9A, 0xCF);

    // Entry 2: Kernel Data
    // Base: 0, Limit: 4GB, Access: 0x92 (Present, Ring0, Code, Writable)
    // Granularity: 0xCF (4KB blocks, 32-bit)
    gdt_entries[2] = createGdtEntry(0, 0xFFFFFFFF, 0x92, 0xCF);

    // Entry 3: Kernel Stack
    // Base: 0, Limit: 4GB, Access: 0x92 (Present, Ring0, Code, Writable)
    // Granularity: 0xCF (4KB blocks, 32-bit)
    gdt_entries[3] = createGdtEntry(0, 0xFFFFFFFF, 0x92, 0xCF);

    // 4: User Code
    // Access: 0xFA (Present, Ring3 (0x60), Code, Exec/Read)
    gdt_entries[4] = createGdtEntry(0, 0xFFFFFFFF, 0xFA, 0xCF);

    // 5: User Data
    // Access: 0xF2 (Present, Ring3 (0x60), Data, Read/Write)
    gdt_entries[5] = createGdtEntry(0, 0xFFFFFFFF, 0xF2, 0xCF);

    // 6: User Stack
    // Access: 0xF2 (Present, Ring3 (0x60), Data, Read/Write)
    gdt_entries[6] = createGdtEntry(0, 0xFFFFFFFF, 0xF2, 0xCF);

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
        \\ mov $0x18, %ax
        \\ mov %ax, %ss
        :
        : [gdt_ptr] "r" (&gdt_ptr),
        : .{ .ax = true });
}
