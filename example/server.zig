const std = @import("std");
const networking = @import("zig_networking");

pub fn main() !void {
    std.debug.print("Hello, Zig Networking! I'm the server {}\n", .{networking.add(2, 2)});
}
