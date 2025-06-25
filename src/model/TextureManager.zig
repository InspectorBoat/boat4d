block_texture_dir: ?std.fs.Dir,
resource_ident_to_index: std.HashMapUnmanaged(ResourceLocation, TextureLocation, ResourceLocation.HashContext, 80),

pub const TextureLocation = union(enum) { unsupported, index: u16 };

pub fn init(texture_dir: std.fs.Dir) !@This() {
    return .{
        .block_texture_dir = try texture_dir.openDir("block", .{ .iterate = true }),
        .resource_ident_to_index = .empty,
    };
}

pub fn loadAll(self: *@This(), texture: gl.Texture, gpa: std.mem.Allocator) !void {
    var ok = true;
    defer {
        if (ok) {
            self.block_texture_dir.?.close();
            self.block_texture_dir = null;
        }
    }
    errdefer ok = false;
    const block_texture_dir = self.block_texture_dir orelse return error.AlreadyInitialized;
    var iter = block_texture_dir.iterate();
    var texture_index: u16 = 0;
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".png")) continue;
        // if (!std.mem.startsWith(u8, entry.name, "cake") and
        //     !std.mem.startsWith(u8, entry.name, "sniffer") and
        //     !std.mem.startsWith(u8, entry.name, "polished_andesite") and
        //     !std.mem.startsWith(u8, entry.name, "gold_block")) continue;

        const texture_file = try block_texture_dir.openFile(entry.name, .{});

        const name_without_extension = entry.name[0 .. entry.name.len - ".png".len];

        // TODO: translucency
        var file_stream: std.io.StreamSource = .{ .file = texture_file };
        var trns: zigimg.formats.png.TrnsProcessor = .{};
        var plte: zigimg.formats.png.PlteProcessor = .{};
        var processors: [2]zigimg.formats.png.ReaderProcessor = .{ trns.processor(), plte.processor() };
        var image: zigimg.ImageUnmanaged = try zigimg.formats.png.load(&file_stream, gpa, .{
            .processors = &processors,
        });
        // zigimg.ImageUnmanaged.fromFile(gpa, file_stream);
        defer image.deinit(gpa);

        // TODO: support animations

        const name_with_block_prefix = try gpa.alloc(u8, "block/".len + name_without_extension.len);
        @memcpy(name_with_block_prefix[0.."block/".len], "block/");
        @memcpy(name_with_block_prefix["block/".len..], name_without_extension);

        if (image.width == 16) {
            std.log.scoped(.image).info("uploading image {s} at index {}", .{ name_without_extension, texture_index });
            try self.resource_ident_to_index.put(gpa, try .initAlloc(name_with_block_prefix, gpa), .{ .index = texture_index });
            std.log.scoped(.image).debug("image {s} has format {}", .{ name_without_extension, image.pixelFormat() });
            try image.convert(gpa, .rgba32);
            try image.flipVertically(gpa);
            texture.subImage3D(
                0,
                0,
                0,
                texture_index,
                16,
                16,
                1,
                .rgba,
                .unsigned_byte,
                image.rawBytes().ptr,
            );
        } else {
            std.log.scoped(.image).info("image {s} not 16x16, got {}x{}", .{ name_without_extension, image.width, image.height });
            try self.resource_ident_to_index.put(gpa, try .initAlloc(name_with_block_prefix, gpa), .unsupported);
        }
        texture_index += 1;
    }
}

pub fn getTextureLocation(self: @This(), resource_id: ResourceLocation) !TextureLocation {
    return self.resource_ident_to_index.get(resource_id) orelse return error.MissingTexture;
}

const std = @import("std");
const Model = @import("ModelManager.zig");
const ResourceLocation = @import("ResourceLocation.zig");
const zigimg = @import("zigimg");
const gl = @import("gl");
