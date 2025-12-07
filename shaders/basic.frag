#version 450

// Inputs from vertex shader
layout(location = 0) in vec3 fragColor;
layout(location = 1) in vec2 fragTexCoord;

// Output
layout(location = 0) out vec4 outColor;

// Optional texture sampler
// layout(binding = 1) uniform sampler2D texSampler;

void main() {
    // Simple color output
    outColor = vec4(fragColor, 1.0);
    
    // With texture:
    // outColor = texture(texSampler, fragTexCoord) * vec4(fragColor, 1.0);
}
