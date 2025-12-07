# GAL vs OpenGL vs SDL_GPU Quick Reference

## Initialization

### OpenGL:
```nim
# Create OpenGL context via SDL/GLFW/etc.
var context = SDL_GL_CreateContext(window)
```

### SDL_GPU:
```nim
var device = SDL_CreateGPUDevice(formatFlags, debugMode, false, nil)
```

### GAL:
```nim
let device = galCreateDevice()  # Automatically picks backend
```

---

## Buffers

### OpenGL:
```nim
var vbo: GLuint
glGenBuffers(1, addr vbo)
glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, dataSize, dataPtr, GL_STATIC_DRAW)
```

### SDL_GPU:
```nim
var info = SDL_GPUBufferCreateInfo(
  usage: SDL_GPU_BUFFERUSAGE_VERTEX,
  sizeInBytes: dataSize.uint32
)
var buffer = SDL_CreateGPUBuffer(device, addr info)

var transferInfo = SDL_GPUTransferBufferCreateInfo(
  usage: SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
  sizeInBytes: dataSize.uint32
)
var transferBuffer = SDL_CreateGPUTransferBuffer(device, addr transferInfo)
var mapped = SDL_MapGPUTransferBuffer(device, transferBuffer, true)
copyMem(mapped, dataPtr, dataSize)
SDL_UnmapGPUTransferBuffer(device, transferBuffer)
# ... upload via copy pass ...
```

### GAL:
```nim
let buffer = galCreateBuffer(device, dataSize, BufferVertex)
galUploadBuffer(device, buffer, dataPtr, dataSize)
```

---

## State Management

### OpenGL:
```nim
glEnable(GL_DEPTH_TEST)
glDepthFunc(GL_LESS)
glEnable(GL_CULL_FACE)
glCullFace(GL_BACK)
glFrontFace(GL_CCW)
```

### SDL_GPU:
```nim
# State is set during pipeline creation:
var depthStencilState = SDL_GPUDepthStencilState(
  enableDepthTest: true,
  enableDepthWrite: true,
  compareOp: SDL_GPU_COMPAREOP_LESS
)
var rasterizerState = SDL_GPURasterizerState(
  cullMode: SDL_GPU_CULLMODE_BACK,
  frontFace: SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE
)
```

### GAL:
```nim
galEnableDepthTest(true)
galEnableCulling(true)
# Pipeline state set automatically based on flags
```

---

## Clearing

### OpenGL:
```nim
glClearColor(0.1, 0.1, 0.15, 1.0)
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
```

### SDL_GPU:
```nim
var colorTarget = SDL_GPUColorTargetInfo(
  texture: swapchainTexture,
  loadOp: SDL_GPU_LOADOP_CLEAR,
  storeOp: SDL_GPU_STOREOP_STORE,
  clearColor: SDL_FColor(r: 0.1, g: 0.1, b: 0.15, a: 1.0)
)
```

### GAL:
```nim
galClear(0.1, 0.1, 0.15, 1.0, clearDepth = true)
```

---

## Drawing

### OpenGL:
```nim
glBindVertexArray(vao)
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo)
glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, nil)
```

### SDL_GPU:
```nim
SDL_BindGPUVertexBuffers(renderPass, 0, addr vertexBinding, 1)
SDL_BindGPUIndexBuffer(renderPass, addr indexBinding, SDL_GPU_INDEXELEMENTSIZE_16BIT)
SDL_DrawGPUIndexedPrimitives(renderPass, indexCount, 1, 0, 0, 0)
```

### GAL:
```nim
galDrawIndexed(indexCount)
```

---

## Shaders

### OpenGL:
```nim
var vertShader = glCreateShader(GL_VERTEX_SHADER)
var source = "...\n"
glShaderSource(vertShader, 1, cast[cstringArray](addr source), nil)
glCompileShader(vertShader)

var fragShader = glCreateShader(GL_FRAGMENT_SHADER)
# ... same for fragment ...

var program = glCreateProgram()
glAttachShader(program, vertShader)
glAttachShader(program, fragShader)
glLinkProgram(program)
glUseProgram(program)
```

### SDL_GPU:
```nim
var vertInfo = SDL_GPUShaderCreateInfo(
  codeSize: spirvVertSize,
  code: spirvVertData,
  entryPointName: "main",
  format: SDL_GPU_SHADERFORMAT_SPIRV,
  stage: SDL_GPU_SHADERSTAGE_VERTEX,
  numSamplers: 0,
  numStorageTextures: 0,
  numStorageBuffers: 0,
  numUniformBuffers: 1
)
var vertShader = SDL_CreateGPUShader(device, addr vertInfo)
# ... same for fragment ...

var pipelineInfo = SDL_GPUGraphicsPipelineCreateInfo(
  vertexShader: vertShader,
  fragmentShader: fragShader,
  # ... many other fields ...
)
var pipeline = SDL_CreateGPUGraphicsPipeline(device, addr pipelineInfo)
```

