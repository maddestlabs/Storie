#!/bin/bash
# Build SDL3 and SDL3_ttf using CMake for native platform

set -e

VERSION="0.1.0"
BUILD_DIR="build"
BUILD_TYPE="Release"

show_help() {
    cat << EOF
Storie CMake Build Script v$VERSION
Builds SDL3 and SDL3_ttf from source for native platform

Usage: ./build-cmake.sh [OPTIONS]

Options:
  -h, --help            Show this help message
  -d, --debug           Build in debug mode
  -c, --clean           Clean build directory before building
  --install             Install to vendor/SDL3 after building

Examples:
  ./build-cmake.sh              # Build in release mode
  ./build-cmake.sh -d           # Build in debug mode
  ./build-cmake.sh -c           # Clean and rebuild
  ./build-cmake.sh --install    # Build and install

EOF
}

CLEAN=false
INSTALL=false

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
        --install)
            INSTALL=true
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

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

echo "Configuring SDL3 and SDL3_ttf..."
echo "Build type: $BUILD_TYPE"
echo ""

# Configure with CMake
cmake -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_SHARED_LIBS=OFF

if [ $? -ne 0 ]; then
    echo "❌ CMake configuration failed!"
    exit 1
fi

echo ""
echo "Building SDL3 and SDL3_ttf..."
echo ""

# Build
cmake --build "$BUILD_DIR" --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "✅ SDL3 and SDL3_ttf built successfully!"

# Install if requested
if [ "$INSTALL" = true ]; then
    echo ""
    echo "Installing to vendor/SDL3..."
    cmake --install "$BUILD_DIR"
    
    if [ $? -eq 0 ]; then
        echo "✅ Installation complete!"
        echo ""
        echo "SDL3 libraries and headers installed to:"
        echo "  vendor/SDL3/lib/"
        echo "  vendor/SDL3/include/"
    else
        echo "❌ Installation failed!"
        exit 1
    fi
fi

echo ""
echo "Build artifacts are in: $BUILD_DIR/"
echo ""
echo "Next steps:"
echo "  1. Run with --install to install libraries to vendor/SDL3"
echo "  2. Use ./build.sh to compile Nim code with these libraries"
