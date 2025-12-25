const drivers = @import("drivers");
const debug = @import("debug.zig");
const fmt = @import("fmt.zig");
const keyboard = drivers.keyboard;
const vga = drivers.vga;

const MAX_CMD_LEN = 256;

pub fn init() void {
	fmt.printk(fmt.LogLevel.Info, "Starting P-Kern Shell....\n", .{});
	run();
}

fn run() void {
	var cmd_buffer: [MAX_CMD_LEN]u8 = undefined;
	var cmd_len: usize = 0;

	printPrompt();

	while (true) {
        if (keyboard.getKey()) |char| {
			switch (char) {
				'\n' => {
					vga.putChar('\n');
					if (cmd_len > 0) {
						executeCommand(cmd_buffer[0..cmd_len]);
					}
					cmd_len = 0;
					printPrompt();
				},
				'\x08' => {
                    if (cmd_len > 0) {
						cmd_len -= 1;
                        vga.putChar('\x08');
                    }
				},
				else => {
					if (cmd_len < MAX_CMD_LEN) {
						cmd_buffer[cmd_len] = char;
						cmd_len += 1;
						vga.putChar(char);
                    }
				},
			}
		}

        asm volatile ("hlt");
	}
}

fn printPrompt() void {
	vga.setColor(vga.Color.LightGreen, vga.Color.Black);
	vga.print("pkern> ");
	vga.setColor(vga.Color.LightGray, vga.Color.Black);
}

fn streq(a: []const u8, b: []const u8) bool {
	if (a.len != b.len)
		return false;
	for (a, 0..) |char, i| {
		if (char != b[i])
			return false;
	}
	return true;
}

fn executeCommand(cmd: []const u8) void {
	if (streq(cmd, "help")) {
		vga.print("Available commands:\n");
		vga.print("  help    - Show this message\n");
		vga.print("  clear   - Clear the screen\n");
		vga.print("  stack   - Dump kernel stack\n");
		vga.print("  reboot  - Reboot the system\n");
		vga.print("  halt    - Halt the CPU\n");
	} else if (streq(cmd, "clear")) {
		vga.clearScreen();
	} else if (streq(cmd, "stack")) {
		debug.dumpStack(10);
	} else if (streq(cmd, "reboot")) {
		vga.print("Rebooting...\n");
		rebootSystem();
	} else if (streq(cmd, "halt")) {
		vga.print("System Halted.\n");
		while (true) asm volatile ("hlt");
	} else {
		fmt.printk(fmt.LogLevel.Warn, "Unknown command: %s\n", .{cmd});
	}
}

fn outb(port: u16, value: u8) void {
	asm volatile ("outb %[value], %[port]"
		:
		: [value] "{al}" (value),
		  [port] "{dx}" (port),
		: .{ .memory = true });
}

fn rebootSystem() void {
    var temp: u8 = 0x02;
	while ((temp & 0x02) != 0) {
		temp = asm volatile ("inb $0x64, %[ret]" : [ret] "={al}" (-> u8));
	}
	outb(0x64, 0xFE);

    asm volatile ("lidt 0");
    asm volatile ("int3");
}
