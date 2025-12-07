## Graphics Abstraction Layer (GAL)
## Provides a unified API that compiles to OpenGL (web) or SDL_GPU (native)
##
## Usage:
##   when defined(emscripten):
##     Uses OpenGL/WebGL backend
##   when defined(sdlgpu) and not defined(emscripten):
##     Uses SDL_GPU backend (Vulkan/D3D12/Metal)
##   else:
##     Uses OpenGL backend

when defined(sdlgpu) and not defined(emscripten):
  import sdl/sdl_gpu_bindings
else:
  import sdl/sdl3_bindings/opengl

# ================================================================
# ABSTRACT TYPES
# ================================================================

type
  GalDevice* = ref object
    ## Abstract graphics device
    when defined(sdlgpu) and not defined(emscripten):
      gpuDevice*: pointer  # SDL_GPUDevice
    else:
      dummy*: int  # OpenGL has no device object
  
  GalBuffer* = ref object
    ## Abstract GPU buffer (vertex/index/uniform)
    when defined(sdlgpu) and not defined(emscripten):
      gpuBuffer*: pointer
    else:
      glBuffer*: uint32
    size*: int
    usage*: BufferUsage
  
  GalShader* = ref object
    ## Abstract shader program
    when defined(sdlgpu) and not defined(emscripten):
      vertexShader*: pointer
      fragmentShader*: pointer
    else:
      glProgram*: uint32
  
  GalPipeline* = ref object
    ## Abstract graphics pipeline (shader + render state)
    when defined(sdlgpu) and not defined(emscripten):
      gpuPipeline*: pointer
    else:
      shader*: GalShader
      # OpenGL state is global, stored separately
  
  GalTexture* = ref object
    ## Abstract texture
    when defined(sdlgpu) and not defined(emscripten):
      gpuTexture*: pointer
      gpuSampler*: pointer
    else:
      glTexture*: uint32
    width*, height*: int
    format*: TextureFormat
  
  GalVertexLayout* = ref object
    ## Vertex attribute layout
    attributes*: seq[VertexAttribute]
    stride*: int
  
  VertexAttribute* = object
    ## Single vertex attribute
    location*: int
    format*: VertexFormat
    offset*: int
  
  PipelineState* = object
    ## Pipeline render state configuration
    depthTest*: bool
    depthWrite*: bool
    cullMode*: CullMode
    blendEnabled*: bool
    primitiveType*: PrimitiveType
  
  BufferUsage* = enum
    BufferVertex
    BufferIndex
    BufferUniform
  
  ShaderStage* = enum
    ShaderVertex
    ShaderFragment
  
  PrimitiveType* = enum
    PrimitiveTriangles
    PrimitiveLines
    PrimitivePoints
  
  TextureFormat* = enum
    TextureRGBA8
    TextureRGB8
    TextureR8
    TextureDepth24Stencil8
  
  TextureFilter* = enum
    FilterNearest
    FilterLinear
  
  TextureWrap* = enum
    WrapRepeat
    WrapClamp
    WrapMirror
  
  VertexFormat* = enum
    VertexFloat
    VertexFloat2
    VertexFloat3
    VertexFloat4
    VertexByte4
  
  CullMode* = enum
    CullNone
    CullBack
    CullFront

# ================================================================
# STATE MANAGEMENT
# ================================================================

var galCurrentDevice*: GalDevice
var galCurrentPipeline*: GalPipeline

when not defined(sdlgpu) or defined(emscripten):
  # OpenGL state tracking (for future optimization)
  var galOpenGLState {.used.} = (
    depthTestEnabled: false,
    cullFaceEnabled: false,
    blendEnabled: false,
    currentVao: 0'u32,
    currentProgram: 0'u32
  )

# ================================================================
# DEVICE MANAGEMENT
# ================================================================

