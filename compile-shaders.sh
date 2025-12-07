#!/bin/bash
# Compile shaders for SDL_GPU
# Requires: Vulkan SDK (for glslangValidator)

set -e

echo "========================================"
echo "Shader Compilation for SDL_GPU"
echo "========================================"
echo ""

SHADER_DIR="shaders"
OUTPUT_DIR="shaders/compiled"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check for glslangValidator (part of Vulkan SDK)
if ! command -v glslangValidator &> /dev/null; then
    echo "ERROR: glslangValidator not found!"
    echo ""
    echo "Install Vulkan SDK:"
    echo "  Ubuntu/Debian: sudo apt install vulkan-sdk"
    echo "  Arch: sudo pacman -S vulkan-headers vulkan-validation-layers"
    echo "  macOS: brew install vulkan-headers"
    echo "  Windows: Download from https://vulkan.lunarg.com/"
    echo ""
    exit 1
fi

echo "Found glslangValidator: $(which glslangValidator)"
echo ""

# Compile vertex shader to SPIR-V
echo "Compiling vertex shader..."
glslangValidator -V \
    "$SHADER_DIR/vertex.glsl" \
    -o "$OUTPUT_DIR/vertex.spv"

if [ $? -eq 0 ]; then
    echo "✓ vertex.spv created"
else
    echo "✗ Failed to compile vertex shader"
    exit 1
fi

# Compile fragment shader to SPIR-V
echo "Compiling fragment shader..."
glslangValidator -V \
    "$SHADER_DIR/fragment.glsl" \
    -o "$OUTPUT_DIR/fragment.spv"

if [ $? -eq 0 ]; then
    echo "✓ fragment.spv created"
else
    echo "✗ Failed to compile fragment shader"
    exit 1
fi

echo ""
echo "========================================"
echo "Shader compilation complete!"
echo "========================================"
echo ""
echo "Output files:"
ls -lh "$OUTPUT_DIR"/*.spv

echo ""
echo "Next steps:"
echo "1. These SPIR-V shaders work with Vulkan backend"
echo "2. For D3D12, compile with: glslangValidator -D -V -S vert vertex.glsl -o vertex.dxil"
echo "3. For Metal, use spirv-cross: spirv-cross vertex.spv --output vertex.metal --msl"
echo ""
