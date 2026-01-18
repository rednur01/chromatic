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

l: f64, // [0-1]
c: f64, // [0-1]
h: f64, // [0-360]

/// Input must be of the format "oklch(f64%,f64,f64)" or "oklch(f64% f64 f64)"
/// Whitespaces are allowed after commas
pub fn parse(str: []const u8) !Oklch {
    // TODO: Input validation

    var oklch: Oklch = undefined;

    const has_oklch_decl = std.mem.eql(u8, str[0..6], "oklch(");
    if (!has_oklch_decl) return ColorError.InvalidInput;

    const closing_paren_idx = std.mem.findScalar(u8, str, ')');
    if (closing_paren_idx == null) return ColorError.InvalidInput;

    const start_idx: usize = 6;
    const end_idx: usize = closing_paren_idx.?;
    const values = str[start_idx..end_idx];

    const comma_count = std.mem.countScalar(u8, str, ',');
    const sep: u8 = if (comma_count == 2) ',' else ' ';

    var iter = std.mem.splitScalar(u8, values, sep);
    var i: usize = 0;

    const trim_chars = [_]u8{' '};

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => oklch.l = try parseFloat(f64, val[0 .. val.len - 1]) / 100,
            1 => oklch.c = try parseFloat(f64, std.mem.trim(u8, val, &trim_chars)),
            2 => oklch.h = try parseFloat(f64, std.mem.trim(u8, val, &trim_chars)),
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
    return allocPrint(gpa, "oklch({:.3},{:.3},{:.3})", .{ self.l, self.c, self.h });
}
