pub const keyboard = @import("keyboard.zig");
pub const vga = @import("vga.zig");

pub fn initDrivers() void {
    vga.init();
    _ = keyboard;
}
