pub const Vertex = packed struct(u128) {
    pos: PackedVector3(f32),
    texture_index: u16 = 0,
    uv: PackedVector2xy(u8) = .origin,

    pub fn quad(pos: Vector3(f32), x: Vector3(f32), y: Vector3(f32)) [4]Vertex {
        return .{
            .{ .pos = pos.toPacked() },
            .{ .pos = pos.add(x).toPacked() },
            .{ .pos = pos.add(x).add(y).toPacked() },
            .{ .pos = pos.add(y).toPacked() },
        };
    }

    pub fn box(
        pos: Vector3(f32),
        x: Vector3(f32),
        y: Vector3(f32),
        z: Vector3(f32),
        faces: struct {
            west: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
            south: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
            east: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
            north: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
            up: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
            down: ?struct { uv: [2]Vector2xy(f32), texture_index: u16 },
        },
    ) struct { [6][4]Vertex, usize } {
        var vertices: [6][4]Vertex = undefined;
        const @"000" = pos.toPacked();
        const @"001" = pos.add(z).toPacked();
        const @"010" = pos.add(y).toPacked();
        const @"011" = pos.add(y).add(z).toPacked();
        const @"100" = pos.add(x).toPacked();
        const @"101" = pos.add(x).add(z).toPacked();
        const @"110" = pos.add(x).add(y).toPacked();
        const @"111" = pos.add(x).add(y).add(z).toPacked();

        var existing_faces: usize = 0;
        // west
        if (faces.west) |west| {
            const uv: [2]PackedVector2xy(u8) = .{ west.uv[0].floatToInt(u8).toPacked(), west.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"000", .texture_index = west.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"001", .texture_index = west.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"011", .texture_index = west.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"010", .texture_index = west.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        // south
        if (faces.south) |south| {
            const uv: [2]PackedVector2xy(u8) = .{ south.uv[0].floatToInt(u8).toPacked(), south.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"001", .texture_index = south.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"101", .texture_index = south.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"111", .texture_index = south.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"011", .texture_index = south.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        // east
        if (faces.east) |east| {
            const uv: [2]PackedVector2xy(u8) = .{ east.uv[0].floatToInt(u8).toPacked(), east.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"101", .texture_index = east.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"100", .texture_index = east.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"110", .texture_index = east.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"111", .texture_index = east.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        // north
        if (faces.north) |north| {
            const uv: [2]PackedVector2xy(u8) = .{ north.uv[0].floatToInt(u8).toPacked(), north.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"100", .texture_index = north.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"000", .texture_index = north.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"010", .texture_index = north.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"110", .texture_index = north.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        // up
        if (faces.up) |up| {
            const uv: [2]PackedVector2xy(u8) = .{ up.uv[0].floatToInt(u8).toPacked(), up.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"011", .texture_index = up.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"111", .texture_index = up.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"110", .texture_index = up.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"010", .texture_index = up.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        // down
        if (faces.down) |down| {
            const uv: [2]PackedVector2xy(u8) = .{ down.uv[0].floatToInt(u8).toPacked(), down.uv[1].floatToInt(u8).toPacked() };
            vertices[existing_faces] = .{
                .{ .pos = @"000", .texture_index = down.texture_index, .uv = .{ .x = uv[0].x, .y = uv[1].y } },
                .{ .pos = @"100", .texture_index = down.texture_index, .uv = .{ .x = uv[1].x, .y = uv[1].y } },
                .{ .pos = @"101", .texture_index = down.texture_index, .uv = .{ .x = uv[1].x, .y = uv[0].y } },
                .{ .pos = @"001", .texture_index = down.texture_index, .uv = .{ .x = uv[0].x, .y = uv[0].y } },
            };
            existing_faces += 1;
        }
        return .{ vertices, existing_faces };
    }

    pub const debug_model_box: ResolvedBox = .{
        .from = .{ .x = -1, .y = 3.5, .z = 7 },
        .to = .{ .x = 1, .y = 13.5, .z = 9 },
        .rotation = .{ .angle = .@"-22.5", .axis = .z, .origin = .{ .x = 0, .y = 3.5, .z = 8 }, .rescale = false },
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

    pub fn model_box(resolved_box: ResolvedBox, offset: Vector3(f32)) struct { [6][4]Vertex, usize } {
        const axis_vectors = resolved_box.getAxisVectors();
        const size = resolved_box.getSize();
        const scale_factor = resolved_box.toWorldSpaceScaleFactor();
        const origin = resolved_box.getOrigin();

        std.log.scoped(.render_model).debug("origin: {}", .{origin.scaleUniform(scale_factor)});
        std.log.scoped(.render_model).debug("axis: {}", .{axis_vectors});
        std.log.scoped(.render_model).debug("size: {}", .{size.scaleUniform(scale_factor)});

        return box(
            origin.scaleUniform(scale_factor).add(offset),
            axis_vectors.x.scaleUniform(size.x).scaleUniform(scale_factor),
            axis_vectors.y.scaleUniform(size.y).scaleUniform(scale_factor),
            axis_vectors.z.scaleUniform(size.z).scaleUniform(scale_factor),
            .{
                .west = if (resolved_box.faces.west) |west| .{ .uv = west.uv, .texture_index = west.texture_index } else null,
                .south = if (resolved_box.faces.south) |south| .{ .uv = south.uv, .texture_index = south.texture_index } else null,
                .east = if (resolved_box.faces.east) |east| .{ .uv = east.uv, .texture_index = east.texture_index } else null,
                .north = if (resolved_box.faces.north) |north| .{ .uv = north.uv, .texture_index = north.texture_index } else null,
                .up = if (resolved_box.faces.up) |up| .{ .uv = up.uv, .texture_index = up.texture_index } else null,
                .down = if (resolved_box.faces.down) |down| .{ .uv = down.uv, .texture_index = down.texture_index } else null,
            },
        );
    }
};

pub const AxisAlignedQuad = packed struct(u96) {
    block_pos: PackedVector3(u10),
    _0: u2 = 0,
    offset: PackedVector3(u4),
    size: PackedVector2xy(u4),
    normal: u4, // 4
    uv0: PackedVector2xy(u4), // 12

    uv1: PackedVector2xy(u4), // 12
    flip: PackedVector2xy(u1),
    texture: u11, // 12
    _1: u11 = 0,

    pub fn model_box(resolved_box: ResolvedBox, block_pos: PackedVector3(u10)) !struct { [6]AxisAlignedQuad, usize } {
        if (resolved_box.rotation.angle != .@"0") return error.NotAxisAligned;
        if (!resolved_box.from.isWhole().all() or !resolved_box.to.isWhole().all()) return error.NotGridAligned;
        if (resolved_box.from.cmpScalar(.lt, 0).any() or resolved_box.from.cmpScalar(.gt, 16).any() or
            resolved_box.to.cmpScalar(.lt, 0).any() or resolved_box.to.cmpScalar(.gt, 16).any())
        {
            return error.OutOfBoundsModel;
        }
        var quads: [6]@This() = undefined;
        var written_quads: usize = 0;
        const size = resolved_box.getSize();

        // TODO: Fix UVs

        // normal: 0
        if (resolved_box.faces.west) |west| {
            const uv, const flip = fixUv(west.uv);
            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.from.x),
                    .y = @intFromFloat(resolved_box.from.y),
                    .z = @intFromFloat(resolved_box.from.z),
                },
                .size = .{
                    .x = @intFromFloat(size.z - 1),
                    .y = @intFromFloat(size.y - 1),
                },
                .texture = @intCast(west.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,
                .normal = 0,
            };
            written_quads += 1;
        }

        // normal: 1
        // z offset: -1
        if (resolved_box.faces.south) |south| {
            const uv, const flip = fixUv(south.uv);

            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.from.x),
                    .y = @intFromFloat(resolved_box.from.y),
                    .z = @intFromFloat(resolved_box.to.z - 1),
                },
                .size = .{
                    .x = @intFromFloat(size.x - 1),
                    .y = @intFromFloat(size.y - 1),
                },
                .texture = @intCast(south.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,
                .normal = 1,
            };
            written_quads += 1;
        }

        // normal:2
        // x/z offset: -1
        if (resolved_box.faces.east) |east| {
            const uv, const flip = fixUv(east.uv);

            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.to.x - 1),
                    .y = @intFromFloat(resolved_box.from.y),
                    .z = @intFromFloat(resolved_box.to.z - 1),
                },
                .size = .{
                    .x = @intFromFloat(size.z - 1),
                    .y = @intFromFloat(size.y - 1),
                },
                .texture = @intCast(east.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,

                .normal = 2,
            };
            written_quads += 1;
        }

        // normal: 3
        // x offset: -1
        if (resolved_box.faces.north) |north| {
            const uv, const flip = fixUv(north.uv);

            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.to.x - 1),
                    .y = @intFromFloat(resolved_box.from.y),
                    .z = @intFromFloat(resolved_box.from.z),
                },
                .size = .{
                    .x = @intFromFloat(size.x - 1),
                    .y = @intFromFloat(size.y - 1),
                },
                .texture = @intCast(north.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,

                .normal = 3,
            };
            written_quads += 1;
        }

        // normal: 4
        // y/z offset: -1
        if (resolved_box.faces.up) |up| {
            const uv, const flip = fixUv(up.uv);

            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.from.x),
                    .y = @intFromFloat(resolved_box.to.y - 1),
                    .z = @intFromFloat(resolved_box.to.z - 1),
                },
                .size = .{
                    .x = @intFromFloat(size.x - 1),
                    .y = @intFromFloat(size.z - 1),
                },
                .texture = @intCast(up.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,

                .normal = 4,
            };
            written_quads += 1;
        }

        // normal: 5
        if (resolved_box.faces.down) |down| {
            const uv, const flip = fixUv(down.uv);
            quads[written_quads] = .{
                .block_pos = block_pos,
                .offset = .{
                    .x = @intFromFloat(resolved_box.from.x),
                    .y = @intFromFloat(resolved_box.from.y),
                    .z = @intFromFloat(resolved_box.from.z),
                },
                .size = .{
                    .x = @intFromFloat(size.x - 1),
                    .y = @intFromFloat(size.z - 1),
                },
                .texture = @intCast(down.texture_index),
                .uv0 = .{ .x = uv[0].x, .y = uv[1].y },
                .uv1 = .{ .x = uv[1].x, .y = uv[0].y },
                .flip = flip,

                .normal = 5,
            };
            written_quads += 1;
        }

        return .{ quads, written_quads };
    }

    pub fn fixUv(uvs: [2]Vector2xy(f32)) struct { [2]PackedVector2xy(u4), PackedVector2xy(u1) } {
        const x_mirrored = uvs[0].x > uvs[1].x;
        const y_mirrored = uvs[0].y > uvs[1].y;
        const fixed_uvs: [2]PackedVector2xy(u4) = .{
            .{
                .x = @intFromFloat(if (x_mirrored) uvs[0].x - 1 else uvs[0].x),
                .y = @intFromFloat(if (y_mirrored) uvs[0].y - 1 else uvs[0].y),
            },
            .{
                .x = @intFromFloat(if (x_mirrored) uvs[1].x else uvs[1].x - 1),
                .y = @intFromFloat(if (y_mirrored) uvs[1].y else uvs[1].y - 1),
            },
        };
        return .{ fixed_uvs, .{ .x = @intFromBool(x_mirrored), .y = @intFromBool(y_mirrored) } };
    }
};

pub const Quad = packed struct(u96) {
    block_pos: PackedVector3(u4), // 12
    offset: PackedVector3(u6), // 18
    texture_flip: PackedVector2xy(u1), // 2

    size: PackedVector2xy(u8), // 10
    uv0: PackedVector2xy(u4), // 8
    uv1: PackedVector2xy(u4), // 8

    normal_index: u12, // 12
    texture: u12, // 12
    size_invert: PackedVector2xy(u1), // 2
    _: u6,

    pub fn getCornerPosition(
        normal_index_to_corner_axes: []const Vector2xy(Vector3(f32)),
        corner: PackedVector2xy(u1),
        quad: @This(),
    ) Vector3(f32) {
        const corner_axes = normal_index_to_corner_axes[quad.normal_index];
        const size: Vector2xy(f32) = blk: {
            const size_raw: Vector2xy(f32) = .{
                .x = @floatFromInt(@as(u9, quad.size.x + 1)),
                .y = @floatFromInt(@as(u9, quad.size.y + 1)),
            };
            break :blk .{
                .x = if (quad.size_invert.x == 1) -size_raw.x else size_raw.x,
                .y = if (quad.size_invert.y == 1) -size_raw.y else size_raw.y,
            };
        };
        const corner_offset: Vector2xy(Vector3(f32)) = .{
            .x = if (corner.x == 1) corner_axes.x.scaleUniform(size.x) else .origin,
            .y = if (corner.y == 1) corner_axes.y.scaleUniform(size.y) else .origin,
        };
        const offset = quad.offset.intToFloat(f32).scaleUniform(1.0 / 63.0);
        return offset.add(corner_offset.x).add(corner_offset.y);
    }

    pub fn getPositions(
        normal_index_to_corner_axes: []Vector2xy(Vector3(f32)),
        quad: @This(),
    ) [4]Vector3(f32) {
        const corner_axes = normal_index_to_corner_axes[quad.normal_index];
        const size: Vector2xy(f32) = blk: {
            const size_raw: Vector2xy(f32) = .{
                .x = @floatFromInt(@as(u9, quad.size.x + 1)),
                .y = @floatFromInt(@as(u9, quad.size.y + 1)),
            };
            break :blk .{
                .x = if (quad.size_invert.x == 1) -size_raw.x else size_raw.x,
                .y = if (quad.size_invert.y == 1) -size_raw.y else size_raw.y,
            };
        };
        const corner_offset: Vector2xy(Vector3(f32)) = .{
            .x = corner_axes.x.scaleUniform(size.x),
            .y = corner_axes.y.scaleUniform(size.y),
        };
        const offset = quad.offset.intToFloat(f32).scaleUniform(1.0 / 63.0);
        return .{
            offset,
            offset.add(corner_offset.x),
            offset.add(corner_offset.x).add(corner_offset.y),
            offset.add(corner_offset.y),
        };
    }
};

pub export const foo = &&Quad.getCornerPosition;

const std = @import("std");
const root = @import("root");
const PackedVector2xy = root.math.PackedVector2xy;
const Vector2xy = root.math.Vector2xy;
const PackedVector3 = root.math.PackedVector3;
const Vector3 = root.math.Vector3;
const ResolvedBox = @import("../model/ResolvedBox.zig");
const ResolvedModel = @import("../model/ResolvedModel.zig");
