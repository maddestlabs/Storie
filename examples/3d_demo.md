# 3D Demo - Spinning Cubes

This demo shows how to use the 3D rendering features in Storie.

Run with: `./build/storie --3d examples/3d_demo.md`

## Initialize

```nim on:init
# Set up the camera
setCamera(5.0, 5.0, 10.0, 0.0, 0.0, 0.0)
setCameraFov(60.0)

# Initial rotation angle
var angle = 0.0
```

## Update Loop

```nim on:update
# Increment rotation angle
angle = angle + 0.02
```

## Render Scene

```nim on:render
# Clear the 3D scene with a dark blue background
clear3D(20, 20, 40)

# Draw a red spinning cube at origin
resetTransform()
rotate3D(angle, angle * 0.7, 0.0)
setColor(255, 50, 50)
drawCube(2.0)

# Draw a green cube to the right
resetTransform()
translate3D(4.0, 0.0, 0.0)
rotate3D(0.0, angle, angle * 1.5)
setColor(50, 255, 50)
drawCube(1.5)

# Draw a blue cube to the left
resetTransform()
translate3D(-4.0, 0.0, 0.0)
rotate3D(angle * 1.3, 0.0, angle)
setColor(50, 100, 255)
drawCube(1.5)

# Draw a yellow sphere above
resetTransform()
translate3D(0.0, 4.0, 0.0)
rotate3D(angle * 0.5, angle, 0.0)
setColor(255, 255, 50)
drawSphere(1.0, 20)

# Draw small white cubes orbiting
resetTransform()
var orbitAngle = angle * 2.0
var orbitRadius = 6.0
translate3D(cos(orbitAngle) * orbitRadius, 0.0, sin(orbitAngle) * orbitRadius)
rotate3D(angle * 3.0, angle * 2.0, angle)
setColor(255, 255, 255)
drawCube(0.5)
```

## Instructions

- Press **ESC** to quit
- Resize the window to see the 3D scene adjust

## Available 3D Functions

### Camera Control
- `setCamera(posX, posY, posZ, targetX, targetY, targetZ)` - Position and aim the camera
- `setCameraFov(degrees)` - Set field of view (default: 60)

### Transformations
- `resetTransform()` - Reset to identity matrix (start fresh)
- `translate3D(x, y, z)` - Move position
- `rotate3D(angleX, angleY, angleZ)` - Rotate (angles in radians)
- `scale3D(x, y, z)` - Scale object

### Drawing
- `drawCube([size])` - Draw a cube (default size: 1.0)
- `drawSphere([radius], [segments])` - Draw a sphere (default: radius=1.0, segments=16)
- `clear3D([r], [g], [b])` - Clear scene with color (0-255)

### Color
- `setColor(r, g, b)` - Set drawing color (0-255 range)

### Math
- `sin(angle)`, `cos(angle)` - Trigonometric functions
