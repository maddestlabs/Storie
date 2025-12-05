## Raylib Text - Font loading and text drawing

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const textBindingMetadata* = BindingMetadata(
    library: "raylib",
    module: "text",
    features: @["fonts", "text_rendering", "text_measurement"],
    functions: @[
      "GetFontDefault", "LoadFont", "LoadFontEx", "LoadFontFromMemory", "UnloadFont",
      "DrawFPS", "DrawText", "DrawTextEx", "DrawTextPro",
      "MeasureText", "MeasureTextEx"
    ],
    minimalBuild: true,   # Text is included in minimal (uses default font)
    estimatedSize: 45_000,  # ~45KB for text rendering
    dependencies: @["core", "types"],
    description: "Font loading and text rendering with raylib's built-in default font"
  )
  
  static:
    getRegistry().registerBinding(textBindingMetadata)

import build_config
import types
export types

# ================================================================
# FONT LOADING
# ================================================================

proc GetFontDefault*(): Font {.importc: "GetFontDefault", header: "raylib.h".}
proc LoadFont*(fileName: cstring): Font {.importc: "LoadFont", header: "raylib.h".}
proc LoadFontEx*(fileName: cstring, fontSize: cint, fontChars: ptr cint, glyphCount: cint): Font {.importc: "LoadFontEx", header: "raylib.h".}
proc LoadFontFromMemory*(fileType: cstring, fileData: ptr uint8, dataSize, fontSize: cint, fontChars: ptr cint, glyphCount: cint): Font {.importc: "LoadFontFromMemory", header: "raylib.h".}
proc UnloadFont*(font: Font) {.importc: "UnloadFont", header: "raylib.h".}

# ================================================================
# TEXT DRAWING
# ================================================================

proc DrawFPS*(posX, posY: cint) {.importc: "DrawFPS", header: "raylib.h".}
proc DrawText*(text: cstring, posX, posY, fontSize: cint, color: Color) {.importc: "DrawText", header: "raylib.h".}
proc DrawTextEx*(font: Font, text: cstring, position: Vector2, fontSize, spacing: float32, tint: Color) {.importc: "DrawTextEx", header: "raylib.h".}
proc DrawTextPro*(font: Font, text: cstring, position, origin: Vector2, rotation, fontSize, spacing: float32, tint: Color) {.importc: "DrawTextPro", header: "raylib.h".}

# ================================================================
# TEXT MEASUREMENT
# ================================================================

proc MeasureText*(text: cstring, fontSize: cint): cint {.importc: "MeasureText", header: "raylib.h".}
proc MeasureTextEx*(font: Font, text: cstring, fontSize, spacing: float32): Vector2 {.importc: "MeasureTextEx", header: "raylib.h".}
