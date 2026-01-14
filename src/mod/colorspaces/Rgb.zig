/// RGB representation
/// 0-256 values for red, green, blue
const Rgb = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const parseInt = std.fmt.parseInt;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Hex = @import("Hex.zig");
const Hsv = @import("Hsv.zig");
const Hsl = @import("Hsl.zig");

r: u8,
g: u8,
b: u8,

pub fn parse(str: []const u8) !Rgb {
    if (!validateRgbString(str)) return ColorError.InvalidInput;

    const has_rgb_decl = std.mem.eql(u8, str[0..4], "rgb(");
    const start_idx: usize = if (has_rgb_decl) 4 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_rgb_decl and closing_paren_idx == null) return ColorError.InvalidInput;

    const end_idx: usize = if (has_rgb_decl) closing_paren_idx.? else str.len;
    const colors = str[start_idx..end_idx];

    var rgb: Rgb = undefined;

    var iter = std.mem.splitScalar(u8, colors, ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => rgb.r = try parseInt(u8, val, 10),
            1 => rgb.g = try parseInt(u8, val, 10),
            2 => rgb.b = try parseInt(u8, val, 10),
            else => unreachable,
        }
    }

    return rgb;
}

pub fn fromHex(hex: Hex) Rgb {
    var rgb: Rgb = undefined;

    rgb.r = @intCast(hex.value >> 16 & 0xFF);
    rgb.g = @intCast(hex.value >> 8 & 0xFF);
    rgb.b = @intCast(hex.value & 0xFF);

    return rgb;
}

// Formula from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
pub fn fromHsv(hsv: Hsv) Rgb {
    const h = hsv.h;
    const s = hsv.s;
    const v = hsv.v;

    const c = v * s;
    const x = c * (1 - @abs(@as(f64, @mod(h / 60, 2)) - 1));
    const m = v - c;

    var r: f64 = undefined;
    var g: f64 = undefined;
    var b: f64 = undefined;

    if (h < 60) {
        r = c;
        g = x;
        b = 0;
    } else if (h < 120) {
        r = x;
        g = c;
        b = 0;
    } else if (h < 180) {
        r = 0;
        g = c;
        b = x;
    } else if (h < 240) {
        r = 0;
        g = x;
        b = c;
    } else if (h < 300) {
        r = x;
        g = 0;
        b = c;
    } else {
        r = c;
        g = 0;
        b = x;
    }

    return .{
        .r = @intFromFloat((r + m) * 255),
        .g = @intFromFloat((g + m) * 255),
        .b = @intFromFloat((b + m) * 255),
    };
}

// Formula from https://www.rapidtables.com/convert/color/hsl-to-rgb.html
pub fn fromHsl(hsl: Hsl) Rgb {
    const h = hsl.h;
    const s = hsl.s;
    const l = hsl.l;

    const c = 1 - @abs(2 * l - 1) * s;
    const x = c * (1 - @abs(@as(f64, @mod(h / 60, 2)) - 1));
    const m = l - (c / 2);

    var r: f64 = undefined;
    var g: f64 = undefined;
    var b: f64 = undefined;

    if (h < 60) {
        r = c;
        g = x;
        b = 0;
    } else if (h < 120) {
        r = x;
        g = c;
        b = 0;
    } else if (h < 180) {
        r = 0;
        g = c;
        b = x;
    } else if (h < 240) {
        r = 0;
        g = x;
        b = c;
    } else if (h < 300) {
        r = x;
        g = 0;
        b = c;
    } else {
        r = c;
        g = 0;
        b = x;
    }

    return .{
        .r = @intFromFloat((r + m) * 255),
        .g = @intFromFloat((g + m) * 255),
        .b = @intFromFloat((b + m) * 255),
    };
}

/// Caller owns memory
pub fn stringify(self: Rgb, gpa: Allocator) ![]u8 {
    return try allocPrint(gpa, "rgb({},{},{})", .{ self.r, self.g, self.b });
}

// TODO: Print useful errors to stderr
fn validateRgbString(str: []const u8) bool {
    // Validate n,n,n or rgb(n,n,n) format
    // Validate that numbers are 0->255 range
    const has_rgb_decl = std.mem.eql(u8, str[0..4], "rgb(");
    const start_idx: usize = if (has_rgb_decl) 4 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_rgb_decl and closing_paren_idx == null) return false;

    const end_idx: usize = if (has_rgb_decl) closing_paren_idx.? else str.len;

    var iter = std.mem.splitScalar(u8, str[start_idx..end_idx], ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        if (i > 2) return false;
        const int = std.fmt.parseInt(u8, val, 10) catch return false;
        if (int < 0 or int > 255) return false;
    }

    return true;
}

// TODO: Write lots of unit tests
// Or a fuzz test