proc galCreateDevice*(): GalDevice =
  ## Create graphics device
  result = GalDevice()
  
  when defined(sdlgpu) and not defined(emscripten):
    # Create SDL_GPU device
    const formatFlags = (1 shl SDL_GPU_SHADERFORMAT_SPIRV.ord) or
                        (1 shl SDL_GPU_SHADERFORMAT_DXIL.ord) or
                        (1 shl SDL_GPU_SHADERFORMAT_MSL.ord)
    result.gpuDevice = SDL_CreateGPUDevice(formatFlags.uint32, false, false, nil)
    echo "[GAL] Created SDL_GPU device"
  else:
    # OpenGL - no device object needed
    echo "[GAL] Using OpenGL backend"
  
  galCurrentDevice = result

proc galDestroyDevice*(device: GalDevice) =
  ## Destroy graphics device
  when defined(sdlgpu) and not defined(emscripten):
    if not device.gpuDevice.isNil:
      SDL_DestroyGPUDevice(cast[SDL_GPUDevice](device.gpuDevice))

# ================================================================
# BUFFER MANAGEMENT
# ================================================================

proc galCreateBuffer*(device: GalDevice, size: int, usage: BufferUsage): GalBuffer =
  ## Create a GPU buffer
  result = GalBuffer(size: size, usage: usage)
  
  when defined(sdlgpu) and not defined(emscripten):
    var usageFlags = case usage
      of BufferVertex: SDL_GPU_BUFFERUSAGE_VERTEX
      of BufferIndex: SDL_GPU_BUFFERUSAGE_INDEX
      of BufferUniform: SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ
    
    var info = SDL_GPUBufferCreateInfo(
      usage: usageFlags,
      sizeInBytes: size.uint32,
      props: 0
    )
    result.gpuBuffer = SDL_CreateGPUBuffer(
      cast[SDL_GPUDevice](device.gpuDevice), addr info)
  else:
    # OpenGL
    var buffer: GLuint
    glGenBuffers(1, addr buffer)
    result.glBuffer = buffer

proc galUploadBuffer*(device: GalDevice, buffer: GalBuffer, data: pointer, size: int) =
  ## Upload data to buffer
  when defined(sdlgpu) and not defined(emscripten):
    # Create transfer buffer
    var transferInfo = SDL_GPUTransferBufferCreateInfo(
      usage: SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
      sizeInBytes: size.uint32,
      props: 0
    )
    let transferBuffer = SDL_CreateGPUTransferBuffer(
      cast[SDL_GPUDevice](device.gpuDevice), addr transferInfo)
    
    # Map and copy
    let mapped = SDL_MapGPUTransferBuffer(
      cast[SDL_GPUDevice](device.gpuDevice), transferBuffer, true)
    if not mapped.isNil:
      copyMem(mapped, data, size)
      SDL_UnmapGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
    
    # Upload via command buffer (simplified - needs proper command buffer)
    # In production, this would be done during render pass
    
    SDL_ReleaseGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
  else:
    # OpenGL
    let target = case buffer.usage
      of BufferVertex: GL_ARRAY_BUFFER
      of BufferIndex: GL_ELEMENT_ARRAY_BUFFER
      of BufferUniform: GL_ARRAY_BUFFER  # Use array buffer for uniforms in simple case
    
    glBindBuffer(target, buffer.glBuffer)
    glBufferData(target, size.GLsizei, data, GL_STATIC_DRAW)
    glBindBuffer(target, 0)

proc galDestroyBuffer*(device: GalDevice, buffer: GalBuffer) =
  ## Destroy a buffer
  when defined(sdlgpu) and not defined(emscripten):
    if not buffer.gpuBuffer.isNil:
      SDL_ReleaseGPUBuffer(cast[SDL_GPUDevice](device.gpuDevice),
                          cast[SDL_GPUBuffer](buffer.gpuBuffer))
  else:
    var buf = buffer.glBuffer
    glDeleteBuffers(1, addr buf)

