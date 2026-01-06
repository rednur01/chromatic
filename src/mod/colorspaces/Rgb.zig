/// RGB representation
/// 0-256 values for red, green, blue
const Rgb = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const parseInt = std.fmt.parseInt;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Hex = @import("Hex.zig");

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
