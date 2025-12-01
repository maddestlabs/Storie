# Platform Architecture

This directory contains the platform abstraction layer for Storie, designed to support multiple backends (terminal, SDL3, etc.).

## Structure

```
platform/
├── platform_types.nim          # Core types (Color, Style, Buffer, Input events)
├── platform_interface.nim      # Platform interface (methods each backend implements)
├── terminal/
│   └── terminal_platform.nim   # Terminal backend implementation
└── (future) sdl/
    └── sdl_platform.nim        # SDL3 backend implementation
```

## Design Goals

1. **Separation of Concerns**: Platform-specific code (terminal ANSI, SDL rendering) is isolated
2. **Common Buffer System**: All platforms render to TermBuffer, then display it their own way
3. **Pluggable Backends**: Easy to add new platforms without touching core engine
4. **Type Safety**: Platform interface uses Nim methods for compile-time safety

## Usage

### Current (Terminal-only)

```nim
import storie  # Works as before, uses terminal
```

### Future (With Platform Abstraction)

```nim
import platform
import storie_core

let platform = createPlatform()  # Creates terminal or SDL platform
platform.init()

# Engine uses platform for I/O
# ...

platform.shutdown()
```

## Migration Status

- ✅ Platform types extracted
- ✅ Terminal backend created
- ✅ Lib modules renamed (term_*)
- ⏳ Storie.nim refactor (keeping legacy path for now)
- ⏳ SDL3 backend (future)

## Adding a New Platform

1. Create `platform/myplatform/myplatform_platform.nim`
2. Implement `Platform` interface methods:
   - `init()` - Setup
   - `shutdown()` - Cleanup
   - `getSize()` - Window/screen dimensions
   - `pollEvents()` - Input handling
   - `display()` - Render buffer to screen
   - `setTargetFps()` - Frame rate control
   - `sleepFrame()` - Timing
3. Update `platform.nim` to export your backend
4. Compile with `-d:myplatform` flag

## Terminal Backend Details

The terminal backend (`terminal_platform.nim`):
- Uses ANSI escape sequences for rendering
- Supports true color (24-bit), 256-color, and 8-color modes
- Handles keyboard, mouse, and resize events
- Works on Linux, macOS, Windows (with modern terminal)
- Falls back gracefully in WASM (no-op)

The terminal backend reuses existing platform-agnostic input parsing and rendering code from `storie.nim`.

## SDL3 Backend (Planned)

Will provide:
- Hardware-accelerated rendering
- Texture support
- Audio playback  
- Gamepad input
- Same TermBuffer-based API for compatibility
- Extended features (sprites, particles, etc.)

Users can write once, compile for both terminal and GUI!
