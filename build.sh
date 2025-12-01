#!/bin/bash
# Storie native build script - SDL3 backend

VERSION="0.1.0"

show_help() {
    cat << EOF
storie v$VERSION
SDL3-based engine with markdown content (index.md)

Usage: ./build.sh [OPTIONS]

Options:
  -h, --help            Show this help message
  -v, --version         Show version information
  -r, --release         Compile in release mode (optimized)
  -c, --compile-only    Compile without running

Examples:
  ./build.sh                           # Compile and run
  ./build.sh -r                        # Compile optimized and run
  ./build.sh -c                        # Compile only, don't run

Note: Content is loaded from index.md at runtime.

EOF
}

RELEASE_MODE=""
COMPILE_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "storie version $VERSION"
            exit 0
            ;;
        -r|--release)
            RELEASE_MODE="-d:release"
            shift
            ;;
        -c|--compile-only)
            COMPILE_ONLY=true
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

# Check for index.md
if [ ! -f "index.md" ]; then
    echo "Warning: index.md not found. Create it with Nim code blocks."
fi

# Compile
echo "Compiling Storie (SDL3 native)..."
nim c $RELEASE_MODE storie.nim

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Run if not compile-only
if [ "$COMPILE_ONLY" = false ]; then
    echo "Running storie..."
    echo ""
    ./storie "$@"
else
    echo "Compilation successful!"
    echo "Run with: ./storie"
fi
