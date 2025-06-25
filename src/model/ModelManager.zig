block_model_dir: std.fs.Dir,
item_model_dir: std.fs.Dir,

unresolved_arena: ?std.heap.ArenaAllocator,
unresolved_block_models: ?std.StringHashMapUnmanaged(UnresolvedModel),

resolved_arena: ?std.heap.ArenaAllocator,
resolved_block_models: ?std.StringHashMapUnmanaged(ResolvedModel),
resolved_block_models_by_id: ?std.ArrayListUnmanaged(ResolvedModel),

pub fn init(model_dir: std.fs.Dir, gpa: std.mem.Allocator) !@This() {
    return .{
        .block_model_dir = try model_dir.openDir("block", .{ .iterate = true }),
        .item_model_dir = try model_dir.openDir("item", .{ .iterate = true }),
        .unresolved_block_models = null,
        .unresolved_arena = .init(gpa),
        .resolved_block_models = null,
        .resolved_arena = .init(gpa),
        .resolved_block_models_by_id = null,
    };
}

pub fn loadAll(self: *@This()) !void {
    defer {
        self.block_model_dir.close();
        self.item_model_dir.close();
    }

    var iter = self.block_model_dir.iterate();
    self.unresolved_block_models = .empty;

    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".json")) continue;

        const file = try self.block_model_dir.openFile(entry.name, .{});
        defer file.close();
        const model = UnresolvedModel.fromFile(file, self.unresolved_arena.?.allocator()) catch {
            std.log.scoped(.model).err("error parsing model {s}", .{entry.name});
            return error.ModelParseError;
        };
        const model_name = try self.unresolved_arena.?.allocator().dupe(u8, entry.name[0 .. entry.name.len - ".json".len]);
        try self.unresolved_block_models.?.put(self.unresolved_arena.?.allocator(), model_name, model);
    }
}

pub fn resolveAll(self: *@This(), texture_manager: TextureManager) !void {
    const allocator = self.resolved_arena.?.allocator();
    var iter = self.unresolved_block_models.?.iterator();
    self.resolved_block_models = .empty;
    self.resolved_block_models_by_id = .empty;

    while (iter.next()) |entry| {
        const model_name = entry.key_ptr.*;
        const unresolved_model = entry.value_ptr;

        std.log.scoped(.model).info("resolving {s}", .{entry.key_ptr.*});
        const resolved_model = ResolvedModel.init(self, unresolved_model, texture_manager, allocator) catch |err| switch (err) {
            error.IncompleteModel => {
                std.log.scoped(.model).info("incomplete model {s}", .{entry.key_ptr.*});
                continue;
            },
            else => return err,
        };

        try self.resolved_block_models.?.put(
            allocator,
            try allocator.dupe(u8, model_name),
            resolved_model,
        );
        try self.resolved_block_models_by_id.?.append(
            allocator,
            resolved_model,
        );
    }
    self.unresolved_block_models = null;
    self.unresolved_arena.?.deinit();
    self.unresolved_arena = null;
}

