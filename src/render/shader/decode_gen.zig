pub fn all(
    comptime Container: type,
    comptime vertex_attribute_divisor: usize,
) []const u8 {
    return comptime blk: {
        var generated: []const u8 = @"glVertexId -> base_index"(Container, vertex_attribute_divisor) ++ "\n";
        for (@typeInfo(Container).@"struct".fields) |struct_field| {
            if (std.mem.startsWith(u8, struct_field.name, "_")) continue;
            generated = generated ++ field(Container, struct_field.name) ++ "\n";
        }
        break :blk generated;
    };
}

pub fn @"glVertexId -> base_index"(comptime Container: type, comptime vertex_attribute_divisor: usize) []const u8 {
    return comptime blk: {
        const exact_byte_size = @import("root").util.exactByteSizeOf(Container);
        std.debug.assert(@mod(exact_byte_size, @sizeOf(u32)) == 0);
        break :blk std.fmt.comptimePrint(
            \\int get_base_index() {{
            \\    return gl_VertexID / {[vertex_attribute_divisor]d} * {[size_in_uints]};
            \\}}
        , .{
            .vertex_attribute_divisor = vertex_attribute_divisor,
            .size_in_uints = exact_byte_size / @sizeOf(u32),
        });
    };
}

pub fn field(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return switch (@typeInfo(@FieldType(Container, field_name))) {
        .int => @"uN -> uint"(Container, field_name),
        .float => @"f32 -> float"(Container, field_name),
        .@"struct" => |@"struct"| if (@"struct".fields[0].type == f32) switch (@"struct".fields.len) {
            2 => @"Vector2(f32) -> vec2"(Container, field_name),
            3 => @"Vector3(f32) -> vec3"(Container, field_name),
            4 => @"Vector4(f32) -> vec4"(Container, field_name),
            else => @compileError("Unsupported amount of struct fields"),
        } else switch (@"struct".fields.len) {
            2 => @"Vector2(uN, uN) -> uvec2"(Container, field_name),
            3 => @"Vector3(uN, uN, uN) -> uvec3"(Container, field_name),
            4 => @"Vector4(uN, uN, uN, uN) -> uvec4"(Container, field_name),
            else => @compileError("Unsupported amount of struct fields"),
        },
        .@"union" => |@"union"| blk: {
            const FirstUnionField = @"union".fields[0].type;
            switch (@typeInfo(FirstUnionField)) {
                .int => break :blk @"packed union -> uint"(Container, field_name),
                else => @compileError("Unsupported first union field"),
            }
        },
        else => @compileError("Unsupported field type"),
    };
}

pub fn @"packed union -> uint"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"union");
        std.debug.assert(fieldInfo.@"union".layout != .auto);
        const FirstUnionField = fieldInfo.@"union".fields[0].type;
        std.debug.assert(@typeInfo(FirstUnionField) == .int);
        std.debug.assert(@typeInfo(FirstUnionField).int.signedness == .unsigned);

        const bit_offset = @bitOffsetOf(Container, field_name);
        const byte_offset = bit_offset / 8;
        const uint_offset = byte_offset / @sizeOf(u32);

        const end_bit_offset = bit_offset + @bitSizeOf(FieldType) - 1;
        const end_byte_offset = end_bit_offset / 8;
        const end_uint_offset = end_byte_offset / @sizeOf(u32);

        if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");

        break :blk std.fmt.comptimePrint(
            \\uint unpack_{[field_name]s}(int base_index) {{
            \\    return data[base_index + {[index_offset]d}] >>
            \\           {[shift]d} &
            \\           0x{[mask]x};
            \\}}
        , .{
            .field_name = field_name,
            .index_offset = uint_offset,
            .shift = @mod(bit_offset, @bitSizeOf(u32)),
            .mask = std.math.maxInt(FirstUnionField),
        });
    };
}

