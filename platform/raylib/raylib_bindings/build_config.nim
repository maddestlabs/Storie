## Build Configuration - Compiler flags and linking setup for Raylib
## Used by all Raylib binding modules

when not defined(emscripten):
  # Native builds: Use vendored raylib built in build/vendor/raylib-build
  const raylibSrcPath* = "vendor/raylib-src/src"
  const raylibBuildPath* = "build/vendor/raylib-build/raylib"
  
  # Raylib headers from source
  {.passC: "-I" & raylibSrcPath.}
  
  # Link raylib library (will be provided by build.sh with --passL)
  # {.passL: raylibBuildPath & "/libraylib.a".}
  
  # Platform-specific dependencies  
  when defined(linux):
    {.passL: "-lGL -lm -lpthread -ldl -lrt -lX11".}
  elif defined(macosx):
    {.passL: "-framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo".}
  elif defined(windows):
    {.passL: "-lopengl32 -lgdi32 -lwinmm".}

else:
  # Emscripten: Raylib built from source for WebAssembly
  const raylibSrcPath* = "vendor/raylib-src/src"
  const raylibBuildPath* = "build-wasm/vendor/raylib-build/raylib"
  
  # Raylib headers
  {.passC: "-I" & raylibSrcPath.}
  
  # Link against the WebAssembly library (provided by build-web.sh with --passL via EMCC_CFLAGS)
  # {.passL: raylibBuildPath & "/libraylib.a".}
  
  # Emscripten flags for raylib
  {.passL: "-s USE_GLFW=3".}
  {.passL: "-s ALLOW_MEMORY_GROWTH=1".}
