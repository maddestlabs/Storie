## Example: Drawing a cube using GAL (Graphics Abstraction Layer)
## 
## This code works identically on:
## - Native with SDL_GPU (compile with -d:sdl3 -d:sdlgpu)
## - Native with OpenGL (compile with -d:sdl3)
## - Web with WebGL (compile with -d:emscripten)

import ../platform/gal
import ../platform/pixel_types
import math

# ================================================================
# VERTEX DATA
# ================================================================

type
  Vertex = object
    position: array[3, float32]
    color: array[4, float32]

let cubeVertices = [
  # Front face (red)
  Vertex(position: [-1.0'f32, -1, 1], color: [1'f32, 0, 0, 1]),
  Vertex(position: [1'f32, -1, 1], color: [1'f32, 0, 0, 1]),
  Vertex(position: [1'f32, 1, 1], color: [1'f32, 0, 0, 1]),
  Vertex(position: [-1'f32, 1, 1], color: [1'f32, 0, 0, 1]),
  # Back face (green)
  Vertex(position: [-1'f32, -1, -1], color: [0'f32, 1, 0, 1]),
  Vertex(position: [1'f32, -1, -1], color: [0'f32, 1, 0, 1]),
  Vertex(position: [1'f32, 1, -1], color: [0'f32, 1, 0, 1]),
  Vertex(position: [-1'f32, 1, -1], color: [0'f32, 1, 0, 1]),
]

let cubeIndices: array[36, uint16] = [
  # Front
  0'u16, 1, 2, 0, 2, 3,
  # Right
  1, 5, 6, 1, 6, 2,
  # Back
  5, 4, 7, 5, 7, 6,
  # Left
  4, 0, 3, 4, 3, 7,
  # Top
  3, 2, 6, 3, 6, 7,
  # Bottom
  4, 5, 1, 4, 1, 0
]

# ================================================================
# MAIN RENDERING LOOP
# ================================================================

proc main() =
  echo "GAL Cube Example"
  echo "Backend: ",
    when defined(sdlgpu) and not defined(emscripten):
      "SDL_GPU (Vulkan/D3D12/Metal)"
    elif defined(emscripten):
      "WebGL"
    else:
      "OpenGL"
  
  # Create device
  let device = galCreateDevice()
  
  # Create vertex buffer
  let vertexBuffer = galCreateBuffer(
    device,
    sizeof(Vertex) * cubeVertices.len,
    BufferVertex
  )
  galUploadBuffer(
    device,
    vertexBuffer,
    unsafeAddr cubeVertices[0],
    sizeof(Vertex) * cubeVertices.len
  )
  
  # Create index buffer
  let indexBuffer = galCreateBuffer(
    device,
    sizeof(uint16) * cubeIndices.len,
    BufferIndex
  )
  galUploadBuffer(
    device,
    indexBuffer,
    unsafeAddr cubeIndices[0],
    sizeof(uint16) * cubeIndices.len
  )
  
  # Main loop (simplified)
  var rotation = 0.0'f32
  for frame in 0..<100:
    rotation += 0.01
    
    # Clear
    galClear(0.1, 0.1, 0.15, 1.0)
    
    # Enable depth test & culling
    galEnableDepthTest(true)
    galEnableCulling(true)
    
    # Set viewport
    galSetViewport(0, 0, 800, 600)
    
    # Draw cube
    galDrawIndexed(cubeIndices.len)
    
    # Swap buffers (platform-specific code would go here)
  
  # Cleanup
  galDestroyBuffer(device, vertexBuffer)
  galDestroyBuffer(device, indexBuffer)
  galDestroyDevice(device)
  
  echo "Done!"

when isMainModule:
  main()
