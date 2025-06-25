camera: Camera = .init,

vao: gl.VertexArray,
program: gl.Program,
quad_index_buffer: gl.Buffer,

quad_program: gl.Program,

geometry_buffer: gl.Buffer,
regular_vertices: usize = 0,

axis_aligned_geometry_buffer: gl.Buffer,
axis_aligned_quads: usize = 0,

block_textures: gl.Texture,
texture_manager: TextureManager,

model_manager: ModelManager,

pub fn init() !@This() {
    var arena: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
    defer arena.deinit();

    const vao = gl.createVertexArray();
    vao.bind();

    const program = try initProgram("shader/tri.vert", "shader/tri.frag", arena.allocator());
    program.use();

    const quad_program = try initProgram("shader/quad.vert", "shader/quad.frag", arena.allocator());

    const geometry_buffer = gl.createBuffer();
    geometry_buffer.storage(u8, 1024 * 1024 * 8, null, .{ .dynamic_storage = true });

    const axis_aligned_geometry_buffer = gl.createBuffer();
    axis_aligned_geometry_buffer.storage(u8, 1024 * 1024 * 8, null, .{ .dynamic_storage = true });

    const quad_index_buffer = gl.createBuffer();
    quad_index_buffer.storage(u32, 1024 * 1024 * 5, null, .{ .dynamic_storage = true });
    initQuadIndexBuffer(quad_index_buffer);
    vao.elementBuffer(quad_index_buffer);

    const block_textures: gl.Texture = .create(.@"2d_array");
    block_textures.storage3D(1, .rgba8, 16, 16, 2048);
    block_textures.parameter(.min_filter, .nearest);
    block_textures.parameter(.mag_filter, .nearest);
    block_textures.parameter(.wrap_s, .repeat);
    block_textures.parameter(.wrap_t, .repeat);
    block_textures.parameter(.wrap_r, .repeat);

    const texture_manager = try initTextureManager(block_textures, std.heap.smp_allocator);
    const model_manager = try initModelManager(texture_manager, std.heap.smp_allocator);
    block_textures.bindTo(14);

    return .{
        .vao = vao,
        .geometry_buffer = geometry_buffer,
        .axis_aligned_geometry_buffer = axis_aligned_geometry_buffer,
        .program = program,
        .quad_index_buffer = quad_index_buffer,
        .model_manager = model_manager,
        .block_textures = block_textures,
        .texture_manager = texture_manager,
        .quad_program = quad_program,
    };
}

pub fn debugGeometry(self: *@This()) !void {
    {
        var staging_buffer: StagingBuffer(1024 * 1024 * 8) = .init;
        var models = self.model_manager.resolved_block_models.?.iterator();
        var pos: PackedVector3(u10) = .{ .x = 0, .y = 0, .z = 0 };
        while (models.next()) |entry| {
            const model = entry.value_ptr.*;
            var simple = true;
            for (model.elements) |box| simple = simple and box.isAxisGridAligned();
            if (simple) {
                // continue;
            }
            std.log.scoped(.render_model).info("rendering model {s}", .{entry.key_ptr.*});

            for (model.elements) |box| {
                if (!box.isAxisGridAligned()) continue;
                const quads, const quad_count = try vertex_format.AxisAlignedQuad.model_box(box, pos);
                for (quads[0..quad_count]) |quad| {
                    try staging_buffer.appendPacked(vertex_format.AxisAlignedQuad, quad);
                    self.axis_aligned_quads += 1;
                }
            }
            pos = pos.add(.{ .x = 2, .y = 0, .z = 0 });
            if (pos.x >= 100) {
                pos.x = 0;
                pos.z += 2;
            }
        }

        self.axis_aligned_geometry_buffer.subData(0, u8, staging_buffer.writtenSlice());
    }

    {
        var staging_buffer: StagingBuffer(1024 * 1024 * 8) = .init;
        var models = self.model_manager.resolved_block_models.?.iterator();
        var pos: Vector3(f32) = .origin;
        while (models.next()) |entry| {
            // if (!std.mem.startsWith(u8, entry.key_ptr.*, "cake") and
            //     !std.mem.startsWith(u8, entry.key_ptr.*, "sniffer") and
            //     !std.mem.startsWith(u8, entry.key_ptr.*, "polished_andesite") and
            //     !std.mem.startsWith(u8, entry.key_ptr.*, "gold_block")) continue;

            const model = entry.value_ptr.*;
            var simple = true;
            for (model.elements) |box| simple = simple and box.isAxisGridAligned();
            if (simple) {
                // continue;
            }
            std.log.scoped(.render_model).info("rendering model {s}", .{entry.key_ptr.*});

            for (model.elements) |box| {
                if (box.isAxisGridAligned()) continue;
                const quads, const quad_count = Vertex.model_box(box, pos);
                for (quads[0..quad_count]) |quad| {
                    for (quad) |vertex| {
                        try staging_buffer.appendPacked(Vertex, vertex);
                        self.regular_vertices += 1;
                    }
                }
            }
            pos = pos.add(.{ .x = 2, .y = 0, .z = 0 });
            if (pos.x >= 100) {
                pos.x = 0;
                pos.z += 2;
            }
        }

        self.geometry_buffer.subData(0, u8, staging_buffer.writtenSlice());
    }
}

pub fn initModelManager(texture_manager: TextureManager, gpa: std.mem.Allocator) !ModelManager {
    const path = "C:/Users/inspe/Documents/Code/boat4d/VanillaDefault 1.21.5/assets/minecraft/models";
    var dir = try std.fs.openDirAbsolute(path, .{ .iterate = true });
    defer dir.close();
    var model_manager: ModelManager = try .init(dir, gpa);
    try model_manager.loadAll();
    const start = try std.time.Instant.now();
    try model_manager.resolveAll(texture_manager);
    std.debug.print("models took {d} ms\n", .{
        @as(f64, @floatFromInt((try std.time.Instant.now()).since(start))) / std.time.ns_per_ms,
    });

    try model_manager.countUniqueNormals(gpa);
    return model_manager;
}

