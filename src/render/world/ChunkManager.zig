// chunks: std.AutoHashMap(Vector3(i32), ?BakedChunkRenderInfo),

// pub const BakedChunkRenderInfo = struct {
//     axis_aligned_solid_merged_geometry_buffer: ?gl.Buffer,
//     cutout_rotated_unmerged_geometry: ?gl.Buffer,
// };

// pub fn meshAndAddChunk(self: *@This(), pos: Vector3(i32), models: [4096]u16, model_manager: ModelManager, allocator: std.mem.Allocator) void {
//     for (0..16) |x| {
//         for (0..16) |y| {
//             for (0..16) |z| {
//                 const index = x << 8 | y << 4 | z;
//                 const model_id = models[index];
//                 const model = model_manager.resolved_block_models_by_id.?.items[model_id];
//             }
//         }
//     }
// }

// const std = @import("std");
// const gl = @import("gl");
// const root = @import("root");
// const ModelManager = @import("../../model/ModelManager.zig");
// const Vector3 = root.math.Vector3;
