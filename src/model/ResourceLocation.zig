namespace: []const u8,
id: []const u8,

pub fn init(str: []const u8) @This() {
    if (std.mem.containsAtLeastScalar(u8, str, 1, ':')) {
        var split = std.mem.splitScalar(u8, str, ':');
        const namespace = split.next().?;
        const id = split.next().?;
        return .{ .namespace = namespace, .id = id };
    } else {
        return .{ .namespace = @as([]const u8, "minecraft"), .id = str };
    }
}

pub fn initAlloc(str: []const u8, gpa: std.mem.Allocator) !@This() {
    if (std.mem.containsAtLeastScalar(u8, str, 1, ':')) {
        var split = std.mem.splitScalar(u8, str, ':');
        const namespace = split.next().?;
        const id = split.next().?;
        return .{ .namespace = try gpa.dupe(u8, namespace), .id = try gpa.dupe(u8, id) };
    } else {
        return .{ .namespace = @as([]const u8, "minecraft"), .id = try gpa.dupe(u8, str) };
    }
}

pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    try writer.print("{s}:{s}", .{ self.namespace, self.id });
}

pub const HashContext = struct {
    pub fn hash(self: @This(), s: ResourceLocation) u64 {
        _ = self;
        var hasher: std.hash.Wyhash = .init(0);
        hasher.update(s.id);
        hasher.update(s.namespace);
        return hasher.final();
    }
    pub fn eql(self: @This(), a: ResourceLocation, b: ResourceLocation) bool {
        _ = self;
        return std.mem.eql(u8, a.id, b.id) and std.mem.eql(u8, a.namespace, b.namespace);
    }
};

const std = @import("std");
const ResourceLocation = @This();
