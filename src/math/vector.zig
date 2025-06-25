const std = @import("std");
const Direction = @import("direction.zig").Direction;

pub fn Vector2xy(comptime Element: type) type {
    return extern struct {
        x: Element,
        y: Element,

        pub const origin: @This() = .{
            .x = 0,
            .y = 0,
        };

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn sub(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
            };
        }
        pub fn scaleUniform(self: @This(), factor: Element) @This() {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
            };
        }

        pub fn negate(self: @This()) @This() {
            return .{
                .x = -self.x,
                .y = -self.y,
            };
        }

        pub fn magnitude_squared(self: @This()) Element {
            return self.x * self.x + self.y * self.y;
        }

        pub fn magnitude(self: @This()) Element {
            return @sqrt(self.x * self.x + self.y * self.y);
        }

        pub fn distance_squared(self: @This(), other: @This()) Element {
            const delta = other.sub(self);
            return delta.x * delta.x + delta.y * delta.y;
        }

        pub fn equals(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y;
        }

        pub fn floatCast(self: @This(), comptime Target: type) Vector2xy(Target) {
            if (@typeInfo(Target) != .float) @compileError("floatCast start type must be float!");
            if (@typeInfo(Element) != .float) @compileError("floatCast target type must be float!");
            return .{
                .x = @floatCast(self.x),
                .y = @floatCast(self.y),
            };
        }

        pub fn intCast(self: @This(), comptime Target: type) Vector2xy(Target) {
            if (@typeInfo(Target) != .int) @compileError("intCast start type must be int!");
            if (@typeInfo(Element) != .int) @compileError("intCast target type must be int!");
            return .{
                .x = @intCast(self.x),
                .y = @intCast(self.y),
            };
        }

        pub fn floatToInt(self: @This(), comptime Target: type) Vector2xy(Target) {
            if (@typeInfo(Element) != .float) @compileError("floatToInt start type must be float!");
            if (@typeInfo(Target) != .int) @compileError("floatToInt target type must be int!");
            return .{
                .x = @intFromFloat(self.x),
                .y = @intFromFloat(self.y),
            };
        }

        pub fn intToFloat(self: @This(), comptime Target: type) Vector2xy(Target) {
            if (@typeInfo(Element) != .int) @compileError("intToFloat start type must be int!");
            if (@typeInfo(Target) != .float) @compileError("intToFloat target type must be float!");
            return .{
                .x = @floatFromInt(self.x),
                .y = @floatFromInt(self.y),
            };
        }

        pub fn bitCast(self: @This(), comptime Target: type) Vector2xy(Target) {
            return .{
                .x = @bitCast(self.x),
                .y = @bitCast(self.y),
            };
        }

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("{{ x: {d} y: {d} }}", .{
                self.x,
                self.y,
            });
        }

        pub fn toPacked(self: @This()) PackedVector2xy(Element) {
            return .{ .x = self.x, .y = self.y };
        }
    };
}

