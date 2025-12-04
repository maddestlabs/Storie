# 3D Backend Integration Guide

## Overview

Storie now has an abstracted 3D rendering interface that allows multiple backend implementations. The SDL3+OpenGL backend is complete, and the raylib backend is ready for integration.

## Architecture

```
User Code (Nimini DSL)
    ↓
3D API Functions (drawCube, drawSphere, etc.)
    ↓
render3d_interface.nim (Abstract types: Vec3, Mat4, Camera3D, Renderer3D)
    ↓
    ├── sdl_render3d.nim (OpenGL implementation) ✅ COMPLETE
    └── raylib_render3d.nim (Raylib implementation) ⏳ TODO
```

## Completed Changes

### ✅ Created Backend-Agnostic Interface
- **`platform/render3d_interface.nim`**: Common types and math operations
  - `Vec3`, `Vec4`, `Mat4` - Math types used by all backends
  - `Camera3D` - Universal camera representation
  - `Renderer3D` - Abstract base class for backends
  - `MeshData` - Platform-independent mesh data
  - Primitive builders: `createCubeMeshData()`, `createSphereMeshData()`

### ✅ Refactored SDL3 Backend
- **`platform/sdl/sdl_render3d.nim`**: OpenGL-specific implementation
  - `SdlRenderer3D` - Implements `Renderer3D` interface
  - All OpenGL code moved here (shaders, VAO/VBO, etc.)
  - Maintains existing functionality with cleaner separation

### ✅ Updated Main Engine
- **`storie.nim`**: Now uses abstracted interface
  - Uses `SdlRenderer3D` instead of direct OpenGL
  - All 3D globals managed through renderer
  - Prepared for runtime backend selection

### ✅ Created Raylib Stubs
- **`platform/raylib/raylib_render3d.nim`**: Ready for implementation
- **`platform/raylib/raylib_platform.nim`**: Ready for implementation

## Next Steps: Raylib Integration

### 1. Add Raylib Bindings

**Option A**: Use existing nim-raylib package
```bash
nimble install raylib
```

**Option B**: Create minimal bindings (recommended for control)
Create `platform/raylib/raylib_bindings.nim`:

```nim
when defined(emscripten):
  {.passL: "-lraylib".}
else:
  when defined(windows):
    {.passL: "-lraylib -lopengl32 -lgdi32 -lwinmm".}
  elif defined(macosx):
    {.passL: "-lraylib -framework OpenGL -framework Cocoa -framework IOKit".}
  else:
    {.passL: "-lraylib -lGL -lm -lpthread -ldl -lrt".}

type
  Vector3* {.importc: "Vector3", header: "raylib.h".} = object
    x*, y*, z*: float32
  
  Color* {.importc: "Color", header: "raylib.h".} = object
    r*, g*, b*, a*: uint8
  
  Camera3D* {.importc: "Camera3D", header: "raylib.h".} = object
    position*: Vector3
    target*: Vector3
    up*: Vector3
    fovy*: float32
    projection*: int32
  
  Mesh* {.importc: "Mesh", header: "raylib.h".} = object
    vertexCount*: int32
    triangleCount*: int32
    vertices*: ptr float32
    indices*: ptr uint16
    # ... more fields

# Window management
proc InitWindow*(width, height: int32, title: cstring) {.importc: "InitWindow", header: "raylib.h".}
proc CloseWindow*() {.importc: "CloseWindow", header: "raylib.h".}
proc WindowShouldClose*(): bool {.importc: "WindowShouldClose", header: "raylib.h".}
proc SetTargetFPS*(fps: int32) {.importc: "SetTargetFPS", header: "raylib.h".}

# Drawing
proc BeginDrawing*() {.importc: "BeginDrawing", header: "raylib.h".}
proc EndDrawing*() {.importc: "EndDrawing", header: "raylib.h".}
proc ClearBackground*(color: Color) {.importc: "ClearBackground", header: "raylib.h".}

# 3D mode
proc BeginMode3D*(camera: Camera3D) {.importc: "BeginMode3D", header: "raylib.h".}
proc EndMode3D*() {.importc: "EndMode3D", header: "raylib.h".}

# 3D shapes
proc DrawCube*(position: Vector3, width, height, length: float32, color: Color) {.importc: "DrawCube", header: "raylib.h".}
proc DrawSphere*(position: Vector3, radius: float32, color: Color) {.importc: "DrawSphere", header: "raylib.h".}
proc DrawMesh*(mesh: Mesh, material: Material, transform: Matrix) {.importc: "DrawMesh", header: "raylib.h".}

# Input
proc IsKeyPressed*(key: int32): bool {.importc: "IsKeyPressed", header: "raylib.h".}
proc IsMouseButtonPressed*(button: int32): bool {.importc: "IsMouseButtonPressed", header: "raylib.h".}

# More functions as needed...
```

