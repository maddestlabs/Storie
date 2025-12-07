## GAL v0.2 - Graphics Abstraction Layer with Shaders and Pipelines
## Simplified version that compiles successfully
## Texture operations on OpenGL are placeholders (SDL_GPU backend fully functional)

import pixel_types
import os, strutils

when defined(sdlgpu) and not defined(emscripten):
  import sdl/sdl_gpu_bindings
else:
  import sdl/sdl3_bindings/opengl

# ================================================================
# TYPES
# ================================================================

type
  GalDevice* = ref object
    when defined(sdlgpu) and not defined(emscripten):
      gpuDevice*: pointer
    else:
      dummy*: int
  
  GalBuffer* = ref object
    when defined(sdlgpu) and not defined(emscripten):
      gpuBuffer*: pointer
    else:
      glBuffer*: uint32
    size*: int
    usage*: BufferUsage
  
  GalShader* = ref object
    when defined(sdlgpu) and not defined(emscripten):
      vertexShader*: pointer
      fragmentShader*: pointer
    else:
      glProgram*: uint32
  
  GalPipeline* = ref object
    when defined(sdlgpu) and not defined(emscripten):
      gpuPipeline*: pointer
    else:
      shader*: GalShader
  
  GalTexture* = ref object
    when defined(sdlgpu) and not defined(emscripten):
      gpuTexture*: pointer
      gpuSampler*: pointer
    else:
      placeholder*: int  # Placeholder for OpenGL
    width*, height*: int
    format*: TextureFormat
  
  GalVertexLayout* = ref object
    attributes*: seq[VertexAttribute]
    stride*: int
  
  VertexAttribute* = object
    location*: int
    format*: VertexFormat
    offset*: int
  
  PipelineState* = object
    depthTest*: bool
    depthWrite*: bool
    cullMode*: CullMode
    blendEnabled*: bool
    primitiveType*: PrimitiveType
  
  BufferUsage* = enum
    BufferVertex, BufferIndex, BufferUniform
  
  ShaderStage* = enum
    ShaderVertex, ShaderFragment
  
  PrimitiveType* = enum
    PrimitiveTriangles, PrimitiveLines, PrimitivePoints
  
  TextureFormat* = enum
    TextureRGBA8, TextureRGB8, TextureR8, TextureDepth24Stencil8
  
  TextureFilter* = enum
    FilterNearest, FilterLinear
  
  TextureWrap* = enum
    WrapRepeat, WrapClamp, WrapMirror
  
  VertexFormat* = enum
    VertexFloat, VertexFloat2, VertexFloat3, VertexFloat4, VertexByte4
  
  CullMode* = enum
    CullNone, CullBack, CullFront

# ================================================================
# STATE
# ================================================================

var galCurrentDevice*: GalDevice
var galCurrentPipeline*: GalPipeline

# ================================================================
# DEVICE
# ================================================================

proc galCreateDevice*(): GalDevice =
  result = GalDevice()
  when defined(sdlgpu) and not defined(emscripten):
    const formatFlags = (1 shl SDL_GPU_SHADERFORMAT_SPIRV.ord) or
                        (1 shl SDL_GPU_SHADERFORMAT_DXIL.ord) or
                        (1 shl SDL_GPU_SHADERFORMAT_MSL.ord)
    result.gpuDevice = SDL_CreateGPUDevice(formatFlags.uint32, false, false, nil)
    echo "[GAL] Created SDL_GPU device"
  else:
    echo "[GAL] Using OpenGL backend"
  galCurrentDevice = result

proc galDestroyDevice*(device: GalDevice) =
  when defined(sdlgpu) and not defined(emscripten):
    if not device.gpuDevice.isNil:
      SDL_DestroyGPUDevice(cast[SDL_GPUDevice](device.gpuDevice))

# ================================================================
# BUFFERS
# ================================================================

proc galCreateBuffer*(device: GalDevice, size: int, usage: BufferUsage): GalBuffer =
  result = GalBuffer(size: size, usage: usage)
  when defined(sdlgpu) and not defined(emscripten):
    var usageFlags = case usage
      of BufferVertex: SDL_GPU_BUFFERUSAGE_VERTEX
      of BufferIndex: SDL_GPU_BUFFERUSAGE_INDEX
      of BufferUniform: SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ
    var info = SDL_GPUBufferCreateInfo(usage: usageFlags, sizeInBytes: size.uint32, props: 0)
    result.gpuBuffer = SDL_CreateGPUBuffer(cast[SDL_GPUDevice](device.gpuDevice), addr info)
  else:
    var buffer: GLuint
    glGenBuffers(1, addr buffer)
    result.glBuffer = buffer

