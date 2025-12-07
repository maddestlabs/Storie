#!/bin/bash
# Build Storie with SDL3 + SDL_GPU backend
# This uses modern graphics APIs: Vulkan (Linux), D3D12 (Windows), Metal (macOS)

set -e

# Auto-detect repository/project name
# Priority: 1) PROJECT_NAME env var, 2) .project-name file, 3) git remote, 4) directory name
if [ -n "$PROJECT_NAME" ]; then
    REPO_NAME="$PROJECT_NAME"
elif [ -f ".project-name" ]; then
    REPO_NAME=$(cat .project-name | tr '[:upper:]' '[:lower:]')
elif git rev-parse --git-dir > /dev/null 2>&1; then
    # Try to get name from git remote URL
    REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
    if [ -n "$REMOTE_URL" ]; then
        REPO_NAME=$(basename -s .git "$REMOTE_URL" | tr '[:upper:]' '[:lower:]')
    else
        # Fallback to git repo directory name
        REPO_NAME=$(basename "$(git rev-parse --show-toplevel)" | tr '[:upper:]' '[:lower:]')
    fi
else
    # Final fallback to current directory name
    REPO_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')
fi

echo "========================================"
echo "${REPO_NAME^} Build (SDL3 + SDL_GPU)"
echo "========================================"
echo ""

# Parse arguments
RELEASE_FLAG=""
RUN=false
if [[ "$1" == "--release" ]] || [[ "$1" == "-r" ]]; then
    RELEASE_FLAG="-d:release"
    echo "Build type: Release"
    if [[ "$2" == "--run" ]]; then
        RUN=true
    fi
elif [[ "$1" == "--run" ]]; then
    RUN=true
    echo "Build type: Debug"
else
    echo "Build type: Debug"
fi

echo "Backend: SDL3 + SDL_GPU (Vulkan/D3D12/Metal)"
echo ""

# Check for compiled shaders
if [ ! -f "shaders/compiled/vertex.spv" ]; then
    echo "⚠️  Warning: Compiled shaders not found!"
    echo "Run ./compile-shaders.sh first to compile GLSL to SPIR-V"
    echo "The build will continue but 3D rendering may not work."
    echo ""
fi

echo "Compiling..."
echo ""

# Compile with SDL3 + SDL_GPU backend
nim c $RELEASE_FLAG \
    -d:sdl3 \
    -d:sdlgpu \
    --out:${REPO_NAME}-sdlgpu \
    index.nim

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build successful!"
    echo "========================================"
    echo ""
    echo "Binary: ./${REPO_NAME}-sdlgpu"
    echo "Backend: SDL3 + SDL_GPU"
    echo "Graphics: Vulkan/D3D12/Metal (auto-detected)"
    echo ""
    
    if [ "$RUN" = true ]; then
        echo "Running..."
        ./${REPO_NAME}-sdlgpu
    else
        echo "Run with: ./${REPO_NAME}-sdlgpu"
    fi
    echo ""
else
    echo ""
    echo "========================================"
    echo "Build failed!"
    echo "========================================"
    echo ""
    exit 1
fi
