# GAL Texture System Documentation

## Overview

GAL provides a unified texture API that works across OpenGL and SDL_GPU:

- **Create textures** with various formats
- **Upload pixel data** from memory
- **Configure filtering** and wrapping
- **Automatic format conversion** where needed

## Creating Textures

### Basic Texture Creation:

```nim
let texture = galCreateTexture(device, width, height, TextureRGBA8)
```

### Supported Formats:

| Format | Description | Bytes per Pixel |
|--------|-------------|-----------------|
| `TextureRGBA8` | 8-bit RGBA | 4 |
| `TextureRGB8` | 8-bit RGB | 3 |
| `TextureR8` | 8-bit grayscale | 1 |
| `TextureDepth24Stencil8` | Depth + stencil | 4 |

### Format Examples:

```nim
# Color texture (most common)
let colorTex = galCreateTexture(device, 512, 512, TextureRGBA8)

# Grayscale texture (memory efficient)
let grayTex = galCreateTexture(device, 256, 256, TextureR8)

# Depth buffer (for shadow maps, etc.)
let depthTex = galCreateTexture(device, 1024, 1024, TextureDepth24Stencil8)
```

## Uploading Pixel Data

### From Memory:

```nim
# Create pixel data
var pixels = newSeq[uint8](width * height * 4)  # RGBA

# Fill with data
for y in 0..<height:
  for x in 0..<width:
    let idx = (y * width + x) * 4
    pixels[idx + 0] = red
    pixels[idx + 1] = green
    pixels[idx + 2] = blue
    pixels[idx + 3] = alpha

# Upload to GPU
galUploadTexture(device, texture, addr pixels[0])
```

### Pixel Layout:

For `TextureRGBA8`, pixels are stored as:
```
[R0, G0, B0, A0, R1, G1, B1, A1, R2, G2, B2, A2, ...]
```

Row-major order (left-to-right, top-to-bottom).

## Texture Filtering

### Filter Modes:

- `FilterNearest` - Sharp, pixelated (good for pixel art)
- `FilterLinear` - Smooth, blurred (good for photos)

### Setting Filters:

```nim
# Pixelated look
galSetTextureFilter(texture, FilterNearest, FilterNearest)

# Smooth look
galSetTextureFilter(texture, FilterLinear, FilterLinear)

# Mixed (uncommon)
galSetTextureFilter(texture, FilterNearest, FilterLinear)
```

### Visual Comparison:

```
Nearest:        Linear:
████████        ▒▒▒▒▒▒▒▒
████████        ▒▒▒▒▒▒▒▒
░░░░░░░░        ░░░░░░░░
░░░░░░░░        ░░░░░░░░
Sharp edges     Smooth blend
```

## Texture Wrapping

### Wrap Modes:

- `WrapRepeat` - Tile texture (default)
- `WrapClamp` - Clamp to edge
- `WrapMirror` - Mirror at boundaries

### Setting Wrap Modes:

```nim
# Tile texture (for floors, walls, etc.)
galSetTextureWrap(texture, WrapRepeat, WrapRepeat)

# Clamp to edge (for UI elements)
galSetTextureWrap(texture, WrapClamp, WrapClamp)

# Mirror tiling (for seamless patterns)
galSetTextureWrap(texture, WrapMirror, WrapMirror)
```

### Visual Examples:

#### WrapRepeat (Tiling):
```
┌─────┬─────┬─────┐
│ TEX │ TEX │ TEX │
├─────┼─────┼─────┤
│ TEX │ TEX │ TEX │
└─────┴─────┴─────┘
UV: 0.0-3.0
```

#### WrapClamp:
```
┌─────────────────┐
│ T │           │ X│
│ E │           │ E│
│ X │  Clamped  │ T│
└─────────────────┘
UV: -1.0-2.0
```

#### WrapMirror:
```
┌─────┬─────┬─────┐
│ TEX │ XET │ TEX │
│     │     │     │
└─────┴─────┴─────┘
UV: 0.0-3.0
```

## Complete Texture Example

### Creating a Checkerboard:

