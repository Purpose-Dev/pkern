const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
const VGA_MEMORY: usize = 0xB8000;
const NUM_CONSOLES: usize = 3; // F1, F2, F3

const VgaChar = extern struct {
    char: u8,
    color: u8,
};

const VirtualConsole = struct {
    buffer: [VGA_WIDTH * VGA_HEIGHT]VgaChar,
    row: usize,
    col: usize,
    color: u8,
};

const video_memory: [*]volatile VgaChar = @ptrFromInt(VGA_MEMORY);

var consoles: [NUM_CONSOLES]VirtualConsole = undefined;
var active_console_idx: usize = 0;

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

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
        : .{ .memory = true });
}

fn updateHwCursor(row: usize, col: usize) void {
    const index = row * VGA_WIDTH + col;

    outb(0x3D4, 0x0F);
    outb(0x3D5, @intCast(index & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, @intCast((index >> 8) & 0xFF));
}

pub fn init() void {
    for (&consoles) |*c| {
        c.row = 0;
        c.col = 0;
        c.color = 0x0F;

        const blank = VgaChar{ .char = ' ', .color = 0x0F };
        for (0..VGA_WIDTH * VGA_HEIGHT) |i| {
            c.buffer[i] = blank;
        }
    }

    switchConsole(0);
}

pub fn switchConsole(index: usize) void {
    if (index >= NUM_CONSOLES)
        return;

    active_console_idx = index;
    const console = &consoles[active_console_idx];

    var i: usize = 0;
    while (i < VGA_WIDTH * VGA_HEIGHT) : (i += 1) {
        video_memory[i] = console.buffer[i];
    }

    updateHwCursor(console.row, console.col);
}

pub fn setColor(fg: Color, bg: Color) void {
    consoles[active_console_idx].color = (@as(u8, @intFromEnum(bg)) << 4) | @intFromEnum(fg);
}

pub fn clearScreen() void {
    const console = &consoles[active_console_idx];
    console.row = 0;
    console.col = 0;

    const blank = VgaChar{ .char = ' ', .color = console.color };
    for (0..VGA_WIDTH * VGA_HEIGHT) |i| {
        console.buffer[i] = blank;
        video_memory[i] = blank;
    }
    updateHwCursor(0, 0);
}

pub fn putChar(c: u8) void {
    const console = &consoles[active_console_idx];

    switch (c) {
        '\n' => {
            console.col = 0;
            console.row += 1;
        },
        '\x08' => {
            if (console.col > 0) {
                console.col -= 1;
                const index = console.row * VGA_WIDTH + console.col;
                const blank = VgaChar{ .char = ' ', .color = console.color };
                console.buffer[index] = blank;
                video_memory[index] = blank;
            }
        },
        else => {
            const index = console.row * VGA_WIDTH + console.col;
            if (index < VGA_WIDTH * VGA_HEIGHT) {
                const char_obj = VgaChar{ .char = c, .color = console.color };
                console.buffer[index] = char_obj;
                video_memory[index] = char_obj;
            }
            console.col += 1;
        },
    }

    if (console.col >= VGA_WIDTH) {
        console.col = 0;
        console.row += 1;
    }

    if (console.row >= VGA_HEIGHT) {
        const chars_to_move = (VGA_HEIGHT - 1) * VGA_WIDTH;
        var i: usize = 0;
        while (i < chars_to_move) : (i += 1) {
            console.buffer[i] = console.buffer[i + VGA_WIDTH];
        }

        const blank = VgaChar{ .char = ' ', .color = console.color };
        i = chars_to_move;
        while (i < VGA_HEIGHT * VGA_WIDTH) : (i += 1) {
            console.buffer[i] = blank;
        }

        console.row = VGA_HEIGHT - 1;
        switchConsole(active_console_idx);
    }

    updateHwCursor(console.row, console.col);
}

pub fn print(s: []const u8) void {
    for (s) |char| {
        putChar(char);
    }
}
