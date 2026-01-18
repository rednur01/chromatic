const std = @import("std");
const eql = std.mem.eql;
const Init = std.process.Init;
const Tw = @import("mod/colorsystems/Tw.zig");
const help_msg = @import("mod/cli/help.zig").help_msg;
const invalid_msg = @import("mod/cli/invalid.zig").invalid_msg;

pub fn main(init: Init) !void {
    // TODO: Make a real arg parser or wait for zig stdlib
    // to finish theirs
    // This adhoc way is BS but enough to get me through testing

    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    // TODO: Add "version"
    if (args.len < 2) {
        std.debug.print("{s}\n", .{invalid_msg});
    } else if (eql(u8, args[1], "help")) {
        std.debug.print("{s}\n", .{help_msg});
    } else if (eql(u8, args[1], "tw")) {
        if (args.len < 3) {
            std.debug.print("{s}\n", .{invalid_msg});
        } else {
            Tw.printScale(args[2]);
        }
    } else {
        std.debug.print("{s}\n", .{invalid_msg});
    }

    return;
}
