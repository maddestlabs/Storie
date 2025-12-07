#version 450

// Vertex shader for 3D rendering with SDL_GPU
// Compile with: glslangValidator -V vertex.glsl -o vertex.spv

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inColor;

layout(binding = 0) uniform UniformBlock {
    mat4 model;
    mat4 view;
    mat4 projection;
} ubo;

layout(location = 0) out vec3 fragColor;

void main() {
    fragColor = inColor;
    gl_Position = ubo.projection * ubo.view * ubo.model * vec4(inPosition, 1.0);
}