# ================================================================
# RENDERING STATE
# ================================================================

proc galEnableDepthTest*(enable: bool) =
  ## Enable/disable depth testing
  when defined(sdlgpu) and not defined(emscripten):
    # State is set in pipeline creation
    discard
  else:
    if enable:
      glEnable(GL_DEPTH_TEST)
    else:
      glDisable(GL_DEPTH_TEST)

proc galEnableCulling*(enable: bool) =
  ## Enable/disable backface culling
  when defined(sdlgpu) and not defined(emscripten):
    # State is set in pipeline creation
    discard
  else:
    if enable:
      glEnable(GL_CULL_FACE)
    else:
      glDisable(GL_CULL_FACE)

proc galClear*(r, g, b, a: float32, clearDepth: bool = true) =
  ## Clear the screen
  when defined(sdlgpu) and not defined(emscripten):
    # Handled in render pass begin
    discard
  else:
    glClearColor(r, g, b, a)
    var mask = GL_COLOR_BUFFER_BIT
    if clearDepth:
      mask = mask or GL_DEPTH_BUFFER_BIT
    glClear(mask)

proc galSetViewport*(x, y, width, height: int) =
  ## Set viewport
  when defined(sdlgpu) and not defined(emscripten):
    # Handled in render pass
    discard
  else:
    glViewport(x.GLint, y.GLint, width.GLsizei, height.GLsizei)

# ================================================================
# DRAWING
# ================================================================

proc galDrawIndexed*(indexCount: int, instanceCount: int = 1) =
  ## Draw indexed primitives
  when defined(sdlgpu) and not defined(emscripten):
    # Requires active render pass
    # SDL_DrawGPUIndexedPrimitives(renderPass, indexCount.uint32, 
    #                              instanceCount.uint32, 0, 0, 0)
    discard
  else:
    glDrawElements(GL_TRIANGLES, indexCount.GLsizei, cGL_UNSIGNED_SHORT, nil)

# ================================================================
# SHADER MANAGEMENT
# ================================================================

proc galCompileShaderFromSource*(device: GalDevice, source: string, stage: ShaderStage): pointer =
  ## Compile shader from source code (OpenGL only, SDL_GPU uses precompiled)
  when defined(sdlgpu) and not defined(emscripten):
    # SDL_GPU requires precompiled shaders (SPIR-V/DXIL/MSL)
    echo "[GAL] Warning: SDL_GPU requires precompiled shaders, use galLoadShader instead"
    return nil
  else:
    let shaderType = if stage == ShaderVertex: GL_VERTEX_SHADER else: GL_FRAGMENT_SHADER
    let shader = glCreateShader(shaderType)
    
    var srcCstr = source.cstring
    glShaderSource(shader, 1, cast[ptr cstring](addr srcCstr), nil)
    
    glCompileShader(shader)
    
    # Check compilation status
    var success: GLint
    glGetShaderiv(shader, GL_COMPILE_STATUS, addr success)
    if success == 0:
      var logLen: GLint
      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr logLen)
      var log = newString(logLen)
      glGetShaderInfoLog(shader, logLen, nil, cast[ptr GLchar](addr log[0]))
      echo "[GAL] Shader compilation failed: ", log
      glDeleteShader(shader)
      return nil
    
    return cast[pointer](shader)

