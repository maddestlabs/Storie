## GAL Pipeline Example
## Demonstrates different pipeline configurations

import ../platform/gal

proc createBasicVertexLayout(): GalVertexLayout =
  ## Create a simple vertex layout: position + color
  result = galCreateVertexLayout(28)  # 3 floats pos + 4 floats color
  result.galAddAttribute(0, VertexFloat3, 0)   # position at offset 0
  result.galAddAttribute(1, VertexFloat4, 12)  # color at offset 12

proc createTexturedVertexLayout(): GalVertexLayout =
  ## Create vertex layout with texture coordinates
  result = galCreateVertexLayout(32)  # 3 floats pos + 3 floats color + 2 floats uv
  result.galAddAttribute(0, VertexFloat3, 0)   # position
  result.galAddAttribute(1, VertexFloat3, 12)  # color
  result.galAddAttribute(2, VertexFloat2, 24)  # texCoord

proc main() =
  echo "GAL Pipeline Example"
  echo "==================="
  
  let device = galCreateDevice()
  
  # Note: For this example to work fully, you need compiled shaders
  # For now, we'll demonstrate pipeline creation without actual shaders
  
  echo "\nCreating vertex layouts..."
  let basicLayout = createBasicVertexLayout()
  let texturedLayout = createTexturedVertexLayout()
  
  echo "Basic layout: ", basicLayout.attributes.len, " attributes, stride: ", basicLayout.stride
  echo "Textured layout: ", texturedLayout.attributes.len, " attributes, stride: ", texturedLayout.stride
  
  # Different pipeline configurations
  echo "\nPipeline state configurations:"
  
  # 1. Opaque geometry pipeline
  echo "\n1. Opaque Geometry Pipeline:"
  let opaqueState = PipelineState(
    depthTest: true,
    depthWrite: true,
    cullMode: CullBack,
    blendEnabled: false,
    primitiveType: PrimitiveTriangles
  )
  echo "  - Depth test: ON"
  echo "  - Depth write: ON"
  echo "  - Cull mode: Back faces"
  echo "  - Blend: OFF"
  echo "  - Primitive: Triangles"
  
  # 2. Transparent object pipeline
  echo "\n2. Transparent Object Pipeline:"
  let transparentState = PipelineState(
    depthTest: true,
    depthWrite: false,  # Don't write to depth for transparency
    cullMode: CullNone,  # Render both sides
    blendEnabled: true,
    primitiveType: PrimitiveTriangles
  )
  echo "  - Depth test: ON"
  echo "  - Depth write: OFF"
  echo "  - Cull mode: None"
  echo "  - Blend: ON"
  echo "  - Primitive: Triangles"
  
  # 3. Wireframe/line pipeline
  echo "\n3. Wireframe Pipeline:"
  let wireframeState = PipelineState(
    depthTest: true,
    depthWrite: true,
    cullMode: CullNone,
    blendEnabled: false,
    primitiveType: PrimitiveLines
  )
  echo "  - Depth test: ON"
  echo "  - Depth write: ON"
  echo "  - Cull mode: None"
  echo "  - Blend: OFF"
  echo "  - Primitive: Lines"
  
  # 4. Point cloud pipeline
  echo "\n4. Point Cloud Pipeline:"
  let pointState = PipelineState(
    depthTest: true,
    depthWrite: false,
    cullMode: CullNone,
    blendEnabled: true,
    primitiveType: PrimitivePoints
  )
  echo "  - Depth test: ON"
  echo "  - Depth write: OFF"
  echo "  - Cull mode: None"
  echo "  - Blend: ON"
  echo "  - Primitive: Points"
  
  # 5. 2D overlay pipeline
  echo "\n5. 2D Overlay Pipeline:"
  let overlayState = PipelineState(
    depthTest: false,
    depthWrite: false,
    cullMode: CullNone,
    blendEnabled: true,
    primitiveType: PrimitiveTriangles
  )
  echo "  - Depth test: OFF"
  echo "  - Depth write: OFF"
  echo "  - Cull mode: None"
  echo "  - Blend: ON"
  echo "  - Primitive: Triangles"
  
  echo "\n==================="
  echo "Pipeline configurations demonstrated!"
  echo "\nTo create actual pipelines, you need:"
  echo "1. Compiled shaders (GLSL for OpenGL, SPIR-V for SDL_GPU)"
  echo "2. Vertex layout matching shader inputs"
  echo "3. Pipeline state configuration"
  echo "\nExample:"
  echo "  let shader = galLoadShader(device, 'vert.glsl', 'frag.glsl')"
  echo "  let pipeline = galCreatePipeline(device, shader, layout, state)"
  echo "  galBindPipeline(pipeline)"
  echo "  galDrawIndexed(indexCount)"
  
  galDestroyDevice(device)

when isMainModule:
  main()