### 2. Implement RaylibRenderer3D

Update `platform/raylib/raylib_render3d.nim`:

```nim
import ../render3d_interface
import raylib_bindings

type
  RaylibRenderer3D* = ref object of Renderer3D
    currentCamera*: raylib_bindings.Camera3D
    inFrame: bool

proc toRaylibVec3(v: Vec3): Vector3 =
  Vector3(x: v.x, y: v.y, z: v.z)

proc toRaylibColor(v: Vec3): Color =
  Color(
    r: uint8(v.x * 255.0),
    g: uint8(v.y * 255.0),
    b: uint8(v.z * 255.0),
    a: 255
  )

proc newRaylibRenderer3D*(): RaylibRenderer3D =
  result = RaylibRenderer3D()
  result.inFrame = false

method init3D*(r: RaylibRenderer3D): bool =
  echo "Raylib 3D renderer initialized"
  return true

method beginFrame3D*(r: RaylibRenderer3D, clearR, clearG, clearB: float32) =
  let color = Color(
    r: uint8(clearR * 255.0),
    g: uint8(clearG * 255.0),
    b: uint8(clearB * 255.0),
    a: 255
  )
  ClearBackground(color)
  BeginMode3D(r.currentCamera)
  r.inFrame = true

method endFrame3D*(r: RaylibRenderer3D) =
  if r.inFrame:
    EndMode3D()
    r.inFrame = false

method setCamera*(r: RaylibRenderer3D, cam: Camera3D, aspect: float32) =
  r.currentCamera.position = toRaylibVec3(cam.position)
  r.currentCamera.target = toRaylibVec3(cam.target)
  r.currentCamera.up = toRaylibVec3(cam.up)
  r.currentCamera.fovy = cam.fov
  r.currentCamera.projection = 0  # CAMERA_PERSPECTIVE

method drawMesh*(r: RaylibRenderer3D, meshData: MeshData) =
  # Create temporary raylib mesh
  var mesh: Mesh
  mesh.vertexCount = (meshData.vertices.len div 6).int32
  mesh.triangleCount = (meshData.indices.len div 3).int32
  
  # Allocate and copy data
  # ... implement mesh creation from MeshData
  
  # Draw with default material
  # DrawMesh(mesh, defaultMaterial, identityMatrix)
  
  # Clean up temporary data
```

### 3. Implement RaylibPlatform

Update `platform/raylib/raylib_platform.nim`:

```nim
import ../platform_interface
import ../pixel_types
import raylib_bindings

proc init*(p: RaylibPlatform, enable3D: bool = false): bool =
  InitWindow(1024, 768, "Storie Raylib")
  SetTargetFPS(60)
  p.running = true
  return true

proc pollEvents*(p: RaylibPlatform): seq[InputEvent] =
  if WindowShouldClose():
    p.running = false
  
  # Map raylib input to InputEvent
  # ... implement key/mouse handling

proc display*(p: RaylibPlatform, renderBuffer: RenderBuffer) =
  BeginDrawing()
  
  # Execute render commands with raylib functions
  for cmd in renderBuffer.commands:
    case cmd.kind
    of FillRect:
      # Use raylib's DrawRectangle
      discard
    of DrawCircle:
      # Use raylib's DrawCircle
      discard
    # ... etc
  
  EndDrawing()
```

