# Assets Directory Structure

This directory contains assets that are preloaded into WASM builds.

## Directory Structure

```
docs/assets/
├── audio/          # Audio files (.wav, .ogg, .mp3)
├── fonts/          # Font files
│   └── core/       # Core Google Fonts (preloaded in full builds)
├── images/         # Image files (.png, .jpg, .gif)
└── models/         # 3D models (.obj, .gltf)
```

## Using Assets in WASM

### Basic Build (`build-web.sh`)

The basic build now automatically preloads the entire `docs/assets/` folder if it exists.

**Access files at runtime:**
```nim
# Audio
let sound = LoadSound("/assets/audio/test.wav")
PlaySound(sound)

# Images  
let texture = LoadTexture("/assets/images/sprite.png")

# Fonts
let font = LoadFont("/assets/fonts/custom.ttf")
```

### Full Build (`build-web-full.sh`)

The full build preloads fonts from `docs/assets/fonts/core/` plus any other assets.

## Adding Your Audio Files

1. Place `.wav` files in `docs/assets/audio/`:
   ```bash
   cp my-sound.wav docs/assets/audio/
   ```

2. Rebuild WASM:
   ```bash
   ./build-web.sh
   ```

3. Access in code:
   ```nim
   let sound = LoadSound("/assets/audio/my-sound.wav")
   if IsAudioDeviceReady():
     PlaySound(sound)
   ```

## Asset Formats Supported

### Audio (with `build-web-full.sh`)
- ✅ `.wav` - Waveform Audio
- ✅ `.ogg` - Ogg Vorbis
- ✅ `.mp3` - MPEG Audio
- ✅ `.flac` - Free Lossless Audio Codec
- ✅ `.xm`, `.mod` - Module formats

### Images
- ✅ `.png` - Portable Network Graphics
- ✅ `.jpg`/`.jpeg` - JPEG
- ✅ `.gif` - Graphics Interchange Format
- ✅ `.bmp` - Bitmap
- ✅ `.qoi` - Quite OK Image

### 3D Models (with `build-web-full.sh`)
- ✅ `.obj` - Wavefront OBJ
- ✅ `.gltf`/`.glb` - GL Transmission Format
- ✅ `.vox` - MagicaVoxel

### Fonts
- ✅ `.ttf` - TrueType Font
- ✅ `.otf` - OpenType Font

## File Size Considerations

Each file in `docs/assets/` adds to the download size:
- Small WAV files: ~50-500 KB
- PNG images: ~10-200 KB per image
- Fonts: ~100-500 KB per font
- 3D models: ~500 KB - 5 MB

**Tip:** Keep assets small for web deployment. Use compressed formats:
- Audio: OGG instead of WAV
- Images: PNG with compression or WebP
- Models: Optimize mesh/texture resolution

## Build Output

When assets are preloaded, you'll see an additional file:
```
docs/
├── storie-raylib.js
├── storie-raylib.wasm
└── storie-raylib.data    ← Assets packed here
```

The `.data` file contains all preloaded assets and is automatically loaded by Emscripten.

## Testing Audio in Browser

```nim
import platform/audio

proc testAudio() =
  let sys = newAudioSystem()
  
  if not sys.initAudio():
    echo "Failed to initialize audio"
    return
  
  # Load preloaded asset
  let sound = sys.loadSound("/assets/audio/beep.wav")
  
  # Play it
  sys.playSound(sound)
  
  # Wait for playback
  while sys.isSoundPlaying(sound):
    discard
  
  sys.shutdownAudio()

testAudio()
```

## Alternative: Runtime Loading (Not Recommended)

You can also use Emscripten's FS API to load files at runtime from URLs, but this is more complex and slower than preloading.

## Quick Start

1. **Add a test WAV file:**
   ```bash
   # Generate a simple beep (requires sox)
   sox -n docs/assets/audio/beep.wav synth 0.5 sine 440
   ```

2. **Rebuild:**
   ```bash
   ./build-web.sh
   ```

3. **Use in code:**
   ```nim
   let sound = LoadSound("/assets/audio/beep.wav")
   PlaySound(sound)
   ```

Done! Your audio file is now embedded in the WASM build.
