# Storie Platform Architecture

## High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User Markdown Code                        │
│                                                               │
│  ``` nim on:render                                           │
│  setColor(255, 0, 0)                                         │
│  fillRect(10, 10, 100, 100)                                  │
│  drawCube(2.0)  # 3D if enabled                              │
│  ```                                                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   Nimini DSL Interpreter                     │
│                   (src/nimini/*.nim)                         │
│                                                               │
│  • Tokenizer → Parser → Runtime                              │
│  • Executes lifecycle blocks (init, update, render)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      storie.nim                              │
│                   (Main Engine Core)                         │
│                                                               │
│  • Lifecycle management                                      │
│  • Markdown parsing                                          │
│  • Nimini function bindings                                  │
│  • State management (AppState)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
┌─────────────────────┐   ┌─────────────────────┐
│   2D Rendering      │   │   3D Rendering      │
│   (pixel_types)     │   │  (render3d_*)       │
│                     │   │                     │
│  • RenderBuffer     │   │  • Renderer3D       │
│  • DrawCommand      │   │  • Camera3D         │
│  • Layer system     │   │  • Vec3, Mat4       │
└─────────┬───────────┘   └──────────┬──────────┘
          │                          │
          └────────────┬─────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Platform Interface (abstract)                   │
│              (platform_interface.nim)                        │
│                                                               │
│  method init()                                               │
│  method display(RenderBuffer)                                │
│  method pollEvents(): seq[InputEvent]                        │
│  method shutdown()                                           │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│  SDL3 Backend    │      │ Raylib Backend   │
│  (sdl_platform)  │      │ (raylib_platform)│
│                  │      │                  │
│  • SDL3 window   │      │  • Raylib window │
│  • SDL3 renderer │      │  • Raylib draw   │
│  • TTF fonts     │      │  • Built-in text │
│  • Event system  │      │  • Event system  │
└────────┬─────────┘      └──────────┬───────┘
         │                           │
         ▼                           ▼
┌──────────────────┐      ┌──────────────────┐
│ SDL 3D Renderer  │      │ Raylib 3D Render │
│ (sdl_render3d)   │      │ (raylib_render3d)│
│                  │      │                  │
│  • OpenGL/ES     │      │  • Native 3D API │
│  • Shaders       │      │  • Simple calls  │
│  • VAO/VBO/EBO   │      │  • Auto lighting │
└────────┬─────────┘      └──────────┬───────┘
         │                           │
         ▼                           ▼
┌──────────────────┐      ┌──────────────────┐
│   OpenGL 3.3+    │      │    Raylib 5.0    │
│   OpenGL ES 3.0  │      │                  │
└──────────────────┘      └──────────────────┘
```

## 2D Rendering Pipeline

```
User Code
   │
   ▼
drawRect(10, 10, 100, 100)  [Nimini function]
   │
   ▼
RenderBuffer.drawRect(...)   [Command creation]
   │
   ▼
DrawCommand(kind: DrawRect, ...)  [Stored in buffer]
   │
   ▼
Platform.display(RenderBuffer)    [Frame render]
   │
   ├─ SDL3: SDL_RenderFillRect(...)
   │
   └─ Raylib: DrawRectangle(...)
```

## 3D Rendering Pipeline

```
User Code
   │
   ▼
drawCube(2.0)                    [Nimini function]
   │
   ▼
createCubeMeshData(...)          [Platform-agnostic]
   │
   ▼
Renderer3D.drawMesh(meshData)    [Interface method]
   │
   ├─ SdlRenderer3D
   │    └─ createMesh() → VAO/VBO
   │    └─ shader.use()
   │    └─ glDrawElements()
   │
   └─ RaylibRenderer3D
        └─ DrawCube() / DrawMesh()
```

## Compile-Time Backend Selection

```
build.sh (no flags)
   └─> SDL3 Backend (default)

build.sh -d:raylib
   └─> Raylib Backend

build-web.sh
   └─> SDL3 WASM (~1.5 MB)

build-raylib-web.sh -d:raylib
   └─> Raylib WASM (~750 KB)
```

## Runtime Backend Selection (Future)

```
https://example.com/storie.html
   └─> Loads storie-sdl3.wasm (default)

https://example.com/storie.html?backend=raylib
   └─> Loads storie-raylib.wasm (smaller, faster load)
```

## Module Dependency Graph

```
storie.nim
   ├─ platform_interface.nim (abstract)
   ├─ render3d_interface.nim (abstract)
   ├─ pixel_types.nim
   ├─ storie_core.nim
   ├─ nimini/*
   │
   ├─ [SDL3 Backend] when not defined(raylib)
   │    ├─ sdl_platform.nim
   │    │    ├─ sdl3_bindings/*
   │    │    └─ platform_interface
   │    └─ sdl_render3d.nim
   │         ├─ opengl bindings
   │         └─ render3d_interface
   │
   └─ [Raylib Backend] when defined(raylib)
        ├─ raylib_platform.nim
        │    ├─ raylib_bindings.nim
        │    └─ platform_interface
        └─ raylib_render3d.nim
             ├─ raylib_bindings.nim
             └─ render3d_interface
```

## File Organization

```
platform/
├── platform_interface.nim      # Abstract base for all platforms
├── render3d_interface.nim      # Abstract base for 3D renderers
├── pixel_types.nim             # Shared 2D types
├── render3d.nim                # DEPRECATED (re-exports SDL)
│
├── sdl/                        # SDL3 + OpenGL backend
│   ├── sdl_platform.nim        # ✅ Complete
│   ├── sdl_render3d.nim        # ✅ Complete  
│   └── sdl3_bindings/          # ✅ Complete
│       ├── opengl.nim
│       └── ...
│
└── raylib/                     # Raylib backend
    ├── raylib_platform.nim     # ⏳ Stub (needs implementation)
    ├── raylib_render3d.nim     # ⏳ Stub (needs implementation)
    └── raylib_bindings.nim     # ❌ TODO: Create bindings
```

## Key Design Patterns

### 1. Interface-Based Polymorphism
```nim
type Platform* = ref object of RootObj
method display*(p: Platform, buf: RenderBuffer) {.base.}

type SdlPlatform* = ref object of Platform
method display*(p: SdlPlatform, buf: RenderBuffer) = 
  # SDL-specific implementation
```

### 2. Backend-Agnostic Data
```nim
type MeshData* = object
  vertices*: seq[float32]  # Platform-independent
  indices*: seq[uint16]

# Each backend converts to its native format:
# SDL → VAO/VBO
# Raylib → Mesh struct
```

### 3. Compile-Time Selection
```nim
when defined(raylib):
  type PlatformImpl = RaylibPlatform
else:
  type PlatformImpl = SdlPlatform
```

### 4. Command Pattern (2D)
```nim
type DrawCommand = object
  case kind: DrawCommandKind
  of FillRect:
    rectX, rectY, rectW, rectH: int
    rectColor: Color
  # ... stored and executed later
```

## Performance Characteristics

| Feature        | SDL3+OpenGL | Raylib     |
|----------------|-------------|------------|
| Binary Size    | 1.5 MB      | ~750 KB    |
| Init Time      | Medium      | Fast       |
| 2D Performance | Good        | Excellent  |
| 3D Performance | Excellent   | Good       |
| Features       | Maximum     | Essential  |
| Complexity     | High        | Low        |

## Use Case Recommendations

**Choose SDL3 when:**
- Need maximum features
- Desktop-first application
- Advanced 3D rendering
- Custom shaders required
- Cross-platform priority

**Choose Raylib when:**
- Web deployment priority
- Quick prototypes/demos
- Educational content
- Mobile-friendly
- Simplicity over features

## Future Extensions

Possible additional backends:
- **Sokol**: Even smaller than raylib (~300 KB)
- **WebGPU**: Modern web graphics
- **Vulkan**: Desktop performance
- **Metal**: macOS/iOS native
- **ASCII**: Terminal rendering (fun experiment!)

Each just needs to implement:
- `Platform` interface
- `Renderer3D` interface
- Backend-specific bindings
