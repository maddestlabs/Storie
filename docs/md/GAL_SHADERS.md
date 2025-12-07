# GAL Shader System Documentation

## Overview

GAL provides a unified shader system that works across OpenGL and SDL_GPU backends:

- **OpenGL/WebGL**: Uses GLSL source code compiled at runtime
- **SDL_GPU**: Uses precompiled SPIR-V shaders (compiled offline)

## Shader Format

All shaders are written in **GLSL 450** (Vulkan-compatible GLSL).

### Why GLSL 450?

- ✅ Compatible with Vulkan (SDL_GPU)
- ✅ Can be compiled to SPIR-V
- ✅ Works with OpenGL 4.5+ (and 3.3 with minor changes)
- ✅ Easy to read and write

## Shader Workflow

### For OpenGL Backend:

```nim
# Load GLSL source directly
let shader = galLoadShader(device, "shaders/basic.vert", "shaders/basic.frag")
```

**What happens:**
1. Reads GLSL source files
2. Compiles at runtime using `glCompileShader`
3. Links into a program

### For SDL_GPU Backend:

```nim
# Compile GLSL to SPIR-V first
import platform/shader_compiler
let result = compileShaderPair("shaders/basic.vert", "shaders/basic.frag")

# Load precompiled SPIR-V
let shader = galLoadShader(device, 
                          "shaders/basic.vert.spv",
                          "shaders/basic.frag.spv")
```

**What happens:**
1. `glslc` or `glslangValidator` compiles GLSL → SPIR-V offline
2. SPIR-V bytecode is loaded at runtime
3. SDL_GPU creates shader objects from SPIR-V

## Shader Compilation

### Manual Compilation:

```bash
# Using glslc (Vulkan SDK)
glslc -fshader-stage=vert basic.vert -o basic.vert.spv
glslc -fshader-stage=frag basic.frag -o basic.frag.spv

# Using glslangValidator
glslangValidator -V -S vert basic.vert -o basic.vert.spv
glslangValidator -V -S frag basic.frag -o basic.frag.spv
```

### Automatic Compilation:

```nim
import platform/shader_compiler

# Compile a shader pair
let result = compileShaderPair("shaders/basic.vert", "shaders/basic.frag")
if result.vert.success and result.frag.success:
  echo "Compiled successfully!"

# Compile all shaders in a directory
ensureShadersCompiled("shaders")

# Check if recompilation needed
if needsRecompile("shaders/basic.vert"):
  discard compileGLSLtoSPIRV("shaders/basic.vert", "vert")
```

## Vertex Shader Example

```glsl
#version 450

// Vertex attributes (must match vertex layout)
layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inColor;
layout(location = 2) in vec2 inTexCoord;

// Outputs to fragment shader
layout(location = 0) out vec3 fragColor;
layout(location = 1) out vec2 fragTexCoord;

// Uniforms
layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 projection;
} ubo;

void main() {
    gl_Position = ubo.projection * ubo.view * ubo.model * vec4(inPosition, 1.0);
    fragColor = inColor;
    fragTexCoord = inTexCoord;
}
```

**Key points:**
- `layout(location = N)` for vertex attributes (matches `GalVertexLayout`)
- `layout(binding = N)` for uniform buffers
- GLSL 450 syntax

## Fragment Shader Example

```glsl
#version 450

// Inputs from vertex shader
layout(location = 0) in vec3 fragColor;
layout(location = 1) in vec2 fragTexCoord;

// Output color
layout(location = 0) out vec4 outColor;

// Optional texture
layout(binding = 1) uniform sampler2D texSampler;

void main() {
    // Simple color output
    outColor = vec4(fragColor, 1.0);
    
    // With texture:
    // outColor = texture(texSampler, fragTexCoord) * vec4(fragColor, 1.0);
}
```

## Vertex Layout Matching

Your vertex layout **must match** the shader inputs:

```nim
type Vertex = object
  position: array[3, float32]  # 12 bytes, offset 0
  color: array[3, float32]     # 12 bytes, offset 12
  texCoord: array[2, float32]  # 8 bytes, offset 24
  # Total: 32 bytes

let layout = galCreateVertexLayout(32)  # stride = 32
layout.galAddAttribute(0, VertexFloat3, 0)   # location 0 = position
layout.galAddAttribute(1, VertexFloat3, 12)  # location 1 = color
layout.galAddAttribute(2, VertexFloat2, 24)  # location 2 = texCoord
```

## Uniform Buffers

### Defining Uniforms in Shader:

```glsl
layout(binding = 0) uniform UniformBufferObject {
    mat4 model;      // 64 bytes
    mat4 view;       // 64 bytes
    mat4 projection; // 64 bytes
} ubo;               // Total: 192 bytes
```

### Creating and Using in Code:

```nim
type UniformData = object
  model: array[16, float32]
  view: array[16, float32]
  projection: array[16, float32]

var uniforms = UniformData(...)

let uniformBuffer = galCreateBuffer(device, sizeof(UniformData), BufferUniform)
galUploadBuffer(device, uniformBuffer, addr uniforms, sizeof(UniformData))

# Update uniforms each frame
uniforms.model = createRotationMatrix(angle)
galUploadBuffer(device, uniformBuffer, addr uniforms, sizeof(UniformData))
```

