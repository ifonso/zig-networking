const std = @import("std");
const networking = @import("zig_networking");

pub fn main() !void {
    std.debug.print("Hello, Zig Networking! I'm the client {}\n", .{networking.add(1, 1)});
}
