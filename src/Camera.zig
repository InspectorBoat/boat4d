pos: Vector3(f64),
rot: Rotation2(f32),
speed: f32 = 1,
pub const init: @This() = .{
    .pos = .origin,
    .rot = .origin,
};

pub fn getMvpMatrix(self: *const @This(), window: WindowInput) Mat4 {
    const window_width: f32 = @floatFromInt(window.window_size.x);
    const window_height: f32 = @floatFromInt(window.window_size.y);

    const projection: Mat4 = za.perspective(90.0, window_width / window_height, 0.05, 1000.0);

    const model_view: Mat4 = .mul(
        .mul(
            .fromEulerAngles(.new(self.rot.pitch, 0, 0)),
            .fromEulerAngles(.new(0, self.rot.yaw + 180, 0)),
        ),
        .fromTranslate(.new(
            @floatCast(-self.pos.x),
            @floatCast(-self.pos.y),
            @floatCast(-self.pos.z),
        )),
    );

    return projection.mul(model_view);
}

const root = @import("root");
const za = @import("zalgebra");
const WindowInput = @import("WindowInput.zig");
const Mat4 = za.Mat4;
const Vector3 = root.math.Vector3;
const Rotation2 = root.math.Rotation2;
