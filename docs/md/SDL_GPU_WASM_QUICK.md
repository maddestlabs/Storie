# Quick Answer: SDL_GPU + WASM

## Can SDL_GPU be used in WASM?

**Short Answer:** Not yet. SDL_GPU doesn't have a WebGPU backend as of December 2025.

## What Works for WASM Today

### ✅ Option 1: SDL3 + OpenGL/WebGL (Recommended)

```bash
./build-web-sdl.sh
```

- Works in ALL browsers
- Good performance
- Available now

### ✅ Option 2: Raylib + WebGL

```bash
./build-web.sh
```

- Simplest option
- Smaller WASM size
- Great for prototyping

## Recommended Build Strategy

### Native Builds (Best Performance)

```bash
# Use SDL_GPU for native platforms
nim c -d:sdl3 -d:sdlgpu index.nim
```

**Backends:**
- Linux/Windows → Vulkan or D3D12
- macOS/iOS → Metal
- 27% better CPU performance

### WASM Builds (Best Compatibility)

```bash
# Use OpenGL/WebGL for web
./build-web-sdl.sh
```

**Backend:**
- All browsers → WebGL (via OpenGL ES)
- Works everywhere today

## Platform Matrix

| Platform | Recommended Backend | Build Command |
|----------|-------------------|---------------|
| Linux | SDL_GPU (Vulkan) | `nim c -d:sdl3 -d:sdlgpu` |
| Windows | SDL_GPU (D3D12) | `nim c -d:sdl3 -d:sdlgpu` |
| macOS/iOS | SDL_GPU (Metal) | `nim c -d:sdl3 -d:sdlgpu` |
| **WASM** | **OpenGL/WebGL** | `./build-web-sdl.sh` |

## Why Not WebGPU Yet?

SDL_GPU currently supports:
- ✅ Vulkan (desktop/Android)
- ✅ Direct3D 12 (Windows/Xbox)
- ✅ Metal (Apple platforms)
- ❌ WebGPU (not implemented yet)

**WebGPU is coming** but no ETA from SDL team yet.

## Your Code Doesn't Change!

The beauty of the `Renderer3D` abstraction:

```nim
# Same code works with ALL backends
import storie

let cube = createCubeMeshData(2.0, vec3(1, 0, 0))
renderer.drawMesh(cube)
```

Build with different flags, same code:
- Native: `-d:sdl3 -d:sdlgpu` → Uses Vulkan/D3D12/Metal
- WASM: (build-web-sdl.sh) → Uses WebGL

## Future: When WebGPU is Ready

```bash
# This will work eventually (not yet)
./build-web-sdlgpu.sh  # SDL_GPU + WebGPU
```

Timeline: Unknown (likely 2026+)

## Summary

✅ **Native:** Use SDL_GPU (`-d:sdlgpu`) for best performance  
✅ **WASM:** Use OpenGL/WebGL (`./build-web-sdl.sh`) for compatibility  
⏳ **Future:** SDL_GPU WebGPU backend coming eventually  

**Your code works with both** - the abstraction handles everything!

---

See `SDL_GPU_WASM_STATUS.md` for detailed technical information.
