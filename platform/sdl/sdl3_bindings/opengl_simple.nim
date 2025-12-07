## Simple OpenGL bindings - uses Nim's standard opengl module
## This handles Windows function loading automatically

when defined(emscripten):
  {.passL: "-lGL".}

# Use Nim's built-in OpenGL bindings which handle Windows wglGetProcAddress automatically
import std/opengl

# Re-export everything
export opengl

# Load OpenGL functions (required on Windows after creating GL context)
proc loadOpenGLProcs*() =
  when not defined(emscripten):
    loadExtensions()
