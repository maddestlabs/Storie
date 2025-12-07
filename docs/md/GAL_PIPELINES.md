# GAL Pipeline System Documentation

## Overview

A **pipeline** in GAL combines:
1. **Shaders** (vertex + fragment)
2. **Vertex Layout** (attribute description)
3. **Render State** (depth, culling, blending, etc.)

Pipelines are compiled once and used many times for efficient rendering.

## Pipeline Components

### 1. Shader

Defines what code runs on the GPU:

```nim
let shader = galLoadShader(device, "basic.vert", "basic.frag")
```

### 2. Vertex Layout

Describes how vertex data is structured:

```nim
let layout = galCreateVertexLayout(32)  # stride in bytes
layout.galAddAttribute(0, VertexFloat3, 0)   # position
layout.galAddAttribute(1, VertexFloat3, 12)  # color
layout.galAddAttribute(2, VertexFloat2, 24)  # texCoord
```

### 3. Render State

Controls how primitives are rendered:

```nim
let state = PipelineState(
  depthTest: true,
  depthWrite: true,
  cullMode: CullBack,
  blendEnabled: false,
  primitiveType: PrimitiveTriangles
)
```

## Creating Pipelines

### Complete Example:

```nim
# 1. Load shaders
let shader = galLoadShader(device, "shader.vert", "shader.frag")

# 2. Define vertex layout
let layout = galCreateVertexLayout(sizeof(Vertex))
layout.galAddAttribute(0, VertexFloat3, 0)
layout.galAddAttribute(1, VertexFloat4, 12)

# 3. Configure render state
let state = PipelineState(
  depthTest: true,
  depthWrite: true,
  cullMode: CullBack,
  blendEnabled: false,
  primitiveType: PrimitiveTriangles
)

# 4. Create pipeline
let pipeline = galCreatePipeline(device, shader, layout, state)

# 5. Use pipeline
galBindPipeline(pipeline)
galDrawIndexed(indexCount)

# 6. Cleanup
galDestroyPipeline(device, pipeline)
```

## Vertex Layouts

### Layout Creation:

```nim
proc galCreateVertexLayout*(stride: int): GalVertexLayout
```

- **stride**: Total size of one vertex in bytes

### Adding Attributes:

```nim
proc galAddAttribute*(layout, location, format, offset)
```

- **location**: Matches shader `layout(location = N)`
- **format**: Data type (see VertexFormat)
- **offset**: Byte offset within vertex

### Vertex Formats:

| Format | Type | Size (bytes) | Example |
|--------|------|--------------|---------|
| `VertexFloat` | float | 4 | `x: float32` |
| `VertexFloat2` | vec2 | 8 | `xy: array[2, float32]` |
| `VertexFloat3` | vec3 | 12 | `xyz: array[3, float32]` |
| `VertexFloat4` | vec4 | 16 | `xyzw: array[4, float32]` |
| `VertexByte4` | ubyte4 | 4 | `rgba: array[4, uint8]` |

### Layout Examples:

#### Position Only:

```nim
type Vertex = object
  position: array[3, float32]  # 12 bytes

let layout = galCreateVertexLayout(12)
layout.galAddAttribute(0, VertexFloat3, 0)
```

#### Position + Color:

```nim
type Vertex = object
  position: array[3, float32]  # 12 bytes, offset 0
  color: array[4, float32]     # 16 bytes, offset 12

let layout = galCreateVertexLayout(28)
layout.galAddAttribute(0, VertexFloat3, 0)   # position
layout.galAddAttribute(1, VertexFloat4, 12)  # color
```

#### Position + Color + TexCoord:

```nim
type Vertex = object
  position: array[3, float32]  # 12 bytes, offset 0
  color: array[3, float32]     # 12 bytes, offset 12
  texCoord: array[2, float32]  # 8 bytes, offset 24

let layout = galCreateVertexLayout(32)
layout.galAddAttribute(0, VertexFloat3, 0)   # position
layout.galAddAttribute(1, VertexFloat3, 12)  # color
layout.galAddAttribute(2, VertexFloat2, 24)  # texCoord
```

#### Packed Color (Memory Efficient):

```nim
type Vertex = object
  position: array[3, float32]  # 12 bytes, offset 0
  color: array[4, uint8]       # 4 bytes, offset 12

let layout = galCreateVertexLayout(16)
layout.galAddAttribute(0, VertexFloat3, 0)  # position
layout.galAddAttribute(1, VertexByte4, 12)  # color (normalized to 0-1)
```

## Render State

### PipelineState Fields:

