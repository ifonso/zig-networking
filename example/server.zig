const std = @import("std");
const networking = @import("zig_networking");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var server = try networking.Server.init(allocator, 8080, "127.0.0.1");
    try server.listen();
}
