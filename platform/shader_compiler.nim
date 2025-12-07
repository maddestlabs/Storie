## Shader Compiler Utilities
## Compiles GLSL to SPIR-V for SDL_GPU, keeps GLSL for OpenGL

import os, osproc, strutils

type
  ShaderCompileResult* = object
    success*: bool
    spirvPath*: string  # For SDL_GPU
    glslPath*: string   # For OpenGL
    errorMsg*: string

proc compileGLSLtoSPIRV*(glslPath: string, stage: string): ShaderCompileResult =
  ## Compile GLSL to SPIR-V using glslangValidator or glslc
  ## stage: "vert" or "frag"
  result.glslPath = glslPath
  
  let outputPath = glslPath.changeFileExt(".spv")
  result.spirvPath = outputPath
  
  # Try glslc first (from Vulkan SDK)
  var cmd = ""
  if findExe("glslc") != "":
    cmd = "glslc -fshader-stage=" & stage & " \"" & glslPath & "\" -o \"" & outputPath & "\""
  elif findExe("glslangValidator") != "":
    cmd = "glslangValidator -V -S " & stage & " \"" & glslPath & "\" -o \"" & outputPath & "\""
  else:
    result.success = false
    result.errorMsg = "Shader compiler not found. Install Vulkan SDK (glslc or glslangValidator)"
    return
  
  let (output, exitCode) = execCmdEx(cmd)
  
  if exitCode == 0 and fileExists(outputPath):
    result.success = true
    echo "[Shader Compiler] Compiled: ", glslPath, " -> ", outputPath
  else:
    result.success = false
    result.errorMsg = "Compilation failed:\n" & output
    echo "[Shader Compiler] Error compiling ", glslPath, ":\n", output

proc compileShaderPair*(vertGlslPath, fragGlslPath: string): tuple[vert, frag: ShaderCompileResult] =
  ## Compile a vertex and fragment shader pair
  result.vert = compileGLSLtoSPIRV(vertGlslPath, "vert")
  result.frag = compileGLSLtoSPIRV(fragGlslPath, "frag")

proc ensureShadersCompiled*(shaderDir: string) =
  ## Compile all GLSL shaders in a directory to SPIR-V
  echo "[Shader Compiler] Scanning ", shaderDir
  
  for file in walkFiles(shaderDir / "*.vert"):
    discard compileGLSLtoSPIRV(file, "vert")
  
  for file in walkFiles(shaderDir / "*.frag"):
    discard compileGLSLtoSPIRV(file, "frag")

proc getSPIRVPath*(glslPath: string): string =
  ## Get the SPIR-V path for a GLSL shader
  glslPath.changeFileExt(".spv")

proc needsRecompile*(glslPath: string): bool =
  ## Check if GLSL needs recompilation
  let spirvPath = getSPIRVPath(glslPath)
  
  if not fileExists(spirvPath):
    return true
  
  let glslTime = getLastModificationTime(glslPath)
  let spirvTime = getLastModificationTime(spirvPath)
  
  return glslTime > spirvTime
