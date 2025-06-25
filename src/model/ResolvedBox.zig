from: Vector3(f32),
to: Vector3(f32),
rotation: struct {
    angle: enum(u3) { @"-45", @"-22.5", @"0", @"22.5", @"45" },
    axis: enum(u2) { x, y, z },
    origin: Vector3(f32),
    rescale: bool,

    pub const none: @This() = .{ .angle = .@"0", .axis = .x, .origin = .origin, .rescale = false };
},
shade: bool,
light_emmision: u4,
faces: struct {
    down: ?Face,
    up: ?Face,
    north: ?Face,
    south: ?Face,
    west: ?Face,
    east: ?Face,
},

pub const RotationAngle = enum(u3) { @"-45", @"-22.5", @"0", @"22.5", @"45" };
pub const RotationAxis = enum(u2) { x, y, z };

pub const cube: @This() = .{
    .from = .origin,
    .to = .{ .x = 16, .y = 16, .z = 16 },
    .rotation = .none,
    .shade = false,
    .light_emmision = 0,
    .faces = .{
        .down = .null,
        .up = .null,
        .north = .null,
        .south = .null,
        .west = .null,
        .east = .null,
    },
};

pub fn getOrigin(self: *const @This()) Vector3(f32) {
    const rotation_axis: za.Vec3_f64 = switch (self.rotation.axis) {
        .x => .new(1, 0, 0),
        .y => .new(0, 1, 0),
        .z => .new(0, 0, 1),
    };
    const rotation_angle: f64 = switch (self.rotation.angle) {
        .@"-45" => -45,
        .@"-22.5" => -22.5,
        .@"0" => 0,
        .@"22.5" => 22.5,
        .@"45" => 45,
    };
    const rotation_matrix: za.Mat3_f64 = .fromRotation(rotation_angle, rotation_axis);
    const delta_to_origin = self.from.sub(self.rotation.origin);
    const rescale: f32 = if (self.rotation.rescale) switch (self.rotation.angle) {
        .@"-45", .@"45" => 1.41421356237,
        .@"-22.5", .@"22.5" => 1.08239220029,
        else => 1.0,
    } else 1.0;

    const origin = rotation_matrix
        .mulByVec3(delta_to_origin.floatCast(f64).toZa())
        .mul(.new(
            if (self.rotation.axis != .x) rescale else 1,
            if (self.rotation.axis != .y) rescale else 1,
            if (self.rotation.axis != .z) rescale else 1,
        ))
        .add(self.rotation.origin.floatCast(f64).toZa());
    return .{
        .x = @floatCast(origin.x()),
        .y = @floatCast(origin.y()),
        .z = @floatCast(origin.z()),
    };
}

pub fn getAxisVectors(self: *const @This()) Vector3(Vector3(f32)) {
    const rotation_axis: za.Vec3_f64 = switch (self.rotation.axis) {
        .x => .new(1, 0, 0),
        .y => .new(0, 1, 0),
        .z => .new(0, 0, 1),
    };
    const rotation_angle: f64 = switch (self.rotation.angle) {
        .@"-45" => -45,
        .@"-22.5" => -22.5,
        .@"0" => 0,
        .@"22.5" => 22.5,
        .@"45" => 45,
    };
    // \sqrt{1+\tan\left(a\right)^{2}}
    // sqrt(1 + (tan(a))^2)
    // https://www.desmos.com/calculator/ydu71ep77v
    const rescale: f32 = if (self.rotation.rescale) switch (self.rotation.angle) {
        .@"-45", .@"45" => 1.41421356237,
        .@"-22.5", .@"22.5" => 1.08239220029,
        else => 1.0,
    } else 1.0;
    const rotation_matrix: za.Mat3_f64 = .fromRotation(rotation_angle, rotation_axis);
    const x = rotation_matrix.mulByVec3(.new(if (self.rotation.axis != .x) rescale else 1, 0, 0));
    const y = rotation_matrix.mulByVec3(.new(0, if (self.rotation.axis != .y) rescale else 1, 0));
    const z = rotation_matrix.mulByVec3(.new(0, 0, if (self.rotation.axis != .z) rescale else 1));
    return .{
        .x = .{ .x = @floatCast(x.x()), .y = @floatCast(x.y()), .z = @floatCast(x.z()) },
        .y = .{ .x = @floatCast(y.x()), .y = @floatCast(y.y()), .z = @floatCast(y.z()) },
        .z = .{ .x = @floatCast(z.x()), .y = @floatCast(z.y()), .z = @floatCast(z.z()) },
    };
}

pub fn getSize(self: *const @This()) Vector3(f32) {
    return self.to.sub(self.from);
}

pub fn toWorldSpaceScaleFactor(_: *const @This()) f32 {
    return 1.0 / 16.0;
}

