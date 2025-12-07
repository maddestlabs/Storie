# SDL_GPU + WebAssembly Support

## Current Status: ⚠️ Limited WebGPU Support

### What Works Today

**OpenGL for WASM** (Current solution)
```bash
# Build SDL3 + OpenGL for WASM (works now)
./build-web-sdl.sh
```

This uses **WebGL** (OpenGL ES via Emscripten), which works in all modern browsers.

### SDL_GPU + WebAssembly: The Reality

**Short Answer:** SDL_GPU's WebGPU backend is **not yet available** in SDL3 (as of December 2025).

**Current SDL_GPU Backends:**
- ✅ Vulkan (desktop Linux/Windows/Android)
- ✅ Direct3D 12 (Windows/Xbox)
- ✅ Metal (macOS/iOS)
- ❌ **WebGPU** (not yet implemented in SDL3)

### Why WebGPU Matters

WebGPU is the modern web graphics API (successor to WebGL):
- Modern shader language (WGSL)
- Better performance than WebGL
- Access to compute shaders
- Similar to Vulkan/D3D12/Metal

**Browser Support (2025):**
- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support  
- Safari: ⚠️ Partial support

## Your Options for WASM Today

### Option 1: Use OpenGL/WebGL (Recommended Now) ✅

```bash
# Build with SDL3 + OpenGL for WASM
./build-web-sdl.sh
```

**Pros:**
- Works in ALL browsers
- Available now
- Good performance
- Well-tested

**Cons:**
- Older API
- No compute shaders
- Less efficient than WebGPU

### Option 2: Use Raylib for WASM ✅

```bash
# Build with Raylib for WASM (simplest)
./build-web.sh
```

**Pros:**
- Easiest to build
- Works everywhere
- Smaller WASM size

**Cons:**
- Less control than SDL3

### Option 3: Wait for SDL_GPU WebGPU Backend ⏳

SDL_GPU **will likely add WebGPU** in a future release, but it's not ready yet.

**Timeline:** Unknown (probably 2026+)

## Workaround: Use WebGPU Directly (Advanced)

If you need WebGPU now, you can:

1. **Use Emscripten's WebGPU bindings** directly
2. **Use wgpu-native** (Rust-based, has C API)
3. **Wait for SDL_GPU WebGPU backend**

### Example: Emscripten WebGPU

```nim
# For advanced users only
when defined(emscripten):
  {.passL: "-sUSE_WEBGPU=1".}
  
  type WGPUDevice {.importc.} = pointer
  
  proc emscripten_webgpu_get_device(): WGPUDevice 
    {.importc, header: "emscripten/html5_webgpu.h".}
```

This is **complex** and requires significant work.

## Recommendation

### For Production WASM Today:

**Use SDL3 + OpenGL/WebGL:**

```bash
# Native builds: Use SDL_GPU for performance
nim c -d:sdl3 -d:sdlgpu index.nim

# WASM builds: Use OpenGL/WebGL (best compatibility)
./build-web-sdl.sh
```

**Build Matrix:**

| Platform | Backend | Command |
|----------|---------|---------|
| Linux/Windows | SDL_GPU (Vulkan/D3D12) | `nim c -d:sdl3 -d:sdlgpu` |
| macOS/iOS | SDL_GPU (Metal) | `nim c -d:sdl3 -d:sdlgpu` |
| **WASM** | **OpenGL/WebGL** | `./build-web-sdl.sh` |

### Future (When SDL_GPU WebGPU is Ready):

```bash
# Native: SDL_GPU (Vulkan/D3D12/Metal)
nim c -d:sdl3 -d:sdlgpu index.nim

# WASM: SDL_GPU (WebGPU)
./build-web-sdlgpu.sh  # Will work when SDL3 adds WebGPU backend
```

## How to Track SDL_GPU WebGPU Progress

Watch these resources:

1. **SDL3 Repository:**
   - https://github.com/libsdl-org/SDL
   - Watch for "WebGPU" or "wgpu" in commits

2. **SDL_GPU Documentation:**
   - https://wiki.libsdl.org/SDL3/CategoryGPU
   - Check "System Requirements" section

3. **Emscripten + SDL3:**
   - https://github.com/emscripten-ports/SDL3

## Summary

### ✅ What Works Now (WASM)

```
Storie → SDL3 → OpenGL → WebGL → Browser
```

Build: `./build-web-sdl.sh`

### ⏳ What's Coming (Future)

```
Storie → SDL3 → SDL_GPU → WebGPU → Browser
```

Build: *Not yet available*

### 🎯 Best Practice Today

**For native builds:** Use SDL_GPU (best performance)
```bash
nim c -d:sdl3 -d:sdlgpu index.nim
```

**For WASM builds:** Use OpenGL/WebGL (best compatibility)
```bash
./build-web-sdl.sh
```

**Code stays the same!** The `Renderer3D` interface abstracts everything.

## Creating a WASM Build Script (OpenGL)

I'll create a script that builds SDL3 + OpenGL for WASM, which is the current recommended approach:

```bash
# Coming next: build-web-sdl3.sh
# This will build SDL3 + OpenGL for WASM (not SDL_GPU yet)
```

---

## Technical Details: Why WebGPU Isn't Ready Yet

### SDL_GPU Architecture

SDL_GPU is a **thin abstraction** over native APIs:
- Vulkan: SPIR-V shaders
- D3D12: DXIL shaders
- Metal: MSL shaders
- WebGPU: WGSL shaders (different!)

WebGPU requires:
1. Different shader compilation pipeline
2. Different memory model
3. Different synchronization primitives
4. Browser security constraints

This is why it takes time to implement properly.

### Interim Solution: sokol_gfx

If you need WebGPU now, consider **sokol_gfx**:
- Has WebGPU backend today
- Smaller API surface
- Good Emscripten support

But it requires more manual setup than SDL_GPU.

---

## Conclusion

**Can SDL_GPU be used in WASM?**

- **Today:** No, SDL_GPU doesn't have a WebGPU backend yet
- **For WASM:** Use SDL3 + OpenGL/WebGL (works great)
- **For native:** Use SDL_GPU (Vulkan/D3D12/Metal)
- **Future:** SDL_GPU will likely add WebGPU support

**Your best approach:**
1. Native: SDL_GPU (`-d:sdlgpu`)
2. WASM: OpenGL/WebGL (`./build-web-sdl.sh`)
3. Same code, different backends!

The abstraction layer makes this seamless - your application code doesn't change.
