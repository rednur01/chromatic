const ArgParser = @This();
const std = @import("std");
const Args = std.process.Args;
const stringToEnum = std.meta.stringToEnum;
const build_options = @import("build_options");
const Tw = @import("../colorsystems/Tw.zig");

pub fn parse(args: Args) void {
    var iter = args.iterate();
    _ = iter.next(); // Discard program name

    var arg = iter.next();
    if (arg == null) {
        printInvalidMsg();
        return;
    }

    const parsed: ?Command = stringToEnum(Command, arg.?);
    if (parsed == null) {
        printInvalidMsg();
        return;
    }

    switch (parsed.?) {
        .tw => {
            arg = iter.next();
            if (arg == null) {
                printInvalidMsg();
                return;
            }
            Tw.printScale(arg.?);
        },
        .help => printHelpMsg(),
        .version => printVersion(),
        _ => printInvalidMsg(),
    }
}

const Command = enum(u4) {
    tw,
    help,
    version,
    _,
};

fn printInvalidMsg() void {
    std.debug.print("{s}\n", .{invalid_msg});
}

fn printHelpMsg() void {
    std.debug.print("{s}\n", .{help_msg});
}

fn printVersion() void {
    std.debug.print("{s}\n", .{build_options.version});
}

const help_msg =
    \\Usage: chromatic [command] [options]
    \\
    \\Commands:
    \\  tw <color name>       Print the colorscale of a named tailwind color
    \\  help                  Print this help message
    \\  version               Print version number
;

const invalid_msg =
    \\Unknown command format.
    \\Usage: chromatic [command] [options]
    \\Use chromatic help for more details.
;
