# Using Raylib Directly (No Wrapper Package)

## Overview

Storie now uses **direct C bindings** to raylib, just like it does with SDL3. This avoids the limitations of Nim wrapper packages like naylib and gives you full control over the API.

## Why Direct Bindings?

### Problems with Wrapper Packages (like naylib)
- **Outdated**: Often lag behind the C library
- **Incomplete**: Missing functions or types
- **Overhead**: Extra abstraction layers
- **Breaking changes**: Wrapper API changes break your code
- **Limited control**: Can't customize bindings

### Benefits of Direct Bindings
- ✅ **Always current**: Use latest raylib features immediately
- ✅ **Complete API**: Access every raylib function
- ✅ **Zero overhead**: Direct C calls, no wrappers
- ✅ **Stable**: C API is stable, no wrapper breakage
- ✅ **Customizable**: Add only what you need
- ✅ **Transparent**: Know exactly what's being called

## How It Works

### The Workflow (Same as SDL3)

```
Your Nim Code
    ↓
platform/raylib/raylib_bindings.nim
    ↓
{.importc.} pragma (Nim's C FFI)
    ↓
raylib.h (C header)
    ↓
libraylib.a (C library)
```

### Binding Structure

```
platform/raylib/
├── raylib_bindings.nim           # Main module (imports all)
└── raylib_bindings/
    ├── build_config.nim           # Compiler flags, linking
    ├── types.nim                  # Types (Vector3, Color, etc.)
    ├── core.nim                   # Window, timing
    ├── input.nim                  # Keyboard, mouse
    ├── shapes.nim                 # 2D drawing
    ├── text.nim                   # Text/font functions
    └── models.nim                 # 3D functions
```

## Adding Raylib Functions

Super simple! Just add the C binding:

### Example: Adding a New Function

**C API** (from raylib.h):
```c
void DrawRectangle(int posX, int posY, int width, int height, Color color);
```

**Nim Binding** (add to `shapes.nim`):
```nim
proc DrawRectangle*(posX, posY, width, height: cint, color: Color) {.
  importc: "DrawRectangle",
  header: "raylib.h"
.}
```

That's it! The function is now available.

### Adding Types

**C Type** (from raylib.h):
```c
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;
```

**Nim Binding** (add to `types.nim`):
```nim
type
  Vector3* {.importc, header: "raylib.h", bycopy.} = object
    x*, y*, z*: float32
```

Done!

## Build Configuration

### Native Builds

The `build_config.nim` handles linking automatically:

```nim
# Use vendored raylib
nim c -d:vendorRaylib -r your_app.nim

# Use system raylib
nim c -r your_app.nim
```

**Linux system install:**
```bash
# Install raylib
sudo apt install libraylib-dev

# Build
nim c -r storie.nim
```

**Vendored raylib** (recommended):
```bash
# Download raylib source
cd vendor
git clone https://github.com/raysan5/raylib.git raylib-src

# Build raylib
mkdir raylib
cd raylib-src
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../../raylib
make && make install

# Now Nim will find it automatically with -d:vendorRaylib
```

### Emscripten (WASM) Builds

The config handles WASM linking:

```bash
# Build raylib for WASM (do once)
cd vendor/raylib-src
mkdir build-wasm && cd build-wasm
emcmake cmake .. -DPLATFORM=Web
emmake make

# Build Storie with raylib for WASM
nim c -d:emscripten -d:raylib \
  --os:linux --cpu:wasm32 \
  --cc:clang --clang.exe:emcc \
  -o:docs/storie-raylib.js \
  storie.nim
```

## Comparison with SDL3 Bindings

Both use the exact same approach:

| Aspect | SDL3 | Raylib |
|--------|------|--------|
| Binding method | Direct C | Direct C |
| Header file | SDL3/SDL.h | raylib.h |
| Pragma | `{.importc.}` | `{.importc.}` |
| Types | Opaque pointers | Byvalue structs |
| Complexity | Multi-library | Single library |
| Size | ~1.5 MB | ~750 KB |

## Current Implementation Status

### ✅ Complete Bindings
- **Core**: Window, timing, drawing lifecycle
- **Input**: Keyboard, mouse
- **Shapes**: All 2D primitives
- **Text**: Font loading, text drawing
- **Models**: 3D shapes, meshes, materials