pub fn Vector2xz(comptime Element: type) type {
    return extern struct {
        x: Element,
        z: Element,

        pub const origin: @This() = .{
            .x = 0,
            .z = 0,
        };

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .z = self.z + other.z,
            };
        }

        pub fn sub(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .z = self.z - other.z,
            };
        }
        pub fn scaleUniform(self: @This(), factor: Element) @This() {
            return .{
                .x = self.x * factor,
                .z = self.z * factor,
            };
        }

        pub fn negate(self: @This()) @This() {
            return .{
                .x = -self.x,
                .z = -self.z,
            };
        }

        pub fn magnitude_squared(self: @This()) Element {
            return self.x * self.x + self.z * self.z;
        }

        pub fn magnitude(self: @This()) Element {
            return @sqrt(self.x * self.x + self.z * self.z);
        }

        pub fn distance_squared(self: @This(), other: @This()) Element {
            const delta = other.sub(self);
            return delta.x * delta.x + delta.z * delta.z;
        }

        pub fn equals(self: @This(), other: @This()) bool {
            return self.x == other.x and self.z == other.z;
        }

        pub fn floatCast(self: @This(), comptime Target: type) Vector2xz(Target) {
            if (@typeInfo(Target) != .float) @compileError("floatCast start type must be float!");
            if (@typeInfo(Element) != .float) @compileError("floatCast target type must be float!");
            return .{
                .x = @floatCast(self.x),
                .z = @floatCast(self.z),
            };
        }

        pub fn intCast(self: @This(), comptime Target: type) Vector2xz(Target) {
            if (@typeInfo(Target) != .int) @compileError("intCast start type must be int!");
            if (@typeInfo(Element) != .int) @compileError("intCast target type must be int!");
            return .{
                .x = @intCast(self.x),
                .z = @intCast(self.z),
            };
        }

        pub fn floatToInt(self: @This(), comptime Target: type) Vector2xz(Target) {
            if (@typeInfo(Element) != .float) @compileError("floatToInt start type must be float!");
            if (@typeInfo(Target) != .int) @compileError("floatToInt target type must be int!");
            return .{
                .x = @intFromFloat(self.x),
                .z = @intFromFloat(self.z),
            };
        }

        pub fn intToFloat(self: @This(), comptime Target: type) Vector2xz(Target) {
            if (@typeInfo(Element) != .int) @compileError("intToFloat start type must be int!");
            if (@typeInfo(Target) != .float) @compileError("intToFloat target type must be float!");
            return .{
                .x = @floatFromInt(self.x),
                .z = @floatFromInt(self.z),
            };
        }

        pub fn bitCast(self: @This(), comptime Target: type) Vector2xz(Target) {
            return .{
                .x = @bitCast(self.x),
                .z = @bitCast(self.z),
            };
        }

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("{{ x: {d} z: {d} }}", .{
                self.x,
                self.z,
            });
        }
    };
}

pub fn PackedVector2xy(comptime Element: type) type {
    return packed struct {
        x: Element,
        y: Element,

        pub const origin: @This() = .{
            .x = 0,
            .y = 0,
        };

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn sub(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
            };
        }
        pub fn scaleUniform(self: @This(), factor: Element) @This() {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
            };
        }

        pub fn negate(self: @This()) @This() {
            return .{
                .x = -self.x,
                .y = -self.y,
            };
        }

        pub fn magnitude_squared(self: @This()) Element {
            return self.x * self.x + self.y * self.y;
        }

        pub fn magnitude(self: @This()) Element {
            return @sqrt(self.x * self.x + self.y * self.y);
        }

        pub fn distance_squared(self: @This(), other: @This()) Element {
            const delta = other.sub(self);
            return delta.x * delta.x + delta.y * delta.y;
        }

        pub fn equals(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y;
        }

        pub fn floatCast(self: @This(), comptime Target: type) PackedVector2xy(Target) {
            if (@typeInfo(Target) != .float) @compileError("floatCast start type must be float!");
            if (@typeInfo(Element) != .float) @compileError("floatCast target type must be float!");
            return .{
                .x = @floatCast(self.x),
                .y = @floatCast(self.y),
            };
        }

        pub fn intCast(self: @This(), comptime Target: type) PackedVector2xy(Target) {
            if (@typeInfo(Target) != .int) @compileError("intCast start type must be int!");
            if (@typeInfo(Element) != .int) @compileError("intCast target type must be int!");
            return .{
                .x = @intCast(self.x),
                .y = @intCast(self.y),
            };
        }

        pub fn floatToInt(self: @This(), comptime Target: type) PackedVector2xy(Target) {
            if (@typeInfo(Element) != .float) @compileError("floatToInt start type must be float!");
            if (@typeInfo(Target) != .int) @compileError("floatToInt target type must be int!");
            return .{
                .x = @intFromFloat(self.x),
                .y = @intFromFloat(self.y),
            };
        }

        pub fn intToFloat(self: @This(), comptime Target: type) PackedVector2xy(Target) {
            if (@typeInfo(Element) != .int) @compileError("intToFloat start type must be int!");
            if (@typeInfo(Target) != .float) @compileError("intToFloat target type must be float!");
            return .{
                .x = @floatFromInt(self.x),
                .y = @floatFromInt(self.y),
            };
        }

        pub fn bitCast(self: @This(), comptime Target: type) PackedVector2xy(Target) {
            return .{
                .x = @bitCast(self.x),
                .y = @bitCast(self.y),
            };
        }

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("{{ x: {d} z: {d} }}", .{
                self.x,
                self.y,
            });
        }
    };
}

