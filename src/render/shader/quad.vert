#version 460

layout(std430, binding = 0) buffer geometry {
    uint data[];
};

layout(location = 0) uniform mat4 mvp;

out vec3 vertex_color;
flat out uint texture_index;
out vec2 uv;

uvec3 unpack_block_pos(int base_index);
uvec3 unpack_offset(int base_index);
uvec2 unpack_size(int base_index);
uint unpack_normal(int base_index);
uvec2 unpack_uv0(int base_index);
uvec2 unpack_uv1(int base_index);
uint unpack_texture(int base_index);
uvec2 unpack_flip(int base_index);
int get_base_index();

const vec3 constant_offsets[6] = vec3[](
    // west
    vec3(0, 0, 0),
    // south
    vec3(0, 0, 1),
    // east
    vec3(1, 0, 1),
    // north
    vec3(1, 0, 0),
    // up
    vec3(0, 1, 1),
    // down
    vec3(0, 0, 0)
);

const vec3 constant_axes[6][2] = vec3[][](
    // west
    vec3[](vec3(0, 0, 1), vec3(0, 1, 0)),
    // south
    vec3[](vec3(1, 0, 0), vec3(0, 1, 0)),
    // east
    vec3[](vec3(0, 0, -1), vec3(0, 1, 0)),
    // north
    vec3[](vec3(-1, 0, 0), vec3(0, 1, 0)),
    // up
    vec3[](vec3(1, 0, 0), vec3(0, 0, -1)),
    // down
    vec3[](vec3(1, 0, 0), vec3(0, 0, 1))
);

void main() {
    int base_index = get_base_index();
    uint normal = unpack_normal(base_index);
    vec3 block_pos = vec3(unpack_block_pos(base_index));
    uvec2 size = unpack_size(base_index);
    vec2 corner_multiplier = vec2(
        (gl_VertexID & 1) != 0 ? size.x + 1 : 0,
        (gl_VertexID & 2) != 0 ? size.y + 1 : 0
    );
    uvec3 offset = unpack_offset(base_index);
    vec3 pos = block_pos +
        vec3(offset) / 16 +
        corner_multiplier.x * constant_axes[normal][0] / 16 +
        corner_multiplier.y * constant_axes[normal][1] / 16 +
        constant_offsets[normal] / 16;
    gl_Position = vec4(pos, 1) * mvp;

    uvec2 flip = unpack_flip(base_index);
    uvec2 uv0 = unpack_uv0(base_index) + uvec2(flip.x, 1 - flip.y);
    uvec2 uv1 = unpack_uv1(base_index) + uvec2(1 - flip.x, flip.y);
    uv = vec2(
        (gl_VertexID & 1) != 0 ? uv1.x : uv0.x,
        (gl_VertexID & 2) != 0 ? uv1.y : uv0.y
    );
    texture_index = unpack_texture(base_index);
}