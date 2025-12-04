#!/bin/bash
# Setup script for raylib - builds native and WASM versions

set -e

RAYLIB_VERSION="5.5"
VENDOR_DIR="vendor"
RAYLIB_SRC="$VENDOR_DIR/raylib-src"
BUILD_DIR="build/vendor"
BUILD_WASM_DIR="build-wasm/vendor"

echo "=== Raylib Setup Script ==="
echo "Version: $RAYLIB_VERSION"
echo ""

# Create vendor directory if it doesn't exist
mkdir -p "$VENDOR_DIR"

# Download raylib if not already present
if [ ! -d "$RAYLIB_SRC" ]; then
    echo "Downloading raylib $RAYLIB_VERSION..."
    cd "$VENDOR_DIR"
    wget -q "https://github.com/raysan5/raylib/archive/refs/tags/$RAYLIB_VERSION.tar.gz" -O raylib.tar.gz
    tar -xzf raylib.tar.gz
    mv "raylib-$RAYLIB_VERSION" raylib-src
    rm raylib.tar.gz
    cd ..
    echo "✓ Downloaded raylib"
else
    echo "✓ Raylib source already present"
fi

# Build native version
echo ""
echo "Building raylib (native)..."
mkdir -p "$BUILD_DIR/raylib-build"
cd "$BUILD_DIR/raylib-build"

cmake ../../../"$RAYLIB_SRC" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_GAMES=OFF

make -j$(nproc)
echo "✓ Native raylib built"
cd ../../..

# Build WASM version
echo ""
echo "Building raylib (WASM)..."

# Check if emscripten is available
if ! command -v emcc &> /dev/null; then
    echo "Emscripten not found. Sourcing emsdk..."
    if [ -f "emsdk/emsdk_env.sh" ]; then
        source emsdk/emsdk_env.sh
    else
        echo "Error: emsdk not found. Run ./setup-emscripten.sh first"
        exit 1
    fi
fi

mkdir -p "$BUILD_WASM_DIR/raylib-build"
cd "$BUILD_WASM_DIR/raylib-build"

emcmake cmake ../../../"$RAYLIB_SRC" \
    -DCMAKE_BUILD_TYPE=Release \
    -DPLATFORM=Web \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_GAMES=OFF \
    -DUSE_EXTERNAL_GLFW=OFF \
    -DCUSTOMIZE_BUILD=ON

emmake make -j$(nproc)
echo "✓ WASM raylib built"
cd ../../..

echo ""
echo "=== Raylib Setup Complete ==="
echo "Native library: $BUILD_DIR/raylib-build/libraylib.a"
echo "WASM library:   $BUILD_WASM_DIR/raylib-build/libraylib.a"
echo ""
echo "You can now build Storie with:"
echo "  ./build.sh              # Native with raylib"
echo "  ./build-web.sh          # WASM with raylib"