pub fn @"uN -> uint"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .int);
        std.debug.assert(fieldInfo.int.signedness == .unsigned);

        const bit_offset = @bitOffsetOf(Container, field_name);
        const byte_offset = bit_offset / 8;
        const uint_offset = byte_offset / @sizeOf(u32);

        const end_bit_offset = bit_offset + @bitSizeOf(FieldType) - 1;
        const end_byte_offset = end_bit_offset / 8;
        const end_uint_offset = end_byte_offset / @sizeOf(u32);

        if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");

        break :blk std.fmt.comptimePrint(
            \\uint unpack_{[field_name]s}(int base_index) {{
            \\    return data[base_index + {[index_offset]d}] >>
            \\           {[shift]d} &
            \\           0x{[mask]x};
            \\}}
        , .{
            .field_name = field_name,
            .index_offset = uint_offset,
            .shift = @mod(bit_offset, @bitSizeOf(u32)),
            .mask = std.math.maxInt(FieldType),
        });
    };
}

pub fn @"Vector2(uN, uN) -> uvec2"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 2);

        var bit_offsets: [2]usize = undefined;
        var uint_offsets: [2]usize = undefined;
        var masks: [2]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(isUnsignedInt(SubFieldType));

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            bit_offsets[i] = bit_offset;
            uint_offsets[i] = uint_offset;
            masks[i] = std.math.maxInt(SubFieldType);
        }

        break :blk std.fmt.comptimePrint(
            \\uvec2 unpack_{[field_name]s}(int base_index) {{
            \\    return uvec2(data[base_index + {[index_offset_0]d}], data[base_index + {[index_offset_1]d}]) >>
            \\           uvec2({[shift_0]d}, {[shift_1]d}) &
            \\           uvec2(0x{[mask_0]x}, 0x{[mask_1]x});
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
            .shift_0 = @mod(bit_offsets[0], @bitSizeOf(u32)),
            .shift_1 = @mod(bit_offsets[1], @bitSizeOf(u32)),
            .mask_0 = masks[0],
            .mask_1 = masks[1],
        });
    };
}

pub fn @"Vector3(uN, uN, uN) -> uvec3"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 3);

        var bit_offsets: [3]usize = undefined;
        var uint_offsets: [3]usize = undefined;
        var masks: [3]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(isUnsignedInt(SubFieldType));

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            bit_offsets[i] = bit_offset;
            uint_offsets[i] = uint_offset;
            masks[i] = std.math.maxInt(SubFieldType);
        }

        break :blk std.fmt.comptimePrint(
            \\uvec3 unpack_{[field_name]s}(int base_index) {{
            \\    return uvec3(data[base_index + {[index_offset_0]d}], data[base_index + {[index_offset_1]d}], data[base_index + {[index_offset_2]d}]) >>
            \\           uvec3({[shift_0]d}, {[shift_1]d}, {[shift_2]d}) &
            \\           uvec3(0x{[mask_0]x}, 0x{[mask_1]x}, 0x{[mask_2]x});
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
            .index_offset_2 = uint_offsets[2],
            .shift_0 = @mod(bit_offsets[0], @bitSizeOf(u32)),
            .shift_1 = @mod(bit_offsets[1], @bitSizeOf(u32)),
            .shift_2 = @mod(bit_offsets[2], @bitSizeOf(u32)),
            .mask_0 = masks[0],
            .mask_1 = masks[1],
            .mask_2 = masks[2],
        });
    };
}

pub fn @"Vector4(uN, uN, uN, uN) -> uvec4"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 4);

        var bit_offsets: [4]usize = undefined;
        var uint_offsets: [4]usize = undefined;
        var masks: [4]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(isUnsignedInt(SubFieldType));

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            bit_offsets[i] = bit_offset;
            uint_offsets[i] = uint_offset;
            masks[i] = std.math.maxInt(SubFieldType);
        }

        break :blk std.fmt.comptimePrint(
            \\uvec4 unpack_{[field_name]s}(int base_index) {{
            \\    return uvec4(data[base_index + {[index_offset_0]d}], data[base_index + {[index_offset_1]d}], data[base_index + {[index_offset_2]d}], data[base_index + {[index_offset_3]d}]) >>
            \\           uvec4({[shift_0]d}, {[shift_1]d}, {[shift_2]d}, {[shift_3]d}) &
            \\           uvec4(0x{[mask_0]x}, 0x{[mask_1]x}, 0x{[mask_2]x}, 0x{[mask_3]x});
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
            .index_offset_2 = uint_offsets[2],
            .index_offset_3 = uint_offsets[3],
            .shift_0 = @mod(bit_offsets[0], @bitSizeOf(u32)),
            .shift_1 = @mod(bit_offsets[1], @bitSizeOf(u32)),
            .shift_2 = @mod(bit_offsets[2], @bitSizeOf(u32)),
            .shift_3 = @mod(bit_offsets[3], @bitSizeOf(u32)),
            .mask_0 = masks[0],
            .mask_1 = masks[1],
            .mask_2 = masks[2],
            .mask_3 = masks[3],
        });
    };
}

