pub fn main() !void {
    const cwd = std.fs.cwd();
    const tri_vert = try cwd.openFile("shader/tri.vert", .{ .mode = .read_write });
    try tri_vert.seekTo(try tri_vert.getEndPos());
    try tri_vert.writeAll("\n\n");
    try tri_vert.writeAll(decode_gen.all(Vertex, 1));
    tri_vert.close();

    const quad_vert = try cwd.openFile("shader/quad.vert", .{ .mode = .read_write });
    try quad_vert.seekTo(try quad_vert.getEndPos());
    try quad_vert.writeAll("\n\n");
    try quad_vert.writeAll(decode_gen.all(AxisAlignedQuad, 4));
    quad_vert.close();
}

const std = @import("std");
const decode_gen = @import("render/shader/decode_gen.zig");
const vertex_format = @import("render/vertex_format.zig");
const Vertex = vertex_format.Vertex;
const AxisAlignedQuad = vertex_format.AxisAlignedQuad;

pub const math = @import("math/math.zig");
pub const util = @import("util/util.zig");
