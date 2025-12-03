# 3D Rendering in Storie

Storie now supports 3D rendering using OpenGL (desktop) and WebGL (browser) via SDL3.

## Features

- **Cross-platform 3D**: Works on Linux, macOS, Windows, and web browsers
- **Simple API**: Easy-to-use 3D primitives exposed to Nimini scripting
- **Camera control**: Position, aim, and adjust FOV
- **Matrix transformations**: Translate, rotate, and scale objects
- **Built-in primitives**: Cubes and spheres with customizable parameters
- **Color support**: Set colors for 3D objects using familiar RGB values

## Getting Started

### Enable 3D Mode

Run Storie with the `--3d` flag to enable 3D rendering:

```bash
./storie --3d your_3d_scene.md
```

### Basic 3D Scene

```markdown
# My First 3D Scene

## Setup
\`\`\`nim on:init
# Position camera: looking from (5,5,10) at origin (0,0,0)
setCamera(5.0, 5.0, 10.0, 0.0, 0.0, 0.0)
setCameraFov(60.0)

var rotation = 0.0
\`\`\`

## Update
\`\`\`nim on:update
rotation = rotation + 0.02
\`\`\`

## Render
\`\`\`nim on:render
# Clear with dark blue background
clear3D(20, 20, 40)

# Draw a spinning red cube
resetTransform()
rotate3D(rotation, rotation * 0.7, 0.0)
setColor(255, 50, 50)
drawCube(2.0)
\`\`\`
```

## API Reference

### Camera Control

#### `setCamera(posX, posY, posZ, targetX, targetY, targetZ)`
Position and aim the camera in 3D space.
- **posX, posY, posZ**: Camera position
- **targetX, targetY, targetZ**: Point the camera is looking at

Example:
```nim
# Camera at (0, 5, 10) looking at origin
setCamera(0.0, 5.0, 10.0, 0.0, 0.0, 0.0)
```

#### `setCameraFov(degrees)`
Set the camera's field of view (default: 60 degrees).

Example:
```nim
setCameraFov(75.0)  # Wider field of view
```

### Transformations

Transformations are applied cumulatively to the current model matrix. Always call `resetTransform()` before positioning a new object.

#### `resetTransform()`
Reset the model matrix to identity (start fresh for a new object).

#### `translate3D(x, y, z)`
Move the current object in 3D space.

Example:
```nim
resetTransform()
translate3D(5.0, 0.0, 0.0)  # Move 5 units right
drawCube(1.0)
```

#### `rotate3D(angleX, angleY, angleZ)`
Rotate the current object. **Angles are in radians.**

Example:
```nim
resetTransform()
rotate3D(0.0, 1.57, 0.0)  # Rotate 90° around Y axis (1.57 ≈ π/2)
drawCube(1.0)
```

Tip: Use `sin()` and `cos()` for smooth animations:
```nim
var time = 0.0
# In update block:
time = time + 0.01

# In render block:
rotate3D(time, time * 0.5, 0.0)
```

#### `scale3D(x, y, z)`
Scale the current object along each axis.

Example:
```nim
resetTransform()
scale3D(2.0, 1.0, 1.0)  # Stretch along X axis
drawCube(1.0)
```

### Drawing Primitives

#### `drawCube([size])`
Draw a cube centered at the current position.
- **size** (optional): Edge length (default: 1.0)

Example:
```nim
setColor(255, 100, 50)
drawCube(2.0)  # 2x2x2 cube
```

#### `drawSphere([radius], [segments])`
Draw a sphere centered at the current position.
- **radius** (optional): Sphere radius (default: 1.0)
- **segments** (optional): Number of segments for smoothness (default: 16)

Example:
```nim
setColor(50, 150, 255)
drawSphere(1.5, 24)  # Radius 1.5, 24 segments (smoother)
```

### Colors and Clearing

#### `setColor(r, g, b)`
Set the current drawing color (0-255 range).

