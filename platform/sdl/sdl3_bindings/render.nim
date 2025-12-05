## SDL3 Render - 2D rendering, textures, and drawing primitives

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const renderBindingMetadata* = BindingMetadata(
    library: "sdl3",
    module: "render",
    features: @["2d_rendering", "textures", "primitives"],
    functions: @[
      "SDL_CreateRenderer", "SDL_DestroyRenderer",
      "SDL_SetRenderDrawColor", "SDL_SetRenderViewport",
      "SDL_RenderClear", "SDL_RenderFillRect", "SDL_RenderLine", "SDL_RenderPoint",
      "SDL_RenderPresent",
      "SDL_CreateTextureFromSurface", "SDL_DestroyTexture", "SDL_RenderTexture",
      "SDL_DestroySurface",
      "SDL_RenderDebugText"
    ],
    minimalBuild: true,   # 2D rendering is core functionality
    estimatedSize: 100_000,  # ~100KB for rendering
    dependencies: @["core", "types"],
    description: "2D rendering, texture management, and drawing primitives"
  )
  
  static:
    getRegistry().registerBinding(renderBindingMetadata)

import build_config
import types
export types

# Renderer management
proc SDL_CreateRenderer*(window: ptr SDL_Window, name: cstring): ptr SDL_Renderer {.importc, header: "SDL3/SDL_render.h".}
proc SDL_DestroyRenderer*(renderer: ptr SDL_Renderer) {.importc, header: "SDL3/SDL_render.h".}

# Rendering state
proc SDL_SetRenderDrawColor*(renderer: ptr SDL_Renderer, r, g, b, a: uint8): bool {.importc, header: "SDL3/SDL_render.h".}
proc SDL_SetRenderViewport*(renderer: ptr SDL_Renderer, rect: ptr SDL_Rect): bool {.importc, header: "SDL3/SDL_render.h".}

# Drawing operations
proc SDL_RenderClear*(renderer: ptr SDL_Renderer): bool {.importc, header: "SDL3/SDL_render.h".}
proc SDL_RenderFillRect*(renderer: ptr SDL_Renderer, rect: ptr SDL_FRect): bool {.importc, header: "SDL3/SDL_render.h".}
proc SDL_RenderLine*(renderer: ptr SDL_Renderer, x1, y1, x2, y2: cfloat): bool {.importc, header: "SDL3/SDL_render.h".}
proc SDL_RenderPoint*(renderer: ptr SDL_Renderer, x, y: cfloat): bool {.importc, header: "SDL3/SDL_render.h".}
proc SDL_RenderPresent*(renderer: ptr SDL_Renderer): bool {.importc, header: "SDL3/SDL_render.h".}

# Texture management
proc SDL_CreateTextureFromSurface*(renderer: ptr SDL_Renderer, surface: ptr SDL_Surface): ptr SDL_Texture {.importc, header: "SDL3/SDL_render.h".}
proc SDL_DestroyTexture*(texture: ptr SDL_Texture) {.importc, header: "SDL3/SDL_render.h".}
proc SDL_RenderTexture*(renderer: ptr SDL_Renderer, texture: ptr SDL_Texture, srcrect: ptr SDL_FRect, dstrect: ptr SDL_FRect): bool {.importc, header: "SDL3/SDL_render.h".}

# Surface management
proc SDL_DestroySurface*(surface: ptr SDL_Surface) {.importc, header: "SDL3/SDL_surface.h".}

# Debug text rendering (no TTF needed, built into SDL3)
proc SDL_RenderDebugText*(renderer: ptr SDL_Renderer, x, y: cfloat, text: cstring): bool {.importc, header: "SDL3/SDL_render.h".}
