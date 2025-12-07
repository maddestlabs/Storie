## GAL Texture Example
## Demonstrates texture creation, upload, and sampling

import ../platform/gal

proc createCheckerboardTexture(device: GalDevice, size: int): GalTexture =
  ## Create a simple checkerboard texture
  result = galCreateTexture(device, size, size, TextureRGBA8)
  
  var pixels = newSeq[uint8](size * size * 4)
  let checkSize = size div 8
  
  for y in 0..<size:
    for x in 0..<size:
      let checker = ((x div checkSize) + (y div checkSize)) mod 2
      let idx = (y * size + x) * 4
      
      if checker == 0:
        # White
        pixels[idx] = 255
        pixels[idx + 1] = 255
        pixels[idx + 2] = 255
        pixels[idx + 3] = 255
      else:
        # Black
        pixels[idx] = 0
        pixels[idx + 1] = 0
        pixels[idx + 2] = 0
        pixels[idx + 3] = 255
  
  galUploadTexture(device, result, addr pixels[0])
  galSetTextureFilter(result, FilterLinear, FilterLinear)
  galSetTextureWrap(result, WrapRepeat, WrapRepeat)
  
  echo "Created ", size, "x", size, " checkerboard texture"

proc createGradientTexture(device: GalDevice, width, height: int): GalTexture =
  ## Create a color gradient texture
  result = galCreateTexture(device, width, height, TextureRGBA8)
  
  var pixels = newSeq[uint8](width * height * 4)
  
  for y in 0..<height:
    for x in 0..<width:
      let idx = (y * width + x) * 4
      pixels[idx] = uint8((x * 255) div width)       # Red gradient X
      pixels[idx + 1] = uint8((y * 255) div height)  # Green gradient Y
      pixels[idx + 2] = 128                           # Blue constant
      pixels[idx + 3] = 255                           # Alpha
  
  galUploadTexture(device, result, addr pixels[0])
  galSetTextureFilter(result, FilterLinear, FilterLinear)
  galSetTextureWrap(result, WrapClamp, WrapClamp)
  
  echo "Created ", width, "x", height, " gradient texture"

proc main() =
  echo "GAL Texture Example"
  echo "=================="
  
  let device = galCreateDevice()
  
  # Test different texture types
  echo "\nCreating textures..."
  let checker = createCheckerboardTexture(device, 256)
  let gradient = createGradientTexture(device, 512, 256)
  
  # Test texture parameters
  echo "\nTesting texture parameters..."
  
  echo "Setting nearest filtering..."
  galSetTextureFilter(checker, FilterNearest, FilterNearest)
  
  echo "Setting mirrored wrap..."
  galSetTextureWrap(gradient, WrapMirror, WrapMirror)
  
  # Cleanup
  echo "\nCleaning up..."
  galDestroyTexture(device, checker)
  galDestroyTexture(device, gradient)
  galDestroyDevice(device)
  
  echo "\nDone!"

when isMainModule:
  main()
