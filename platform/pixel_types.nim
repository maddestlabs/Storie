## Pixel-Based Rendering Types
## Modern pixel/vector graphics system for SDL3

# ================================================================
# COLOR SYSTEM
# ================================================================

type
  Color* = object
    r*, g*, b*, a*: uint8

# Basic color constructors
proc rgba*(r, g, b: uint8, a: uint8 = 255): Color =
  Color(r: r, g: g, b: b, a: a)

proc rgb*(r, g, b: uint8): Color =
  rgba(r, g, b, 255)

proc black*(): Color = rgb(0, 0, 0)
proc white*(): Color = rgb(255, 255, 255)
proc red*(): Color = rgb(255, 0, 0)
proc green*(): Color = rgb(0, 255, 0)
proc blue*(): Color = rgb(0, 0, 255)
proc yellow*(): Color = rgb(255, 255, 0)
proc cyan*(): Color = rgb(0, 255, 255)
proc magenta*(): Color = rgb(255, 0, 255)
proc gray*(level: uint8): Color = rgb(level, level, level)
proc transparent*(): Color = rgba(0, 0, 0, 0)

# ================================================================
# INPUT EVENTS
# ================================================================

type
  InputAction* = enum
    Press
    Release
    Repeat

  MouseButton* = enum
    Left
    Middle
    Right
    Unknown

  InputEventKind* = enum
    KeyEvent
    MouseEvent
    MouseMoveEvent
    MouseScrollEvent
    ResizeEvent

  InputEvent* = object
    case kind*: InputEventKind
    of KeyEvent:
      keyCode*: int
      keyAction*: InputAction
    of MouseEvent:
      button*: MouseButton
      mouseX*: int
      mouseY*: int
      action*: InputAction
    of MouseMoveEvent:
      moveX*: int
      moveY*: int
    of MouseScrollEvent:
      scrollX*: float
      scrollY*: float
    of ResizeEvent:
      newWidth*: int
      newHeight*: int

# ================================================================
# DRAWING COMMANDS - Modern rendering primitives
# ================================================================

type
  DrawCommandKind* = enum
    ClearScreen
    DrawRect
    FillRect
    DrawCircle
    FillCircle
    DrawLine
    DrawText
    DrawPixel

  DrawCommand* = object
    case kind*: DrawCommandKind
    of ClearScreen:
      clearColor*: Color
    of DrawRect, FillRect:
      rectX*, rectY*, rectW*, rectH*: int
      rectColor*: Color
      rectLineWidth*: int  # for DrawRect only
    of DrawCircle, FillCircle:
      circleX*, circleY*, circleRadius*: int
      circleColor*: Color
      circleLineWidth*: int  # for DrawCircle only
    of DrawLine:
      lineX1*, lineY1*, lineX2*, lineY2*: int
      lineColor*: Color
      lineWidth*: int
    of DrawText:
      textX*, textY*: int
      textContent*: string
      textColor*: Color
      textSize*: int
    of DrawPixel:
      pixelX*, pixelY*: int
      pixelColor*: Color

# ================================================================
# RENDER BUFFER - Command-based rendering
# ================================================================

type
  RenderBuffer* = ref object
    width*, height*: int
    commands*: seq[DrawCommand]
    backgroundColor*: Color

proc newRenderBuffer*(w, h: int): RenderBuffer =
  RenderBuffer(
    width: w,
    height: h,
    commands: @[],
    backgroundColor: black()
  )

# ================================================================
# DRAWING API - High-level commands
# ================================================================

proc clear*(rb: RenderBuffer, color: Color = black()) =
  rb.commands.add(DrawCommand(kind: ClearScreen, clearColor: color))

proc drawRect*(rb: RenderBuffer, x, y, w, h: int, color: Color, lineWidth: int = 1) =
  rb.commands.add(DrawCommand(
    kind: DrawRect,
    rectX: x, rectY: y, rectW: w, rectH: h,
    rectColor: color,
    rectLineWidth: lineWidth
  ))

proc fillRect*(rb: RenderBuffer, x, y, w, h: int, color: Color) =
  rb.commands.add(DrawCommand(
    kind: FillRect,
    rectX: x, rectY: y, rectW: w, rectH: h,
    rectColor: color
  ))

proc drawCircle*(rb: RenderBuffer, x, y, radius: int, color: Color, lineWidth: int = 1) =
  rb.commands.add(DrawCommand(
    kind: DrawCircle,
    circleX: x, circleY: y, circleRadius: radius,
    circleColor: color,
    circleLineWidth: lineWidth
  ))

proc fillCircle*(rb: RenderBuffer, x, y, radius: int, color: Color) =
  rb.commands.add(DrawCommand(
    kind: FillCircle,
    circleX: x, circleY: y, circleRadius: radius,
    circleColor: color
  ))

proc drawLine*(rb: RenderBuffer, x1, y1, x2, y2: int, color: Color, lineWidth: int = 1) =
  rb.commands.add(DrawCommand(
    kind: DrawLine,
    lineX1: x1, lineY1: y1, lineX2: x2, lineY2: y2,
    lineColor: color,
    lineWidth: lineWidth
  ))

proc drawText*(rb: RenderBuffer, x, y: int, text: string, color: Color, size: int = 16) =
  rb.commands.add(DrawCommand(
    kind: DrawText,
    textX: x, textY: y,
    textContent: text,
    textColor: color,
    textSize: size
  ))

proc drawPixel*(rb: RenderBuffer, x, y: int, color: Color) =
  rb.commands.add(DrawCommand(
    kind: DrawPixel,
    pixelX: x, pixelY: y,
    pixelColor: color
  ))

proc clearCommands*(rb: RenderBuffer) =
  rb.commands.setLen(0)

# ================================================================
# LAYER SYSTEM - Pixel-based compositing
# ================================================================

type
  Layer* = ref object
    id*: string
    z*: int
    visible*: bool
    renderBuffer*: RenderBuffer