pub fn countUniqueNormals(self: *const @This(), gpa: std.mem.Allocator) !void {
    var axis_vectors: std.ArrayListUnmanaged(struct { []const u8, Vector2xy(Vector3(f32)) }) = .empty;
    var model_entries = self.resolved_block_models.?.iterator();
    var elements: usize = 0;
    while (model_entries.next()) |entry| {
        const name = entry.key_ptr.*;
        const model = entry.value_ptr.*;
        for (model.elements) |element| {
            elements += 1;

            const box_axis_vectors = element.getAxisVectors();
            {
                const axis_vectors_xy: Vector2xy(Vector3(f32)) = .{ .x = box_axis_vectors.x, .y = box_axis_vectors.y };
                switch (findMatchingNormal(undefined, axis_vectors_xy, axis_vectors.items)) {
                    .none => try axis_vectors.append(gpa, .{ name, axis_vectors_xy }),
                    // .match => |match| std.log.debug("normal of {s} matches with {s}", .{ name, match[0] }),
                    else => {},
                }
            }
            {
                const axis_vectors_xz: Vector2xy(Vector3(f32)) = .{ .x = box_axis_vectors.x, .y = box_axis_vectors.z };
                switch (findMatchingNormal(undefined, axis_vectors_xz, axis_vectors.items)) {
                    .none => try axis_vectors.append(gpa, .{ name, axis_vectors_xz }),
                    // .match => |match| std.log.debug("normal of {s} matches with {s}", .{ name, match[0] }),
                    else => {},
                }
            }
            {
                const axis_vectors_yz: Vector2xy(Vector3(f32)) = .{ .x = box_axis_vectors.y, .y = box_axis_vectors.z };
                switch (findMatchingNormal(undefined, axis_vectors_yz, axis_vectors.items)) {
                    .none => try axis_vectors.append(gpa, .{ name, axis_vectors_yz }),
                    // .match => |match| std.log.debug("normal of {s} matches with {s}", .{ name, match[0] }),
                    else => {},
                }
            }
        }
    }
    std.log.scoped(.normal).debug("total normals: {}", .{elements});
    std.log.scoped(.normal).debug("{} unique normals\n", .{axis_vectors.items.len});
}

pub fn findMatchingNormal(
    ideal_vertex_positions: [4]Vector3(f32),
    ideal_axis_vectors: Vector2xy(Vector3(f32)),
    normal_index_to_axis_vectors: []const struct { []const u8, Vector2xy(Vector3(f32)) },
) union(enum) { none: void, match: struct { []const u8, Vector2xy(Vector3(f32)) } } {
    _ = ideal_vertex_positions;
    for (normal_index_to_axis_vectors) |potential_match| {
        const potential_axis_vectors = potential_match[1];
        if (potential_axis_vectors.x.isLinearlyDependent(ideal_axis_vectors.x) and
            potential_axis_vectors.y.isLinearlyDependent(ideal_axis_vectors.y))
            return .{ .match = potential_match };
    } else return .none;
}

pub fn getUnresolved(self: *@This(), resource_location: ResourceLocation) !?*UnresolvedModel {
    if (std.mem.startsWith(u8, resource_location.id, "block/")) {
        const id = resource_location.id["block/".len..];
        return self.unresolved_block_models.?.getPtr(id);
    } else {
        std.log.scoped(.model).err("bad model resource id: {s}:{s}", .{ resource_location.namespace, resource_location.id });
        return error.BadId;
    }
}

pub fn openResourceLocation(self: *const @This(), resource_location: ResourceLocation) !std.fs.File {
    if (std.mem.eql(u8, resource_location.namespace, "minecraft")) {
        return error.BadNamespace;
    }

    if (std.mem.startsWith(u8, resource_location.id, "block/")) {
        var buf: [1024]u8 = undefined;
        const id = resource_location.id["block/".len..];
        @memcpy(buf[0..id.len], id);
        @memcpy(buf[id.len][0..5], ".json");
        return self.block_model_dir.openFile(buf, .{});
    } else if (std.mem.startsWith(u8, resource_location.id, "item/")) {
        var buf: [1024]u8 = undefined;
        const id = resource_location.id["item/".len..];
        @memcpy(buf[0..id.len], id);
        @memcpy(buf[id.len][0..5], ".json");
        return self.item_model_dir.openFile(buf, .{});
    } else return error.BadId;
}

const std = @import("std");
const root = @import("root");
const UnresolvedModel = @import("UnresolvedModel.zig");
const ResolvedModel = @import("ResolvedModel.zig");
const ResourceLocation = @import("ResourceLocation.zig");
const TextureManager = @import("TextureManager.zig");
const Vector2xy = root.math.Vector2xy;
const Vector3 = root.math.Vector3;
const vertex_format = @import("../render/vertex_format.zig");
