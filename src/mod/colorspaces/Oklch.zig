/// Oklch representation
/// A polar coordinate representation of Oklab
const Oklch = @This();

const std = @import("std");
const sqrt = std.math.sqrt;
const atan2 = std.math.atan2;
const pi = std.math.pi;
const Allocator = std.mem.Allocator;
const parseFloat = std.fmt.parseFloat;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Rgb = @import("Rgb.zig");
const Oklab = @import("Oklab.zig");

l: f64,
c: f64,
h: f64,

pub fn parse(str: []const u8) !Oklch {
    // TODO: Input validation

    var oklch: Oklch = undefined;

    const has_oklch_decl = std.mem.eql(u8, str[0..6], "oklch(");
    const start_idx: usize = if (has_oklch_decl) 6 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_oklch_decl and closing_paren_idx == null) return ColorError.InvalidInput;

    const end_idx: usize = if (has_oklch_decl) closing_paren_idx.? else str.len;
    const colors = str[start_idx..end_idx];

    var iter = std.mem.splitScalar(u8, colors, ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => oklch.l = try parseFloat(f64, val),
            1 => oklch.c = try parseFloat(f64, val),
            2 => oklch.h = try parseFloat(f64, val),
            else => unreachable,
        }
    }

    return oklch;
}

// Formula from https://observablehq.com/@coulterg/oklab-oklch-color-functions
pub fn fromRgb(rgb: Rgb) Oklch {
    var oklab: Oklab = .fromRgb(rgb);

    const c = sqrt(oklab.a * oklab.a + oklab.b * oklab.b);

    var h = atan2(oklab.b, oklab.a) * 180 / pi;
    if (h < 0) h += 360;

    return .{
        .l = oklab.l,
        .c = c,
        .h = h,
    };
}

/// Caller owns memory
pub fn stringify(self: Oklch, gpa: Allocator) ![]u8 {
    return try allocPrint(gpa, "oklch({},{},{})", .{ self.l, self.c, self.h });
}
