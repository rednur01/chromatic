/// RGB representation
/// 0-256 values for red, green, blue
const Rgb = @This();

const std = @import("std");
const pi = std.math.pi;
const cos = std.math.cos;
const sin = std.math.sin;
const pow = std.math.pow;
const clamp = std.math.clamp;
const Allocator = std.mem.Allocator;
const parseInt = std.fmt.parseInt;
const allocPrint = std.fmt.allocPrint;
const ColorError = @import("Color.zig").ColorError;
const Hex = @import("Hex.zig");
const Hsv = @import("Hsv.zig");
const Hsl = @import("Hsl.zig");
const Oklab = @import("Oklab.zig");
const Oklch = @import("Oklch.zig");

r: u8, // [0,255]
g: u8, // [0,255]
b: u8, // [0,255]

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

// Formula from https://bottosson.github.io/posts/oklab/
pub fn fromOklab(oklab: Oklab) Rgb {
    const l1 = oklab.l + 0.3963377774 * oklab.a + 0.2158037573 * oklab.b;
    const m1 = oklab.l - 0.1055613458 * oklab.a - 0.0638541728 * oklab.b;
    const s1 = oklab.l - 0.0894841775 * oklab.a - 1.2914855480 * oklab.b;

    const l = l1 * l1 * l1;
    const m = m1 * m1 * m1;
    const s = s1 * s1 * s1;

    var r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    var g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    var b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    r = linearToSrgb(clamp(r, 0.0, 1.0));
    g = linearToSrgb(clamp(g, 0.0, 1.0));
    b = linearToSrgb(clamp(b, 0.0, 1.0));

    return .{
        .r = @intFromFloat(@round(r * 255)),
        .g = @intFromFloat(@round(g * 255)),
        .b = @intFromFloat(@round(b * 255)),
    };
}

// Formula from https://observablehq.com/@coulterg/oklab-oklch-color-functions
pub fn fromOklch(oklch: Oklch) Rgb {
    var oklab: Oklab = undefined;

    const h_radians = oklch.h * pi / 180;

    oklab.l = oklch.l;
    oklab.a = oklch.c * cos(h_radians);
    oklab.b = oklch.c * sin(h_radians);

    return .fromOklab(oklab);
}

/// Caller owns memory
pub fn stringify(self: Rgb, gpa: Allocator) ![]u8 {
    return allocPrint(gpa, "rgb({},{},{})", .{ self.r, self.g, self.b });
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

pub fn srgbToLinear(c: f64) f64 {
    return if (c <= 0.04045) c / 12.92 else pow(f64, (c + 0.055) / 1.055, 2.4);
}

pub fn linearToSrgb(c: f64) f64 {
    return if (c <= 0.0031308) 12.92 * c else 1.055 * pow(f64, c, 1.0 / 2.4) - 0.055;
}

// TODO: Write lots of unit tests
// Or a fuzz test
