# Graphics Abstraction Layer (GAL) Design

## Overview

GAL provides a **unified high-level graphics API** that automatically compiles to the best backend for each platform:

- **Web (WASM)**: OpenGL ES 3.0 / WebGL 2.0
- **Native Desktop**: SDL_GPU → Vulkan / Direct3D 12 / Metal
- **Legacy Native**: OpenGL 3.3+

## Why Not Full OpenGL Translation?

### Problems with Direct Translation:
1. **Architectural Mismatch**
   - OpenGL: Immediate mode, global state machine
   - SDL_GPU: Command buffers, explicit pipelines
   - WebGPU: Similar to SDL_GPU
   
2. **State Management**
   - OpenGL: `glEnable(GL_DEPTH_TEST)` sets global state
   - SDL_GPU: Depth test configured in pipeline creation
   - Translation requires capturing all state before drawing

3. **Shader Compilation**
   - OpenGL: Runtime compilation from GLSL strings
   - SDL_GPU: Requires precompiled SPIR-V/DXIL/MSL
   - Cannot translate `glShaderSource()` at runtime

4. **API Surface**
   - OpenGL: 300+ functions
   - Manual translation layer = thousands of lines, hard to maintain

### GAL Solution:
- **High-level abstraction** that both backends implement
- Write code once, compiles optimally for each platform
- Simpler API (50-100 functions vs 300+)
- Better performance (no translation overhead)

## Architecture

```
User Code (Nimini scripts)
         ↓
    GAL API Layer
         ↓
   ┌──────┴──────┐
   ↓             ↓
OpenGL      SDL_GPU
(Web)      (Native)
```

### Compile-Time Backend Selection:

```nim
when defined(emscripten):
  # Force OpenGL for web
  galBackend = OpenGL
elif defined(sdlgpu):
  # Use SDL_GPU for native
  galBackend = SDLGPU
else:
  # Default to OpenGL
  galBackend = OpenGL
```

## API Design Principles

### 1. Abstract Resources
```nim
type
  GalDevice* = ref object  # Abstract graphics device
  GalBuffer* = ref object  # Vertex/index/uniform buffer
  GalShader* = ref object  # Shader program
  GalPipeline* = ref object  # Pipeline state
  GalTexture* = ref object  # Texture
```

Backend-specific data is stored internally using `when defined()`.

### 2. Explicit Resource Management
```nim
let device = galCreateDevice()
let buffer = galCreateBuffer(device, size, BufferVertex)
galUploadBuffer(device, buffer, data, dataSize)
# ... use buffer ...
galDestroyBuffer(device, buffer)
galDestroyDevice(device)
```

### 3. Simplified State Management
```nim
# Instead of glEnable/glDisable for many states:
galEnableDepthTest(true)
galEnableCulling(true)
galEnableBlending(true)
```

### 4. Batched Drawing
```nim
# Instead of immediate mode glBegin/glEnd:
galDrawIndexed(indexCount)
galDrawInstanced(indexCount, instanceCount)
```

## Feature Coverage

### Current Implementation:
✅ Device management (create/destroy)
✅ Buffer management (vertex/index/uniform)
✅ Buffer uploads
✅ Basic rendering state (depth, culling)
✅ Clear operations
✅ Viewport management
✅ Indexed drawing

### TODO:
- [ ] Shader compilation/loading
- [ ] Pipeline creation (shaders + render state)
- [ ] Texture creation/sampling
- [ ] Uniform buffer binding
- [ ] Render targets/framebuffers
- [ ] Advanced blending modes
- [ ] Compute shaders

## Usage Examples

### Simple Cube Rendering:

```nim
import platform/gal

# Create device
let device = galCreateDevice()

# Create buffers
let vbo = galCreateBuffer(device, vertices.len * sizeof(Vertex), BufferVertex)
let ibo = galCreateBuffer(device, indices.len * sizeof(uint16), BufferIndex)

galUploadBuffer(device, vbo, addr vertices[0], vertices.len * sizeof(Vertex))
galUploadBuffer(device, ibo, addr indices[0], indices.len * sizeof(uint16))

# Render loop
while running:
  galClear(0.1, 0.1, 0.15, 1.0)
  galEnableDepthTest(true)
  galSetViewport(0, 0, 800, 600)
  galDrawIndexed(indices.len)

# Cleanup
galDestroyBuffer(device, vbo)
galDestroyBuffer(device, ibo)
galDestroyDevice(device)
```

### Backend Comparison:

| Feature | OpenGL (Web) | SDL_GPU (Native) |
|---------|--------------|------------------|
| API | OpenGL ES 3.0 | Vulkan/D3D12/Metal |
| Shader Format | GLSL (runtime) | SPIR-V (precompiled) |
| State | Global | Pipeline objects |
| Command Model | Immediate | Command buffers |
| Performance | Good | Excellent |
| Validation | Weak | Strong |

## Integration with Storie

### Nimini Scripts Can Use GAL:

```markdown
# my_demo.md

## Spinning Cube

```nim
import gal

let device = galCreateDevice()
# ... create cube mesh ...

while true:
  rotation += dt
  galClear(0, 0, 0, 1)
  galDrawIndexed(36)  # Draw cube
```\`\`\`

### Automatic Backend Selection:

```bash
# Native build with SDL_GPU
nim c -d:sdl3 -d:sdlgpu my_demo.nim
# → Uses Vulkan/D3D12/Metal

# Web build
nim c -d:emscripten my_demo.nim
# → Uses WebGL

# Native fallback
nim c -d:sdl3 my_demo.nim
# → Uses OpenGL
```

## Performance Characteristics

### OpenGL Backend:
- **Overhead**: Minimal (direct OpenGL calls)
- **Driver Validation**: Per-call validation overhead
- **Multi-threading**: Limited

### SDL_GPU Backend:
- **Overhead**: Minimal (thin wrapper over native APIs)
- **Driver Validation**: Validation layers in debug, none in release
- **Multi-threading**: Command buffers support parallel recording

### Translation Layer (Avoided):
- **Overhead**: High (state tracking + conversion)
- **Complexity**: Very high (1000+ lines of state management)
- **Maintenance**: Difficult (OpenGL spec changes)

## Implementation Status

- **Core**: 80% complete
- **Rendering**: 40% complete (basic draw calls work)
- **Shaders**: 0% (needs design for dual compilation)
- **Textures**: 0%
- **Documentation**: 60%

## Next Steps

1. **Shader System**: Design dual-path shader compilation
   - GLSL → GLSL for OpenGL
   - GLSL → SPIR-V → MSL/DXIL for SDL_GPU

2. **Pipeline Creation**: Complete pipeline abstraction
   ```nim
   let pipeline = galCreatePipeline(device, shaders, renderState)
   galBindPipeline(pipeline)
   ```

3. **Texture Support**: Complete texture operations
   ```nim
   let tex = galCreateTexture(device, width, height, format)
   galUploadTexture(tex, pixels)
   ```

4. **Integration**: Update existing renderers to use GAL
   - Refactor `sdl_render3d.nim` to use GAL
   - Add GAL examples to docs

## Conclusion

GAL provides the best of both worlds:
- ✅ **Write once**: Single codebase for all platforms
- ✅ **Optimal performance**: Native APIs on each platform
- ✅ **Simple API**: Easier than raw OpenGL/Vulkan
- ✅ **Web compatible**: Works in browser via WebGL
- ✅ **Future-proof**: Easy to add new backends (WebGPU, etc.)

The key insight: **Don't translate OpenGL → SDL_GPU at runtime**. Instead, provide a **higher-level API that both implement efficiently**.
