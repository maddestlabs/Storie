# Storie

Storie is a hackable engine designed for fast prototyping with a clear path to native compilation.

- Built with [Nim](https://nim-lang.org/). Readable code, fast compilation and small binaries.
- Write markdown with executable code blocks in simplified Nim via [Nimini](https://github.com/maddestlabs/nimini).
- Code with [raylib](https://www.raylib.com/) as an entry point.
- Auto-converts to [SDL3](https://wiki.libsdl.org/SDL3/FrontPage) for more robust rendering and platform support.
- Compiles to WASM (via Emscripten) by default with easy compilation to native.

Swap backends (Raylib/SDL3), modify anything, break things. It's made for tinkerers who want zero constraints.

Check it out live: [Demo](https://maddestlabs.github.io/storie/)

GitHub Gist examples:
- [Audio - Sinewave](https://maddestlabs.github.io/storie?gist=b515ad4b2cf3897bd787e8b5e45c7024&platform=sdl-full) | [Source Gist](https://gist.github.com/R3V1Z3/b515ad4b2cf3897bd787e8b5e45c7024)
- [3D - OpenGL](https://maddestlabs.github.io/storie?gist=1fc7e8ae84beee67a5b90cb0866e5d7c&platform=sdl-full) | [Source Gist](https://gist.github.com/R3V1Z3/1fc7e8ae84beee67a5b90cb0866e5d7c)

The engine is built around GitHub features. No need to actually install Nim, or anything for that matter. Just create a new repo from the Storie template, update index.md with your own content and it'll auto-compile for the web. Enable GitHub Pages and you'll see that content served live within moments. GitHub Actions take care of the full compilation process.

## Features

Core engine features:
- **Cross-Platform** - Runs natively and in web browsers via WebAssembly
- **Fast-Prototyping** - Write code on GitHub Gist and see it run live. [Example](https://maddestlabs.github.io/storie?gist=bd236fe257f02e371e04f7d9899be0c2) | [Source Gist](https://gist.github.com/R3V1Z3/bd236fe257f02e371e04f7d9899be0c2)
- **SDL3-powered** - Code in Raylib, get the same code rendered via SDL3. [Example](https://maddestlabs.github.io/storie?gist=bd236fe257f02e371e04f7d9899be0c2&platform=sdl-full)

## Getting Started

Quick Start:
- Create a gist using Markdown and Nim code blocks. [Example Gist](https://gist.github.com/R3V1Z3/bd236fe257f02e371e04f7d9899be0c2)
- See your gist running live: `https://maddestlabs.github.io/Storie?gist=GistID`

Create your own project:
- Create a template from Storie and enable GitHub Pages
- Update index.md with your content and commit the change
- See your content running live in moments

Native compilation:
- In your repo, go to Actions -> Export Code and get the exported code
- Install Nim locally
- Replace index.nim with your exported code
- Choose your backend:
  - Raylib (default): `./build.sh`
  - SDL3 + OpenGL: `./build-cmake.sh` 
  - SDL3 + GPU (Vulkan/D3D12/Metal): `./build-sdlgpu.sh`
  - Web: `./build-web.sh`
  - Windows: `build-win.bat`

You'll get a native compiled binary in just moments, Nim compiles super fast.

## Graphics Backends

Storie supports multiple graphics backends:

| Backend           | API                | Platforms      | WASM      | Use Case                       |
|-------------------|--------------------|----------------|-----------|--------------------------------|
| **Raylib**        | Raylib 3D          | All            | ✅ WebGL | Easiest, great for prototyping |
| **SDL3 + OpenGL** | OpenGL 3.3         | All            | ✅ WebGL | Balance of ease and control    |
| **SDL3 + GPU**    | Vulkan/D3D12/Metal | Desktop/Mobile | ⏳ Future | Best performance, modern GPUs  |

**Note:** SDL_GPU WebGPU backend for WASM is not yet available. For WASM builds, use OpenGL/WebGL.

### SDL_GPU Backend (NEW!)

For production builds requiring maximum performance:

```bash
# Compile shaders first (one-time setup)
./compile-shaders.sh

# Build with SDL_GPU
./build-sdlgpu.sh
```

**Benefits:**
- 27% less CPU overhead vs OpenGL
- Vulkan (Linux/Windows), Direct3D 12 (Windows), Metal (macOS/iOS)
- Modern GPU architecture
- Better for complex 3D scenes

**WASM Note:** SDL_GPU doesn't support WebGPU yet. For web builds, use:
```bash
./build-web.sh        # Raylib (simplest)
./build-web-sdl.sh    # SDL3 + WebGL
```

See `START_HERE_SDL_GPU.md` and `SDL_GPU_WASM_STATUS.md` for details.

## History

- Successor to [Storiel](https://github.com/maddestlabs/storiel), the terminal based proof-of-concept with Lua scripting.
- Rebuilt from [Backstorie](https://github.com/maddestlabs/backstorie), a terminal focused template providing a more robust foundation for further projects.
