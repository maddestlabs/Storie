## SDL3 Core - Initialization, window management, and basic functionality

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const coreBindingMetadata* = BindingMetadata(
    library: "sdl3",
    module: "core",
    features: @["init", "window", "video", "opengl"],
    functions: @[
      "SDL_Init", "SDL_Quit",
      "SDL_CreateWindow", "SDL_DestroyWindow",
      "SDL_GetWindowSize", "SDL_SetWindowSize",
      "SDL_GL_SetAttribute", "SDL_GL_CreateContext", "SDL_GL_DeleteContext",
      "SDL_GL_SwapWindow"
    ],
    minimalBuild: true,   # Core is always included
    estimatedSize: 150_000,  # ~150KB for SDL3 core
    dependencies: @["types"],
    description: "SDL3 initialization, window management, and OpenGL context"
  )
  
  static:
    getRegistry().registerBinding(coreBindingMetadata)

import build_config
import types
export types

# Initialization constants
var
  SDL_INIT_VIDEO* {.importc, header: "SDL3/SDL_init.h".}: uint32
  SDL_INIT_AUDIO* {.importc, header: "SDL3/SDL_init.h".}: uint32
  SDL_INIT_EVENTS* {.importc, header: "SDL3/SDL_init.h".}: uint32

# Window flags
var
  SDL_WINDOW_RESIZABLE* {.importc, header: "SDL3/SDL_video.h".}: uint64
  SDL_WINDOW_OPENGL* {.importc, header: "SDL3/SDL_video.h".}: uint64

# OpenGL attributes
var
  SDL_GL_CONTEXT_MAJOR_VERSION* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_CONTEXT_MINOR_VERSION* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_CONTEXT_PROFILE_MASK* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_CONTEXT_PROFILE_CORE* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_CONTEXT_PROFILE_ES* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_DOUBLEBUFFER* {.importc, header: "SDL3/SDL_video.h".}: cint
  SDL_GL_DEPTH_SIZE* {.importc, header: "SDL3/SDL_video.h".}: cint

# Core initialization and shutdown
proc SDL_Init*(flags: uint32): cint {.importc, header: "SDL3/SDL_init.h".}
proc SDL_Quit*() {.importc, header: "SDL3/SDL_init.h".}

# Window management
proc SDL_CreateWindow*(title: cstring, w, h: cint, flags: uint64): ptr SDL_Window {.importc, header: "SDL3/SDL_video.h".}
proc SDL_DestroyWindow*(window: ptr SDL_Window) {.importc, header: "SDL3/SDL_video.h".}
proc SDL_GetWindowSize*(window: ptr SDL_Window, w, h: ptr cint): bool {.importc, header: "SDL3/SDL_video.h".}
proc SDL_SetWindowSize*(window: ptr SDL_Window, w, h: cint): bool {.importc, header: "SDL3/SDL_video.h".}

# OpenGL context management
proc SDL_GL_SetAttribute*(attr: cint, value: cint): cint {.importc, header: "SDL3/SDL_video.h".}
proc SDL_GL_CreateContext*(window: ptr SDL_Window): SDL_GLContext {.importc, header: "SDL3/SDL_video.h".}
proc SDL_GL_DestroyContext*(context: SDL_GLContext) {.importc, header: "SDL3/SDL_video.h".}
proc SDL_GL_SetSwapInterval*(interval: cint): cint {.importc, header: "SDL3/SDL_video.h".}
proc SDL_GL_SwapWindow*(window: ptr SDL_Window) {.importc, header: "SDL3/SDL_video.h".}

# Error handling
proc SDL_GetError*(): cstring {.importc, header: "SDL3/SDL_error.h".}

# Timing
proc SDL_Delay*(ms: uint32) {.importc, header: "SDL3/SDL_timer.h".}

# Emscripten-specific functions for canvas handling
when defined(emscripten):
  proc emscripten_get_canvas_element_size*(target: cstring, width, height: ptr cint): cint {.importc, header: "emscripten/html5.h".}
