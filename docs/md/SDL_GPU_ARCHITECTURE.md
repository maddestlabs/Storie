```
SDL_GPU ARCHITECTURE IN STORIE
===============================

USER CODE (Markdown with Nimini)
│
│   on:render
│   var angle = 0.0
│   drawCube(vec3(0,0,0), 2.0, RED)
│
└─────────────────────────────────────────────────────────────────┐
                                                                  │
ENGINE LAYER (storie.nim + storie_core.nim)                      │
│                                                                  │
│  proc executeNiminiCode(code: string)                           │
│  proc drawCube(pos: Vec3, size: float, color: Color)            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┤
                                                                  │
ABSTRACTION LAYER (render3d_interface.nim)                       │
│                                                                  │
│  type Renderer3D = ref object of RootObj                        │
│  method init3D(r: Renderer3D): bool                             │
│  method beginFrame3D(r: Renderer3D, ...)                        │
│  method drawMesh(r: Renderer3D, mesh: MeshData)                 │
│  method endFrame3D(r: Renderer3D)                               │
│                                                                  │
└──────────────────┬───────────────────────────────┬──────────────┤
                   │                               │              │
         ┌─────────▼──────────┐          ┌────────▼──────────┐   │
         │  OPENGL BACKEND    │          │  SDL_GPU BACKEND  │   │
         │                    │          │                   │   │
         │ sdl_render3d.nim   │          │sdl_gpu_render3d.nim   │
         │                    │          │                   │   │
         │ - Simple API       │          │ - Modern API      │   │
         │ - Immediate mode   │          │ - Command buffers │   │
         │ - Runtime shaders  │          │ - Precompiled     │   │
         │ - State machine    │          │ - Explicit state  │   │
         │                    │          │                   │   │
         └─────────┬──────────┘          └────────┬──────────┘   │
                   │                              │              │
         ┌─────────▼──────────┐          ┌───────▼────────────┐ │
         │   OpenGL Driver    │          │   SDL_GPU Layer    │ │
         │                    │          │                    │ │
         │ glEnable(...)      │          │ SDL_CreateGPU...() │ │
         │ glDrawElements(...) │          │ SDL_BeginGPU...()  │ │
         │                    │          │                    │ │
         └─────────┬──────────┘          └───────┬────────────┘ │
                   │                             │              │
                   │                    ┌────────┴─────┬────────┤
                   │                    │              │        │
         ┌─────────▼──────────┐  ┌──────▼───┐  ┌──────▼───┐  ┌▼─────┐
         │   GPU (OpenGL)     │  │ Vulkan   │  │  D3D12   │  │Metal │
         │                    │  │  Driver  │  │  Driver  │  │Driver│
         │   All Platforms    │  │          │  │          │  │      │
         │   (but deprecated  │  │  Linux   │  │ Windows  │  │macOS │
         │    on macOS)       │  │ Windows  │  │   Xbox   │  │ iOS  │
         │                    │  │ Android  │  │          │  │      │
         └────────────────────┘  └──────────┘  └──────────┘  └──────┘
                                      
================================================================================

RENDER FLOW COMPARISON
======================

OPENGL FLOW:
-----------
1. glClear()                     ← Clear screen
2. glUseProgram()                ← Activate shader
3. glUniformMatrix4fv() x3       ← Upload matrices
4. glBindVertexArray()           ← Bind mesh
5. glDrawElements()              ← Draw
6. SDL_GL_SwapWindow()           ← Present

Total: 6 calls per frame base + N draw calls

SDL_GPU FLOW:
------------
1. SDL_AcquireGPUCommandBuffer()           ← Get command buffer
2. SDL_WaitAndAcquireGPUSwapchainTexture() ← Get render target
3. SDL_BeginGPURenderPass()                ← Begin (clears automatically)
4. SDL_BindGPUGraphicsPipeline()           ← Bind pipeline (shader+state)
5. SDL_PushGPUVertexUniformData()          ← Upload uniforms (all at once)
6. SDL_BindGPUVertexBuffers()              ← Bind vertex buffer
7. SDL_BindGPUIndexBuffer()                ← Bind index buffer
8. SDL_DrawGPUIndexedPrimitives()          ← Draw
9. SDL_EndGPURenderPass()                  ← End pass
10. SDL_SubmitGPUCommandBuffer()           ← Submit (presents automatically)

Total: 10 calls per frame base + N draw calls

More calls, but:
- Lower driver overhead (batched)
- Explicit control (predictable)
- Better for complex scenes (parallel recording)

================================================================================

DATA STRUCTURES
===============

OPENGL:
------
Mesh3D:
  vao: GLuint        ← Vertex Array Object
  vbo: GLuint        ← Vertex Buffer Object  
  ebo: GLuint        ← Element Buffer Object

Shader3D:
  program: GLuint    ← Compiled shader program
  
State: IMPLICIT (in OpenGL driver)

SDL_GPU:
-------
GpuMesh3D:
  vertexBuffer: SDL_GPUBuffer   ← GPU vertex memory
  indexBuffer: SDL_GPUBuffer    ← GPU index memory

GraphicsPipeline:
  vertexShader: SDL_GPUShader   ← Precompiled vertex shader
  fragmentShader: SDL_GPUShader ← Precompiled fragment shader
  rasterizerState: ...          ← Culling, fill mode, etc.
  depthStencilState: ...        ← Depth testing config
  
State: EXPLICIT (in pipeline objects)

================================================================================

SHADER COMPILATION
==================

OPENGL:
------
vertex.glsl ──glCompileShader()──> GPU memory (runtime)
                                   ↑ Happens at startup
                                   ↑ Can fail at runtime
                                   ↑ Platform-specific drivers

SDL_GPU:
-------
vertex.glsl ──glslangValidator──> vertex.spv  (SPIR-V for Vulkan)
            ──dxc──────────────> vertex.dxil (DXIL for D3D12)
            ──spirv-cross──────> vertex.metal (MSL for Metal)
                                       ↑ Happens at build time
                                       ↑ Errors caught early
                                       ↑ Optimized per platform

At runtime:
vertex.spv ──SDL_CreateGPUShader()──> GPU memory (validated)

================================================================================

FILE ORGANIZATION
=================

Storie/
├── platform/
│   ├── render3d_interface.nim      ← Abstract interface (common types)
│   └── sdl/
│       ├── sdl_platform.nim        ← SDL3 windowing/input
│       ├── sdl_render3d.nim        ← OpenGL 3D rendering
│       ├── sdl_gpu_bindings.nim    ← SDL_GPU C API bindings (NEW)
│       └── sdl_gpu_render3d.nim    ← SDL_GPU 3D rendering (NEW)
│
├── shaders/
│   ├── vertex.glsl                 ← Vertex shader source (NEW)
│   ├── fragment.glsl               ← Fragment shader source (NEW)
│   └── compiled/
│       ├── vertex.spv              ← SPIR-V (Vulkan)
│       ├── vertex.dxil             ← DXIL (D3D12)
│       └── vertex.metal            ← MSL (Metal)
│
├── compile-shaders.sh              ← Build shaders (NEW)
│
└── docs/
    ├── SDL_GPU_MIGRATION.md        ← Migration guide (NEW)
    ├── SDL_GPU_POC_README.md       ← Quick start (NEW)
    └── OPENGL_VS_SDL_GPU.md        ← Comparison (NEW)

================================================================================

COMPILE-TIME SELECTION
======================

Default (OpenGL):
$ nim c -r index.nim
    ↓
  Uses sdl_render3d.nim
    ↓
  OpenGL backend
    ↓
  Works everywhere, simple

With SDL_GPU:
$ nim c -d:sdlgpu -r index.nim
    ↓
  Uses sdl_gpu_render3d.nim
    ↓
  SDL_GPU backend
    ↓
  Vulkan/D3D12/Metal, fast

Implementation in storie.nim:
```nim
when defined(sdlgpu):
  import platform/sdl/sdl_gpu_render3d
  let renderer = newSdlGpuRenderer3D(window)
else:
  import platform/sdl/sdl_render3d
  let renderer = newSdlRenderer3D()
```

Both implement Renderer3D interface!

================================================================================
```