```nim
proc createCheckerboard(device: GalDevice, size: int): GalTexture =
  result = galCreateTexture(device, size, size, TextureRGBA8)
  
  var pixels = newSeq[uint8](size * size * 4)
  let checkSize = size div 8
  
  for y in 0..<size:
    for x in 0..<size:
      let checker = ((x div checkSize) + (y div checkSize)) mod 2
      let idx = (y * size + x) * 4
      
      if checker == 0:
        pixels[idx..idx+3] = [255'u8, 255, 255, 255]  # White
      else:
        pixels[idx..idx+3] = [0'u8, 0, 0, 255]        # Black
  
  galUploadTexture(device, result, addr pixels[0])
  galSetTextureFilter(result, FilterNearest, FilterNearest)
  galSetTextureWrap(result, WrapRepeat, WrapRepeat)
```

### Creating a Gradient:

```nim
proc createGradient(device: GalDevice, width, height: int): GalTexture =
  result = galCreateTexture(device, width, height, TextureRGBA8)
  
  var pixels = newSeq[uint8](width * height * 4)
  
  for y in 0..<height:
    for x in 0..<width:
      let idx = (y * width + x) * 4
      pixels[idx + 0] = uint8((x * 255) div width)       # R: X gradient
      pixels[idx + 1] = uint8((y * 255) div height)      # G: Y gradient
      pixels[idx + 2] = 128                               # B: Constant
      pixels[idx + 3] = 255                               # A: Opaque
  
  galUploadTexture(device, result, addr pixels[0])
  galSetTextureFilter(result, FilterLinear, FilterLinear)
```

### Loading from File:

```nim
# Using a PNG library (e.g., nimPNG)
import nimPNG

proc loadTexture(device: GalDevice, filename: string): GalTexture =
  let png = loadPNG32(filename)
  
  result = galCreateTexture(device, png.width, png.height, TextureRGBA8)
  galUploadTexture(device, result, addr png.data[0])
  galSetTextureFilter(result, FilterLinear, FilterLinear)
  galSetTextureWrap(result, WrapRepeat, WrapRepeat)
```

## Using Textures in Shaders

### Vertex Shader:

```glsl
#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec2 inTexCoord;

layout(location = 0) out vec2 fragTexCoord;

void main() {
    gl_Position = vec4(inPosition, 1.0);
    fragTexCoord = inTexCoord;
}
```

### Fragment Shader:

```glsl
#version 450

layout(location = 0) in vec2 fragTexCoord;
layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform sampler2D texSampler;

void main() {
    outColor = texture(texSampler, fragTexCoord);
}
```

### Code:

```nim
type VertexTextured = object
  position: array[3, float32]
  texCoord: array[2, float32]

let vertices = [
  VertexTextured(position: [-1'f32, -1, 0], texCoord: [0'f32, 0]),
  VertexTextured(position: [1'f32, -1, 0], texCoord: [1'f32, 0]),
  VertexTextured(position: [1'f32, 1, 0], texCoord: [1'f32, 1]),
  VertexTextured(position: [-1'f32, 1, 0], texCoord: [0'f32, 1]),
]

let texture = createCheckerboard(device, 256)
# TODO: Bind texture in render loop (API coming soon)
```

## Texture Coordinates

### UV Space:

```
(0,0) ───────────> (1,0)
  │                   │
  │                   │
  │     Texture       │
  │                   │
  │                   │
  v                   v
(0,1) ───────────> (1,1)
```

- Origin at **top-left** (OpenGL convention)
- U axis: left (0) → right (1)
- V axis: top (0) → bottom (1)

### Common Patterns:

```nim
# Full quad (entire texture)
texCoords = [(0, 0), (1, 0), (1, 1), (0, 1)]

# Half texture (left side)
texCoords = [(0, 0), (0.5, 0), (0.5, 1), (0, 1)]

# Tiled (2x2)
texCoords = [(0, 0), (2, 0), (2, 2), (0, 2)]
```

## Performance Tips

### 1. Power-of-Two Textures

Use sizes like 256, 512, 1024 for best performance:

```nim
# Good
let tex = galCreateTexture(device, 512, 512, TextureRGBA8)

# Avoid (non-power-of-two)
let tex = galCreateTexture(device, 500, 500, TextureRGBA8)
```

