# Storie Interactive Demo

Interactive demo showcasing keyboard, mouse, and touch event handling.

```nim on:init
print("=== Storie Interactive Demo ===")
print("Display size: " & $width & " x " & $height & " pixels")
print("Try moving your mouse, clicking, scrolling, and typing!")
```

```nim on:render
# Clear both layers
clear()
clearFg()

# Fill background with a dark gradient
setColor(20, 20, 40)
fillRect(0, 0, width, height)

# Get mouse/touch position
var mouseX = getMouseX()
var mouseY = getMouseY()
var touchActive = isTouchActive()

# Draw title
setColor(255, 255, 100)
drawText(width / 2 - 150, 20, "STORIE EVENT HANDLING DEMO", 20)

# ===== MOUSE TRACKING =====
setColor(100, 200, 255)
drawText(20, 60, "MOUSE POSITION:", 16)
setColor(255, 255, 255)
var mousePosText = "X: " & $mouseX & " Y: " & $mouseY
drawText(20, 80, mousePosText, 14)

# Draw cursor indicator
setColor(255, 100, 100)
fillCircle(mouseX, mouseY, 8)
setColor(255, 255, 255)
drawCircle(mouseX, mouseY, 8, 2)

# Draw crosshair at mouse
setColor(255, 200, 200)
drawLine(mouseX - 15, mouseY, mouseX + 15, mouseY, 1)
drawLine(mouseX, mouseY - 15, mouseX, mouseY + 15, 1)

# ===== MOUSE BUTTONS =====
setColor(100, 200, 255)
drawText(20, 120, "MOUSE BUTTONS:", 16)

var leftDown = isMouseButtonDown(0)
var rightDown = isMouseButtonDown(2)
var middleDown = isMouseButtonDown(1)

# Left button indicator
if leftDown:
  setColor(100, 255, 100)
else:
  setColor(80, 80, 80)
fillRect(20, 140, 60, 30)
setColor(255, 255, 255)
drawText(25, 148, "LEFT", 12)

# Right button indicator
if rightDown:
  setColor(100, 255, 100)
else:
  setColor(80, 80, 80)
fillRect(90, 140, 60, 30)
setColor(255, 255, 255)
drawText(95, 148, "RIGHT", 12)

# Middle button indicator
if middleDown:
  setColor(100, 255, 100)
else:
  setColor(80, 80, 80)
fillRect(160, 140, 60, 30)
setColor(255, 255, 255)
drawText(162, 148, "MIDDLE", 12)

# ===== MOUSE CLICKS =====
if isMouseButtonPressed(0):
  setColor(255, 255, 100)
  drawText(20, 185, "Left Click!", 14)

if isMouseButtonPressed(2):
  setColor(255, 255, 100)
  drawText(150, 185, "Right Click!", 14)

# ===== KEYBOARD =====
setColor(100, 200, 255)
drawText(20, 220, "KEYBOARD:", 16)

# Arrow keys
var keyText = "Arrow Keys: "
if isKeyDown(KEY_UP):
  keyText = keyText & "UP "
if isKeyDown(KEY_DOWN):
  keyText = keyText & "DOWN "
if isKeyDown(KEY_LEFT):
  keyText = keyText & "LEFT "
if isKeyDown(KEY_RIGHT):
  keyText = keyText & "RIGHT "
setColor(255, 255, 255)
drawText(20, 240, keyText, 14)

# WASD keys
var wasdText = "WASD: "
if isKeyDown(KEY_W):
  wasdText = wasdText & "W "
if isKeyDown(KEY_A):
  wasdText = wasdText & "A "
if isKeyDown(KEY_S):
  wasdText = wasdText & "S "
if isKeyDown(KEY_D):
  wasdText = wasdText & "D "
setColor(255, 255, 255)
drawText(20, 260, wasdText, 14)

# Space bar
if isKeyDown(KEY_SPACE):
  setColor(255, 255, 100)
  drawText(20, 280, "SPACE BAR PRESSED!", 14)

# Character input
var ch = getCharPressed()
if ch > 0:
  setColor(100, 255, 100)
  var charText = "Last Char: '" & $ch & "' (code: " & $ch & ")"
  drawText(20, 300, charText, 14)

# ===== MOUSE WHEEL =====
var wheelY = getMouseWheelY()
if wheelY != 0.0:
  setColor(255, 200, 100)
  var wheelText = "Mouse Wheel: " & $wheelY
  drawText(20, 330, wheelText, 14)

# ===== INTERACTIVE DRAWING =====
setColor(150, 150, 255)
drawText(width / 2 - 100, height - 180, "INTERACTIVE AREA", 16)
setColor(100, 100, 100)
drawRect(width / 2 - 150, height - 150, 300, 120, 2)

# Draw when left mouse button is held
if leftDown and mouseY > height - 150 and mouseY < height - 30:
  if mouseX > width / 2 - 150 and mouseX < width / 2 + 150:
    var time = frameCount / 60.0
    var hue = (frameCount % 360) / 360.0
    var r = int(sin(hue * 6.28) * 127.5 + 127.5)
    var g = int(sin((hue + 0.333) * 6.28) * 127.5 + 127.5)
    var b = int(sin((hue + 0.666) * 6.28) * 127.5 + 127.5)
    setColor(r, g, b)
    fillCircle(mouseX, mouseY, 5)

setColor(200, 200, 200)
drawText(width / 2 - 120, height - 160, "Click and drag to paint!", 12)

# ===== TOUCH INDICATOR =====
if touchActive:
  setColor(255, 150, 255)
  drawText(width - 200, 60, "TOUCH ACTIVE", 16)
  var tx = getTouchX()
  var ty = getTouchY()
  setColor(255, 100, 255)
  fillCircle(tx, ty, 12)

# Display info at bottom
setColor(200, 200, 200)
var info = "Frame: " & $frameCount & " | FPS: " & $fps
drawText(10, height - 20, info, 12)
drawText(width - 180, height - 20, "Press ESC to quit", 12)
```