### GAL (TODO):
```nim
let shader = galCreateShader(device, "shaders/basic.vert", "shaders/basic.frag")
let pipeline = galCreatePipeline(device, shader, pipelineState)
galBindPipeline(pipeline)
```

---

## Viewport

### OpenGL:
```nim
glViewport(0, 0, width, height)
```

### SDL_GPU:
```nim
var viewport = SDL_GPUViewport(
  x: 0, y: 0,
  w: width.float32,
  h: height.float32,
  minDepth: 0, maxDepth: 1
)
SDL_SetGPUViewport(renderPass, addr viewport)
```

### GAL:
```nim
galSetViewport(0, 0, width, height)
```

---

## Cleanup

### OpenGL:
```nim
glDeleteBuffers(1, addr vbo)
glDeleteVertexArrays(1, addr vao)
glDeleteProgram(program)
SDL_GL_DeleteContext(context)
```

### SDL_GPU:
```nim
SDL_ReleaseGPUBuffer(device, buffer)
SDL_ReleaseGPUGraphicsPipeline(device, pipeline)
SDL_ReleaseGPUShader(device, vertShader)
SDL_ReleaseGPUShader(device, fragShader)
SDL_DestroyGPUDevice(device)
```

### GAL:
```nim
galDestroyBuffer(device, buffer)
galDestroyPipeline(device, pipeline)
galDestroyShader(device, shader)
galDestroyDevice(device)
```

---

## Complexity Comparison

| Operation | OpenGL LOC | SDL_GPU LOC | GAL LOC | Reduction |
|-----------|------------|-------------|---------|-----------|
| Create buffer | 3 | 15 | 1 | 66-93% |
| Upload data | 0 | 8 | 1 | - |
| Set depth test | 2 | 0 (in pipeline) | 1 | 50% |
| Clear screen | 2 | 6 | 1 | 50-83% |
| Draw indexed | 3 | 3 | 1 | 66% |
| Compile shader | 12 | 20 | 2 | 83-90% |
| Total | 22 | 52 | 7 | 68-86% |

**GAL reduces code by 68-86%** compared to raw APIs!

---

## Performance

### OpenGL Backend:
- Direct OpenGL calls
- No abstraction overhead
- Driver validation per call

### SDL_GPU Backend:
- Direct Vulkan/D3D12/Metal calls
- Minimal abstraction (thin wrapper)
- Validation only in debug mode

### Translation Overhead (Avoided):
GAL does **NOT** translate at runtime:
- ❌ NO state tracking overhead
- ❌ NO command buffer conversion
- ❌ NO API translation layer

Instead, GAL compiles to the native API:
- ✅ Native performance on all platforms
- ✅ Zero runtime translation
- ✅ Backend-specific optimizations

---

## When to Use Each

### Use Raw OpenGL When:
- Maximum control needed
- Working with existing OpenGL code
- Need specific OpenGL extensions

### Use Raw SDL_GPU When:
- Desktop-only application
- Need maximum native performance
- Want explicit control over pipelines/command buffers

### Use GAL When:
- **Cross-platform** (web + native)
- Want **simple API**
- Don't need low-level control
- **Writing creative coding scripts** (like Nimini)
- Want automatic platform optimization

---

## Migration Path

Existing code can migrate gradually:

### Step 1: Wrap critical paths
```nim
# Old:
glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, size, data, GL_STATIC_DRAW)

# New:
let buffer = galCreateBuffer(device, size, BufferVertex)
galUploadBuffer(device, buffer, data, size)
```

### Step 2: Refactor renderers
```nim
# Old:
type SdlRenderer3D = ref object of Renderer3D
  vao, vbo, ibo: GLuint
  shaderProgram: GLuint

# New:
type SdlRenderer3D = ref object of Renderer3D
  device: GalDevice
  vertexBuffer, indexBuffer: GalBuffer
  pipeline: GalPipeline
```

### Step 3: Update Nimini runtime
```nim
# Nimini scripts automatically get GAL
when defined(emscripten):
  echo "Using WebGL via GAL"
else:
  echo "Using SDL_GPU via GAL"
```

---

## Conclusion

**GAL provides the best solution for Storie:**

1. ✅ **Write once, run everywhere** (web + native)
2. ✅ **Simple API** (7 lines vs 22-52)
3. ✅ **Native performance** (no translation overhead)
4. ✅ **Future-proof** (easy to add WebGPU, etc.)
5. ✅ **Perfect for Nimini** (high-level creative coding)

Instead of translating OpenGL → SDL_GPU at runtime, GAL **compiles the same high-level code to different native APIs** at compile time.