Example:
```nim
setColor(255, 0, 0)    # Red
setColor(0, 255, 0)    # Green
setColor(128, 128, 255) # Light blue
```

#### `clear3D([r], [g], [b])`
Clear the 3D scene with a background color (0-255 range).

Example:
```nim
clear3D(10, 10, 20)  # Dark blue background
```

### Math Functions

Standard math functions are available:
- `sin(angle)` - Sine (radians)
- `cos(angle)` - Cosine (radians)

Useful constants:
- π (pi) ≈ 3.14159
- π/2 ≈ 1.5708 (90 degrees)
- π/4 ≈ 0.7854 (45 degrees)

## Examples

### Rotating Solar System

```nim
# Init
var time = 0.0
setCamera(0.0, 15.0, 25.0, 0.0, 0.0, 0.0)

# Update
time = time + 0.01

# Render
clear3D(5, 5, 10)

# Sun (center)
resetTransform()
setColor(255, 200, 50)
drawSphere(2.0, 20)

# Earth (orbiting)
resetTransform()
translate3D(cos(time) * 8.0, 0.0, sin(time) * 8.0)
setColor(50, 150, 255)
drawSphere(1.0, 16)

# Moon (orbiting Earth)
translate3D(cos(time * 5.0) * 2.0, 0.0, sin(time * 5.0) * 2.0)
setColor(200, 200, 200)
drawSphere(0.3, 12)
```

### Spinning Cube Grid

```nim
# Init
var rot = 0.0
setCamera(10.0, 10.0, 10.0, 0.0, 0.0, 0.0)

# Update
rot = rot + 0.02

# Render
clear3D(0, 0, 0)

for x in -2..2:
  for z in -2..2:
    resetTransform()
    translate3D(float(x) * 3.0, 0.0, float(z) * 3.0)
    rotate3D(rot, rot * 1.5, 0.0)
    
    # Color based on position
    setColor(int(128 + x * 32), int(128 + z * 32), 200)
    drawCube(1.0)
```

## Technical Details

### Rendering Pipeline

1. **3D Mode**: Enabled with `--3d` flag at startup
2. **OpenGL Context**: Created automatically when 3D mode is enabled
3. **Shader**: Simple vertex/fragment shader for colored vertices
4. **Camera**: Perspective projection with customizable FOV
5. **Depth Testing**: Enabled by default (objects render correctly in 3D space)
6. **Backface Culling**: Enabled for performance

### Coordinate System

- **Right-handed coordinate system**
- **+X**: Right
- **+Y**: Up
- **+Z**: Toward viewer
- Camera by default looks down the -Z axis

### Performance Tips

1. **Sphere segments**: Use lower values (12-20) for better performance
2. **Reuse meshes**: Each `drawCube()` creates a new mesh - avoid calling thousands per frame
3. **Simple scenes**: Start simple and add complexity gradually
4. **Color changes**: Free - set colors as often as needed

## Mixing 2D and 3D

Currently, running in 3D mode disables the 2D rendering layer. The engine operates in either 2D or 3D mode, not both simultaneously. Future versions may support overlay rendering.

## Building for Web

3D rendering works in WebAssembly using WebGL 2.0. Use the standard build script:

```bash
./build-web.sh
```

The `--3d` flag is not needed for web builds - 3D capability is detected automatically.

## Troubleshooting

### "3D mode must be enabled at startup"
Solution: Run with `./storie --3d yourfile.md`

### Black screen
Check:
1. Camera position - make sure it's not inside an object
2. `clear3D()` is called at the start of render
3. Objects are being drawn with visible colors

### Objects appear flat
- Ensure you're calling `rotate3D()` to add dimension
- Check camera FOV and position

### Performance issues
- Reduce sphere segments
- Simplify scene complexity
- Check for accidental geometry explosion (loops creating too many objects)

## See Also

- `examples/3d_demo.md` - Full working example
- Main README for general Storie information
- SDL3 documentation for advanced features
