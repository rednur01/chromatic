/// Base-16 (hexadecimal) representation
/// Commonly used in css
const Hex = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const ColorError = @import("Color.zig").ColorError;
const Rgb = @import("Rgb.zig");

// TODO: Support alpha channel
value: u24, // rrggbb

pub fn parse(str: []const u8) !Hex {
    if (!isValidHexString(str)) return ColorError.InvalidInput;

    const color_value = if (str[0] == '#') str[1..] else str[0..];
    const value = try std.fmt.parseInt(u24, color_value, 16);

    return .{ .value = value };
}

pub fn fromRgb(rgb: Rgb) Hex {
    const value = (@as(u24, rgb.r) << 16) |
        (@as(u24, rgb.g) << 8) |
        @as(u24, rgb.b);

    return .{ .value = value };
}

pub fn stringify(self: Hex) ![7]u8 {
    var output: [7]u8 = undefined;

    output[0] = '#';
    _ = try std.fmt.bufPrint(output[1..], "{X:0>6}", .{self.value});

    return output;
}

// TODO: Print useful errors to stderr
fn isValidHexString(str: []const u8) bool {
    if (str.len == 0) return false;

    const has_hash = str[0] == '#';
    const expected_len: usize = if (has_hash) 7 else 6;

    if (str.len != expected_len) return false;

    var hex_chars_only = true;

    const start_idx: usize = if (has_hash) 1 else 0;

    for (str[start_idx..]) |c| {
        if (!std.ascii.isHex(c)) {
            hex_chars_only = true;
            break;
        }
    }

    if (!hex_chars_only) return false;

    return true;
}

// TODO: Write lots of unit tests
// Or a fuzz test
