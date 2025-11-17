const vga = @import("drivers").vga;

pub const LogLevel = enum {
    Debug,
    Info,
    Warn,
    Error,
};

fn print_u64(n: u64, base: u8) void {
    const digits = "0123456789abcdef";
    var buffer: [64]u8 = undefined;
    var i: usize = 0;
    var m = n;

    if (m == 0) {
        vga.putChar('0');
        return;
    }

    while (m > 0) {
        buffer[i] = digits[@intCast(m % base)];
        m /= base;
        i += 1;
    }

    while (i > 0) {
        i -= 1;
        vga.putChar(buffer[i]);
    }
}

fn print_i64(n: i64, base: u8) void {
    const I64_MIN = @as(i64, -0x8000_0000_0000_0000);
    const I64_MAX = @as(i64, 0x7fff_ffff_ffff_ffff);

    if (n < 0) {
        vga.putChar('-');
        const m = if (n == I64_MIN)
            @as(u64, @intCast(I64_MAX)) + 1
        else
            @as(u64, @intCast(-n));
        print_u64(m, base);
    } else {
        print_u64(@intCast(n), base);
    }
}

pub fn printk(level: LogLevel, comptime fmt: []const u8, args: anytype) void {
    const default_fg = vga.Color.LightGray;
    const default_bg = vga.Color.Black;

    switch (level) {
        .Debug => vga.setColor(vga.Color.DarkGray, default_bg),
        .Info => vga.setColor(vga.Color.White, default_bg),
        .Warn => vga.setColor(vga.Color.Yellow, default_bg),
        .Error => vga.setColor(vga.Color.LightRed, default_bg),
    }

    vga.print(switch (level) {
        .Debug => "[DBG] ",
        .Info => "[NFO] ",
        .Warn => "[WRN] ",
        .Error => "[ERR] ",
    });

    comptime var arg_index: usize = 0;
    comptime var i: usize = 0;

    inline while (i < fmt.len) {
        if (fmt[i] == '%') {
            i += 1;
            if (i >= fmt.len)
                break;

            switch (fmt[i]) {
                '%' => vga.putChar('%'),
                's' => {
                    const arg = args[arg_index];
                    comptime {
                        switch (@typeInfo(@TypeOf(arg))) {
                            .pointer => |ptr| {
                                if (ptr.size == .slice) {
                                    if (ptr.child != u8) {
                                        @compileError("%s slice must be of u8");
                                    }
                                } else if (ptr.size == .one) {
                                    switch (@typeInfo(ptr.child)) {
                                        .array => |arr| {
                                            if (arr.child != u8) {
                                                @compileError("%s pointer to array must be of u8");
                                            }

                                            const sp_uncasted = arr.sentinel_ptr orelse {
                                                @compileError("%s array pointer has no sentinel");
                                            };

                                            const sp: *const arr.child = @ptrCast(@alignCast(sp_uncasted));
                                            if (sp.* != 0) {
                                                @compileError("%s pointer to array must be 0-terminated");
                                            }
                                        },
                                        else => @compileError("%s pointer must be to a slice or a 0-terminated array"),
                                    }
                                } else {
                                    @compileError("%s expects a slice or a pointer to a 0-terminated array");
                                }
                            },
                            else => @compileError("%s expects a slice or a 0-terminated array pointer"),
                        }
                    }
                    vga.print(arg);
                    arg_index += 1;
                },
                'd', 'i' => {
                    const arg = args[arg_index];
                    comptime {
                        switch (@typeInfo(@TypeOf(arg))) {
                            .int => {},
                            else => @compileError("%d/%i expects an integer"),
                        }
                    }
                    print_i64(@intCast(arg), 10);
                    arg_index += 1;
                },
                'u' => {
                    const arg = args[arg_index];
                    comptime {
                        switch (@typeInfo(@TypeOf(arg))) {
                            .int => {},
                            else => @compileError("%u expects an integer"),
                        }
                    }
                    print_u64(@intCast(arg), 10);
                    arg_index += 1;
                },
                'x', 'p' => {
                    const arg = args[arg_index];
                    comptime {
                        if (@TypeOf(arg) == usize) {} else switch (@typeInfo(@TypeOf(arg))) {
                            .int, .pointer => {},
                            else => @compileError("%x/%p expects an integer, usize, or pointer"),
                        }
                    }

                    vga.print("0x");
                    const val: u64 = if (@TypeOf(arg) == usize)
                        @as(u64, @intCast(arg))
                    else switch (@typeInfo(@TypeOf(arg))) {
                        .int => @as(u64, @intCast(arg)),
                        .pointer => @intFromPtr(arg),
                        else => unreachable,
                    };
                    print_u64(val, 16);
                    arg_index += 1;
                },
                'c' => {
                    const arg = args[arg_index];
                    comptime {
                        switch (@typeInfo(@TypeOf(arg))) {
                            .int => {},
                            else => @compileError("%c expects an integer-like type"),
                        }
                    }
                    vga.putChar(@intCast(arg));
                    arg_index += 1;
                },
                else => {
                    vga.putChar('%');
                    vga.putChar(fmt[i]);
                },
            }
        } else {
            vga.putChar(fmt[i]);
        }
        i += 1;
    }

    comptime if (arg_index != args.len) {
        @compileError("Number of arguments does not match format string");
    };

    vga.setColor(default_fg, default_bg);
}