```nim
type PipelineState* = object
  depthTest*: bool          # Enable depth testing
  depthWrite*: bool         # Write to depth buffer
  cullMode*: CullMode       # Backface culling
  blendEnabled*: bool       # Alpha blending
  primitiveType*: PrimitiveType  # Triangle/Line/Point
```

### Depth Testing:

Controls which fragments are visible based on depth:

```nim
# Enable depth test (normal 3D rendering)
depthTest: true
depthWrite: true

# Disable depth test (2D overlays)
depthTest: false
depthWrite: false

# Transparent objects (test but don't write)
depthTest: true
depthWrite: false
```

**Visual:**
```
depthTest = true:
  ┌─────┐
  │  A  │     B behind A = hidden
  │  ┌──┼──┐
  │  │B │  │
  └──┼──┘  │
     └─────┘

depthTest = false:
  ┌─────┐
  │  A  │     B behind A = visible
  │  ┌──┼──┐
  │  │█ │  │  Both drawn
  └──┼──┘  │
     └─────┘
```

### Culling:

Controls which triangle faces are rendered:

```nim
type CullMode* = enum
  CullNone   # Render both sides
  CullBack   # Render front faces only (default)
  CullFront  # Render back faces only
```

**Visual:**
```
CullBack:
   Front          Back
  ┌─────┐       ┌─────┐
  │  ✓  │       │  ✗  │
  └─────┘       └─────┘
  Rendered      Culled

CullNone:
   Front          Back
  ┌─────┐       ┌─────┐
  │  ✓  │       │  ✓  │
  └─────┘       └─────┘
  Rendered      Rendered
```

**When to use:**
- `CullBack`: Solid objects (faster, most common)
- `CullNone`: Transparent objects, vegetation, double-sided
- `CullFront`: Special effects (inside-out rendering)

### Blending:

Controls how transparent colors are mixed:

```nim
# Opaque rendering (default)
blendEnabled: false

# Transparent rendering
blendEnabled: true
# Formula: finalColor = srcColor * srcAlpha + dstColor * (1 - srcAlpha)
```

**Visual:**
```
blendEnabled = false:
  Background   Foreground   Result
  ████████  +  ▓▓▓▓▓▓▓▓  =  ▓▓▓▓▓▓▓▓
                             Replaces

blendEnabled = true:
  Background   Foreground   Result
  ████████  +  ░░░░░░░░  =  ▒▒▒▒▒▒▒▒
               (alpha=0.5)   Blended
```

### Primitive Type:

```nim
type PrimitiveType* = enum
  PrimitiveTriangles  # Solid surfaces
  PrimitiveLines      # Wireframe, debug
  PrimitivePoints     # Particles, point clouds
```

## Common Pipeline Configurations

### 1. Opaque 3D Objects

```nim
let opaqueState = PipelineState(
  depthTest: true,
  depthWrite: true,
  cullMode: CullBack,
  blendEnabled: false,
  primitiveType: PrimitiveTriangles
)
```

**Use for**: Buildings, terrain, solid props

### 2. Transparent Objects

```nim
let transparentState = PipelineState(
  depthTest: true,
  depthWrite: false,  # Don't write depth!
  cullMode: CullNone,  # Render both sides
  blendEnabled: true,
  primitiveType: PrimitiveTriangles
)
```

**Use for**: Glass, water, vegetation, UI

**Important**: Render after opaque objects, back-to-front!

### 3. Skybox

```nim
let skyboxState = PipelineState(
  depthTest: false,     # Always behind everything
  depthWrite: false,
  cullMode: CullFront,  # Inside-out cube
  blendEnabled: false,
  primitiveType: PrimitiveTriangles
)
```

**Use for**: Sky, distant background

### 4. 2D UI Overlay

```nim
let uiState = PipelineState(
  depthTest: false,  # Always on top
  depthWrite: false,
  cullMode: CullNone,
  blendEnabled: true,  # For text/icons
  primitiveType: PrimitiveTriangles
)
```

**Use for**: HUD, menus, text

### 5. Wireframe Debug

```nim
let wireframeState = PipelineState(
  depthTest: true,
  depthWrite: false,
  cullMode: CullNone,  # Show all edges
  blendEnabled: false,
  primitiveType: PrimitiveLines
)
```

**Use for**: Debug visualization, mesh preview

### 6. Particle System

```nim
let particleState = PipelineState(
  depthTest: true,
  depthWrite: false,  # Particles don't block
  cullMode: CullNone,
  blendEnabled: true,  # Additive blending
  primitiveType: PrimitivePoints
)
```

