const fmt = @import("fmt.zig");

pub fn dumpStack(max_lines: usize) void {
    var esp: usize = undefined;
    var ebp: usize = undefined;

    asm volatile ("mov %%esp, %[ret]"
        : [ret] "=r" (esp),
    );
    asm volatile ("mov %%ebp, %[ret]"
        : [ret] "=r" (ebp),
    );

    fmt.printk(fmt.LogLevel.Info, "=== Kernel Stack Dump ===\n", .{});
    fmt.printk(fmt.LogLevel.Info, "ESP: %x | EBP: %x\n", .{ esp, ebp });

    var ptr = esp;
    var i: usize = 0;
    while (i < max_lines) : (i += 1) {
        const val = @as(*usize, @ptrFromInt(ptr)).*;
        fmt.printk(fmt.LogLevel.Debug, "%x: %x\n", .{ ptr, val });
        ptr += 4;
        if (ptr > ebp + 64)
            break;
    }
    fmt.printk(fmt.LogLevel.Info, "=========================\n", .{});
}