### 2. Use Appropriate Formats

```nim
# Grayscale? Use R8
let heightMap = galCreateTexture(device, 1024, 1024, TextureR8)  # 1MB

# Not this (wastes memory)
let heightMap = galCreateTexture(device, 1024, 1024, TextureRGBA8)  # 4MB
```

### 3. Batch Texture Uploads

```nim
# Create all textures
let tex1 = galCreateTexture(...)
let tex2 = galCreateTexture(...)

# Then upload all at once
galUploadTexture(device, tex1, data1)
galUploadTexture(device, tex2, data2)
```

### 4. Texture Atlases

Combine multiple textures into one:

```
┌────────┬────────┐
│ Tex 1  │ Tex 2  │
├────────┼────────┤
│ Tex 3  │ Tex 4  │
└────────┴────────┘
```

Reduces texture switches (faster rendering).

## Common Use Cases

### 1. Sprite Rendering

```nim
let spriteSheet = loadTexture(device, "sprites.png")

# Render sub-rectangle
let uMin = spriteIndex * spriteWidth / sheetWidth
let uMax = (spriteIndex + 1) * spriteWidth / sheetWidth
# Update tex coords accordingly
```

### 2. Terrain Texturing

```nim
let grass = loadTexture(device, "grass.png")
let rock = loadTexture(device, "rock.png")
let dirt = loadTexture(device, "dirt.png")

# Blend based on terrain height/slope in shader
```

### 3. UI Elements

```nim
let buttonNormal = loadTexture(device, "button.png")
let buttonHover = loadTexture(device, "button_hover.png")
let buttonPressed = loadTexture(device, "button_pressed.png")

# Switch based on UI state
```

### 4. Post-Processing

```nim
# Render scene to texture
let sceneTexture = galCreateTexture(device, screenW, screenH, TextureRGBA8)

# Apply effects in shader
# blur, bloom, color grading, etc.
```

## Troubleshooting

### Problem: Texture appears black

**Possible causes:**
1. Forgot to upload data: `galUploadTexture(device, tex, data)`
2. Invalid pixel data (all zeros)
3. Wrong format specified

### Problem: Texture is flipped/mirrored

**Solution:**
- Flip pixel data vertically before upload, or
- Flip UV coordinates in shader: `texCoord.y = 1.0 - texCoord.y`

### Problem: Texture looks pixelated

**Solution:**
```nim
galSetTextureFilter(texture, FilterLinear, FilterLinear)
```

### Problem: Texture has seams when tiled

**Solutions:**
1. Use seamless texture (design)
2. Use `WrapMirror` instead of `WrapRepeat`
3. Add padding to texture edges

## Advanced Topics

### Mipmaps (Coming Soon)

```nim
# TODO: Generate mipmap chain
galGenerateMipmaps(texture)
```

### Compressed Textures (Coming Soon)

```nim
# TODO: Support for compressed formats (DXT, ETC, ASTC)
```

### 3D Textures (Coming Soon)

```nim
# TODO: Volume textures for volumetric effects
```

### Cubemaps (Coming Soon)

```nim
# TODO: Skybox and environment mapping
```

## API Reference

### Functions:

```nim
proc galCreateTexture*(device, width, height, format): GalTexture
proc galUploadTexture*(device, texture, data)
proc galSetTextureFilter*(texture, minFilter, magFilter)
proc galSetTextureWrap*(texture, wrapS, wrapT)
proc galDestroyTexture*(device, texture)
```

### Types:

```nim
type TextureFormat* = enum
  TextureRGBA8
  TextureRGB8
  TextureR8
  TextureDepth24Stencil8

type TextureFilter* = enum
  FilterNearest
  FilterLinear

type TextureWrap* = enum
  WrapRepeat
  WrapClamp
  WrapMirror
```

## Summary

✅ Easy texture creation with multiple formats
✅ Simple pixel upload from memory
✅ Configurable filtering (nearest/linear)
✅ Flexible wrapping modes (repeat/clamp/mirror)
✅ Works identically on OpenGL and SDL_GPU
✅ Efficient GPU memory usage

**Next**: See `GAL_SHADERS.md` for using textures in shaders!
