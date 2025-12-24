const vga = @import("vga.zig");

const KeyCode = enum(u16) {
    RESERVED = 0,
    ESC = 1,
    KEY_1 = 2,
    KEY_2 = 3,
    KEY_3 = 4,
    KEY_4 = 5,
    KEY_5 = 6,
    KEY_6 = 7,
    KEY_7 = 8,
    KEY_8 = 9,
    KEY_9 = 10,
    KEY_0 = 11,
    MINUS = 12,
    EQUAL = 13,
    BACKSPACE = 14,
    TAB = 15,
    Q = 16,
    W = 17,
    E = 18,
    R = 19,
    T = 20,
    Y = 21,
    U = 22,
    I = 23,
    O = 24,
    P = 25,
    LEFTBRACE = 26,
    RIGHTBRACE = 27,
    ENTER = 28,
    LEFTCTRL = 29,
    A = 30,
    S = 31,
    D = 32,
    F = 33,
    G = 34,
    H = 35,
    J = 36,
    K = 37,
    L = 38,
    SEMICOLON = 39,
    APOSTROPHE = 40,
    GRAVE = 41,
    LEFTSHIFT = 42,
    BACKSLASH = 43,
    Z = 44,
    X = 45,
    C = 46,
    V = 47,
    B = 48,
    N = 49,
    M = 50,
    COMMA = 51,
    DOT = 52,
    SLASH = 53,
    RIGHTSHIFT = 54,
    KPASTERISK = 55,
    LEFTALT = 56,
    SPACE = 57,
    CAPSLOCK = 58,
    F1 = 59,
    F2 = 60,
    F3 = 61,
    F4 = 62,
    F5 = 63,
    F6 = 64,
    F7 = 65,
    F8 = 66,
    F9 = 67,
    F10 = 68,
    NUMLOCK = 69,
    SCROLLLOCK = 70,
    KP7 = 71,
    KP8 = 72,
    KP9 = 73,
    KPMINUS = 74,
    KP4 = 75,
    KP5 = 76,
    KP6 = 77,
    KPPLUS = 78,
    KP1 = 79,
    KP2 = 80,
    KP3 = 81,
    KP0 = 82,
    KPDOT = 83,
    F11 = 87,
    F12 = 88,
    UNKNOWN = 0xFFFF,
};

const scancode_set1 = [_]KeyCode{
    .RESERVED,   .ESC,   .KEY_1,     .KEY_2,      .KEY_3,   .KEY_4,    .KEY_5,      .KEY_6,
    .KEY_7,      .KEY_8, .KEY_9,     .KEY_0,      .MINUS,   .EQUAL,    .BACKSPACE,  .TAB,
    .Q,          .W,     .E,         .R,          .T,       .Y,        .U,          .I,
    .O,          .P,     .LEFTBRACE, .RIGHTBRACE, .ENTER,   .LEFTCTRL, .A,          .S,
    .D,          .F,     .G,         .H,          .J,       .K,        .L,          .SEMICOLON,
    .APOSTROPHE, .GRAVE, .LEFTSHIFT, .BACKSLASH,  .Z,       .X,        .C,          .V,
    .B,          .N,     .M,         .COMMA,      .DOT,     .SLASH,    .RIGHTSHIFT, .KPASTERISK,
    .LEFTALT,    .SPACE, .CAPSLOCK,  .F1,         .F2,      .F3,       .F4,         .F5,
    .F6,         .F7,    .F8,        .F9,         .F10,     .NUMLOCK,  .SCROLLLOCK, .KP7,
    .KP8,        .KP9,   .KPMINUS,   .KP4,        .KP5,     .KP6,      .KPPLUS,     .KP1,
    .KP2,        .KP3,   .KP0,       .KPDOT,      .UNKNOWN, .UNKNOWN,  .UNKNOWN,    .F11,
    .F12,
};

const KeyMapEntry = struct {
    normal: u8,
    shifted: u8,
};

fn map(n: u8, s: u8) KeyMapEntry {
    return KeyMapEntry{ .normal = n, .shifted = s };
}

