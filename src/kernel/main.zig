const builtin = @import("builtin");
const drivers = @import("drivers");
const fmt = @import("fmt.zig");

pub export fn kmain() callconv(.c) void {
    drivers.initDrivers();

    fmt.printk(fmt.LogLevel.Info, "Welcome into P-Kern (Zig)!\n", .{});

    //const an_int: i32 = -42;
    //const an_uint: u32 = 1234;
    //const a_ptr: usize = 0xDEADBEEF;

    fmt.printk(fmt.LogLevel.Debug, "This is a debug message.\n", .{});
    fmt.printk(fmt.LogLevel.Info, "Let's display a string: '%s'\n", .{"P-Kern"});
    //fmt.printk(fmt.LogLevel.Info, "A signed integer: %d\n", .{an_int});
    //fmt.printk(fmt.LogLevel.Info, "An unsigned integer: %u\n", .{an_uint});
    fmt.printk(fmt.LogLevel.Warn, "This is a warning !\n", .{});
    //fmt.printk(fmt.LogLevel.Error, "Address (pointer): %p\n", .{a_ptr});
    fmt.printk(fmt.LogLevel.Info, "Character: %c\n", .{@as(u8, 'Z')});

    drivers.vga.setColor(.Red, .Black);
    drivers.vga.print("42!\n");

    while (true) {}
}
