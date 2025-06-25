const WindowInput = @This();

window: glfw.Window,

events: std.fifo.LinearFifo(Event, .Dynamic),
keys: std.EnumArray(glfw.Key, bool) = .initFill(false),
mouse_pos: ?Vector2xy(f64) = null,
maximized: bool = false,
window_size: Vector2xy(i32) = .{ .x = 640, .y = 640 },

pub const Event = union(enum) {
    Pos: Vector2xy(i32),
    Size: Vector2xy(i32),
    Close,
    Refresh,
    Focus: bool,
    Iconify: bool,
    Maximize: bool,
    FramebufferSize: Vector2xy(u32),
    ContentScale: Vector2xy(f32),
    Key: struct { key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods },
    /// Codepoint
    Char: u21,
    MouseButton: struct { button: glfw.MouseButton, action: glfw.Action, mods: glfw.Mods },
    CursorPos: struct { pos: Vector2xy(f64), delta: Vector2xy(f64) },
    CursorEnter: bool,
    Scroll: Vector2xy(f64),
    Drop: struct { paths: [][*:0]const u8 },
};

pub fn init(window: glfw.Window, allocator: std.mem.Allocator) @This() {
    return .{
        .window = window,
        .events = .init(allocator),
    };
}

pub fn deinit(self: *@This()) void {
    self.events.deinit();
}

pub fn setGlfwInputCallbacks(self: *@This()) void {
    self.window.setUserPointer(self);

    self.window.setPosCallback(callbacks.pos);
    self.window.setSizeCallback(callbacks.size);
    self.window.setCloseCallback(callbacks.close);
    self.window.setRefreshCallback(callbacks.refresh);
    self.window.setFocusCallback(callbacks.focus);
    self.window.setIconifyCallback(callbacks.iconify);
    self.window.setMaximizeCallback(callbacks.maximize);
    self.window.setFramebufferSizeCallback(callbacks.framebufferSize);
    self.window.setContentScaleCallback(callbacks.contentScale);
    self.window.setKeyCallback(callbacks.key);
    self.window.setCharCallback(callbacks.char);
    self.window.setMouseButtonCallback(callbacks.mouseButton);
    self.window.setCursorPosCallback(callbacks.cursorPos);
    self.window.setCursorEnterCallback(callbacks.cursorEnter);
    self.window.setScrollCallback(callbacks.scroll);
    self.window.setDropCallback(callbacks.drop);
}

pub const callbacks = struct {
    pub fn pos(window: glfw.Window, xpos: i32, ypos: i32) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{ .Pos = .{
            .x = xpos,
            .y = ypos,
        } }) catch unreachable;
    }
    pub fn size(window: glfw.Window, width: i32, height: i32) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{ .Size = .{
            .x = width,
            .y = height,
        } }) catch unreachable;
        window_input.window_size = .{ .x = width, .y = height };
    }
    pub fn close(window: glfw.Window) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.Close) catch unreachable;
    }
    pub fn refresh(window: glfw.Window) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.Refresh) catch unreachable;
    }
    pub fn focus(window: glfw.Window, focused: bool) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Focus = focused,
        }) catch unreachable;
    }
    pub fn iconify(window: glfw.Window, iconified: bool) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Iconify = iconified,
        }) catch unreachable;
    }
    pub fn maximize(window: glfw.Window, maximized: bool) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Maximize = maximized,
        }) catch unreachable;
        window_input.maximized = maximized;
    }
    pub fn framebufferSize(window: glfw.Window, width: u32, height: u32) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .FramebufferSize = .{ .x = width, .y = height },
        }) catch unreachable;
    }
    pub fn contentScale(window: glfw.Window, xscale: f32, yscale: f32) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .ContentScale = .{ .x = xscale, .y = yscale },
        }) catch unreachable;
    }
    pub fn key(window: glfw.Window, glfw_key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Key = .{ .key = glfw_key, .scancode = scancode, .action = action, .mods = mods },
        }) catch unreachable;
        window_input.keys.set(glfw_key, if (action == .release) false else true);
    }
    pub fn char(window: glfw.Window, codepoint: u21) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Char = codepoint,
        }) catch unreachable;
    }
    pub fn mouseButton(window: glfw.Window, button: glfw.MouseButton, action: glfw.Action, mods: glfw.Mods) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .MouseButton = .{ .button = button, .action = action, .mods = mods },
        }) catch unreachable;
    }

    pub fn cursorPos(window: glfw.Window, xpos: f64, ypos: f64) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        const new_pos: Vector2xy(f64) = .{ .x = xpos, .y = ypos };
        const delta: Vector2xy(f64) = if (window_input.mouse_pos) |prev_pos| prev_pos.sub(new_pos) else .{ .x = 0, .y = 0 };

        window_input.events.writeItem(.{
            .CursorPos = .{ .pos = new_pos, .delta = delta },
        }) catch unreachable;

        window_input.mouse_pos = new_pos;
    }
    pub fn cursorEnter(window: glfw.Window, entered: bool) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .CursorEnter = entered,
        }) catch unreachable;
    }
    pub fn scroll(window: glfw.Window, xoffset: f64, yoffset: f64) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Scroll = .{ .x = xoffset, .y = yoffset },
        }) catch unreachable;
    }
    pub fn drop(window: glfw.Window, paths: [][*:0]const u8) void {
        var window_input = window.getUserPointer(WindowInput) orelse {
            std.log.scoped(.glfw).err("glfw user pointer not found!", .{});
            return;
        };
        window_input.events.writeItem(.{
            .Drop = .{ .paths = paths },
        }) catch unreachable;
    }
};