pub fn init(unresolved: UnresolvedBox, texture_variables: TextureVariableMap, texture_manager: TextureManager) !@This() {
    var resolved_box: @This() = .{
        .from = .{ .x = unresolved.from[0], .y = unresolved.from[1], .z = unresolved.from[2] },
        .to = .{ .x = unresolved.to[0], .y = unresolved.to[1], .z = unresolved.to[2] },
        .rotation = if (unresolved.rotation) |rotation| .{
            .angle = @enumFromInt(@intFromEnum(rotation.angle)),
            .axis = @enumFromInt(@intFromEnum(rotation.axis)),
            .origin = .{ .x = rotation.origin[0], .y = rotation.origin[1], .z = rotation.origin[2] },
            .rescale = rotation.rescale,
        } else .none,
        .shade = unresolved.shade,
        .light_emmision = unresolved.light_emmision,
        .faces = .{ .down = null, .up = null, .north = null, .south = null, .west = null, .east = null },
    };
    inline for (@typeInfo(@TypeOf(unresolved.faces)).@"struct".fields) |field| {
        if (@field(unresolved.faces, field.name)) |unresolved_face| {
            // resolve texture variable
            const texture_name = texture_variables.resolveVariable(unresolved_face.texture) catch |err| switch (err) {
                error.MissingTextureVariableReference, error.NoTextureVariables => return error.IncompleteModel,
                error.CyclicVariable => return err,
            };
            const texture_resource_location: ResourceLocation = .init(texture_name);
            const texture_index = blk: {
                const texture_location = texture_manager.getTextureLocation(texture_resource_location) catch |err| {
                    std.log.scoped(.model).warn("Failed to find texture {}: {}", .{ texture_resource_location, err });
                    // TODO: use missing model
                    break :blk 0;
                };
                break :blk switch (texture_location) {
                    .index => |index| index,
                    .unsupported => 0,
                };
            };
            // resolve uv mappings
            const uv: [2]Vector2xy(f32) = if (unresolved_face.uv) |uv|
                .{ .{ .x = uv[0], .y = uv[1] }, .{ .x = uv[2], .y = uv[3] } }
                // autocompute uv mappings on non-rotated boxes with integer coordinates between 0 and 16
            else if (resolved_box.rotation.angle == .@"0")
                try computeAutoUv(
                    resolved_box.from,
                    resolved_box.to,
                    @field(Face.Direction, field.name),
                )
            else
                return error.MissingUvMapping;

            const face: Face = .{
                .uv = uv,
                .texture_index = texture_index,
                .cullface = unresolved_face.cullface,
                .rotation = unresolved_face.rotation,
                .tintindex = unresolved_face.tintindex,
            };
            @field(resolved_box.faces, field.name) = face;
        }
    }
    return resolved_box;
}

pub fn computeAutoUv(from: Vector3(f32), to: Vector3(f32), face: Face.Direction) ![2]Vector2xy(f32) {
    // if (!isWholeNumber(from) or !isWholeNumber(to)) return error.FailedUvMapping;
    if (from.cmpScalar(.lt, 0).any() or from.cmpScalar(.gt, 16).any()) return error.FailedUvMapping;
    if (to.cmpScalar(.lt, 0).any() or to.cmpScalar(.gt, 16).any()) return error.FailedUvMapping;
    // return switch (face) {
    //     .up => .{ .{ .x = from.x, .y = from.z }, .{ .x = to.x, .y = to.z } },
    //     .down => .{ .{ .x = from.x, .y = 16 - to.z }, .{ .x = to.x, .y = 16 - from.z } },
    //     .west => .{ .{ .x = from.z, .y = 16 - to.y }, .{ .x = to.z, .y = 16 - from.y } },
    //     .south => .{ .{ .x = from.x, .y = 16 - to.y }, .{ .x = to.x, .y = 16 - from.y } },
    //     .east => .{ .{ .x = 16 - to.x, .y = 16 - to.y }, .{ .x = 16 - from.x, .y = 16 - from.y } },
    //     .north => .{ .{ .x = 16 - to.x, .y = 16 - to.y }, .{ .x = 16 - from.x, .y = 16 - from.y } },
    // };
    return switch (face) {
        .up => .{ .{ .x = from.x, .y = from.z }, .{ .x = to.x, .y = to.z } },
        .down => .{ .{ .x = from.x, .y = 16 - to.z }, .{ .x = to.x, .y = 16 - from.z } },
        .west => .{ .{ .x = from.z, .y = 16 - to.y }, .{ .x = to.z, .y = 16 - from.y } },
        .south => .{ .{ .x = from.x, .y = 16 - to.y }, .{ .x = to.x, .y = 16 - from.y } },
        .east => .{ .{ .x = 16 - to.x, .y = 16 - to.y }, .{ .x = 16 - from.x, .y = 16 - from.y } },
        .north => .{ .{ .x = 16 - to.x, .y = 16 - to.y }, .{ .x = 16 - from.x, .y = 16 - from.y } },
    };
}

pub fn isAxisGridAligned(self: *const @This()) bool {
    if (self.rotation.angle != .@"0") return false;
    if (!self.from.isWhole().all() or !self.to.isWhole().all()) return false;
    if (self.from.cmpScalar(.lt, 0).any() or self.from.cmpScalar(.gt, 16).any() or
        self.to.cmpScalar(.lt, 0).any() or self.to.cmpScalar(.gt, 16).any())
    {
        return false;
    }
    return true;
}

pub fn isWholeNumber(vec: Vector3(f32)) bool {
    return @trunc(vec.x) == vec.x and
        @trunc(vec.y) == vec.y and
        @trunc(vec.z) == vec.z;
}

pub const Face = struct {
    uv: [2]Vector2xy(f32),
    texture_index: u16,
    cullface: ?Direction,
    rotation: Rotation,
    tintindex: i32,

    pub const Direction = enum { down, up, north, south, west, east };
    pub const Rotation = enum { @"0", @"90", @"180", @"270" };

    pub const @"null": @This() = .{
        .uv = .{ .origin, .{ .x = 15, .y = 15 } },
        .texture = .init("minecraft:grass"),
        .cullface = null,
        .rotation = .@"0",
        .tintindex = -1,
    };
};

const root = @import("root");
const Vector3 = root.math.Vector3;
const Vector2xy = root.math.Vector2xy;
const UnresolvedBox = @import("UnresolvedBox.zig");
const ModelManager = @import("ModelManager.zig");
const TextureVariableMap = @import("UnresolvedModel.zig").TextureVariableMap;
const za = @import("zalgebra");
const std = @import("std");
const ResourceLocation = @import("ResourceLocation.zig");
const TextureManager = @import("TextureManager.zig");