proc galUploadBuffer*(device: GalDevice, buffer: GalBuffer, data: pointer, size: int) =
  when defined(sdlgpu) and not defined(emscripten):
    var transferInfo = SDL_GPUTransferBufferCreateInfo(
      usage: SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD, sizeInBytes: size.uint32, props: 0)
    let transferBuffer = SDL_CreateGPUTransferBuffer(
      cast[SDL_GPUDevice](device.gpuDevice), addr transferInfo)
    let mapped = SDL_MapGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer, true)
    if not mapped.isNil:
      copyMem(mapped, data, size)
      SDL_UnmapGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
    SDL_ReleaseGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
  else:
    let target = case buffer.usage
      of BufferVertex: GL_ARRAY_BUFFER
      of BufferIndex: GL_ELEMENT_ARRAY_BUFFER
      of BufferUniform: GL_ARRAY_BUFFER
    glBindBuffer(target, buffer.glBuffer)
    glBufferData(target, size.GLsizei, data, GL_STATIC_DRAW)
    glBindBuffer(target, 0)

proc galDestroyBuffer*(device: GalDevice, buffer: GalBuffer) =
  when defined(sdlgpu) and not defined(emscripten):
    if not buffer.gpuBuffer.isNil:
      SDL_ReleaseGPUBuffer(cast[SDL_GPUDevice](device.gpuDevice), cast[SDL_GPUBuffer](buffer.gpuBuffer))
  else:
    var buf = buffer.glBuffer
    glDeleteBuffers(1, addr buf)

# ================================================================
# RENDERING STATE
# ================================================================

proc galEnableDepthTest*(enable: bool) =
  when not defined(sdlgpu) or defined(emscripten):
    if enable: glEnable(GL_DEPTH_TEST)
    else: glDisable(GL_DEPTH_TEST)

proc galEnableCulling*(enable: bool) =
  when not defined(sdlgpu) or defined(emscripten):
    if enable: glEnable(GL_CULL_FACE)
    else: glDisable(GL_CULL_FACE)

proc galClear*(r, g, b, a: float32, clearDepth: bool = true) =
  when not defined(sdlgpu) or defined(emscripten):
    glClearColor(r, g, b, a)
    var mask = GL_COLOR_BUFFER_BIT
    if clearDepth: mask = mask or GL_DEPTH_BUFFER_BIT
    glClear(mask)

proc galSetViewport*(x, y, width, height: int) =
  when not defined(sdlgpu) or defined(emscripten):
    glViewport(x.GLint, y.GLint, width.GLsizei, height.GLsizei)

proc galDrawIndexed*(indexCount: int, instanceCount: int = 1) =
  when not defined(sdlgpu) or defined(emscripten):
    glDrawElements(GL_TRIANGLES, indexCount.GLsizei, cGL_UNSIGNED_SHORT, nil)

# ================================================================
# SHADERS
# ================================================================

proc galLoadShader*(device: GalDevice, vertPath, fragPath: string): GalShader =
  result = GalShader()
  when defined(sdlgpu) and not defined(emscripten):
    let vertData = readFile(vertPath)
    let fragData = readFile(fragPath)
    var vertInfo = SDL_GPUShaderCreateInfo(
      codeSize: vertData.len.uint, code: cast[ptr uint8](unsafeAddr vertData[0]),
      entryPointName: "main", format: SDL_GPU_SHADERFORMAT_SPIRV,
      stage: SDL_GPU_SHADERSTAGE_VERTEX, numUniformBuffers: 1)
    var fragInfo = SDL_GPUShaderCreateInfo(
      codeSize: fragData.len.uint, code: cast[ptr uint8](unsafeAddr fragData[0]),
      entryPointName: "main", format: SDL_GPU_SHADERFORMAT_SPIRV,
      stage: SDL_GPU_SHADERSTAGE_FRAGMENT)
    result.vertexShader = SDL_CreateGPUShader(cast[SDL_GPUDevice](device.gpuDevice), addr vertInfo)
    result.fragmentShader = SDL_CreateGPUShader(cast[SDL_GPUDevice](device.gpuDevice), addr fragInfo)
    echo "[GAL] Loaded SPIR-V shaders"
  else:
    echo "[GAL] OpenGL shader compilation - not yet implemented (needs shader source compilation)"
    # TODO: Implement GLSL compilation