**Use for**: Fire, smoke, sparkles

## Multi-Pipeline Rendering

Typical render order:

```nim
# 1. Opaque geometry (front-to-back)
galBindPipeline(opaquePipeline)
renderTerrain()
renderBuildings()

# 2. Skybox (after opaque)
galBindPipeline(skyboxPipeline)
renderSkybox()

# 3. Transparent objects (back-to-front)
galBindPipeline(transparentPipeline)
sortTransparentObjects()  # Important!
renderGlass()
renderWater()

# 4. Particles
galBindPipeline(particlePipeline)
renderParticles()

# 5. UI (last, on top)
galBindPipeline(uiPipeline)
renderHUD()
```

## Pipeline Switching

### Performance Note:

Pipeline switches are relatively expensive. Minimize by:

1. **Batch by pipeline**: Render all objects with same pipeline together
2. **Sort by material**: Within pipeline, sort by texture/material
3. **Instance rendering**: Draw multiple objects in one call

### Example:

```nim
# Bad: Many switches
for obj in objects:
  galBindPipeline(obj.pipeline)  # Switch every time!
  obj.draw()

# Good: Batch by pipeline
for pipeline in pipelines:
  galBindPipeline(pipeline)  # Switch once
  for obj in objectsUsingPipeline[pipeline]:
    obj.draw()
```

## Shader-Layout Matching

**Critical**: Vertex layout must match shader inputs!

### Shader:

```glsl
#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inColor;
layout(location = 2) in vec2 inTexCoord;
```

### Layout:

```nim
layout.galAddAttribute(0, VertexFloat3, 0)   # Must match location 0
layout.galAddAttribute(1, VertexFloat3, 12)  # Must match location 1
layout.galAddAttribute(2, VertexFloat2, 24)  # Must match location 2
```

### Mismatch Symptoms:

- Nothing renders
- Corrupted geometry
- Crash (rare, but possible)

## Troubleshooting

### Problem: Nothing renders

**Check:**
1. Pipeline bound? `galBindPipeline(pipeline)`
2. Vertex layout matches shader?
3. Cull mode culling everything? Try `CullNone`
4. Depth test failing? Check depth clear/near/far planes

### Problem: Transparent objects look wrong

**Solution:**
```nim
# Must disable depth write!
depthWrite: false

# Must render back-to-front!
sortObjects(backToFront)

# Must enable blending!
blendEnabled: true
```

### Problem: Pipeline creation fails

**OpenGL:**
- Check shader compilation errors
- Verify OpenGL context exists

**SDL_GPU:**
- Ensure SPIR-V shaders compiled correctly
- Check vertex attribute count limits

### Problem: Performance issues

**Optimize:**
1. Reduce pipeline switches (batch objects)
2. Reduce draw calls (instance rendering)
3. Use appropriate culling (CullBack)
4. Disable unnecessary features (blending if opaque)

## Advanced Topics

### Dynamic State (Future)

```nim
# TODO: Some state can change without pipeline switch
galSetDepthBias(...)
galSetLineWidth(...)
galSetBlendFactor(...)
```

### Compute Pipelines (Future)

```nim
# TODO: Compute shader pipelines
let computePipeline = galCreateComputePipeline(...)
```

### Pipeline Caching (Future)

```nim
# TODO: Save/load compiled pipelines
galSavePipelineCache("cache.bin")
galLoadPipelineCache("cache.bin")
```

## API Reference

### Types:

```nim
type PipelineState* = object
  depthTest*: bool
  depthWrite*: bool
  cullMode*: CullMode
  blendEnabled*: bool
  primitiveType*: PrimitiveType

type CullMode* = enum
  CullNone, CullBack, CullFront

type PrimitiveType* = enum
  PrimitiveTriangles, PrimitiveLines, PrimitivePoints

type VertexFormat* = enum
  VertexFloat, VertexFloat2, VertexFloat3, VertexFloat4, VertexByte4
```

### Functions:

```nim
proc galCreateVertexLayout*(stride: int): GalVertexLayout
proc galAddAttribute*(layout, location, format, offset)
proc galCreatePipeline*(device, shader, layout, state): GalPipeline
proc galBindPipeline*(pipeline)
proc galDestroyPipeline*(device, pipeline)
```

## Summary

✅ Pipelines combine shaders + layout + state
✅ Create once, use many times
✅ Vertex layout must match shader inputs
✅ Use appropriate state for object type
✅ Render order matters (opaque → transparent → UI)
✅ Minimize pipeline switches for performance

**Pipeline = Shader + Layout + State = Efficient Rendering!**
