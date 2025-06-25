pub const StackBufferAllocator = @import("stack_buffer_allocator.zig").StackBufferAllocator;

pub inline fn toExactByteArray(ptr: anytype) AsBytesReturnType(@TypeOf(ptr)) {
    return @ptrCast(ptr);
}

pub fn exactByteSizeOf(T: type) usize {
    return @divExact(@bitSizeOf(T), 8);
}

pub fn AsBytesReturnType(comptime P: type) type {
    const pointer = @typeInfo(P).pointer;
    const child = @typeInfo(pointer.child);
    std.debug.assert(pointer.size == .one);
    std.debug.assert(child == .@"struct");
    std.debug.assert(child.@"struct".layout == .@"packed");
    std.debug.assert(@bitSizeOf(pointer.child) % 8 == 0);
    const size = @bitSizeOf(pointer.child) / 8;
    return CopyPtrAttrs(P, .one, [size]u8);
}

pub fn CopyPtrAttrs(
    comptime source: type,
    comptime size: std.builtin.Type.Pointer.Size,
    comptime child: type,
) type {
    const info = @typeInfo(source).pointer;
    return @Type(.{
        .pointer = .{
            .size = size,
            .is_const = info.is_const,
            .is_volatile = info.is_volatile,
            .is_allowzero = info.is_allowzero,
            .alignment = info.alignment,
            .address_space = info.address_space,
            .child = child,
            .sentinel_ptr = null,
        },
    });
}

const std = @import("std");