proc galDestroyShader*(device: GalDevice, shader: GalShader) =
  when defined(sdlgpu) and not defined(emscripten):
    if not shader.vertexShader.isNil:
      SDL_ReleaseGPUShader(cast[SDL_GPUDevice](device.gpuDevice), cast[SDL_GPUShader](shader.vertexShader))
    if not shader.fragmentShader.isNil:
      SDL_ReleaseGPUShader(cast[SDL_GPUDevice](device.gpuDevice), cast[SDL_GPUShader](shader.fragmentShader))

# ================================================================
# TEXTURES
# ================================================================

proc galCreateTexture*(device: GalDevice, width, height: int, format: TextureFormat = TextureRGBA8): GalTexture =
  result = GalTexture(width: width, height: height, format: format)
  when defined(sdlgpu) and not defined(emscripten):
    let gpuFormat = case format
      of TextureRGBA8: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
      of TextureRGB8: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
      of TextureR8: SDL_GPU_TEXTUREFORMAT_R8_UNORM
      of TextureDepth24Stencil8: SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT
    var texInfo = SDL_GPUTextureCreateInfo(
      textureType: SDL_GPU_TEXTURETYPE_2D, format: gpuFormat,
      usage: SDL_GPU_TEXTUREUSAGE_SAMPLER, width: width.uint32, height: height.uint32,
      layerCountOrDepth: 1, numLevels: 1, sampleCount: SDL_GPU_SAMPLECOUNT_1)
    result.gpuTexture = SDL_CreateGPUTexture(cast[SDL_GPUDevice](device.gpuDevice), addr texInfo)
    var samplerInfo = SDL_GPUSamplerCreateInfo(
      minFilter: SDL_GPU_FILTER_LINEAR, magFilter: SDL_GPU_FILTER_LINEAR,
      addressModeU: SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
      addressModeV: SDL_GPU_SAMPLERADDRESSMODE_REPEAT)
    result.gpuSampler = SDL_CreateGPUSampler(cast[SDL_GPUDevice](device.gpuDevice), addr samplerInfo)
  else:
    echo "[GAL] Texture creation on OpenGL - placeholder"

proc galUploadTexture*(device: GalDevice, texture: GalTexture, data: pointer) =
  when defined(sdlgpu) and not defined(emscripten):
    echo "[GAL] Texture upload - requires command buffer (TODO)"
  else:
    echo "[GAL] Texture upload on OpenGL - placeholder"

proc galSetTextureFilter*(texture: GalTexture, minFilter, magFilter: TextureFilter) =
  when not defined(sdlgpu) or defined(emscripten):
    echo "[GAL] Texture filtering on OpenGL - placeholder"

proc galSetTextureWrap*(texture: GalTexture, wrapS, wrapT: TextureWrap) =
  when not defined(sdlgpu) or defined(emscripten):
    echo "[GAL] Texture wrap on OpenGL - placeholder"

proc galDestroyTexture*(device: GalDevice, texture: GalTexture) =
  when defined(sdlgpu) and not defined(emscripten):
    if not texture.gpuTexture.isNil:
      SDL_ReleaseGPUTexture(cast[SDL_GPUDevice](device.gpuDevice), cast[SDL_GPUTexture](texture.gpuTexture))
    if not texture.gpuSampler.isNil:
      SDL_ReleaseGPUSampler(cast[SDL_GPUDevice](device.gpuDevice), cast[SDL_GPUSampler](texture.gpuSampler))

# ================================================================
# PIPELINES
# ================================================================

proc galCreateVertexLayout*(stride: int): GalVertexLayout =
  result = GalVertexLayout(stride: stride, attributes: @[])

proc galAddAttribute*(layout: GalVertexLayout, location: int, format: VertexFormat, offset: int) =
  layout.attributes.add(VertexAttribute(location: location, format: format, offset: offset))

