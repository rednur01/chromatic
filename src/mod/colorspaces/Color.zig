const Color = @This();

pub const ColorError = error{
    InvalidInput,
};

// TODO: Put common methods into Vtable
// such as parse, stringify/format, toHex, toRgb, toOklch, etc etc
// and let all colorspaces have this as interface
