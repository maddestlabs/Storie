# SDL3 Platform Backend

This directory contains the SDL3 backend implementation for Storie, using Futhark for automatic C header wrapping.

## Files

- `sdl3_bindings.nim` - Futhark-generated SDL3 bindings
- `sdl_platform.nim` - Platform interface implementation for SDL3
- `generated_sdl3.nim` - Auto-generated bindings (created by Futhark)

## Setup

### Dependencies

SDL3 is included locally in `vendor/SDL3/`. The build process has already installed it.

### Futhark

Futhark is used to automatically generate Nim bindings from SDL3 headers. This gives us:
- Complete SDL3 API coverage (including SDL_ttf, SDL_image, SDL_mixer when added)
- Platform-specific correctness (macros and defines resolved automatically)
- Easy updates when SDL3 evolves

To regenerate bindings (only needed during development):

```bash
nim c -d:useFutharkForStorie test_sdl3.nim
```

For normal usage, the pre-generated `generated_sdl3.nim` is included automatically.

## Usage

```nim
import platform/sdl/sdl_platform

let platform = createSdlPlatform()
if not SdlPlatform(platform).init():
  echo "Failed to initialize SDL3"
  quit(1)

# Use platform...

SdlPlatform(platform).shutdown()
```

## Current Status

### Implemented
- ✅ Window creation and management
- ✅ Event polling (keyboard, mouse, window events)
- ✅ Basic rendering (rectangles, colors)
- ✅ Platform interface compliance
- ✅ Futhark binding generation

### TODO
- ⏳ Font rendering with SDL_ttf
- ⏳ Texture loading with SDL_image
- ⏳ Audio support with SDL_mixer (currently disabled in SDL3 build)
- ⏳ Pixel-based rendering APIs
- ⏳ Performance optimization (dirty rectangles)

## Building

The SDL3 library is built locally in `vendor/SDL3/`. To rebuild:

```bash
cd vendor/SDL3-src/build
cmake .. -DCMAKE_INSTALL_PREFIX=/workspaces/Storie/vendor/SDL3 -DSDL_AUDIO=OFF
make -j$(nproc)
make install
```

## Linking

When compiling Nim programs with SDL3, you need to tell the linker where to find the library:

```bash
nim c \
  --passL:"-L/workspaces/Storie/vendor/SDL3/lib" \
  --passL:"-lSDL3" \
  --passL:"-Wl,-rpath,/workspaces/Storie/vendor/SDL3/lib" \
  your_program.nim
```

Or add to your `.nimble` file:

```nim
when defined(linux):
  switch("passL", "-L/workspaces/Storie/vendor/SDL3/lib")
  switch("passL", "-lSDL3")
  switch("passL", "-Wl,-rpath,/workspaces/Storie/vendor/SDL3/lib")
```

## Why Futhark over Existing SDL3 Wrapper?

The existing Nim SDL3 wrapper is:
- 9 months old (potentially missing recent SDL3 changes)
- Incomplete (no SDL_ttf, SDL_image, SDL_mixer)
- Requires manual updates for new SDL3 features

Futhark gives us:
- Automatic, complete coverage of SDL3
- Easy regeneration as SDL3 updates
- Platform-specific correctness via Clang
- Same approach can wrap SDL_ttf, SDL_image, SDL_mixer seamlessly

## Testing

Run the test program:

```bash
nim c -d:useFutharkForStorie test_sdl3.nim
./test_sdl3
```

This will:
1. Generate SDL3 bindings via Futhark
2. Create an SDL window
3. Verify event handling works
4. Clean up and exit
