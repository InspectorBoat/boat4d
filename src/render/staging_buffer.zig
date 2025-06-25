pub fn StagingBuffer(comptime size: usize) type {
    return struct {
        buffer: [size]u8,
        location: usize,

        pub const init: @This() = .{ .buffer = undefined, .location = 0 };

        pub fn appendPacked(self: *@This(), comptime T: type, vertex: T) !void {
            const len = exactByteSizeOf(T);
            if (self.location + len >= size) return error.OutOfMemory;
            @memcpy(self.buffer[self.location..][0..len], toExactByteArray(&vertex));
            self.location += len;
        }

        pub fn writtenSlice(self: *const @This()) []const u8 {
            return self.buffer[0..self.location];
        }
    };
}

const root = @import("root");
const exactByteSizeOf = root.util.exactByteSizeOf;
const toExactByteArray = root.util.toExactByteArray;
