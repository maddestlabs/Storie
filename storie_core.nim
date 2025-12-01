## Storie Core - Platform-agnostic engine core
## Contains the app state, layer system, and lifecycle management

import platform/pixel_types

export pixel_types

# ================================================================
# APP STATE
# ================================================================

type
  AppState* = ref object
    running*: bool
    width*, height*: int  # Window dimensions in pixels
    frameCount*: int
    totalTime*: float
    fps*: float
    lastFpsUpdate*: float
    targetFps*: float
    layers*: seq[Layer]
    lastMouseX*, lastMouseY*: int

# ================================================================
# LAYER SYSTEM
# ================================================================

proc addLayer*(state: AppState, id: string, z: int): Layer =
  let layer = Layer(
    id: id,
    z: z,
    visible: true,
    renderBuffer: newRenderBuffer(state.width, state.height)
  )
  state.layers.add(layer)
  return layer

proc getLayer*(state: AppState, id: string): Layer =
  for layer in state.layers:
    if layer.id == id:
      return layer
  return nil

proc removeLayer*(state: AppState, id: string) =
  var i = 0
  while i < state.layers.len:
    if state.layers[i].id == id:
      state.layers.delete(i)
    else:
      i += 1

proc resizeLayers*(state: AppState, newWidth, newHeight: int) =
  ## Resize all layer buffers to match new size
  for layer in state.layers:
    layer.renderBuffer = newRenderBuffer(newWidth, newHeight)

proc compositeLayers*(state: AppState): RenderBuffer =
  ## Composite all visible layers into a single render buffer
  let compositeBuffer = newRenderBuffer(state.width, state.height)
  
  if state.layers.len == 0:
    return compositeBuffer
  
  # Sort layers by z-index
  for i in 0 ..< state.layers.len:
    for j in i + 1 ..< state.layers.len:
      if state.layers[j].z < state.layers[i].z:
        swap(state.layers[i], state.layers[j])
  
  # Merge all visible layer commands
  for layer in state.layers:
    if layer.visible:
      for cmd in layer.renderBuffer.commands:
        compositeBuffer.commands.add(cmd)
  
  return compositeBuffer

# ================================================================
# FPS CONTROL
# ================================================================

proc setTargetFps*(state: AppState, fps: float) =
  state.targetFps = fps
