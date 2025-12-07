## Simple test to verify OpenGL texture bindings work
## Compile with: nim check -d:sdl3 examples/test_opengl_textures.nim

import platform/gal

echo "Testing GAL texture API..."

# Create device
let device = galCreateDevice()
echo "✓ Device created"

# Create texture
let texture = galCreateTexture(device, TextureRGBA8, 256, 256)
echo "✓ Texture created (", texture.width, "x", texture.height, ")"

# Create test data
var pixels = newSeq[uint8](256 * 256 * 4)
for i in 0..<pixels.len:
  pixels[i] = (i mod 256).uint8

# Upload texture data
galUploadTexture(device, texture, addr pixels[0])
echo "✓ Texture data uploaded"

# Set filtering
galSetTextureFilter(texture, FilterLinear, FilterLinear)
echo "✓ Texture filtering set"

# Set wrapping
galSetTextureWrap(texture, WrapRepeat, WrapRepeat)
echo "✓ Texture wrapping set"

echo "\n✅ All GAL texture operations compile successfully!"
echo "Note: Texture cleanup omitted for compile-time test"
