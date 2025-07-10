const std = @import("std");
const net = std.net;
const posix = std.posix;

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub const Server = struct {
    address: net.Address,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, port: u16, host_ip: ?[]const u8) !Self {
        const ip = host_ip orelse "0.0.0.0";

        return .{
            .address = try net.Address.resolveIp(ip, port),
            .allocator = allocator,
        };
    }

    pub fn listen(self: *Self) !void {
        // posix.socket retorna um file descriptor no caso de sistemas linux (fd_t === socket_t)
        const listener_sock = posix.socket(
            self.address.any.family, // pega automaticamente se é INET, INET6
            posix.SOCK.STREAM,
            posix.IPPROTO.TCP,
        ) catch |err| {
            std.log.err("Failed to create socket: {}", .{err});
            return err;
        };

        defer posix.close(listener_sock);

        posix.setsockopt(
            listener_sock,
            posix.SOL.SOCKET,
            posix.SO.REUSEADDR,
            &std.mem.toBytes(@as(c_int, 1)),
        ) catch |err| {
            std.log.err("Failed to set socket option SO_REUSEADDR: {}", .{err});
            return err;
        };

        posix.bind(
            listener_sock,
            &self.address.any,
            self.address.getOsSockLen(),
        ) catch |err| {
            std.log.err("Failed to bind socket to address: {}", .{err});
            return err;
        };

        posix.listen(listener_sock, 128) catch |err| {
            std.log.err("Failed to listen on socket: {}", .{err});
            return err;
        };

        std.log.info("Server listening on {}", .{self.address});

        while (true) {
            var client_addr: net.Address = undefined;
            var client_addr_len: posix.socklen_t = @sizeOf(net.Address);

            const c_socket = posix.accept(
                listener_sock,
                &client_addr.any,
                &client_addr_len,
                0,
            ) catch |err| {
                std.log.info("Error accept: {}\n", .{err});
                continue;
            };

            defer posix.close(c_socket);

            std.log.info("{} Connected.", .{client_addr});

            self.writeToSocket(c_socket, "Hello!") catch |err| {
                std.log.err("Failed to write to client: {}", .{err});
                continue;
            };
        }
    }

    pub fn writeToSocket(_: *Self, socket: posix.socket_t, message: []const u8) !void {
        var bytes_sent: usize = 0;

        while (bytes_sent < message.len) {
            const bytes_written = posix.write(
                socket,
                message[bytes_sent..],
            ) catch |err| {
                std.log.err("Failed to write to socket: {}", .{err});
                return err;
            };

            bytes_sent += bytes_written;
        }
    }
};
