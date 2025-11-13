const VGA_WIDTH: usize = 80;
const VGA_HEIGTH: usize = 25;
const VGA_MEMORY: usize = 0xB8000;

const VgaChar = extern struct {
    char: u8,
    color: u8,
};

const vga_buffer: [*]volatile VgaChar = @ptrFromInt(VGA_MEMORY);

var g_row: usize = 0;
var g_col: usize = 0;
var g_color: u8 = 0x0F;

pub const Color = enum(u4) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    Yellow = 14,
    White = 15,
};

pub fn init() void {
    clearScreen();
}

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
        : .{ .memory = true });
}

fn updateCursor(row: usize, col: usize) void {
    const index = row * VGA_WIDTH + col;

    outb(0x3D4, 0x0F);
    outb(0x3D5, @intCast(index & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, @intCast((index >> 8) & 0xFF));
}

pub fn setColor(fg: Color, bg: Color) void {
    g_color = (@as(u8, @intFromEnum(bg)) << 4) | @intFromEnum(fg);
}

pub fn clearScreen() void {
    g_row = 0;
    g_col = 0;
    const blank = VgaChar{ .char = ' ', .color = g_color };

    var i: usize = 0;
    while (i < VGA_WIDTH * VGA_HEIGTH) : (i += 1) {
        vga_buffer[i] = blank;
    }
    updateCursor(0, 0);
}

pub fn putChar(c: u8) void {
    switch (c) {
        '\n' => {
            g_col = 0;
            g_row += 1;
        },
        else => {
            const index = g_row * VGA_WIDTH + g_col;
            vga_buffer[index] = VgaChar{
                .char = c,
                .color = g_color,
            };
            g_col += 1;
        },
    }

    if (g_col >= VGA_WIDTH) {
        g_col = 0;
        g_row += 1;
    }

    if (g_row >= VGA_HEIGTH) {
        const chars_to_move = (VGA_HEIGTH - 1) * VGA_WIDTH;
        var i: usize = 0;
        while (i < chars_to_move) : (i += 1) {
            vga_buffer[i] = vga_buffer[i + VGA_WIDTH];
        }

        const blank = VgaChar{ .char = ' ', .color = g_color };
        i = chars_to_move;
        while (i < VGA_HEIGTH * VGA_WIDTH) : (i += 1) {
            vga_buffer[i] = blank;
        }

        g_row = VGA_HEIGTH - 1;
    }

    updateCursor(g_row, g_col);
}

pub fn print(s: []const u8) void {
    for (s) |char| {
        putChar(char);
    }
}
