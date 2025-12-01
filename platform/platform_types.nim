## Platform Abstraction Layer - Core Types
## Minimal types for the Storie SDL3 engine

# ================================================================
# COLOR SYSTEM (Simple RGB - SDL3 has SDL_Color but we keep this for convenience)
# ================================================================

type
  Color* = object
    r*, g*, b*: uint8

# Basic color constructors
proc rgb*(r, g, b: uint8): Color =
  Color(r: r, g: g, b: b)

proc black*(): Color = rgb(0, 0, 0)
proc white*(): Color = rgb(255, 255, 255)
proc red*(): Color = rgb(255, 0, 0)
proc green*(): Color = rgb(0, 255, 0)
proc blue*(): Color = rgb(0, 0, 255)
proc yellow*(): Color = rgb(255, 255, 0)
proc cyan*(): Color = rgb(0, 255, 255)
proc magenta*(): Color = rgb(255, 0, 255)
proc gray*(level: uint8): Color = rgb(level, level, level)

# ================================================================
# STYLE SYSTEM (For text/cell rendering)
# ================================================================

type
  Style* = object
    fg*: Color
    bg*: Color
    bold*: bool

proc defaultStyle*(): Style =
  Style(fg: white(), bg: black(), bold: false)

# ================================================================
# INPUT EVENTS (Wrapper around SDL3 events for convenience)
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
    of ResizeEvent:
      newWidth*: int
      newHeight*: int

# ================================================================
# BUFFER SYSTEM (Cell-based rendering for terminal-like display)
# ================================================================

type
  Cell* = object
    ch*: string
    style*: Style
    transparent*: bool

  Buffer* = object
    width*, height*: int
    cells*: seq[Cell]

proc newBuffer*(w, h: int): Buffer =
  result.width = w
  result.height = h
  result.cells = newSeq[Cell](w * h)
  let defaultStyle = Style(fg: white(), bg: black(), bold: false)
  for i in 0 ..< result.cells.len:
    result.cells[i] = Cell(ch: " ", style: defaultStyle, transparent: false)

proc write*(tb: var Buffer, x, y: int, ch: string, style: Style) =
  if x >= 0 and x < tb.width and y >= 0 and y < tb.height:
    let idx = y * tb.width + x
    tb.cells[idx] = Cell(ch: ch, style: style, transparent: false)

proc writeText*(tb: var Buffer, x, y: int, text: string, style: Style) =
  var currentX = x
  for c in text:
    if currentX >= tb.width:
      break
    tb.write(currentX, y, $c, style)
    currentX += 1

proc fillRect*(tb: var Buffer, x, y, w, h: int, ch: string, style: Style) =
  for dy in 0 ..< h:
    for dx in 0 ..< w:
      tb.write(x + dx, y + dy, ch, style)

proc clear*(tb: var Buffer) =
  let defaultStyle = Style(fg: white(), bg: black(), bold: false)
  for i in 0 ..< tb.cells.len:
    tb.cells[i] = Cell(ch: " ", style: defaultStyle, transparent: false)

proc clearTransparent*(tb: var Buffer) =
  let defaultStyle = Style(fg: white(), bg: black(), bold: false)
  for i in 0 ..< tb.cells.len:
    tb.cells[i] = Cell(ch: "", style: defaultStyle, transparent: true)

proc compositeBufferOnto*(dest: var Buffer, src: Buffer) =
  let w = min(dest.width, src.width)
  let h = min(dest.height, src.height)
  for y in 0 ..< h:
    for x in 0 ..< w:
      let srcIdx = y * src.width + x
      let destIdx = y * dest.width + x
      let s = src.cells[srcIdx]
      # Composite if not transparent
      if not s.transparent and (s.ch.len > 0 or (s.style.bg.r != 0 or s.style.bg.g != 0 or s.style.bg.b != 0)):
        dest.cells[destIdx] = s

# ================================================================
# LAYER SYSTEM
# ================================================================

type
  Layer* = ref object
    id*: string
    z*: int
    visible*: bool
    buffer*: Buffer
