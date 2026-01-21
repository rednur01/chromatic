const std = @import("std");
const Init = std.process.Init;
const ArgParser = @import("mod/cli/ArgParser.zig");

pub fn main(init: Init) !void {
    ArgParser.parse(init.minimal.args);
}
