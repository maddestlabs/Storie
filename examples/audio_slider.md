# Audio Sine Wave with Volume Slider

Interactive audio demo with volume control.

```nim on:init
print("=== Audio Sine Wave Demo ===")
print("Initializing audio system...")

# Audio parameters
var sampleRate = 48000
var frequency = 440.0  # A4 note
var amplitude = 0.3
var volume = 0.5
var phase = 0.0

# Initialize audio
if initAudio(sampleRate, 2, 4096):
  print("Audio initialized at " & $sampleRate & " Hz")
  playAudio()
else:
  print("Failed to initialize audio")
```

```nim on:render
# Clear screen
clear()
clearFg()

# Background
setColor(25, 25, 35)
fillRect(0, 0, width, height)

# Title
setColor(100, 200, 255)
drawText(width / 2 - 180, 30, "AUDIO SINE WAVE GENERATOR", 24)

# Instructions
setColor(200, 200, 200)
drawText(width / 2 - 150, 80, "Generating " & $int(frequency) & " Hz sine wave", 14)
drawText(width / 2 - 100, 100, "Drag slider to adjust volume", 14)

# Volume slider
var sliderX = width / 2 - 200
var sliderY = height / 2
var sliderWidth = 400
var sliderHeight = 20

# Slider background
setColor(60, 60, 80)
fillRect(sliderX, sliderY, sliderWidth, sliderHeight)

# Slider fill (current volume)
var fillWidth = int(volume * float(sliderWidth))
setColor(100, 200, 100)
fillRect(sliderX, sliderY, fillWidth, sliderHeight)

# Slider border
setColor(150, 150, 180)
drawRect(sliderX, sliderY, sliderWidth, sliderHeight, 2)

# Slider handle
var handleX = sliderX + fillWidth
setColor(255, 255, 255)
fillCircle(handleX, sliderY + sliderHeight / 2, 12)
setColor(100, 100, 120)
drawCircle(handleX, sliderY + sliderHeight / 2, 12, 2)

# Check for mouse interaction with slider
var mouseX = getMouseX()
var mouseY = getMouseY()
var mouseDown = isMouseButtonDown(0)

if mouseDown:
  if mouseY >= sliderY - 20 and mouseY <= sliderY + sliderHeight + 20:
    if mouseX >= sliderX and mouseX <= sliderX + sliderWidth:
      volume = float(mouseX - sliderX) / float(sliderWidth)
      if volume < 0.0:
        volume = 0.0
      if volume > 1.0:
        volume = 1.0

# Display volume percentage
setColor(255, 255, 255)
var volumeText = "Volume: " & $int(volume * 100.0) & "%"
drawText(width / 2 - 40, sliderY + 50, volumeText, 16)

# Volume bars visualization
var barCount = 20
var barWidth = 15
var barSpacing = 5
var barStartX = width / 2 - (barCount * (barWidth + barSpacing)) / 2
var barY = height / 2 + 120

for i in 0..<barCount:
  var barX = barStartX + i * (barWidth + barSpacing)
  var barHeight = 80
  
  if float(i) < volume * float(barCount):
    # Active bars (green to yellow to red gradient)
    var t = float(i) / float(barCount)
    var r = int(t * 255.0)
    var g = int(255.0 - (t * 100.0))
    var b = 50
    setColor(r, g, b)
    fillRect(barX, barY - barHeight, barWidth, barHeight)
  else:
    # Inactive bars
    setColor(40, 40, 50)
    fillRect(barX, barY - barHeight, barWidth, barHeight)
  
  # Bar outline
  setColor(80, 80, 100)
  drawRect(barX, barY - barHeight, barWidth, barHeight, 1)

# Generate and queue audio samples
var samplesToGenerate = 2048
var audioBuffer = newSeq[float](samplesToGenerate * 2)  # Stereo

for i in 0..<samplesToGenerate:
  # Generate sine wave sample
  var sample = sin(phase) * amplitude * volume
  
  # Store as stereo (left and right channels)
  audioBuffer[i * 2] = sample
  audioBuffer[i * 2 + 1] = sample
  
  # Advance phase
  phase = phase + (frequency * 2.0 * 3.14159265358979323846 / float(sampleRate))
  
  # Keep phase in range to prevent overflow
  if phase > 6.28318530717958647692:
    phase = phase - 6.28318530717958647692

# Queue audio samples
queueAudio(audioBuffer)

# Waveform visualization
var waveY = height / 2 - 80
var waveHeight = 60
var waveWidth = 400
var waveX = width / 2 - waveWidth / 2

# Waveform background
setColor(30, 30, 40)
fillRect(waveX, waveY - waveHeight / 2, waveWidth, waveHeight)

# Draw center line
setColor(80, 80, 100)
drawLine(waveX, waveY, waveX + waveWidth, waveY, 1)

# Draw waveform
setColor(100, 200, 255)
var samplesPerPixel = 10
var prevY = waveY
for x in 0..<waveWidth:
  var sampleIdx = (x * samplesPerPixel) % samplesToGenerate
  var sample = audioBuffer[sampleIdx * 2]
  var y = waveY - int(sample * float(waveHeight / 2))
  
  if x > 0:
    drawLine(waveX + x - 1, prevY, waveX + x, y, 2)
  
  prevY = y

# Info
setColor(150, 150, 150)
drawText(10, height - 40, "Frame: " & $frameCount, 12)
drawText(10, height - 20, "Audio Buffer: " & $samplesToGenerate & " samples", 12)
drawText(width - 180, height - 20, "Press ESC to quit", 12)
```
