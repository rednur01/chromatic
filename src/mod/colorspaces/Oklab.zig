/// Oklab representation
/// https://bottosson.github.io/posts/oklab/
const Oklab = @This();

const std = @import("std");
const cbrt = std.math.cbrt;
const Allocator = std.mem.Allocator;
const parseFloat = std.fmt.parseFloat;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Rgb = @import("Rgb.zig");

l: f64,
a: f64,
b: f64,

pub fn parse(str: []const u8) !Oklab {
    // TODO: Input validation

    var oklab: Oklab = undefined;

    const has_oklab_decl = std.mem.eql(u8, str[0..6], "oklab(");
    const start_idx: usize = if (has_oklab_decl) 6 else 0;
    const closing_paren_idx = std.mem.findScalar(u8, str, ')');

    if (has_oklab_decl and closing_paren_idx == null) return ColorError.InvalidInput;

    const end_idx: usize = if (has_oklab_decl) closing_paren_idx.? else str.len;
    const colors = str[start_idx..end_idx];

    var iter = std.mem.splitScalar(u8, colors, ',');
    var i: usize = 0;

    while (iter.next()) |val| : (i += 1) {
        switch (i) {
            0 => oklab.l = try parseFloat(f64, val),
            1 => oklab.a = try parseFloat(f64, val),
            2 => oklab.b = try parseFloat(f64, val),
            else => unreachable,
        }
    }

    return oklab;
}

pub fn fromRgb(rgb: Rgb) Oklab {
    var oklab: Oklab = undefined;

    const r: f64 = @floatFromInt(rgb.r);
    const g: f64 = @floatFromInt(rgb.g);
    const b: f64 = @floatFromInt(rgb.b);

    const l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    const m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    const s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    const l1 = cbrt(l);
    const m1 = cbrt(m);
    const s1 = cbrt(s);

    oklab.l = 0.2104542553 * l1 + 0.7936177850 * m1 - 0.0040720468 * s1;
    oklab.a = 1.9779984951 * l1 - 2.4285922050 * m1 + 0.4505937099 * s1;
    oklab.b = 0.0259040371 * l1 + 0.7827717662 * m1 - 0.8086757660 * s1;

    return oklab;
}

/// Caller owns memory
pub fn stringify(self: Oklab, gpa: Allocator) ![]u8 {
    return try allocPrint(gpa, "oklab({},{},{})", .{ self.l, self.a, self.b });
}
