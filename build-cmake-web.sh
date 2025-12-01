#!/bin/bash
# Build SDL3 and SDL3_ttf using CMake for Emscripten/WebAssembly

set -e

VERSION="0.1.0"
BUILD_DIR="build-wasm"
BUILD_TYPE="Release"

show_help() {
    cat << EOF
Storie Emscripten CMake Build Script v$VERSION
Builds SDL3 and SDL3_ttf from source for WebAssembly

Usage: ./build-cmake-web.sh [OPTIONS]

Options:
  -h, --help            Show this help message
  -d, --debug           Build in debug mode
  -c, --clean           Clean build directory before building

Examples:
  ./build-cmake-web.sh          # Build in release mode
  ./build-cmake-web.sh -d       # Build in debug mode
  ./build-cmake-web.sh -c       # Clean and rebuild

Requirements:
  - Emscripten SDK must be activated
  - Run: source emsdk/emsdk_env.sh

EOF
}

CLEAN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            echo "Error: Unexpected argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check for Emscripten
if ! command -v emcc &> /dev/null; then
    echo "❌ Error: Emscripten (emcc) not found!"
    echo ""
    echo "Please activate Emscripten:"
    echo "  cd emsdk"
    echo "  source ./emsdk_env.sh"
    exit 1
fi

echo "Using Emscripten: $(emcc --version | head -1)"
echo ""

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

echo "Configuring SDL3 and SDL3_ttf for WebAssembly..."
echo "Build type: $BUILD_TYPE"
echo ""

# Configure with Emscripten
emcmake cmake -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_SHARED_LIBS=OFF

if [ $? -ne 0 ]; then
    echo "❌ CMake configuration failed!"
    exit 1
fi

echo ""
echo "Building SDL3 and SDL3_ttf for WebAssembly..."
echo ""

# Build
cmake --build "$BUILD_DIR" --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "✅ SDL3 and SDL3_ttf built successfully for WebAssembly!"
echo ""
echo "Build artifacts are in: $BUILD_DIR/"
echo ""
echo "Next steps:"
echo "  Use ./build-web.sh to compile Nim code with these libraries"
