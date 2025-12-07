#!/bin/bash
# Setup script for SDL3 - builds for Windows x64 using MinGW cross-compiler

set -e

SDL_VERSION="latest"
VENDOR_DIR="vendor"
SDL3_SRC="$VENDOR_DIR/SDL3-src"
BUILD_DIR="build-win/vendor"

echo "=== SDL3 Windows Cross-Compile Setup ==="
echo "Building SDL3 for Windows x64 using MinGW-w64"
echo ""

# Check if MinGW is installed
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "ERROR: MinGW-w64 not found!"
    echo "Install with: sudo apt-get install mingw-w64"
    exit 1
fi

# Check if SDL3 source exists
if [ ! -d "$SDL3_SRC" ]; then
    echo "ERROR: SDL3 source not found at $SDL3_SRC"
    echo "Make sure you've cloned the repository with submodules."
    exit 1
fi

# Build SDL3 for Windows
echo "Building SDL3 for Windows x64..."
mkdir -p "$BUILD_DIR/SDL3-build"
cd "$BUILD_DIR/SDL3-build"

cmake ../../../"$SDL3_SRC" \
    -DCMAKE_TOOLCHAIN_FILE=../../../"$SDL3_SRC"/build-scripts/cmake-toolchain-mingw64-x86_64.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DSDL_SHARED=OFF \
    -DSDL_STATIC=ON \
    -DSDL_TEST=OFF \
    -DSDL_TESTS=OFF

make -j$(nproc)
echo "✓ SDL3 built for Windows"
cd ../../..

echo ""
echo "Note: Skipping SDL3_ttf (not required for basic graphics)"
echo "      Text rendering uses SDL3's basic text functions"

echo ""
echo "=== Setup Complete ==="
echo "SDL3 libraries built for Windows x64 in $BUILD_DIR"
echo ""
echo "Now run: ./build-windows-sdl3.sh to build your application"