proc galLoadShader*(device: GalDevice, vertPath, fragPath: string): GalShader =
  ## Load and compile shaders from files
  result = GalShader()
  
  when defined(sdlgpu) and not defined(emscripten):
    # Load precompiled shaders for SDL_GPU
    # Expected format: .spv (SPIR-V), .dxil, or .metallib
    let vertData = readFile(vertPath)
    let fragData = readFile(fragPath)
    
    var vertInfo = SDL_GPUShaderCreateInfo(
      codeSize: vertData.len.uint,
      code: cast[ptr uint8](unsafeAddr vertData[0]),
      entryPointName: "main",
      format: SDL_GPU_SHADERFORMAT_SPIRV,
      stage: SDL_GPU_SHADERSTAGE_VERTEX,
      numSamplers: 0,
      numStorageTextures: 0,
      numStorageBuffers: 0,
      numUniformBuffers: 1
    )
    
    var fragInfo = SDL_GPUShaderCreateInfo(
      codeSize: fragData.len.uint,
      code: cast[ptr uint8](unsafeAddr fragData[0]),
      entryPointName: "main",
      format: SDL_GPU_SHADERFORMAT_SPIRV,
      stage: SDL_GPU_SHADERSTAGE_FRAGMENT,
      numSamplers: 0,
      numStorageTextures: 0,
      numStorageBuffers: 0,
      numUniformBuffers: 0
    )
    
    result.vertexShader = SDL_CreateGPUShader(cast[SDL_GPUDevice](device.gpuDevice), addr vertInfo)
    result.fragmentShader = SDL_CreateGPUShader(cast[SDL_GPUDevice](device.gpuDevice), addr fragInfo)
    
    echo "[GAL] Loaded precompiled shaders: ", vertPath, " / ", fragPath
  else:
    # Compile GLSL shaders for OpenGL
    let vertSource = readFile(vertPath)
    let fragSource = readFile(fragPath)
    
    let vertShader = galCompileShaderFromSource(device, vertSource, ShaderVertex)
    let fragShader = galCompileShaderFromSource(device, fragSource, ShaderFragment)
    
    if vertShader.isNil or fragShader.isNil:
      echo "[GAL] Failed to compile shaders"
      return nil
    
    # Link program
    let program = glCreateProgram()
    glAttachShader(program, cast[GLuint](vertShader))
    glAttachShader(program, cast[GLuint](fragShader))
    glLinkProgram(program)
    
    # Check link status
    var success: GLint
    glGetProgramiv(program, GL_LINK_STATUS, addr success)
    if success == 0:
      var logLen: GLint
      glGetProgramiv(program, GL_INFO_LOG_LENGTH, addr logLen)
      var log = newString(logLen)
      glGetProgramInfoLog(program, logLen, nil, cast[ptr GLchar](addr log[0]))
      echo "[GAL] Shader linking failed: ", log
      glDeleteProgram(program)
      return nil
    
    # Clean up shader objects
    glDeleteShader(cast[GLuint](vertShader))
    glDeleteShader(cast[GLuint](fragShader))
    
    result.glProgram = program
    echo "[GAL] Compiled and linked shaders: ", vertPath, " / ", fragPath

proc galDestroyShader*(device: GalDevice, shader: GalShader) =
  ## Destroy shader
  when defined(sdlgpu) and not defined(emscripten):
    if not shader.vertexShader.isNil:
      SDL_ReleaseGPUShader(cast[SDL_GPUDevice](device.gpuDevice), 
                          cast[SDL_GPUShader](shader.vertexShader))
    if not shader.fragmentShader.isNil:
      SDL_ReleaseGPUShader(cast[SDL_GPUDevice](device.gpuDevice),
                          cast[SDL_GPUShader](shader.fragmentShader))
  else:
    glDeleteProgram(shader.glProgram)

# ================================================================
# TEXTURE MANAGEMENT
# ================================================================

