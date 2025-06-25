#version 460

out vec3 color;

in vec3 vertex_color;
in vec2 uv;
flat in uint texture_index;

layout(location = 1, binding = 14) uniform sampler2DArray block_textures;

void main() {
    // color = vertex_color;
    vec4 texture = texture(block_textures, vec3(uv.x / 16, 1 - uv.y / 16, float(texture_index)));
    if (texture.a < 0.1) discard;
    // if (texture.r == 0 && texture.g == 0 && texture.b == 0) discard;
    // if (texture.r == 1 && texture.g == 1 && texture.b == 1) discard;
    color = texture.rgb;
    // color = texture(block_textures, vec3(uv / 16, 0)).rgb;
    // color = vec3(float(texture_index >> 8), float(texture_index & 0xff), 0);
    // color = vec3(uv, 0) / 16;
}