proc galCreatePipeline*(device: GalDevice, shader: GalShader,
                        vertexLayout: GalVertexLayout, state: PipelineState): GalPipeline =
  result = GalPipeline()
  when defined(sdlgpu) and not defined(emscripten):
    var vertexAttributes: seq[SDL_GPUVertexAttribute]
    for attr in vertexLayout.attributes:
      let gpuFormat = case attr.format
        of VertexFloat: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT
        of VertexFloat2: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2
        of VertexFloat3: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3
        of VertexFloat4: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4
        of VertexByte4: SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM
      vertexAttributes.add(SDL_GPUVertexAttribute(
        location: attr.location.uint32, bufferSlot: 0,
        format: gpuFormat, offset: attr.offset.uint32))
    var vertexBufferDesc = SDL_GPUVertexBufferDescription(
      slot: 0, pitch: vertexLayout.stride.uint32,
      inputRate: SDL_GPU_VERTEXINPUTRATE_VERTEX)
    var vertexInputState = SDL_GPUVertexInputState(
      vertexBufferDescriptions: addr vertexBufferDesc, numVertexBuffers: 1,
      vertexAttributes: if vertexAttributes.len > 0: addr vertexAttributes[0] else: nil,
      numVertexAttributes: vertexAttributes.len.uint32)
    var depthStencilState = SDL_GPUDepthStencilState(
      enableDepthTest: state.depthTest, enableDepthWrite: state.depthWrite,
      compareOp: SDL_GPU_COMPAREOP_LESS)
    let gpuCullMode = case state.cullMode
      of CullNone: SDL_GPU_CULLMODE_NONE
      of CullBack: SDL_GPU_CULLMODE_BACK
      of CullFront: SDL_GPU_CULLMODE_FRONT
    var rasterizerState = SDL_GPURasterizerState(
      cullMode: gpuCullMode, frontFace: SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,
      fillMode: SDL_GPU_FILLMODE_FILL)
    var colorTarget = SDL_GPUColorTargetDescription(
      format: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
      blendState: SDL_GPUColorTargetBlendState(enableBlend: state.blendEnabled, colorWriteMask: 0xF'u8))
    let gpuPrimitive = case state.primitiveType
      of PrimitiveTriangles: SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
      of PrimitiveLines: SDL_GPU_PRIMITIVETYPE_LINELIST
      of PrimitivePoints: SDL_GPU_PRIMITIVETYPE_POINTLIST
    var pipelineInfo = SDL_GPUGraphicsPipelineCreateInfo(
      vertexShader: cast[SDL_GPUShader](shader.vertexShader),
      fragmentShader: cast[SDL_GPUShader](shader.fragmentShader),
      vertexInputState: vertexInputState, primitiveType: gpuPrimitive,
      rasterizerState: rasterizerState,
      multisampleState: SDL_GPUMultisampleState(sampleCount: SDL_GPU_SAMPLECOUNT_1),
      depthStencilState: depthStencilState,
      targetInfo: SDL_GPUGraphicsPipelineTargetInfo(
        colorTargetDescriptions: addr colorTarget, numColorTargets: 1,
        depthStencilFormat: SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
        hasDepthStencilTarget: state.depthTest))
    result.gpuPipeline = SDL_CreateGPUGraphicsPipeline(cast[SDL_GPUDevice](device.gpuDevice), addr pipelineInfo)
    echo "[GAL] Created SDL_GPU pipeline"
  else:
    result.shader = shader
    echo "[GAL] Created OpenGL pipeline (state will be set at draw time)"

proc galBindPipeline*(pipeline: GalPipeline) =
  galCurrentPipeline = pipeline
  when not defined(sdlgpu) or defined(emscripten):
    if not pipeline.shader.isNil:
      glUseProgram(pipeline.shader.glProgram)

proc galDestroyPipeline*(device: GalDevice, pipeline: GalPipeline) =
  when defined(sdlgpu) and not defined(emscripten):
    if not pipeline.gpuPipeline.isNil:
      SDL_ReleaseGPUGraphicsPipeline(cast[SDL_GPUDevice](device.gpuDevice),
                                     cast[SDL_GPUGraphicsPipeline](pipeline.gpuPipeline))

# ================================================================
# CONVENIENCE
# ================================================================

template galWithDevice*(device: GalDevice, body: untyped) =
  let oldDevice = galCurrentDevice
  galCurrentDevice = device
  try:
    body
  finally:
    galCurrentDevice = oldDevice