fn getKeyChar(code: KeyCode) KeyMapEntry {
    return switch (code) {
        .KEY_1 => map('1', '!'),
        .KEY_2 => map('2', '@'),
        .KEY_3 => map('3', '#'),
        .KEY_4 => map('4', '$'),
        .KEY_5 => map('5', '%'),
        .KEY_6 => map('6', '^'),
        .KEY_7 => map('7', '&'),
        .KEY_8 => map('8', '*'),
        .KEY_9 => map('9', '('),
        .KEY_0 => map('0', ')'),
        .MINUS => map('-', '_'),
        .EQUAL => map('=', '+'),
        .Q => map('q', 'Q'),
        .W => map('w', 'W'),
        .E => map('e', 'E'),
        .R => map('r', 'R'),
        .T => map('t', 'T'),
        .Y => map('y', 'Y'),
        .U => map('u', 'U'),
        .I => map('i', 'I'),
        .O => map('o', 'O'),
        .P => map('p', 'P'),
        .LEFTBRACE => map('[', '{'),
        .RIGHTBRACE => map(']', '}'),
        .BACKSLASH => map('\\', '|'),
        .A => map('a', 'A'),
        .S => map('s', 'S'),
        .D => map('d', 'D'),
        .F => map('f', 'F'),
        .G => map('g', 'G'),
        .H => map('h', 'H'),
        .J => map('j', 'J'),
        .K => map('k', 'K'),
        .L => map('l', 'L'),
        .SEMICOLON => map(';', ':'),
        .APOSTROPHE => map('\'', '"'),
        .Z => map('z', 'Z'),
        .X => map('x', 'X'),
        .C => map('c', 'C'),
        .V => map('v', 'V'),
        .B => map('b', 'B'),
        .N => map('n', 'N'),
        .M => map('m', 'M'),
        .COMMA => map(',', '<'),
        .DOT => map('.', '>'),
        .SLASH => map('/', '?'),
        .GRAVE => map('`', '~'),
        .SPACE => map(' ', ' '),
        .ENTER => map('\n', '\n'),
        .TAB => map('\t', '\t'),
        .BACKSPACE => map('\x08', '\x08'),
        .KP7 => map('7', '7'),
        .KP8 => map('8', '8'),
        .KP9 => map('9', '9'),
        .KP4 => map('4', '4'),
        .KP5 => map('5', '5'),
        .KP6 => map('6', '6'),
        .KP1 => map('1', '1'),
        .KP2 => map('2', '2'),
        .KP3 => map('3', '3'),
        .KP0 => map('0', '0'),
        .KPDOT => map('.', '.'),
        .KPPLUS => map('+', '+'),
        .KPMINUS => map('-', '-'),
        .KPASTERISK => map('*', '*'),
        else => map(0, 0),
    };
}

var shift_pressed: bool = false;

fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[ret]"
        : [ret] "={al}" (-> u8),
        : [port] "{dx}" (port),
        : .{ .memory = true });
}

pub export fn keyboard_handler() callconv(.c) void {
    const raw_scan_code = inb(0x60);
    const is_break = (raw_scan_code & 0x80) != 0;
    const scan_code = raw_scan_code & 0x7F;

    if (scan_code >= scancode_set1.len)
        return;

    const keycode = scancode_set1[scan_code];
    if (keycode == .LEFTSHIFT or keycode == .RIGHTSHIFT) {
        shift_pressed = !is_break;
        return;
    }
    if (is_break)
        return;

    const mapping = getKeyChar(keycode);
    const char = if (shift_pressed) mapping.shifted else mapping.normal;

    if (char != 0) {
        vga.putChar(char);
    } else {
        switch (keycode) {
            .F1 => vga.print("[F1]"),
            .F2 => vga.print("[F2]"),
            .F3 => vga.print("[F3]"),
            .F4 => vga.print("[F4]"),
            .F5 => vga.print("[F5]"),
            .F6 => vga.print("[F6]"),
            .F7 => vga.print("[F7]"),
            .F8 => vga.print("[F8]"),
            .F9 => vga.print("[F9]"),
            .F10 => vga.print("[F10]"),
            .F11 => vga.print("[F11]"),
            .F12 => vga.print("[F12]"),
            .LEFTALT => {},
            .LEFTCTRL => {},
            .CAPSLOCK => {},
            else => {},
        }
    }
}
