const std = @import("std");
const Hex = @import("mod/colorspaces/Hex.zig");
const Rgb = @import("mod/colorspaces/Rgb.zig");
const Hsv = @import("mod/colorspaces/Hsv.zig");
const Hsl = @import("mod/colorspaces/Hsl.zig");
const Oklab = @import("mod/colorspaces/Oklab.zig");
const Oklch = @import("mod/colorspaces/Oklch.zig");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // Testing basic functionality works
    const blue_hex: Hex = try .parse("#0000FF");
    const blue_hex_str = try blue_hex.stringify();
    std.debug.print("Blue hex: {s}\n", .{blue_hex_str});

    const blue_rgb: Rgb = .fromHex(blue_hex);
    const blue_rgb_str = try blue_rgb.stringify(gpa);
    defer gpa.free(blue_rgb_str);
    std.debug.print("Blue rgb: {s}\n", .{blue_rgb_str});

    const green_rgb: Rgb = try .parse("rgb(0,255,0)");
    const green_rgb_str = try green_rgb.stringify(gpa);
    defer gpa.free(green_rgb_str);
    std.debug.print("Green hex: {s}\n", .{green_rgb_str});

    const green_hex: Hex = .fromRgb(green_rgb);
    const green_hex_str = try green_hex.stringify();
    std.debug.print("Green rgb: {s}\n", .{green_hex_str});

    const green_hsv: Hsv = try .parse("hsv(240,0.5,0.5)");
    const green_hsv_str = try green_hsv.stringify(gpa);
    defer gpa.free(green_hsv_str);
    std.debug.print("Green hsv: {s}\n", .{green_hsv_str});

    const red_hsv: Hsv = .fromRgb(try .parse("rgb(255,0,0)"));
    const red_hsv_str = try red_hsv.stringify(gpa);
    defer gpa.free(red_hsv_str);
    std.debug.print("Red hsv: {s}\n", .{red_hsv_str});

    const red_hsl: Hsl = .fromRgb(try .parse("rgb(255,0,0)"));
    const red_hsl_str = try red_hsl.stringify(gpa);
    defer gpa.free(red_hsl_str);
    std.debug.print("Red hsl: {s}\n", .{red_hsl_str});

    const red_rgb: Rgb = .fromHsl(red_hsl);
    const red_rgb_str = try red_rgb.stringify(gpa);
    defer gpa.free(red_rgb_str);
    std.debug.print("Red rgb: {s}\n", .{red_rgb_str});

    const cyan_oklab: Oklab = .fromRgb(try .parse("rgb(0,255,255)"));
    const cyan_oklab_str = try cyan_oklab.stringify(gpa);
    defer gpa.free(cyan_oklab_str);
    std.debug.print("Cyan oklab: {s}\n", .{cyan_oklab_str});

    const cyan_rgb: Rgb = .fromOklab(cyan_oklab);
    const cyan_rgb_str = try cyan_rgb.stringify(gpa);
    defer gpa.free(cyan_rgb_str);
    std.debug.print("Cyan rgb: {s}\n", .{cyan_rgb_str});

    const purple_oklch: Oklch = .fromRgb(try .parse("rgb(255,0,255)"));
    const purple_oklch_str = try purple_oklch.stringify(gpa);
    defer gpa.free(purple_oklch_str);
    std.debug.print("Purple oklch: {s}\n", .{purple_oklch_str});

    const purple_rgb: Rgb = .fromOklch(purple_oklch);
    const purple_rgb_str = try purple_rgb.stringify(gpa);
    defer gpa.free(purple_rgb_str);
    std.debug.print("Purple rgb: {s}\n", .{purple_rgb_str});
}
