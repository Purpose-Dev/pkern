const builtin = @import("builtin");
const drivers = @import("drivers");

pub export fn kmain() callconv(.c) void {
    drivers.initDrivers();

    drivers.vga.print("42!");

    while (true) {}
}

