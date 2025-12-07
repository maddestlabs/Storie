#version 450

// Fragment shader for 3D rendering with SDL_GPU
// Compile with: glslangValidator -V fragment.glsl -o fragment.spv

layout(location = 0) in vec3 fragColor;

layout(location = 0) out vec4 outColor;

void main() {
    outColor = vec4(fragColor, 1.0);
}
