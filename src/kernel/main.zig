const builtin = @import("builtin");
const arch = @import("arch");
const drivers = @import("drivers");
const fmt = @import("fmt.zig");
const debug = @import("debug.zig");

pub export fn kmain() callconv(.c) void {
    arch.gdt.init();
    arch.idt.init();
    arch.pic.remap();

    arch.pic.unmask(1);

    drivers.initDrivers();

    asm volatile ("sti");

    fmt.printk(fmt.LogLevel.Info, "P-Kern GDT @ 0x800 loaded.\n", .{});

    const an_int: i32 = -42;
    const an_uint: u32 = 1234;
    const a_ptr: usize = 0xDEADBEEF;
    const test_val: u32 = 0xCAFEBABE;
    const test_val2: u32 = 0xDEADBEEF;

    _ = an_int;
    _ = an_uint;
    _ = a_ptr;
    _ = test_val;
    _ = test_val2;

    fmt.printk(fmt.LogLevel.Info, "Testing Stack Dump...\n", .{});
    debug.dumpStack(10);

    while (true) {
        asm volatile ("hlt");
    }
}
