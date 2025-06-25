#version 460

layout(std430, binding = 0) buffer geometry {
    uint data[];
};

layout(location = 0) uniform mat4 mvp;

out vec3 vertex_color;
flat out uint texture_index;
out vec2 uv;

int get_base_index();
vec3 unpack_pos(int base_index);
uint unpack_texture_index(int base_index);
uvec2 unpack_uv(int base_index);

void main() {
    int base_index = get_base_index();
    vec3 pos = unpack_pos(base_index);
    gl_Position = vec4(pos, 1) * mvp;
    texture_index = unpack_texture_index(base_index);
    uv = vec2(unpack_uv(base_index));
}