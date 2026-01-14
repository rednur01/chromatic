/// HSL representation
/// Hue [0,360] Saturation [0,1] Lightness [0,1]
const Hsl = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const parseFloat = std.fmt.parseFloat;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Rgb = @import("Rgb.zig");

h: f64, // [0,360]
s: f64, // [0,1]
l: f64, // [0,1]

pub fn parse(str: []const u8) !Hsl {
    // TODO: Input validation

    var hsl: Hsl = undefined;

    const has_hsl_decl = std.mem.eql(u8, str[0..4], "hsl(");
    const start_idx: usize = if (has_hsl_decl) 4 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_hsl_decl and closing_paren_idx == null) return ColorError.InvalidInput;

    const end_idx: usize = if (has_hsl_decl) closing_paren_idx.? else str.len;
    const colors = str[start_idx..end_idx];

    var iter = std.mem.splitScalar(u8, colors, ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => hsl.h = try parseFloat(f64, val),
            1 => hsl.s = try parseFloat(f64, val),
            2 => hsl.l = try parseFloat(f64, val),
            else => unreachable,
        }
    }

    return hsl;
}

pub fn fromRgb(rgb: Rgb) Hsl {
    var hsl: Hsl = undefined;

    const r = @as(f64, @floatFromInt(rgb.r)) / 255.0;
    const g = @as(f64, @floatFromInt(rgb.g)) / 255.0;
    const b = @as(f64, @floatFromInt(rgb.b)) / 255.0;

    const c_max = std.mem.max(f64, &[_]f64{ r, g, b });
    const c_min = std.mem.min(f64, &[_]f64{ r, g, b });
    const delta = c_max - c_min;

    hsl.l = (c_max + c_min) / 2;
    hsl.s = if (delta == 0) 0 else delta / (1 - @abs(2 * hsl.l - 1));

    if (delta == 0) {
        hsl.h = 0;
    } else if (c_max == r) {
        hsl.h = 60.0 * @mod(((g - b) / delta), 6);
    } else if (c_max == g) {
        hsl.h = 60.0 * (((b - r) / delta) + 2);
    } else {
        hsl.h = 60.0 * (((r - g) / delta) + 4);
    }

    return hsl;
}

/// Caller owns memory
pub fn stringify(self: Hsl, gpa: Allocator) ![]u8 {
    return try allocPrint(gpa, "hsl({},{},{})", .{ self.h, self.s, self.l });
}
