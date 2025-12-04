## Platform Interface - Abstract base for graphics backends
## Each platform backend must provide these capabilities

import pixel_types

type
  Platform* = ref object of RootObj
    ## Base platform interface - all backends inherit from this
  
  PlatformCapabilities* = object
    ## Features supported by this platform
    maxTextureSize*: int
    mouseSupport*: bool
    resizeEvents*: bool
    hardwareAcceleration*: bool

# ================================================================
# PLATFORM INTERFACE METHODS (must be implemented by each backend)
# ================================================================

method init*(p: Platform, enable3D: bool = false): bool {.base.} =
  ## Initialize the platform backend
  ## Returns true on success
  ## enable3D: whether to initialize with 3D rendering support
  quit "Platform.init() must be overridden"

method shutdown*(p: Platform) {.base.} =
  ## Clean up platform resources
  quit "Platform.shutdown() must be overridden"

method getSize*(p: Platform): tuple[width, height: int] {.base.} =
  ## Get the current display size in pixels
  quit "Platform.getSize() must be overridden"

method getCapabilities*(p: Platform): PlatformCapabilities {.base.} =
  ## Return what features this platform supports
  quit "Platform.getCapabilities() must be overridden"

method pollEvents*(p: Platform): seq[InputEvent] {.base.} =
  ## Poll for input events (keyboard, mouse, resize, etc.)
  ## Returns empty sequence if no events
  quit "Platform.pollEvents() must be overridden"

method display*(p: Platform, renderBuffer: RenderBuffer) {.base.} =
  ## Render the draw commands to the screen
  quit "Platform.display() must be overridden"

method setTargetFps*(p: Platform, fps: float) {.base.} =
  ## Set the target frame rate
  quit "Platform.setTargetFps() must be overridden"

method sleepFrame*(p: Platform, frameTime: float) {.base.} =
  ## Sleep to maintain target framerate
  ## frameTime is time already spent in this frame
  quit "Platform.sleepFrame() must be overridden"

method swapBuffers*(p: Platform) {.base.} =
  ## Swap rendering buffers (if needed by the backend)
  ## Some backends handle this internally in display()
  discard
