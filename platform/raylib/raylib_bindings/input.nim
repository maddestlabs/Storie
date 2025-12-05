## Raylib Input - Keyboard, mouse, and gamepad input handling

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const inputBindingMetadata* = BindingMetadata(
    library: "raylib",
    module: "input",
    features: @["keyboard", "mouse", "gamepad", "touch"],
    functions: @[
      "IsKeyPressed", "IsKeyDown", "IsKeyReleased", "IsKeyUp",
      "GetKeyPressed", "GetCharPressed", "SetExitKey",
      "IsMouseButtonPressed", "IsMouseButtonDown", "IsMouseButtonReleased", "IsMouseButtonUp",
      "GetMouseX", "GetMouseY", "GetMousePosition", "GetMouseDelta",
      "SetMousePosition", "SetMouseOffset", "SetMouseScale",
      "GetMouseWheelMove", "SetMouseCursor"
    ],
    minimalBuild: true,   # Input is essential for interaction
    estimatedSize: 40_000,  # ~40KB for input handling
    dependencies: @["core", "types"],
    description: "Keyboard, mouse, gamepad, and touch input handling"
  )
  
  static:
    getRegistry().registerBinding(inputBindingMetadata)

import build_config
import types
export types

# ================================================================
# KEYBOARD
# ================================================================

# Key codes
const
  KEY_NULL* = 0
  KEY_APOSTROPHE* = 39
  KEY_COMMA* = 44
  KEY_MINUS* = 45
  KEY_PERIOD* = 46
  KEY_SLASH* = 47
  KEY_ZERO* = 48
  KEY_ONE* = 49
  KEY_TWO* = 50
  KEY_THREE* = 51
  KEY_FOUR* = 52
  KEY_FIVE* = 53
  KEY_SIX* = 54
  KEY_SEVEN* = 55
  KEY_EIGHT* = 56
  KEY_NINE* = 57
  KEY_SEMICOLON* = 59
  KEY_EQUAL* = 61
  KEY_A* = 65
  KEY_B* = 66
  KEY_C* = 67
  KEY_D* = 68
  KEY_E* = 69
  KEY_F* = 70
  KEY_G* = 71
  KEY_H* = 72
  KEY_I* = 73
  KEY_J* = 74
  KEY_K* = 75
  KEY_L* = 76
  KEY_M* = 77
  KEY_N* = 78
  KEY_O* = 79
  KEY_P* = 80
  KEY_Q* = 81
  KEY_R* = 82
  KEY_S* = 83
  KEY_T* = 84
  KEY_U* = 85
  KEY_V* = 86
  KEY_W* = 87
  KEY_X* = 88
  KEY_Y* = 89
  KEY_Z* = 90
  KEY_SPACE* = 32
  KEY_ESCAPE* = 256
  KEY_ENTER* = 257
  KEY_TAB* = 258
  KEY_BACKSPACE* = 259
  KEY_INSERT* = 260
  KEY_DELETE* = 261
  KEY_RIGHT* = 262
  KEY_LEFT* = 263
  KEY_DOWN* = 264
  KEY_UP* = 265
  KEY_PAGE_UP* = 266
  KEY_PAGE_DOWN* = 267
  KEY_HOME* = 268
  KEY_END* = 269
  KEY_LEFT_SHIFT* = 340
  KEY_LEFT_CONTROL* = 341
  KEY_LEFT_ALT* = 342

proc IsKeyPressed*(key: cint): bool {.importc: "IsKeyPressed", header: "raylib.h".}
proc IsKeyDown*(key: cint): bool {.importc: "IsKeyDown", header: "raylib.h".}
proc IsKeyReleased*(key: cint): bool {.importc: "IsKeyReleased", header: "raylib.h".}
proc IsKeyUp*(key: cint): bool {.importc: "IsKeyUp", header: "raylib.h".}
proc GetKeyPressed*(): cint {.importc: "GetKeyPressed", header: "raylib.h".}
proc GetCharPressed*(): cint {.importc: "GetCharPressed", header: "raylib.h".}
proc SetExitKey*(key: cint) {.importc: "SetExitKey", header: "raylib.h".}

# ================================================================
# MOUSE
# ================================================================

# Mouse buttons
const
  MOUSE_BUTTON_LEFT* = 0
  MOUSE_BUTTON_RIGHT* = 1
  MOUSE_BUTTON_MIDDLE* = 2
  MOUSE_BUTTON_SIDE* = 3
  MOUSE_BUTTON_EXTRA* = 4
  MOUSE_BUTTON_FORWARD* = 5
  MOUSE_BUTTON_BACK* = 6

proc IsMouseButtonPressed*(button: cint): bool {.importc: "IsMouseButtonPressed", header: "raylib.h".}
proc IsMouseButtonDown*(button: cint): bool {.importc: "IsMouseButtonDown", header: "raylib.h".}
proc IsMouseButtonReleased*(button: cint): bool {.importc: "IsMouseButtonReleased", header: "raylib.h".}
proc IsMouseButtonUp*(button: cint): bool {.importc: "IsMouseButtonUp", header: "raylib.h".}
proc GetMouseX*(): cint {.importc: "GetMouseX", header: "raylib.h".}
proc GetMouseY*(): cint {.importc: "GetMouseY", header: "raylib.h".}
proc GetMousePosition*(): Vector2 {.importc: "GetMousePosition", header: "raylib.h".}
proc GetMouseDelta*(): Vector2 {.importc: "GetMouseDelta", header: "raylib.h".}
proc SetMousePosition*(x, y: cint) {.importc: "SetMousePosition", header: "raylib.h".}
proc SetMouseOffset*(offsetX, offsetY: cint) {.importc: "SetMouseOffset", header: "raylib.h".}
proc SetMouseScale*(scaleX, scaleY: float32) {.importc: "SetMouseScale", header: "raylib.h".}
proc GetMouseWheelMove*(): float32 {.importc: "GetMouseWheelMove", header: "raylib.h".}
proc SetMouseCursor*(cursor: cint) {.importc: "SetMouseCursor", header: "raylib.h".}
