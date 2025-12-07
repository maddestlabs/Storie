## Complete GAL Example with Shaders, Textures, and Pipelines
## This demonstrates the full GAL API including the new features

import ../platform/gal
import ../platform/shader_compiler
import math

# ================================================================
# VERTEX DATA WITH TEXTURE COORDINATES
# ================================================================

type
  Vertex = object
    position: array[3, float32]
    color: array[3, float32]
    texCoord: array[2, float32]

  UniformData = object
    model: array[16, float32]
    view: array[16, float32]
    projection: array[16, float32]

proc createIdentityMatrix(): array[16, float32] =
  result[0] = 1.0; result[5] = 1.0; result[10] = 1.0; result[15] = 1.0

proc createRotationMatrix(angle: float32): array[16, float32] =
  result = createIdentityMatrix()
  let c = cos(angle)
  let s = sin(angle)
  result[0] = c; result[2] = s
  result[8] = -s; result[10] = c

let cubeVertices = [
  # Front face (red)
  Vertex(position: [-1.0'f32, -1, 1], color: [1'f32, 0, 0], texCoord: [0'f32, 0]),
  Vertex(position: [1'f32, -1, 1], color: [1'f32, 0, 0], texCoord: [1'f32, 0]),
  Vertex(position: [1'f32, 1, 1], color: [1'f32, 0, 0], texCoord: [1'f32, 1]),
  Vertex(position: [-1'f32, 1, 1], color: [1'f32, 0, 0], texCoord: [0'f32, 1]),
  # Back face (green)
  Vertex(position: [-1'f32, -1, -1], color: [0'f32, 1, 0], texCoord: [1'f32, 0]),
  Vertex(position: [1'f32, -1, -1], color: [0'f32, 1, 0], texCoord: [0'f32, 0]),
  Vertex(position: [1'f32, 1, -1], color: [0'f32, 1, 0], texCoord: [0'f32, 1]),
  Vertex(position: [-1'f32, 1, -1], color: [0'f32, 1, 0], texCoord: [1'f32, 1]),
]

let cubeIndices: array[36, uint16] = [
  0'u16, 1, 2, 0, 2, 3,  # Front
  1, 5, 6, 1, 6, 2,      # Right
  5, 4, 7, 5, 7, 6,      # Back
  4, 0, 3, 4, 3, 7,      # Left
  3, 2, 6, 3, 6, 7,      # Top
  4, 5, 1, 4, 1, 0       # Bottom
]

# ================================================================
# MAIN EXAMPLE
# ================================================================

proc main() =
  echo "================================================"
  echo "GAL Complete Feature Example"
  echo "Backend: ",
    when defined(sdlgpu) and not defined(emscripten):
      "SDL_GPU (Vulkan/D3D12/Metal)"
    elif defined(emscripten):
      "WebGL"
    else:
      "OpenGL"
  echo "================================================"
  
  # 1. CREATE DEVICE
  echo "\n[1] Creating device..."
  let device = galCreateDevice()
  
  # 2. COMPILE SHADERS
  echo "\n[2] Compiling shaders..."
  when defined(sdlgpu) and not defined(emscripten):
    # For SDL_GPU, compile GLSL to SPIR-V
    let shaderResult = compileShaderPair("shaders/basic.vert", "shaders/basic.frag")
    if not shaderResult.vert.success or not shaderResult.frag.success:
      echo "Failed to compile shaders!"
      echo "Vert: ", shaderResult.vert.errorMsg
      echo "Frag: ", shaderResult.frag.errorMsg
      return
    
    # Load compiled SPIR-V shaders
    let shader = galLoadShader(device, 
                               shaderResult.vert.spirvPath,
                               shaderResult.frag.spirvPath)
  else:
    # For OpenGL, load GLSL source directly
    let shader = galLoadShader(device, "shaders/basic.vert", "shaders/basic.frag")
  
  if shader.isNil:
    echo "Failed to load shaders!"
    return
  
  # 3. CREATE VERTEX LAYOUT
  echo "\n[3] Creating vertex layout..."
  let vertexLayout = galCreateVertexLayout(sizeof(Vertex))
  vertexLayout.galAddAttribute(0, VertexFloat3, 0)  # position
  vertexLayout.galAddAttribute(1, VertexFloat3, 12) # color
  vertexLayout.galAddAttribute(2, VertexFloat2, 24) # texCoord
  
  # 4. CREATE PIPELINE
  echo "\n[4] Creating pipeline..."
  let pipelineState = PipelineState(
    depthTest: true,
    depthWrite: true,
    cullMode: CullBack,
    blendEnabled: false,
    primitiveType: PrimitiveTriangles
  )
  
  let pipeline = galCreatePipeline(device, shader, vertexLayout, pipelineState)
  
  # 5. CREATE BUFFERS
  echo "\n[5] Creating buffers..."
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
  
  # 6. CREATE UNIFORM BUFFER
  echo "\n[6] Creating uniform buffer..."
  var uniforms = UniformData(
    model: createIdentityMatrix(),
    view: createIdentityMatrix(),
    projection: createIdentityMatrix()
  )
  
  let uniformBuffer = galCreateBuffer(
    device,
    sizeof(UniformData),
    BufferUniform
  )
  
  # 7. CREATE TEXTURE (optional demo)
  echo "\n[7] Creating test texture..."
  let texture = galCreateTexture(device, 256, 256, TextureRGBA8)
  
  # Create checkerboard pattern
  var pixels = newSeq[uint8](256 * 256 * 4)
  for y in 0..<256:
    for x in 0..<256:
      let checker = ((x div 32) + (y div 32)) mod 2
      let color = if checker == 0: 255'u8 else: 128'u8
      let idx = (y * 256 + x) * 4
      pixels[idx] = color
      pixels[idx + 1] = color
      pixels[idx + 2] = color
      pixels[idx + 3] = 255
  
  galUploadTexture(device, texture, addr pixels[0])
  galSetTextureFilter(texture, FilterLinear, FilterLinear)
  galSetTextureWrap(texture, WrapRepeat, WrapRepeat)
  
  # 8. RENDER LOOP (simplified)
  echo "\n[8] Starting render loop..."
  var rotation = 0.0'f32
  
  for frame in 0..<10:
    rotation += 0.1
    
    # Update uniforms
    uniforms.model = createRotationMatrix(rotation)
    galUploadBuffer(device, uniformBuffer, addr uniforms, sizeof(UniformData))
    
    # Render commands
    galClear(0.1, 0.1, 0.15, 1.0)
    galEnableDepthTest(true)
    galEnableCulling(true)
    galSetViewport(0, 0, 800, 600)
    
    galBindPipeline(pipeline)
    galDrawIndexed(cubeIndices.len)
    
    echo "  Frame ", frame, " - Rotation: ", rotation
  
  # 9. CLEANUP
  echo "\n[9] Cleaning up..."
  galDestroyTexture(device, texture)
  galDestroyBuffer(device, uniformBuffer)
  galDestroyBuffer(device, vertexBuffer)
  galDestroyBuffer(device, indexBuffer)
  galDestroyPipeline(device, pipeline)
  galDestroyShader(device, shader)
  galDestroyDevice(device)
  
  echo "\n================================================"
  echo "Example completed successfully!"
  echo "================================================"

when isMainModule:
  main()
