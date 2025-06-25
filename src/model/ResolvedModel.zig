ambientocclusion: bool = true,
elements: []ResolvedBox,

pub fn init(model_manager: *ModelManager, unresolved: *const UnresolvedModel, texture_manager: TextureManager, arena: std.mem.Allocator) !@This() {
    // resolve textures & elements inherited from parents
    var texture_variables: TextureVariableMap = if (unresolved.textures) |textures| try textures.dupe(arena) else .empty;

    var unresolved_elements = unresolved.elements;
    resolve_parents: {
        var maybe_parent = try model_manager.getUnresolved(.init(unresolved.parent orelse break :resolve_parents));
        while (maybe_parent) |parent| : (maybe_parent = try model_manager.getUnresolved(.init(parent.parent orelse break :resolve_parents))) {
            // merge texture variables of parent
            if (parent.textures) |*parent_textures| {
                try texture_variables.merge(parent_textures, arena);
            }
            // child elements overrides parent elements
            if (unresolved_elements == null) unresolved_elements = parent.elements;
        } else return error.MissingParent;
    }
    if (unresolved_elements == null) return error.IncompleteModel;
    const elements = try arena.alloc(ResolvedBox, unresolved_elements.?.len);
    for (unresolved_elements.?, 0..) |unresolved_box, i| {
        elements[i] = try .init(unresolved_box, texture_variables, texture_manager);
    }
    return .{
        .ambientocclusion = unresolved.ambientocclusion,
        .elements = elements,
    };
}

const ModelManager = @import("ModelManager.zig");
const ResolvedBox = @import("ResolvedBox.zig");
const UnresolvedModel = @import("UnresolvedModel.zig");
const TextureManager = @import("TextureManager.zig");

const TextureVariableMap = UnresolvedModel.TextureVariableMap;
const std = @import("std");