proc galCreateTexture*(device: GalDevice, width, height: int, 
                       format: TextureFormat = TextureRGBA8): GalTexture =
  ## Create an empty texture
  result = GalTexture(width: width, height: height, format: format)
  
  when defined(sdlgpu) and not defined(emscripten):
    let gpuFormat = case format
      of TextureRGBA8: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
      of TextureRGB8: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM  # SDL_GPU doesn't have RGB8
      of TextureR8: SDL_GPU_TEXTUREFORMAT_R8_UNORM
      of TextureDepth24Stencil8: SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT
    
    var texInfo = SDL_GPUTextureCreateInfo(
      textureType: SDL_GPU_TEXTURETYPE_2D,
      format: gpuFormat,
      usage: SDL_GPU_TEXTUREUSAGE_SAMPLER,
      width: width.uint32,
      height: height.uint32,
      layerCountOrDepth: 1,
      numLevels: 1,
      sampleCount: SDL_GPU_SAMPLECOUNT_1,
      props: 0
    )
    
    result.gpuTexture = SDL_CreateGPUTexture(cast[SDL_GPUDevice](device.gpuDevice), addr texInfo)
    
    # Create sampler
    var samplerInfo = SDL_GPUSamplerCreateInfo(
      minFilter: SDL_GPU_FILTER_LINEAR,
      magFilter: SDL_GPU_FILTER_LINEAR,
      mipmapMode: SDL_GPU_SAMPLERMIPMAPMODE_LINEAR,
      addressModeU: SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
      addressModeV: SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
      addressModeW: SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
      mipLodBias: 0,
      maxAnisotropy: 1,
      compareOp: SDL_GPU_COMPAREOP_NEVER,
      minLod: 0,
      maxLod: 1000,
      enableCompare: false,
      enableAnisotropy: false,
      props: 0
    )
    
    result.gpuSampler = SDL_CreateGPUSampler(cast[SDL_GPUDevice](device.gpuDevice), addr samplerInfo)
  else:
    var tex: GLuint
    glGenTextures(1, addr tex)
    result.glTexture = tex
    
    glBindTexture(GL_TEXTURE_2D, tex)
    
    let glFormat = case format
      of TextureRGBA8: (GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE)
      of TextureRGB8: (GL_RGB, GL_RGB, GL_UNSIGNED_BYTE)
      of TextureR8: (GL_RED, GL_RED, GL_UNSIGNED_BYTE)
      of TextureDepth24Stencil8: (GL_DEPTH24_STENCIL8, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8)
    
    glTexImage2D(GL_TEXTURE_2D, 0, glFormat[0].GLint, width.GLsizei, height.GLsizei,
                 0, glFormat[1], glFormat[2], nil)
    
    # Default filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.GLint)
    
    glBindTexture(GL_TEXTURE_2D, 0)

proc galUploadTexture*(device: GalDevice, texture: GalTexture, data: pointer) =
  ## Upload pixel data to texture
  when defined(sdlgpu) and not defined(emscripten):
    # Create transfer buffer
    let dataSize = texture.width * texture.height * 4  # Assume RGBA for now
    var transferInfo = SDL_GPUTransferBufferCreateInfo(
      usage: SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
      sizeInBytes: dataSize.uint32,
      props: 0
    )
    let transferBuffer = SDL_CreateGPUTransferBuffer(
      cast[SDL_GPUDevice](device.gpuDevice), addr transferInfo)
    
    # Map and copy
    let mapped = SDL_MapGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), 
                                         transferBuffer, true)
    if not mapped.isNil:
      copyMem(mapped, data, dataSize)
      SDL_UnmapGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
    
    # TODO: Upload via copy pass (requires command buffer)
    
    SDL_ReleaseGPUTransferBuffer(cast[SDL_GPUDevice](device.gpuDevice), transferBuffer)
  else:
    glBindTexture(GL_TEXTURE_2D, texture.glTexture)
    
    let glFormat = case texture.format
      of TextureRGBA8: (GL_RGBA, GL_UNSIGNED_BYTE)
      of TextureRGB8: (GL_RGB, GL_UNSIGNED_BYTE)
      of TextureR8: (GL_RED, GL_UNSIGNED_BYTE)
      of TextureDepth24Stencil8: (GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8)
    
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture.width.GLsizei, texture.height.GLsizei,
                    glFormat[0], glFormat[1], data)
    
    glBindTexture(GL_TEXTURE_2D, 0)

