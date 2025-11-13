const builtin = @import("builtin");
const drivers = @import("drivers");

pub export fn kmain() callconv(.c) void {
    drivers.initDrivers();

    drivers.vga.setColor(.LightGreen, .Black);
    drivers.vga.print("Welcome into P-Kern (Zig)!\n");

    drivers.vga.setColor(.Red, .Black);
    drivers.vga.print("42!\n");

    while (true) {}
}
