# Quick Start: Adding Raylib Backend

## TL;DR
The 3D code is now backend-agnostic. Adding raylib support requires implementing 4 key methods and adding bindings.

## 5-Step Implementation

### Step 1: Add Raylib Bindings (30 min)
Create `platform/raylib/raylib_bindings.nim`:

```nim
# Minimal bindings needed
{.passL: "-lraylib".}

type
  Vector3 {.importc, header: "raylib.h".} = object
    x, y, z: float32
  
  Color {.importc, header: "raylib.h".} = object
    r, g, b, a: uint8
  
  Camera3D {.importc, header: "raylib.h".} = object
    position, target, up: Vector3
    fovy: float32
    projection: int32

proc InitWindow(w, h: int32, title: cstring) {.importc, header: "raylib.h".}
proc CloseWindow() {.importc, header: "raylib.h".}
proc BeginDrawing() {.importc, header: "raylib.h".}
proc EndDrawing() {.importc, header: "raylib.h".}
proc BeginMode3D(cam: Camera3D) {.importc, header: "raylib.h".}
proc EndMode3D() {.importc, header: "raylib.h".}
proc ClearBackground(color: Color) {.importc, header: "raylib.h".}
proc DrawCube(pos: Vector3, w, h, l: float32, color: Color) {.importc, header: "raylib.h".}
proc DrawSphere(pos: Vector3, radius: float32, color: Color) {.importc, header: "raylib.h".}
```

### Step 2: Implement RaylibRenderer3D (1 hour)
Edit `platform/raylib/raylib_render3d.nim`:

```nim
import ../render3d_interface
import raylib_bindings

type
  RaylibRenderer3D* = ref object of Renderer3D
    camera: raylib_bindings.Camera3D
    modelPos: Vector3  # raylib uses position for transforms

proc toRlVec3(v: Vec3): Vector3 = Vector3(x: v.x, y: v.y, z: v.z)
proc toRlColor(v: Vec3): Color = 
  Color(r: uint8(v.x*255), g: uint8(v.y*255), b: uint8(v.z*255), a: 255)

method beginFrame3D*(r: RaylibRenderer3D, cr, cg, cb: float32) =
  ClearBackground(Color(r: uint8(cr*255), g: uint8(cg*255), b: uint8(cb*255), a: 255))
  BeginMode3D(r.camera)

method endFrame3D*(r: RaylibRenderer3D) =
  EndMode3D()

method setCamera*(r: RaylibRenderer3D, cam: Camera3D, aspect: float32) =
  r.camera.position = toRlVec3(cam.position)
  r.camera.target = toRlVec3(cam.target)
  r.camera.up = toRlVec3(cam.up)
  r.camera.fovy = cam.fov
  r.camera.projection = 0  # CAMERA_PERSPECTIVE

method setModelTransform*(r: RaylibRenderer3D, mat: Mat4) =
  # Extract position from matrix (simplified - just translation)
  r.modelPos = Vector3(x: mat[12], y: mat[13], z: mat[14])

method drawMesh*(r: RaylibRenderer3D, meshData: MeshData) =
  # For primitives, use built-in functions
  # For custom meshes, need to create raylib Mesh structure
  # TODO: Implement based on your needs
```

### Step 3: Implement RaylibPlatform (2 hours)
Edit `platform/raylib/raylib_platform.nim`:

```nim
import ../platform_interface, ../pixel_types
import raylib_bindings

proc init*(p: RaylibPlatform, enable3D: bool = false): bool =
  InitWindow(1024, 768, "Storie Raylib")
  SetTargetFPS(60)
  p.running = true
  true

proc pollEvents*(p: RaylibPlatform): seq[InputEvent] =
  if WindowShouldClose():
    p.running = false
  # Map raylib input...

proc display*(p: RaylibPlatform, buf: RenderBuffer) =
  BeginDrawing()
  for cmd in buf.commands:
    case cmd.kind
    of FillRect: DrawRectangle(...)
    of DrawCircle: DrawCircle(...)
    # etc...
  EndDrawing()
```

### Step 4: Update Build (15 min)
Create `build-raylib.sh`:

```bash
#!/bin/bash
nim c -d:raylib -r storie.nim
```

For WASM:
```bash
#!/bin/bash
nim c -d:emscripten -d:raylib \
  --os:linux --cpu:wasm32 --cc:clang \
  --clang.exe:emcc --clang.linkerexe:emcc \
  --passL:"-lraylib" \
  -o:docs/storie-raylib.js \
  storie.nim
```

### Step 5: Test (30 min)
```bash
# Native test
./build-raylib.sh --3d examples/simple_cube.md

# WASM test
./build-raylib-web.sh
# Open docs/index.html?backend=raylib
```

## Files You Need to Edit

1. `platform/raylib/raylib_bindings.nim` - CREATE
2. `platform/raylib/raylib_render3d.nim` - IMPLEMENT (~100 lines)
3. `platform/raylib/raylib_platform.nim` - IMPLEMENT (~200 lines)
4. `build-raylib.sh` - CREATE
5. `build-raylib-web.sh` - CREATE

## What's Already Done ✅

- ✅ Abstract interface defined
- ✅ SDL3 backend working (use as reference)
- ✅ Math types (Vec3, Mat4, Camera3D)
- ✅ Mesh data structures
- ✅ storie.nim uses interface
- ✅ All examples work with SDL3

## Testing Checklist

### 2D Tests
- [ ] `examples/bounce.md` renders
- [ ] `examples/stars.md` renders
- [ ] Text rendering works
- [ ] Input handling works

### 3D Tests
- [ ] `examples/simple_cube.md` renders
- [ ] `examples/3d_demo.md` renders
- [ ] Camera movement works
- [ ] Transformations work
- [ ] Multiple objects render

### WASM Tests
- [ ] Builds successfully
- [ ] Binary size < 1MB
- [ ] Loads in browser
- [ ] All examples work
- [ ] URL param ?backend=raylib works

## Expected Results

**Binary Sizes:**
- SDL3: ~1.5 MB
- Raylib: ~750 KB (50% smaller!)

**Performance:**
- Raylib: Faster startup
- SDL3: Better for complex scenes

## Need Help?

See full documentation:
- `docs/3D_BACKEND_INTEGRATION.md` - Detailed guide
- `docs/3D_REFACTORING_SUMMARY.md` - What was changed
- `platform/sdl/sdl_render3d.nim` - Reference implementation

## Estimated Time

- **Minimal (cube/sphere only)**: 2-3 hours
- **Full 2D + 3D support**: 4-6 hours
- **Production ready**: 8-12 hours

Good luck! The hard part (abstraction) is done. Now it's just mapping raylib functions. 🚀
