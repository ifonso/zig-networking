const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const networking_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    {
        const exe = b.addExecutable(.{
            .name = "client_example",
            .root_source_file = b.path("example/client.zig"),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("zig_networking", networking_mod);
        setupExample(b, exe, "client");
    }

    {
        const exe = b.addExecutable(.{
            .name = "server_example",
            .root_source_file = b.path("example/server.zig"),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("zig_networking", networking_mod);
        setupExample(b, exe, "server");
    }
}

fn setupExample(b: *std.Build, exe: *std.Build.Step.Compile, comptime name: []const u8) void {
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("example_" ++ name, "Run the " ++ name ++ " example.");
    run_step.dependOn(&run_cmd.step);
}