pub fn initTextureManager(texture: gl.Texture, gpa: std.mem.Allocator) !TextureManager {
    const path = "C:/Users/inspe/Documents/Code/boat4d/VanillaDefault 1.21.5/assets/minecraft/textures";
    var dir = try std.fs.openDirAbsolute(path, .{ .iterate = true });
    defer dir.close();
    var texture_manager: TextureManager = try .init(dir);
    try texture_manager.loadAll(texture, gpa);
    return texture_manager;
}

pub fn initQuadIndexBuffer(quad_index_buffer: gl.Buffer) void {
    // 1 cube per block
    var buffer: [1024 * 1024 * 5]u32 = undefined;
    for (0..1024 * 1024) |i| {
        buffer[i * 5 + 0] = @intCast(i * 4 + 0);
        buffer[i * 5 + 1] = @intCast(i * 4 + 1);
        buffer[i * 5 + 2] = @intCast(i * 4 + 2);
        buffer[i * 5 + 3] = @intCast(i * 4 + 3);
        buffer[i * 5 + 4] = std.math.maxInt(u32);
    }
    quad_index_buffer.subData(0, u32, &buffer);
}

pub fn render(self: *const @This(), window: WindowInput) !void {
    gl.enable(.cull_face);
    gl.enable(.depth_test);
    gl.viewport(0, 0, @intCast(window.window_size.x), @intCast(window.window_size.y));
    gl.clear(.{ .color = true, .depth = true });

    self.vao.bind();

    self.program.use();
    const mvp_matrix = self.camera.getMvpMatrix(window);
    self.program.uniformMatrix4(0, true, &.{mvp_matrix.data});
    self.block_textures.bindTo(0);
    gl.enable(.primitive_restart);
    gl.binding.primitiveRestartIndex(std.math.maxInt(u32));
    gl.bindBufferBase(.shader_storage_buffer, 0, self.geometry_buffer);
    gl.drawElements(.triangle_fan, self.regular_vertices / 4 * 5, .unsigned_int, 0);
    {
        // gl.polygonMode(.front_and_back, .line);
        // defer gl.polygonMode(.front_and_back, .fill);
        // gl.disable(.cull_face);
        // defer gl.enable(.cull_face);

        self.quad_program.use();
        self.quad_program.uniformMatrix4(0, true, &.{mvp_matrix.data});
        gl.bindBufferBase(.shader_storage_buffer, 0, self.axis_aligned_geometry_buffer);
        gl.drawElements(.triangle_strip, self.axis_aligned_quads * 5, .unsigned_int, 0);
    }
}

pub fn initProgram(vertex_shader_path: []const u8, frag_shader_path: []const u8, arena: std.mem.Allocator) !gl.Program {
    const vertex_shader_file = try std.fs.cwd().openFile(vertex_shader_path, .{});
    defer vertex_shader_file.close();

    const vertex_shader_source = try vertex_shader_file.readToEndAlloc(arena, std.math.maxInt(usize));
    defer arena.free(vertex_shader_source);

    const frag_shader_file = try std.fs.cwd().openFile(frag_shader_path, .{});
    defer frag_shader_file.close();

    const frag_shader_source = try frag_shader_file.readToEndAlloc(arena, std.math.maxInt(usize));
    defer arena.free(frag_shader_source);

    var log_buffer: [1024 * 1024]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&log_buffer);

    const vertex_shader: gl.Shader = .create(.vertex);
    vertex_shader.source(1, &vertex_shader_source);
    vertex_shader.compile();
    if (vertex_shader.get(.compile_status) != gl.binding.TRUE) {
        const compile_log = try vertex_shader.getCompileLog(fba.allocator());
        std.debug.print("{s}\n", .{compile_log});
        return error.VertexShaderCreationFailed;
    }

    const frag_shader: gl.Shader = .create(.fragment);
    frag_shader.source(1, &frag_shader_source);
    frag_shader.compile();
    if (frag_shader.get(.compile_status) != gl.binding.TRUE) {
        const compile_log = try frag_shader.getCompileLog(fba.allocator());
        std.debug.print("{s}\n", .{compile_log});
        return error.FragmentShaderCreationFailed;
    }

    const program: gl.Program = .create();
    program.attach(vertex_shader);
    program.attach(frag_shader);
    program.link();
    if (program.get(.link_status) != gl.binding.TRUE) {
        const compile_log = try program.getCompileLog(fba.allocator());
        std.debug.print("{s}\n", .{compile_log});
        return error.ProgramCreationFailed;
    }
    return program;
}

const std = @import("std");
const gl = @import("gl");
const root = @import("root");
const vertex_format = @import("vertex_format.zig");
const Vertex = vertex_format.Vertex;
const PackedVector3 = root.math.PackedVector3;
const Vector3 = root.math.Vector3;
const Rotation2 = root.math.Rotation2;
const util = root.util;
const decode_gen = @import("shader/decode_gen.zig");
const Camera = @import("../Camera.zig");
const WindowInput = @import("../WindowInput.zig");
const StagingBuffer = @import("staging_buffer.zig").StagingBuffer;
const ResolvedModelBox = @import("../model/ResolvedBox.zig");
const UnresolvedModel = @import("../model/UnresolvedModel.zig");
const ModelManager = @import("../model/ModelManager.zig");
const TextureManager = @import("../model/TextureManager.zig");