pub fn @"f32 -> float"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);

        std.debug.assert(FieldType == f32);

        const bit_offset = @bitOffsetOf(Container, field_name);
        const byte_offset = bit_offset / 8;
        const uint_offset = byte_offset / @sizeOf(u32);

        const end_bit_offset = bit_offset + @bitSizeOf(FieldType) - 1;
        const end_byte_offset = end_bit_offset / 8;
        const end_uint_offset = end_byte_offset / @sizeOf(u32);

        if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");

        break :blk std.fmt.comptimePrint(
            \\float unpack_{[field_name]s}(int base_index) {{
            \\    return uintBitsToFloat(data[base_index + {[index_offset]d}]);
            \\}}
        , .{
            .field_name = field_name,
            .index_offset = uint_offset,
        });
    };
}

pub fn @"Vector2(f32) -> vec2"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 2);

        var uint_offsets: [2]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(SubFieldType == f32);

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            uint_offsets[i] = uint_offset;
        }

        break :blk std.fmt.comptimePrint(
            \\vec3 unpack_{[field_name]s}(int base_index) {{
            \\    return vec3(
            \\        uintBitsToFloat(data[base_index + {[index_offset_0]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_1]d}])
            \\    );
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
        });
    };
}

pub fn @"Vector3(f32) -> vec3"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 3);

        var uint_offsets: [3]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(SubFieldType == f32);

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            uint_offsets[i] = uint_offset;
        }

        break :blk std.fmt.comptimePrint(
            \\vec3 unpack_{[field_name]s}(int base_index) {{
            \\    return vec3(
            \\        uintBitsToFloat(data[base_index + {[index_offset_0]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_1]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_2]d}])
            \\    );
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
            .index_offset_2 = uint_offsets[2],
        });
    };
}

pub fn @"Vector4(f32) -> vec4"(
    comptime Container: type,
    comptime field_name: []const u8,
) []const u8 {
    return comptime blk: {
        const FieldType = @FieldType(Container, field_name);
        const fieldInfo = @typeInfo(FieldType);

        std.debug.assert(fieldInfo == .@"struct");
        std.debug.assert(fieldInfo.@"struct".layout == .@"packed" or fieldInfo.@"struct".layout == .@"extern");
        // TODO: dummy fields
        std.debug.assert(fieldInfo.@"struct".fields.len == 4);

        var uint_offsets: [4]usize = undefined;
        const base_bit_offset = @bitOffsetOf(Container, field_name);

        for (fieldInfo.@"struct".fields, 0..) |sub_field, i| {
            const SubFieldType = sub_field.type;
            std.debug.assert(SubFieldType == f32);

            const bit_offset = base_bit_offset + @bitOffsetOf(FieldType, sub_field.name);
            const byte_offset = bit_offset / 8;
            const uint_offset = byte_offset / @sizeOf(u32);

            const end_bit_offset = bit_offset + @bitSizeOf(SubFieldType) - 1;
            const end_byte_offset = end_bit_offset / 8;
            const end_uint_offset = end_byte_offset / @sizeOf(u32);

            if (end_uint_offset != uint_offset) @compileError("TODO: Field across multiple uints");
            uint_offsets[i] = uint_offset;
        }

        break :blk std.fmt.comptimePrint(
            \\vec4 unpack_{[field_name]s}(int base_index) {{
            \\    return vec4(
            \\        uintBitsToFloat(data[base_index + {[index_offset_0]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_1]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_2]d}]),
            \\        uintBitsToFloat(data[base_index + {[index_offset_3]d}])
            \\    );
            \\}}
        , .{
            .field_name = field_name,
            .index_offset_0 = uint_offsets[0],
            .index_offset_1 = uint_offsets[1],
            .index_offset_2 = uint_offsets[2],
            .index_offset_3 = uint_offsets[3],
        });
    };
}

pub fn isUnsignedInt(comptime T: type) bool {
    return @typeInfo(T) == .int and
        @typeInfo(T).int.signedness == .unsigned;
}

const std = @import("std");
