const builtin = @import("builtin");
const arch = @import("arch");
const drivers = @import("drivers");
const fmt = @import("fmt.zig");
const shell = @import("shell.zig");

pub export fn kmain() callconv(.c) void {
    arch.gdt.init();
    arch.idt.init();
    arch.pic.remap();
    arch.pic.unmask(1);

    drivers.initDrivers();

    asm volatile ("sti");

    fmt.printk(fmt.LogLevel.Info, "Welcome to P-Kern!\n", .{});

    shell.init();

    while (true) {
        asm volatile ("hlt");
    }
}
