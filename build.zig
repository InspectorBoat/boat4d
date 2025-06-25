const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mach_glfw = b.dependency("mach_glfw", .{
        .target = target,
        .optimize = optimize,
    }).module("mach-glfw");
    const zgl = b.dependency("zgl", .{
        .target = target,
        .optimize = optimize,
    }).module("zgl");
    const zalgebra = b.dependency("zalgebra", .{
        .target = target,
        .optimize = optimize,
    }).module("zalgebra");
    const zigimg = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize,
    }).module("zigimg");

    const exe = b.addExecutable(.{
        .name = "boat4d",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "glfw", .module = mach_glfw },
                .{ .name = "gl", .module = zgl },
                .{ .name = "zalgebra", .module = zalgebra },
                .{ .name = "zigimg", .module = zigimg },
            },
        }),
    });
    exe.stack_size = 1024 * 1024 * 64;
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.setCwd(.{ .cwd_relative = b.getInstallPath(.bin, "") });

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
