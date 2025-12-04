# Multi-Backend Build System

Storie now supports **dual WASM backends** that can be selected at runtime!

## Building

### Build Both Backends
```bash
# Build Raylib backend (409KB, default)
./build-web.sh -r

# Build SDL3 backend (2.6MB, high performance)
./build-web-sdl.sh -r
```

### Build Native
```bash
# Raylib (default)
./build.sh

# SDL3
./build.sh --sdl3
```

## Running

### Web (WASM)
Start a local server:
```bash
cd docs && python3 -m http.server 8000
```

Then open in browser:
- **Raylib** (default): http://localhost:8000
- **SDL3**: http://localhost:8000?platform=sdl

### Native Desktop
```bash
./storie [options]
```

## Backend Comparison

| Backend | WASM Size | Performance | Best For |
|---------|-----------|-------------|----------|
| **Raylib** | 409KB | ~30 FPS | Fast prototyping, small file size |
| **SDL3** | 2.6MB | 60+ FPS | Complex scenes, better performance |

## URL Parameters

- `?platform=raylib` - Load Raylib backend (default)
- `?platform=sdl` - Load SDL3 backend

## Technical Details

### Raylib Backend
- Uses GLFW for web compatibility
- Requires ASYNCIFY for timing (adds overhead)
- Direct C bindings to raylib 5.5
- OpenGL ES2 graphics

### SDL3 Backend  
- Uses `emscripten_set_main_loop` for WASM
- No ASYNCIFY needed (lighter, faster)
- OpenGL 3.3+ for native, WebGL2 for WASM
- Includes SDL_ttf for text rendering

### Code Portability
**All user code in `index.md` is 100% backend-agnostic!** The same markdown file works with both backends without any changes. The platform abstraction layer handles all backend-specific details.

## File Structure

```
docs/
  ├── index.html          # Smart loader (detects ?platform= param)
  ├── index.md            # Your content (backend-agnostic)
  ├── storie-raylib.js    # Raylib backend
  ├── storie-raylib.wasm
  ├── storie-raylib.data
  ├── storie-sdl.js       # SDL3 backend
  ├── storie-sdl.wasm
  └── storie-sdl.data
```

## Desktop Platform Selection

On desktop, specify backend via compile flag:
```bash
# Native with Raylib
./build.sh

# Native with SDL3  
./build.sh --sdl3
```

Or at runtime (planned feature):
```bash
./storie --platform sdl3
```