### ✅ Integrated Platform
- **raylib_platform.nim**: Full 2D rendering
- **raylib_render3d.nim**: 3D support structure
- All platform interface methods implemented

### ⏳ Todo
- Full mesh data conversion for custom 3D models
- Advanced shader support
- Audio bindings (optional)

## Usage Examples

### Simple Window
```nim
import platform/raylib/raylib_bindings

InitWindow(800, 600, "Hello Raylib")
SetTargetFPS(60)

while not WindowShouldClose():
  BeginDrawing()
  ClearBackground(RAYWHITE)
  DrawText("Hello from Raylib!", 100, 100, 20, BLACK)
  EndDrawing()

CloseWindow()
```

### 3D Scene
```nim
import platform/raylib/raylib_bindings

InitWindow(800, 600, "3D Demo")

var camera = Camera3D(
  position: Vector3(x: 0, y: 10, z: 10),
  target: Vector3(x: 0, y: 0, z: 0),
  up: Vector3(x: 0, y: 1, z: 0),
  fovy: 60.0,
  projection: CAMERA_PERSPECTIVE
)

while not WindowShouldClose():
  BeginDrawing()
  ClearBackground(RAYWHITE)
  
  BeginMode3D(camera)
  DrawCube(Vector3(x: 0, y: 0, z: 0), 2, 2, 2, RED)
  DrawGrid(10, 1.0)
  EndMode3D()
  
  DrawFPS(10, 10)
  EndDrawing()

CloseWindow()
```

## Advantages Over Naylib

### Problem: Naylib wrapper limitations
```nim
# Naylib - wrapper might not have latest functions
import naylib  # What version? What's included?

# Missing functions?
# Renamed APIs?
# Extra dependencies?
```

### Solution: Direct bindings
```nim
# Direct - you control what's available
import platform/raylib/raylib_bindings

# Need a new function? Add it yourself in 2 lines:
# proc NewFunction*(...) {.importc, header: "raylib.h".}

# Always matches the C API exactly
```

## Adding Missing Functions

If you need a raylib function that's not bound yet:

1. **Check raylib.h** for the C signature
2. **Add to appropriate bindings file** (core, shapes, models, etc.)
3. **Follow the pattern**:

```nim
proc FunctionName*(param: Type): ReturnType {.
  importc: "FunctionName",  # Exact C name
  header: "raylib.h"        # Header file
.}
```

Example - adding `DrawCapsule`:

```nim
# In models.nim
proc DrawCapsule*(startPos, endPos: Vector3, radius: float32, slices, rings: cint, color: Color) {.
  importc: "DrawCapsule",
  header: "raylib.h"
.}
```

Done! Use it immediately:
```nim
DrawCapsule(start, end, 1.0, 16, 16, BLUE)
```

## Best Practices

### 1. Match C API Exactly
```nim
# Good - matches C signature
proc DrawCircle*(centerX, centerY: cint, radius: float32, color: Color)

# Bad - renamed parameters
proc DrawCircle*(x, y: int, r: float, col: Color)
```

### 2. Use Appropriate Types
```nim
# C: int → Nim: cint
# C: float → Nim: float32
# C: char* → Nim: cstring
# C: struct → Nim: object with {.bycopy.} or incompletestruct
```

### 3. Export Everything
```nim
# Always use * for public API
proc PublicFunction*()  # Exported
proc privateHelper()     # Internal only
```

### 4. Group Logically
```nim
# core.nim - window, timing
# shapes.nim - 2D drawing
# models.nim - 3D functions
# input.nim - keyboard, mouse
```

## Performance

Direct bindings have **zero overhead**:

```nim
# Your Nim code:
DrawCircle(100, 100, 50, RED)

# Compiles to:
DrawCircle(100, 100, 50.0, (Color){255,0,0,255})

# Direct C call - no wrapper overhead!
```

## Maintenance

**SDL3 bindings**: ~500 lines
**Raylib bindings**: ~400 lines
**Both**: Simple, readable, maintainable

Adding new functions takes minutes, not hours.

## Conclusion

Using raylib directly through C bindings gives you:
- ✅ Full control
- ✅ Latest features
- ✅ Zero overhead
- ✅ Simple maintenance
- ✅ No third-party dependencies

The same workflow that makes SDL3 integration clean and powerful works perfectly for raylib!
