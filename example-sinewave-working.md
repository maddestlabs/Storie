# Storie Audio Example - Sine Wave Visualizer

Interactive sine wave visualizer with mouse-controlled frequency.
Click and drag to change the frequency and see the waveform update in real-time.

```nim on:init
print("=== Storie Sine Wave Visualizer ===")
print("Click and drag vertically to change frequency")
print("Display size: " & $width & " x " & $height)
```

```nim on:render
# Clear screen
clear()
setColor(245, 245, 245)
fillRect(0, 0, width, height)

# Get mouse input
var mouseX = getMouseX()
var mouseY = getMouseY()
var mouseDown = isMouseButtonDown(0)

# Calculate frequency from mouse Y position (40 Hz to 490 Hz)
var frequency = 440
if mouseDown:
  frequency = 40 + int(mouseY)
  if frequency < 40:
    frequency = 40
  if frequency > 490:
    frequency = 490

# Draw instructions
setColor(80, 80, 80)
drawText(10, 10, "click and drag vertically to change frequency", 20)

# Draw frequency display
setColor(230, 41, 55)
var freqText = "sine frequency: " & $frequency & " Hz"
drawText(width - 250, 10, freqText, 20)

# Calculate waveform parameters
var samplesPerScreen = 800
var waveLength = int(22050 / frequency)
if waveLength < 1:
  waveLength = 1

# Draw waveform visualization
setColor(230, 41, 55)
var centerY = height / 2
var amplitude = 80

for x in 0..width:
  # Calculate the sample position in the waveform
  var samplePos = x * waveLength / width
  
  # Calculate sine wave value
  var angle = 2.0 * 3.14159 * samplePos / waveLength
  var sineValue = sin(angle)
  
  # Convert to screen coordinates
  var y = centerY + int(amplitude * sineValue)
  
  # Draw the waveform point
  if x > 0:
    # Calculate previous point for line drawing
    var prevSamplePos = (x - 1) * waveLength / width
    var prevAngle = 2.0 * 3.14159 * prevSamplePos / waveLength
    var prevSineValue = sin(prevAngle)
    var prevY = centerY + int(amplitude * prevSineValue)
    
    drawLine(x - 1, prevY, x, y, 2)

# Draw center line for reference
setColor(200, 200, 200)
drawLine(0, centerY, width, centerY, 1)

# Draw frequency range indicator on left side
setColor(150, 150, 150)
drawText(10, 60, "40 Hz", 12)
drawText(10, height - 20, "490 Hz", 12)

# Draw mouse position indicator when dragging
if mouseDown:
  setColor(100, 100, 255)
  fillCircle(mouseX, mouseY, 6)
  setColor(255, 255, 255)
  drawCircle(mouseX, mouseY, 6, 1)

# Draw info
setColor(100, 100, 100)
var info = "Frame: " & $frameCount
drawText(10, height - 40, info, 12)
```