## Texture Sampling

### In Shader:

```glsl
layout(binding = 1) uniform sampler2D texSampler;

void main() {
    vec4 texColor = texture(texSampler, fragTexCoord);
    outColor = texColor * vec4(fragColor, 1.0);
}
```

### In Code:

```nim
let texture = galCreateTexture(device, width, height, TextureRGBA8)
galUploadTexture(device, texture, pixelData)
galSetTextureFilter(texture, FilterLinear, FilterLinear)
# Bind texture in render loop (API TBD)
```

## Complete Shader Pipeline

```nim
# 1. Create/compile shader
when defined(sdlgpu) and not defined(emscripten):
  # Compile to SPIR-V
  let result = compileShaderPair("shader.vert", "shader.frag")
  let shader = galLoadShader(device, result.vert.spirvPath, result.frag.spirvPath)
else:
  # Load GLSL directly
  let shader = galLoadShader(device, "shader.vert", "shader.frag")

# 2. Create vertex layout
let layout = galCreateVertexLayout(sizeof(Vertex))
layout.galAddAttribute(0, VertexFloat3, 0)
layout.galAddAttribute(1, VertexFloat3, 12)

# 3. Create pipeline
let state = PipelineState(
  depthTest: true,
  depthWrite: true,
  cullMode: CullBack,
  blendEnabled: false,
  primitiveType: PrimitiveTriangles
)
let pipeline = galCreatePipeline(device, shader, layout, state)

# 4. Use pipeline
galBindPipeline(pipeline)
galDrawIndexed(indexCount)

# 5. Cleanup
galDestroyPipeline(device, pipeline)
galDestroyShader(device, shader)
```

## Shader Compilation Best Practices

### Development Workflow:

1. **Write GLSL 450 shaders**
2. **Test with OpenGL first** (faster iteration)
3. **Compile to SPIR-V for production** (SDL_GPU)
4. **Version control both** GLSL and SPIR-V

### Build Script Example:

```bash
#!/bin/bash
# compile-shaders.sh

echo "Compiling shaders..."

for vert in shaders/*.vert; do
  spv="${vert}.spv"
  if [ ! -f "$spv" ] || [ "$vert" -nt "$spv" ]; then
    echo "Compiling $vert..."
    glslc -fshader-stage=vert "$vert" -o "$spv"
  fi
done

for frag in shaders/*.frag; do
  spv="${frag}.spv"
  if [ ! -f "$spv" ] || [ "$frag" -nt "$spv" ]; then
    echo "Compiling $frag..."
    glslc -fshader-stage=frag "$frag" -o "$spv"
  fi
done

echo "Done!"
```

### Nim Integration:

```nim
# In your build script or startup code
when defined(sdlgpu) and not defined(emscripten):
  import platform/shader_compiler
  
  # Compile shaders if needed
  ensureShadersCompiled("shaders")
  
  # Or check individual shaders
  if needsRecompile("shaders/basic.vert"):
    let result = compileGLSLtoSPIRV("shaders/basic.vert", "vert")
    if not result.success:
      echo "Shader compilation failed: ", result.errorMsg
```

## Common Issues

### Issue: Shader compilation fails

**OpenGL:**
```nim
# Check compilation log
let shader = galLoadShader(device, "vert.glsl", "frag.glsl")
if shader.isNil:
  echo "Shader compilation failed! Check console for errors."
```

**SDL_GPU:**
```bash
# Compile manually to see errors
glslc -fshader-stage=vert shader.vert -o shader.vert.spv
# Read detailed error messages
```

### Issue: Vertex attributes don't match

**Symptom**: Nothing renders or crashes

**Solution**: Ensure layout matches shader exactly:
```nim
# Shader has:
# layout(location = 0) in vec3 inPosition;
# layout(location = 1) in vec4 inColor;

# Code must have:
layout.galAddAttribute(0, VertexFloat3, 0)   # vec3
layout.galAddAttribute(1, VertexFloat4, 12)  # vec4
```

### Issue: Uniform buffer not updating

**Solution**: Make sure you're uploading every frame:
```nim
while running:
  # Update uniforms
  uniforms.model = newModelMatrix()
  galUploadBuffer(device, uniformBuffer, addr uniforms, sizeof(uniforms))
  
  # Draw
  galDrawIndexed(count)
```

## Shader Library

GAL includes example shaders:

- `shaders/basic.vert/frag` - Position + color
- `shaders/textured.vert/frag` - Textured quad

Create your own by copying and modifying these templates!

## Advanced Topics

### Multiple Render Passes

```nim
# Pass 1: Render to texture
# Pass 2: Post-processing
# TODO: Document when render targets are implemented
```

### Shader Specialization

```glsl
// Use preprocessor for variants
#ifdef USE_TEXTURE
  layout(binding = 1) uniform sampler2D tex;
#endif
```

### Compute Shaders

```nim
# TODO: Implement compute shader support
```

## Summary

✅ Write GLSL 450 shaders once
✅ OpenGL: Runtime compilation from GLSL
✅ SDL_GPU: Offline compilation to SPIR-V
✅ Unified API across backends
✅ Vertex layout matches shader inputs
✅ Uniform buffers for per-frame data
✅ Texture sampling support

**Result**: Write shaders once, deploy everywhere!