pub fn Vector3(comptime Element: type) type {
    return extern struct {
        x: Element,
        y: Element,
        z: Element,

        pub const origin: @This() = .{ .x = 0, .y = 0, .z = 0 };

        pub const unit: @This() = .{ .x = 1, .y = 1, .z = 1 };

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        }

        pub fn sub(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        }

        pub fn scaleUniform(self: @This(), factor: Element) @This() {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
                .z = self.z * factor,
            };
        }

        pub fn scale(self: @This(), factor: @This()) @This() {
            return .{
                .x = self.x * factor.x,
                .y = self.y * factor.y,
                .z = self.z * factor.z,
            };
        }

        pub fn negate(self: @This()) @This() {
            return .{
                .x = -self.x,
                .y = -self.y,
                .z = -self.z,
            };
        }

        pub fn distance_squared(self: @This(), other: @This()) Element {
            const delta = other.sub(self);
            return delta.x * delta.x + delta.y * delta.y + delta.z * delta.z;
        }

        pub fn distance(self: @This(), other: @This()) Element {
            return std.math.sqrt(self.distance_squared(other));
        }

        pub fn magnitudeSquared(self: @This()) Element {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }

        pub fn magnitude(self: @This()) Element {
            return std.math.sqrt(self.magnitudeSquared());
        }

        pub fn anyNaN(self: @This()) bool {
            return std.math.isNan(self.x) or std.math.isNan(self.y) or std.math.isNan(self.z);
        }

        pub fn equals(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y and self.z == other.z;
        }

        pub fn up(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y + 1,
                .z = self.z,
            };
        }
        pub fn down(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y - 1,
                .z = self.z,
            };
        }
        pub fn north(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y,
                .z = self.z - 1,
            };
        }
        pub fn south(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y,
                .z = self.z + 1,
            };
        }
        pub fn west(self: @This()) @This() {
            return .{
                .x = self.x - 1,
                .y = self.y,
                .z = self.z,
            };
        }
        pub fn east(self: @This()) @This() {
            return .{
                .x = self.x + 1,
                .y = self.y,
                .z = self.z,
            };
        }
        pub fn dir(self: @This(), direction: Direction) @This() {
            return switch (direction) {
                .Down => self.down(),
                .East => self.east(),
                .North => self.north(),
                .South => self.south(),
                .Up => self.up(),
                .West => self.west(),
            };
        }

        pub fn isWhole(self: @This()) Vector3(bool) {
            if (@typeInfo(Element) != .float) @compileLog("isWhole only works on floats!");
            return .{
                .x = @trunc(self.x) == self.x,
                .y = @trunc(self.y) == self.y,
                .z = @trunc(self.z) == self.z,
            };
        }

        pub fn cmpScalar(self: @This(), op: std.math.CompareOperator, value: Element) Vector3(bool) {
            return .{
                .x = std.math.compare(self.x, op, value),
                .y = std.math.compare(self.y, op, value),
                .z = std.math.compare(self.z, op, value),
            };
        }

        pub fn cmp(self: @This(), op: std.math.CompareOperator, other: @This()) Vector3(bool) {
            return .{
                .x = std.math.compare(self.x, op, other.x),
                .y = std.math.compare(self.y, op, other.y),
                .z = std.math.compare(self.z, op, other.z),
            };
        }

        pub fn any(self: @This()) bool {
            if (@typeInfo(Element) != .bool) @compileLog("any only works on Vectors of booleans!");
            return self.x or self.y or self.z;
        }

        pub fn all(self: @This()) bool {
            if (@typeInfo(Element) != .bool) @compileLog("all only works on Vectors of booleans!");
            return self.x and self.y and self.z;
        }

        pub fn floatCast(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Target) != .float) @compileLog("Must floatCast to float!");
            if (@typeInfo(Element) != .float) @compileLog("Must floatCast from float!");
            return .{
                .x = @floatCast(self.x),
                .y = @floatCast(self.y),
                .z = @floatCast(self.z),
            };
        }

        pub fn intCast(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Target) != .int) @compileLog("Must intCast to int!");
            if (@typeInfo(Element) != .int) @compileLog("Must intCast from int!");
            return .{
                .x = @intCast(self.x),
                .y = @intCast(self.y),
                .z = @intCast(self.z),
            };
        }

        pub fn floatToInt(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Element) != .float) @compileLog("Start type must be float!");
            if (@typeInfo(Target) != .int) @compileLog("Target type from int!");
            return .{
                .x = @intFromFloat(self.x),
                .y = @intFromFloat(self.y),
                .z = @intFromFloat(self.z),
            };
        }

        pub fn intToFloat(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Element) != .int) @compileError("Start type must be int!");
            if (@typeInfo(Target) != .float) @compileError("Target type from float!");
            return .{
                .x = @floatFromInt(self.x),
                .y = @floatFromInt(self.y),
                .z = @floatFromInt(self.z),
            };
        }

        pub fn bitCast(self: @This(), comptime Target: type) Vector3(Target) {
            return .{
                .x = @bitCast(self.x),
                .y = @bitCast(self.x),
                .z = @bitCast(self.z),
            };
        }

        pub fn isLinearlyDependent(self: @This(), other: @This()) bool {
            if (@typeInfo(Element) == .float) {
                const x_ratio = div(self.x, other.x);
                const y_ratio = div(self.y, other.y);
                const z_ratio = div(self.z, other.z);
                return x_ratio.equals(y_ratio) and x_ratio.equals(z_ratio) and y_ratio.equals(z_ratio);
            } else {
                return self.floatToInt(f64).isLinearlyDependent(other.floatToInt(f64));
            }
        }

        pub fn div(a: Element, b: Element) union(enum) {
            indeterminate,
            inf,
            value: Element,
            pub fn equals(self: @This(), other: @This()) bool {
                if (self == .indeterminate or other == .indeterminate) return true;
                if (self == .inf and other == .inf) return true;
                if (self == .value and other == .value) return std.math.approxEqRel(Element, self.value, other.value, @sqrt(std.math.floatEps(f32)));
                return false;
            }
        } {
            if (a == 0 and b == 0) return .indeterminate;
            const val = a / b;
            if (std.math.isInf(val)) return .inf;
            return .{ .value = val };
        }

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("{{ x: {d} y: {d} z: {d} }}", .{
                self.x,
                self.y,
                self.z,
            });
        }

        pub fn toPacked(self: @This()) PackedVector3(Element) {
            return .{ .x = self.x, .y = self.y, .z = self.z };
        }

        pub fn toZa(self: @This()) za.GenericVector(3, Element) {
            return .new(self.x, self.y, self.z);
        }

        pub fn fromZa(za_vec: za.GenericVector(3, Element)) @This() {
            return .{ .x = za_vec.x(), .y = za_vec.y(), .z = za_vec.z() };
        }
    };
}

