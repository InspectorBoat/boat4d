parent: ?[]const u8 = null,
ambientocclusion: bool = true,
textures: ?TextureVariableMap = null,
elements: ?[]UnresolvedBox = null,

pub fn fromFile(file: std.fs.File, arena: std.mem.Allocator) !@This() {
    var reader = std.json.reader(arena, file.reader());
    return try std.json.parseFromTokenSourceLeaky(
        @This(),
        arena,
        &reader,
        .{ .ignore_unknown_fields = true },
    );
}

pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    try writer.print(
        \\{{
        \\    parent: {s},
        \\    ambient_occlusion: {},
        \\    textures: {{ {?} }},
        \\    elements: {any},
        \\}}
    , .{
        self.parent orelse "",
        self.ambientocclusion,
        self.textures,
        self.elements,
    });
}

pub const TextureVariableMap = struct {
    map: std.StringHashMapUnmanaged([]const u8),

    pub const empty: @This() = .{ .map = .empty };

    pub fn dupe(self: *const @This(), allocator: std.mem.Allocator) !@This() {
        var new: @This() = .empty;
        var iter = self.iterator();
        while (iter.next()) |entry| {
            try new.put(allocator, try allocator.dupe(u8, entry.key_ptr.*), try allocator.dupe(u8, entry.value_ptr.*));
        }
        return new;
    }

    pub fn contains(self: *@This(), variable_name: []const u8) bool {
        return self.map.contains(variable_name);
    }

    pub fn put(self: *@This(), allocator: std.mem.Allocator, variable_name: []const u8, value: []const u8) !void {
        try self.map.put(allocator, variable_name, value);
    }

    pub fn get(self: *const @This(), variable_name: []const u8) ?[]const u8 {
        return self.map.get(variable_name);
    }

    pub fn count(self: *const @This()) u32 {
        return self.map.count();
    }

    pub const VariableResolveError = error{
        MissingTextureVariableReference,
        NoTextureVariables,
        CyclicVariable,
    };

    pub fn resolveVariable(self: *const @This(), variable: []const u8) VariableResolveError![]const u8 {
        var value = variable;
        if (!std.mem.startsWith(u8, variable, "#")) {
            std.log.scoped(.model).warn("variable {s} does not start with #", .{variable});
        }
        for (0..self.count()) |i| {
            if (std.mem.startsWith(u8, value, "#")) {
                // search for a variable reference
                value = self.get(value[1..]) orelse return error.MissingTextureVariableReference;
            } else if (i == 0) {
                // on the first variable, search directly even if reference is malformed
                value = self.get(value) orelse return error.MissingTextureVariableReference;
            } else {
                // Found the concrete texture variable
                return value;
            }
        }
        if (self.count() > 0) {
            std.log.scoped(.model).err("cyclic variables: find {s} in {}", .{ variable, self });
            return error.CyclicVariable;
        } else {
            return error.NoTextureVariables;
        }
    }

    pub fn iterator(self: *const @This()) Iterator {
        return .{ .inner = self.map.iterator() };
    }

    pub const Iterator = struct {
        inner: std.StringHashMapUnmanaged([]const u8).Iterator,

        pub fn next(self: *@This()) ?std.StringHashMapUnmanaged([]const u8).Entry {
            return self.inner.next();
        }
    };

    pub fn merge(self: *@This(), parent: *@This(), allocator: std.mem.Allocator) !void {
        var iter = parent.iterator();
        while (iter.next()) |entry| {
            const variable_name = entry.key_ptr.*;
            // std.mem.doNotOptimizeAway(parent.contains(variable_name));
            // if (self.contains(variable_name)) continue;
            try self.put(allocator, variable_name, entry.value_ptr.*);
        }
    }

    pub fn jsonParse(
        arena: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !@This() {
        if (.object_begin != try source.next()) return error.UnexpectedToken;

        var r: @This() = .empty;

        while (true) {
            const texture_token: ?std.json.Token = try source.nextAllocMax(arena, .alloc_if_needed, options.max_value_len.?);
            const texture_variable = switch (texture_token.?) {
                .string => |slice| try arena.dupe(u8, slice),
                .allocated_string => |slice| slice,
                .object_end => { // No more fields.
                    break;
                },
                else => {
                    return error.UnexpectedToken;
                },
            };

            const texture_value = try std.json.innerParse([]const u8, arena, source, options);
            try r.put(arena, texture_variable, texture_value);
        }
        return r;
    }

    pub fn freeAllocated(allocator: std.mem.Allocator, token: std.json.Token) void {
        switch (token) {
            .allocated_number, .allocated_string => |slice| {
                allocator.free(slice);
            },
            else => {},
        }
    }

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        var iter = self.iterator();
        const entry_count = self.count();
        var i: u32 = 0;
        while (iter.next()) |entry| {
            try writer.print("[{s}: {s}]", .{
                entry.key_ptr.*,
                entry.value_ptr.*,
            });

            if (i < entry_count - 1) try writer.print(", ", .{});
            i += 1;
        }
    }

    pub fn format2(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        try writer.print("{*}", .{self.map.metadata.?});
    }
};

const std = @import("std");
const UnresolvedBox = @import("UnresolvedBox.zig");
