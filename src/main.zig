pub const error_handling: gl.ErrorHandling = .log;

pub const std_options: std.Options = .{
    .log_level = .debug,
    .log_scope_levels = &.{
        .{ .scope = .glfw, .level = .debug },
        .{ .scope = .gl, .level = .debug },
        .{ .scope = .model, .level = .err },
        .{ .scope = .image, .level = .warn },
        .{ .scope = .render_model, .level = .info },
        .{ .scope = .shader, .level = .debug },
        .{ .scope = .camera, .level = .warn },
        .{ .scope = .normal, .level = .debug },
    },
};

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    // innitialize glfw
    glfw_helper.setGlfwErrorCallback();
    try glfw_helper.initGlfw();

    // initialize window
    const window = try glfw_helper.initGlfwWindow();
    window.setInputModeCursor(.disabled);

    // initialize opengl
    try glfw_helper.loadGlPointers();
    glfw_helper.setGlErrorCallback();

    // initialize window_input
    var window_input: WindowInput = .init(window, allocator);
    window_input.setGlfwInputCallbacks();
    var renderer: Renderer = try .init();
    try renderer.debugGeometry();

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        defer window.swapBuffers();
        try renderer.render(window_input);
        glfw.pollEvents();
        try window_input.handleInputs(&renderer.camera);
    }
}

const std = @import("std");
const glfw = @import("glfw");
const glfw_helper = @import("glfw_helper.zig");
const WindowInput = @import("WindowInput.zig");
const Renderer = @import("render/Renderer.zig");
const gl = @import("gl");

pub const math = @import("math/math.zig");
pub const util = @import("util/util.zig");