pub fn PackedVector3(comptime Element: type) type {
    return packed struct {
        x: Element,
        y: Element,
        z: Element,

        pub const origin: @This() = .{ .x = 0, .y = 0, .z = 0 };

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        }

        pub fn sub(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        }

        pub fn scaleUniform(self: @This(), factor: Element) @This() {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
                .z = self.z * factor,
            };
        }

        pub fn scale(self: @This(), factor: @This()) @This() {
            return .{
                .x = self.x * factor.x,
                .y = self.y * factor.y,
                .z = self.z * factor.z,
            };
        }

        pub fn negate(self: @This()) @This() {
            return .{
                .x = -self.x,
                .y = -self.y,
                .z = -self.z,
            };
        }

        pub fn distance_squared(self: @This(), other: @This()) Element {
            const delta = other.sub(self);
            return delta.x * delta.x + delta.y * delta.y + delta.z * delta.z;
        }

        pub fn distance(self: @This(), other: @This()) Element {
            return std.math.sqrt(self.distance_squared(other));
        }

        pub fn magnitudeSquared(self: @This()) Element {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }

        pub fn magnitude(self: @This()) Element {
            return std.math.sqrt(self.magnitudeSquared());
        }

        pub fn anyNaN(self: @This()) bool {
            return std.math.isNan(self.x) or std.math.isNan(self.y) or std.math.isNan(self.z);
        }

        pub fn equals(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y and self.z == other.z;
        }

        pub fn up(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y + 1,
                .z = self.z,
            };
        }
        pub fn down(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y - 1,
                .z = self.z,
            };
        }
        pub fn north(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y,
                .z = self.z - 1,
            };
        }
        pub fn south(self: @This()) @This() {
            return .{
                .x = self.x,
                .y = self.y,
                .z = self.z + 1,
            };
        }
        pub fn west(self: @This()) @This() {
            return .{
                .x = self.x - 1,
                .y = self.y,
                .z = self.z,
            };
        }
        pub fn east(self: @This()) @This() {
            return .{
                .x = self.x + 1,
                .y = self.y,
                .z = self.z,
            };
        }
        pub fn dir(self: @This(), direction: Direction) @This() {
            return switch (direction) {
                .Down => self.down(),
                .East => self.east(),
                .North => self.north(),
                .South => self.south(),
                .Up => self.up(),
                .West => self.west(),
            };
        }

        pub fn floatCast(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Target) != .float) @compileLog("Must floatCast to float!");
            if (@typeInfo(Element) != .float) @compileLog("Must floatCast from float!");
            return .{
                .x = @floatCast(self.x),
                .y = @floatCast(self.y),
                .z = @floatCast(self.z),
            };
        }

        pub fn intCast(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Target) != .int) @compileLog("Must intCast to int!");
            if (@typeInfo(Element) != .int) @compileLog("Must intCast from int!");
            return .{
                .x = @intCast(self.x),
                .y = @intCast(self.y),
                .z = @intCast(self.z),
            };
        }

        pub fn floatToInt(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Element) != .float) @compileLog("Start type must be float!");
            if (@typeInfo(Target) != .int) @compileLog("Target type from int!");
            return .{
                .x = @intFromFloat(self.x),
                .y = @intFromFloat(self.y),
                .z = @intFromFloat(self.z),
            };
        }

        pub fn intToFloat(self: @This(), comptime Target: type) Vector3(Target) {
            if (@typeInfo(Element) != .int) @compileError("Start type must be int!");
            if (@typeInfo(Target) != .float) @compileError("Target type from float!");
            return .{
                .x = @floatFromInt(self.x),
                .y = @floatFromInt(self.y),
                .z = @floatFromInt(self.z),
            };
        }

        pub fn bitCast(self: @This(), comptime Target: type) Vector3(Target) {
            return .{
                .x = @bitCast(self.x),
                .y = @bitCast(self.x),
                .z = @bitCast(self.z),
            };
        }

        pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("{{ x: {d} y: {d} z: {d} }}", .{
                self.x,
                self.y,
                self.z,
            });
        }
    };
}

const za = @import("zalgebra");
