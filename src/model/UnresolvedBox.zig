from: [3]f32,
to: [3]f32,
rotation: ?struct {
    angle: ResolvedBox.RotationAngle,
    axis: ResolvedBox.RotationAxis,
    origin: [3]f32 = .{ 0, 0, 0 },
    rescale: bool = false,

    pub const none: @This() = .{ .angle = .@"0", .axis = .x };
} = null,
shade: bool = true,
light_emmision: u4 = 0,
faces: struct {
    down: ?Face = null,
    up: ?Face = null,
    north: ?Face = null,
    south: ?Face = null,
    west: ?Face = null,
    east: ?Face = null,
},

pub const Face = struct {
    uv: ?[4]f32 = null,
    texture: []const u8,
    cullface: ?ResolvedFace.Direction = null,
    rotation: ResolvedFace.Rotation = .@"0",
    tintindex: i32 = -1,
};

pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    try writer.print(
        "[ {d} {d} {d} -> {d} {d} {d} ]",
        .{
            self.from[0],
            self.from[1],
            self.from[2],

            self.to[0],
            self.to[1],
            self.to[2],
        },
    );
}

const root = @import("root");
const Vector3 = root.math.Vector3;
const Vector2xy = root.math.Vector2xy;
const za = @import("zalgebra");
const std = @import("std");
const ResolvedBox = @import("ResolvedBox.zig");
const ResolvedFace = @import("ResolvedBox.zig").Face;