proc galSetTextureFilter*(texture: GalTexture, minFilter, magFilter: TextureFilter) =
  ## Set texture filtering mode
  when not defined(sdlgpu) or defined(emscripten):
    glBindTexture(GL_TEXTURE_2D, texture.glTexture)
    
    let glMin = if minFilter == FilterNearest: GL_NEAREST else: GL_LINEAR
    let glMag = if magFilter == FilterNearest: GL_NEAREST else: GL_LINEAR
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, glMin.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, glMag.GLint)
    
    glBindTexture(GL_TEXTURE_2D, 0)

proc galSetTextureWrap*(texture: GalTexture, wrapS, wrapT: TextureWrap) =
  ## Set texture wrap mode
  when not defined(sdlgpu) or defined(emscripten):
    glBindTexture(GL_TEXTURE_2D, texture.glTexture)
    
    let glWrapS = case wrapS
      of WrapRepeat: GL_REPEAT
      of WrapClamp: GL_CLAMP_TO_EDGE
      of WrapMirror: GL_MIRRORED_REPEAT
    
    let glWrapT = case wrapT
      of WrapRepeat: GL_REPEAT
      of WrapClamp: GL_CLAMP_TO_EDGE
      of WrapMirror: GL_MIRRORED_REPEAT
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, glWrapS.GLint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, glWrapT.GLint)
    
    glBindTexture(GL_TEXTURE_2D, 0)

proc galDestroyTexture*(device: GalDevice, texture: GalTexture) =
  ## Destroy texture
  when defined(sdlgpu) and not defined(emscripten):
    if not texture.gpuTexture.isNil:
      SDL_ReleaseGPUTexture(cast[SDL_GPUDevice](device.gpuDevice),
                           cast[SDL_GPUTexture](texture.gpuTexture))
    if not texture.gpuSampler.isNil:
      SDL_ReleaseGPUSampler(cast[SDL_GPUDevice](device.gpuDevice),
                           cast[SDL_GPUSampler](texture.gpuSampler))
  else:
    var tex = texture.glTexture
    glDeleteTextures(1, addr tex)

# ================================================================
# PIPELINE MANAGEMENT
# ================================================================

