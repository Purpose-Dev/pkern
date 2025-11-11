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

pub fn init() void {
	clearScreen();
}

pub fn clearScreen() void {
	g_row = 0;
	g_col = 0;
	const blank = VgaChar{ .char = ' ', .color = g_color };

	var i: usize = 0;
	while (i < VGA_WIDTH * VGA_HEIGTH) : (i += 1) {
		vga_buffer[i] = blank;
	}
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
		}
	}
}

pub fn print(s: []const u8) void {
	for (s) |char| {
		putChar(char);
	}
}
