# Simple 3D Cube

A minimal example showing a single rotating cube.

Run with: `./storie --3d examples/simple_cube.md`

## Setup Camera

```nim on:init
# Place camera at (0, 2, 5) looking at origin
setCamera(0.0, 2.0, 5.0, 0.0, 0.0, 0.0)

# Track rotation
var rotation = 0.0
```

## Update Rotation

```nim on:update
# Increment rotation each frame
rotation = rotation + 0.03
```

## Draw Cube

```nim on:render
# Clear with dark background
clear3D(15, 15, 25)

# Reset transformations
resetTransform()

# Rotate the cube
rotate3D(rotation, rotation * 0.5, 0.0)

# Set color and draw
setColor(100, 200, 255)
drawCube(2.0)
```

That's it! A complete 3D scene in just a few lines.

## Try Changing

- **Camera position**: Change the numbers in `setCamera()`
- **Rotation speed**: Adjust the `0.03` value
- **Cube size**: Change `2.0` to other values
- **Color**: Try different RGB values in `setColor()`
- **Multiple cubes**: Copy the reset/rotate/color/draw block