proc galCreatePipeline*(device: GalDevice, shader: GalShader, 
                        vertexLayout: GalVertexLayout,
                        state: PipelineState): GalPipeline =
  ## Create graphics pipeline
  result = GalPipeline()
  
  when defined(sdlgpu) and not defined(emscripten):
    # Build vertex input state
    var vertexAttributes: seq[SDL_GPUVertexAttribute]
    var vertexBufferDesc = SDL_GPUVertexBufferDescription(
      slot: 0,
      pitch: vertexLayout.stride.uint32,
      inputRate: SDL_GPU_VERTEXINPUTRATE_VERTEX,
      instanceStepRate: 0
    )
    
    for attr in vertexLayout.attributes:
      let gpuFormat = case attr.format
        of VertexFloat: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT
        of VertexFloat2: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2
        of VertexFloat3: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3
        of VertexFloat4: SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4
        of VertexByte4: SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM
      
      vertexAttributes.add(SDL_GPUVertexAttribute(
        location: attr.location.uint32,
        bufferSlot: 0,
        format: gpuFormat,
        offset: attr.offset.uint32
      ))
    
    var vertexInputState = SDL_GPUVertexInputState(
      vertexBufferDescriptions: addr vertexBufferDesc,
      numVertexBuffers: 1,
      vertexAttributes: if vertexAttributes.len > 0: addr vertexAttributes[0] else: nil,
      numVertexAttributes: vertexAttributes.len.uint32
    )
    
    # Depth stencil state
    var depthStencilState = SDL_GPUDepthStencilState(
      enableDepthTest: state.depthTest,
      enableDepthWrite: state.depthWrite,
      compareOp: SDL_GPU_COMPAREOP_LESS,
      enableStencilTest: false
    )
    
    # Rasterizer state
    let gpuCullMode = case state.cullMode
      of CullNone: SDL_GPU_CULLMODE_NONE
      of CullBack: SDL_GPU_CULLMODE_BACK
      of CullFront: SDL_GPU_CULLMODE_FRONT
    
    var rasterizerState = SDL_GPURasterizerState(
      cullMode: gpuCullMode,
      frontFace: SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,
      fillMode: SDL_GPU_FILLMODE_FILL,
      enableDepthBias: false,
      enableDepthClip: true
    )
    
    # Color target (blend state simplified)
    var colorTarget = SDL_GPUColorTargetDescription(
      format: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
      blendState: nil  # Blend state simplified in bindings
    )
    
    # Primitive type
    let gpuPrimitive = case state.primitiveType
      of PrimitiveTriangles: SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
      of PrimitiveLines: SDL_GPU_PRIMITIVETYPE_LINELIST
      of PrimitivePoints: SDL_GPU_PRIMITIVETYPE_POINTLIST
    
    # Create pipeline
    var pipelineInfo = SDL_GPUGraphicsPipelineCreateInfo(
      vertexShader: cast[SDL_GPUShader](shader.vertexShader),
      fragmentShader: cast[SDL_GPUShader](shader.fragmentShader),
      vertexInputState: vertexInputState,
      primitiveType: gpuPrimitive,
      rasterizerState: rasterizerState,
      multisampleState: SDL_GPUMultisampleState(
        sampleCount: 1'u32,
        sampleMask: 0xFFFFFFFF'u32
      ),
      depthStencilState: depthStencilState,
      targetInfo: SDL_GPUGraphicsPipelineTargetInfo(
        colorTargetDescriptions: addr colorTarget,
        numColorTargets: 1,
        depthStencilFormat: SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
        hasDepthStencilTarget: state.depthTest
      ),
      props: 0
    )
    
    result.gpuPipeline = SDL_CreateGPUGraphicsPipeline(
      cast[SDL_GPUDevice](device.gpuDevice), addr pipelineInfo)
    
    echo "[GAL] Created SDL_GPU pipeline"
  else:
    # OpenGL: Store shader and state
    result.shader = shader
    echo "[GAL] Created OpenGL pipeline (state will be set at draw time)"

proc galBindPipeline*(pipeline: GalPipeline) =
  ## Bind pipeline for rendering
  galCurrentPipeline = pipeline
  
  when defined(sdlgpu) and not defined(emscripten):
    # Pipeline binding happens in render pass
    discard
  else:
    # OpenGL: Use shader program
    if not pipeline.shader.isNil:
      glUseProgram(pipeline.shader.glProgram)

proc galDestroyPipeline*(device: GalDevice, pipeline: GalPipeline) =
  ## Destroy pipeline
  when defined(sdlgpu) and not defined(emscripten):
    if not pipeline.gpuPipeline.isNil:
      SDL_ReleaseGPUGraphicsPipeline(cast[SDL_GPUDevice](device.gpuDevice),
                                     cast[SDL_GPUGraphicsPipeline](pipeline.gpuPipeline))

# ================================================================
# VERTEX LAYOUT HELPERS
# ================================================================

proc galCreateVertexLayout*(stride: int): GalVertexLayout =
  ## Create vertex layout descriptor
  result = GalVertexLayout(stride: stride, attributes: @[])

proc galAddAttribute*(layout: GalVertexLayout, location: int, 
                      format: VertexFormat, offset: int) =
  ## Add attribute to vertex layout
  layout.attributes.add(VertexAttribute(
    location: location,
    format: format,
    offset: offset
  ))

# ================================================================
# CONVENIENCE WRAPPERS
# ================================================================

template galWithDevice*(device: GalDevice, body: untyped) =
  ## Execute code with device context
  let oldDevice = galCurrentDevice
  galCurrentDevice = device
  try:
    body
  finally:
    galCurrentDevice = oldDevice
