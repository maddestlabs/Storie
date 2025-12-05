## SDL3_ttf - TrueType font rendering

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const ttfBindingMetadata* = BindingMetadata(
    library: "sdl3",
    module: "ttf",
    features: @["fonts", "text_rendering", "truetype", "harfbuzz", "complex_scripts"],
    functions: @[
      "TTF_Init", "TTF_Quit",
      "TTF_OpenFont", "TTF_CloseFont",
      "TTF_RenderText_Solid", "TTF_RenderText_Blended", "TTF_RenderGlyph_Solid"
    ],
    minimalBuild: false,  # TTF not in minimal (requires FreeType, HarfBuzz)
    estimatedSize: 1_800_000,  # ~1.8MB (includes FreeType, HarfBuzz, PlutoSVG)
    dependencies: @["core", "render", "types"],
    description: "TrueType font rendering with FreeType, HarfBuzz text shaping, and PlutoSVG color emoji"
  )
  
  static:
    getRegistry().registerBinding(ttfBindingMetadata)

import build_config
import types
export types

const ttfHeader = "SDL3_ttf/SDL_ttf.h"

type
  TTF_Font* {.importc, header: ttfHeader, incompletestruct.} = object

# TTF initialization
proc TTF_Init*(): bool {.importc, header: ttfHeader.}
proc TTF_Quit*() {.importc, header: ttfHeader.}

# Font management
proc TTF_OpenFont*(file: cstring, ptsize: cfloat): ptr TTF_Font {.importc, header: ttfHeader.}
proc TTF_CloseFont*(font: ptr TTF_Font) {.importc, header: ttfHeader.}

# Text rendering
proc TTF_RenderText_Solid*(font: ptr TTF_Font, text: cstring, length: csize_t, fg: SDL_Color): ptr SDL_Surface {.importc, header: ttfHeader.}
proc TTF_RenderText_Blended*(font: ptr TTF_Font, text: cstring, length: csize_t, fg: SDL_Color): ptr SDL_Surface {.importc, header: ttfHeader.}
proc TTF_RenderGlyph_Solid*(font: ptr TTF_Font, ch: uint32, fg: SDL_Color): ptr SDL_Surface {.importc, header: ttfHeader.}
