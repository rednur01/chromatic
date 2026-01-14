/// HSV representation
/// Hue [0,360] Saturation [0,1] Value [0,1]
const Hsv = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const parseFloat = std.fmt.parseFloat;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Rgb = @import("Rgb.zig");

h: f64, // [0,360]
s: f64, // [0,1]
v: f64, // [0,1]

pub fn parse(str: []const u8) !Hsv {
    // TODO: Input validation

    var hsv: Hsv = undefined;

    const has_hsv_decl = std.mem.eql(u8, str[0..4], "hsv(");
    const start_idx: usize = if (has_hsv_decl) 4 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_hsv_decl and closing_paren_idx == null) return ColorError.InvalidInput;

    const end_idx: usize = if (has_hsv_decl) closing_paren_idx.? else str.len;
    const colors = str[start_idx..end_idx];

    var iter = std.mem.splitScalar(u8, colors, ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => hsv.h = try parseFloat(f64, val),
            1 => hsv.s = try parseFloat(f64, val),
            2 => hsv.v = try parseFloat(f64, val),
            else => unreachable,
        }
    }

    return hsv;
}

pub fn fromRgb(rgb: Rgb) Hsv {
    var hsv: Hsv = undefined;

    const r = @as(f64, @floatFromInt(rgb.r)) / 255.0;
    const g = @as(f64, @floatFromInt(rgb.g)) / 255.0;
    const b = @as(f64, @floatFromInt(rgb.b)) / 255.0;

    const c_max = std.mem.max(f64, &[_]f64{ r, g, b });
    const c_min = std.mem.min(f64, &[_]f64{ r, g, b });
    const delta = c_max - c_min;

    hsv.v = c_max;
    hsv.s = if (c_max == 0) 0 else delta / c_max;

    if (delta == 0) {
        hsv.h = 0;
    } else if (c_max == r) {
        hsv.h = 60.0 * @mod(((g - b) / delta), 6);
    } else if (c_max == g) {
        hsv.h = 60.0 * (((b - r) / delta) + 2);
    } else {
        hsv.h = 60.0 * (((r - g) / delta) + 4);
    }

    return hsv;
}

/// Caller owns memory
pub fn stringify(self: Hsv, gpa: Allocator) ![]u8 {
    return try allocPrint(gpa, "hsv({},{},{})", .{ self.h, self.s, self.v });
}