pub fn handleInputs(self: *@This(), camera: *Camera) !void {
    var changed_size = false;
    var maybe_delta: ?Vector2xy(f64) = null;
    while (self.events.readItem()) |item| {
        switch (item) {
            .Key => |key| {
                switch (key.key) {
                    .escape => {
                        self.window.setShouldClose(true);
                    },
                    .r => {
                        if (key.action != .press) continue;
                        self.window.setInputModeCursor(if (self.window.getInputModeCursor() == .disabled) .normal else .disabled);
                    },
                    .tab => {
                        if (key.action != .press) continue;
                        if (self.maximized) self.window.restore() else self.window.maximize();
                    },
                    else => {},
                }
            },
            .Size,
            .FramebufferSize,
            .Maximize,
            .ContentScale,
            => changed_size = true,
            .CursorPos => |cursor_pos| {
                maybe_delta = cursor_pos.delta;
            },

            .Scroll => |scroll| {
                camera.speed += @floatCast(scroll.y * 0.2);
                if (camera.speed <= 0.0001) camera.speed = 0.2;
                std.log.scoped(.camera).info("speed: {d:.2}", .{camera.speed});
            },

            else => {},
        }
    }
    if (!changed_size and !changed_last_frame) if (maybe_delta) |delta| {
        camera.rot.yaw -= @floatCast(delta.x);
        camera.rot.pitch -= @floatCast(delta.y);
        if (camera.rot.pitch > 90) camera.rot.pitch = 90;
        if (camera.rot.pitch < -90) camera.rot.pitch = -90;
    };
    changed_last_frame = changed_size;

    const now = try std.time.Instant.now();
    const elapsed: f32 = @floatFromInt(if (prev_time) |prev| now.since(prev) else 0);
    defer prev_time = now;
    const steer = self.getSteer().scaleUniform(camera.speed * elapsed * 0.00000001);
    const yaw_radians = camera.rot.yaw * (@as(f32, @floatCast(std.math.pi)) / 180.0);

    const sin = @sin(yaw_radians);
    const cos = @cos(yaw_radians);

    camera.pos = camera.pos.add(.{
        .x = steer.x * cos - steer.z * sin,
        .y = steer.y,
        .z = steer.z * cos + steer.x * sin,
    });
}

var prev_time: ?std.time.Instant = null;
var changed_last_frame = false;
var i: u64 = 0;

pub fn getSteer(self: *const @This()) Vector3(f32) {
    const left = self.keys.get(.a);
    const right = self.keys.get(.d);
    const forward = self.keys.get(.w);
    const back = self.keys.get(.s);
    const up = self.keys.get(.space);
    const down = self.keys.get(.left_shift);

    return .{
        .x = @floatFromInt(@as(i2, @intFromBool(left)) - @as(i2, @intFromBool(right))),
        .y = @floatFromInt(@as(i2, @intFromBool(up)) - @as(i2, @intFromBool(down))),
        .z = @floatFromInt(@as(i2, @intFromBool(forward)) - @as(i2, @intFromBool(back))),
    };
}

const std = @import("std");
const Vector2xy = @import("root").math.Vector2xy;
const Vector3 = @import("root").math.Vector3;
const Vector2xz = @import("root").math.Vector2xz;
const glfw = @import("glfw");
const Camera = @import("Camera.zig");