### 4. Update Build System

**For Native Builds:**
Add to `build.sh`:
```bash
# SDL3 build (default)
nim c -r storie.nim

# Raylib build
nim c -d:raylib -r storie.nim
```

**For WASM Builds:**
Create `build-raylib-web.sh`:
```bash
#!/bin/bash
# Build Storie with raylib backend for web

nim c -d:emscripten -d:raylib \
  --os:linux \
  --cpu:wasm32 \
  --cc:clang \
  --clang.exe:emcc \
  --clang.linkerexe:emcc \
  --passL:"-s USE_GLFW=3" \
  --passL:"-s EXPORTED_FUNCTIONS=['_main']" \
  --passL:"-s EXPORTED_RUNTIME_METHODS=['ccall','cwrap']" \
  --passL:"-s ALLOW_MEMORY_GROWTH=1" \
  --passL:"-lraylib" \
  -o:docs/storie-raylib.js \
  storie.nim
```

### 5. Update storie.nim for Backend Selection

Add compile-time backend selection:

```nim
# Platform backend selection
when defined(raylib):
  import platform/raylib/raylib_platform
  import platform/raylib/raylib_render3d
  type PlatformImpl = RaylibPlatform
  type Renderer3DImpl = RaylibRenderer3D
else:
  import platform/sdl/sdl_platform
  import platform/sdl/sdl_render3d
  type PlatformImpl = SdlPlatform
  type Renderer3DImpl = SdlRenderer3D

# Then in initApp:
proc initApp(enable3D: bool = false) =
  when defined(raylib):
    echo "Initializing Storie with Raylib backend..."
  else:
    echo "Initializing Storie with SDL3 backend..."
  
  appState.platform = PlatformImpl()
  # ... rest of init
```

## Testing Plan

### Phase 1: Raylib 2D
1. Get raylib window opening
2. Implement basic 2D drawing (fillRect, drawCircle)
3. Test with existing 2D examples

### Phase 2: Raylib 3D
1. Implement camera setup
2. Test drawCube() and drawSphere()
3. Verify matrix transformations work
4. Test with existing 3D examples

### Phase 3: Feature Parity
1. Text rendering
2. Input handling
3. All primitive shapes
4. Performance testing

### Phase 4: WASM Optimization
1. Build both SDL3 and raylib WASM binaries
2. Compare sizes (expecting raylib ~50% smaller)
3. Add URL parameter: `?backend=raylib`
4. Update loader HTML to support both

## Expected Benefits

### Size Comparison (Estimated)
- SDL3 WASM: ~1.5 MB
- Raylib WASM: ~750 KB (50% reduction)

### Performance
- Raylib: Better for simple 3D, faster load times
- SDL3: Better for complex rendering, more features

### Use Cases
- **Raylib**: Quick demos, tutorials, gists, mobile-friendly
- **SDL3**: Production apps, advanced graphics, desktop deployment

## Implementation Checklist

- [x] Create render3d_interface.nim
- [x] Refactor SDL3 backend to use interface
- [x] Create raylib stub files
- [x] Update storie.nim to use abstraction
- [ ] Add raylib bindings
- [ ] Implement RaylibRenderer3D methods
- [ ] Implement RaylibPlatform methods
- [ ] Create raylib build scripts
- [ ] Test 2D rendering with raylib
- [ ] Test 3D rendering with raylib
- [ ] Build WASM with both backends
- [ ] Update HTML loader for backend selection
- [ ] Documentation and examples

## Notes

- The math types (Vec3, Mat4) are shared between backends
- Each backend translates these to its native types
- MeshData is the common currency for geometry
- Backends can implement convenience functions beyond the interface
- SDL backend keeps OpenGL shader support for advanced users
- Raylib backend uses high-level functions for simplicity
