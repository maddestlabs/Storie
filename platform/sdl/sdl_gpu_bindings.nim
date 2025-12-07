## SDL_GPU Bindings for Nim
## Minimal bindings for SDL3's GPU API (Vulkan/D3D12/Metal abstraction)

const SDL_GPU_SHADERSTAGE_VERTEX* = 0
const SDL_GPU_SHADERSTAGE_FRAGMENT* = 1

type
  SDL_GPUDevice* = ptr object
  SDL_GPUCommandBuffer* = ptr object
  SDL_GPURenderPass* = ptr object
  SDL_GPUBuffer* = ptr object
  SDL_GPUTransferBuffer* = ptr object
  SDL_GPUTexture* = ptr object
  SDL_GPUShader* = ptr object
  SDL_GPUGraphicsPipeline* = ptr object
  SDL_GPUSampler* = ptr object
  SDL_GPUFence* = ptr object
  
  SDL_GPUShaderFormat* = enum
    SDL_GPU_SHADERFORMAT_INVALID
    SDL_GPU_SHADERFORMAT_PRIVATE   # Precompiled shader format
    SDL_GPU_SHADERFORMAT_SPIRV     # Vulkan
    SDL_GPU_SHADERFORMAT_DXBC      # D3D11
    SDL_GPU_SHADERFORMAT_DXIL      # D3D12
    SDL_GPU_SHADERFORMAT_MSL       # Metal
    SDL_GPU_SHADERFORMAT_METALLIB  # Metal precompiled
  
  SDL_GPUPrimitiveType* = enum
    SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
    SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP
    SDL_GPU_PRIMITIVETYPE_LINELIST
    SDL_GPU_PRIMITIVETYPE_LINESTRIP
    SDL_GPU_PRIMITIVETYPE_POINTLIST
  
  SDL_GPULoadOp* = enum
    SDL_GPU_LOADOP_LOAD
    SDL_GPU_LOADOP_CLEAR
    SDL_GPU_LOADOP_DONT_CARE
  
  SDL_GPUStoreOp* = enum
    SDL_GPU_STOREOP_STORE
    SDL_GPU_STOREOP_DONT_CARE
  
  SDL_GPUIndexElementSize* = enum
    SDL_GPU_INDEXELEMENTSIZE_16BIT
    SDL_GPU_INDEXELEMENTSIZE_32BIT
  
  SDL_GPUTextureFormat* = enum
    SDL_GPU_TEXTUREFORMAT_INVALID
    SDL_GPU_TEXTUREFORMAT_A8_UNORM
    SDL_GPU_TEXTUREFORMAT_R8_UNORM
    SDL_GPU_TEXTUREFORMAT_R8G8_UNORM
    SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
    SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM
    SDL_GPU_TEXTUREFORMAT_R16_FLOAT
    SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT
    SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT
    SDL_GPU_TEXTUREFORMAT_R32_FLOAT
    SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT
    SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT
    SDL_GPU_TEXTUREFORMAT_D16_UNORM
    SDL_GPU_TEXTUREFORMAT_D24_UNORM
    SDL_GPU_TEXTUREFORMAT_D32_FLOAT
    SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT
    SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT
  
  SDL_GPUCullMode* = enum
    SDL_GPU_CULLMODE_NONE
    SDL_GPU_CULLMODE_FRONT
    SDL_GPU_CULLMODE_BACK
  
  SDL_GPUFrontFace* = enum
    SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE
    SDL_GPU_FRONTFACE_CLOCKWISE
  
  SDL_GPUCompareOp* = enum
    SDL_GPU_COMPAREOP_NEVER
    SDL_GPU_COMPAREOP_LESS
    SDL_GPU_COMPAREOP_EQUAL
    SDL_GPU_COMPAREOP_LESS_OR_EQUAL
    SDL_GPU_COMPAREOP_GREATER
    SDL_GPU_COMPAREOP_NOT_EQUAL
    SDL_GPU_COMPAREOP_GREATER_OR_EQUAL
    SDL_GPU_COMPAREOP_ALWAYS
  
  SDL_GPUVertexElementFormat* = enum
    SDL_GPU_VERTEXELEMENTFORMAT_INVALID
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3
    SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE2
    SDL_GPU_VERTEXELEMENTFORMAT_BYTE4
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2
    SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT2
    SDL_GPU_VERTEXELEMENTFORMAT_SHORT4
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT2
    SDL_GPU_VERTEXELEMENTFORMAT_USHORT4
    SDL_GPU_VERTEXELEMENTFORMAT_INT
    SDL_GPU_VERTEXELEMENTFORMAT_INT2
    SDL_GPU_VERTEXELEMENTFORMAT_INT3
    SDL_GPU_VERTEXELEMENTFORMAT_INT4
    SDL_GPU_VERTEXELEMENTFORMAT_UINT
    SDL_GPU_VERTEXELEMENTFORMAT_UINT2
    SDL_GPU_VERTEXELEMENTFORMAT_UINT3
    SDL_GPU_VERTEXELEMENTFORMAT_UINT4
  
  SDL_GPUVertexInputRate* = enum
    SDL_GPU_VERTEXINPUTRATE_VERTEX
    SDL_GPU_VERTEXINPUTRATE_INSTANCE
  
  SDL_GPUFillMode* = enum
    SDL_GPU_FILLMODE_FILL
    SDL_GPU_FILLMODE_LINE
  
  SDL_FColor* = object
    r*, g*, b*, a*: cfloat
  
  SDL_GPUViewport* = object
    x*, y*: cfloat
    w*, h*: cfloat
    minDepth*, maxDepth*: cfloat
  
  SDL_GPUColorTargetInfo* = object
    texture*: SDL_GPUTexture
    mipLevel*: uint32
    layerOrDepthPlane*: uint32
    clearColor*: SDL_FColor
    loadOp*: SDL_GPULoadOp
    storeOp*: SDL_GPUStoreOp
    resolveTexture*: SDL_GPUTexture
    resolveMipLevel*: uint32
    resolveLayer*: uint32
    cycle*: bool
    cycleResolveTexture*: bool
  
  SDL_GPUDepthStencilTargetInfo* = object
    texture*: SDL_GPUTexture
    clearDepth*: cfloat
    loadOp*: SDL_GPULoadOp
    storeOp*: SDL_GPUStoreOp
    stencilLoadOp*: SDL_GPULoadOp
    stencilStoreOp*: SDL_GPUStoreOp
    cycle*: bool
  
  SDL_GPUBufferUsageFlags* = uint32
  
  SDL_GPUBufferCreateInfo* = object
    usage*: SDL_GPUBufferUsageFlags
    sizeInBytes*: uint32
    props*: uint32
  
  SDL_GPUTransferBufferUsage* = enum
    SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD
    SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD
  
  SDL_GPUTransferBufferCreateInfo* = object
    usage*: SDL_GPUTransferBufferUsage
    sizeInBytes*: uint32
    props*: uint32
  
  SDL_GPUShaderCreateInfo* = object
    codeSize*: csize_t
    code*: ptr uint8
    entrypoint*: cstring
    format*: SDL_GPUShaderFormat
    stage*: uint32
    numSamplers*: uint32
    numStorageTextures*: uint32
    numStorageBuffers*: uint32
    numUniformBuffers*: uint32
    props*: uint32
  
  SDL_GPUVertexAttribute* = object
    location*: uint32
    bufferSlot*: uint32
    format*: SDL_GPUVertexElementFormat
    offset*: uint32
  
  SDL_GPUVertexBufferDescription* = object
    slot*: uint32
    pitch*: uint32
    inputRate*: SDL_GPUVertexInputRate
    instanceStepRate*: uint32
  
  SDL_GPUVertexInputState* = object
    vertexBufferDescriptions*: ptr SDL_GPUVertexBufferDescription
    numVertexBuffers*: uint32
    vertexAttributes*: ptr SDL_GPUVertexAttribute
    numVertexAttributes*: uint32
  
  SDL_GPUColorTargetDescription* = object
    format*: SDL_GPUTextureFormat
    blendState*: pointer  # SDL_GPUColorTargetBlendState (simplified)
  
  SDL_GPUGraphicsPipelineTargetInfo* = object
    colorTargetDescriptions*: ptr SDL_GPUColorTargetDescription
    numColorTargets*: uint32
    depthStencilFormat*: SDL_GPUTextureFormat
    hasDepthStencilTarget*: bool
  
  SDL_GPURasterizerState* = object
    fillMode*: SDL_GPUFillMode
    cullMode*: SDL_GPUCullMode
    frontFace*: SDL_GPUFrontFace
    depthBiasConstantFactor*: cfloat
    depthBiasClamp*: cfloat
    depthBiasSlopeFactor*: cfloat
    enableDepthBias*: bool
    enableDepthClip*: bool
  
  SDL_GPUMultisampleState* = object
    sampleCount*: uint32
    sampleMask*: uint32
  
  SDL_GPUDepthStencilState* = object
    compareOp*: SDL_GPUCompareOp
    enableDepthTest*: bool
    enableDepthWrite*: bool
    enableStencilTest*: bool
    # Simplified - full struct has more stencil fields
  
  SDL_GPUGraphicsPipelineCreateInfo* = object
    vertexShader*: SDL_GPUShader
    fragmentShader*: SDL_GPUShader
    vertexInputState*: SDL_GPUVertexInputState
    primitiveType*: SDL_GPUPrimitiveType
    rasterizerState*: SDL_GPURasterizerState
    multisampleState*: SDL_GPUMultisampleState
    depthStencilState*: SDL_GPUDepthStencilState
    targetInfo*: SDL_GPUGraphicsPipelineTargetInfo
    props*: uint32
  
  SDL_GPUBufferBinding* = object
    buffer*: SDL_GPUBuffer
    offset*: uint32
  
  SDL_GPUBufferRegion* = object
    buffer*: SDL_GPUBuffer
    offset*: uint32
    size*: uint32
  
  SDL_GPUTextureTransferInfo* = object
    transferBuffer*: SDL_GPUTransferBuffer
    offset*: uint32
  
  SDL_GPUTextureRegion* = object
    texture*: SDL_GPUTexture
    mipLevel*: uint32
    layer*: uint32
    x*, y*, z*: uint32
    w*, h*, d*: uint32

const
  SDL_GPU_BUFFERUSAGE_VERTEX* = 0x00000001'u32
  SDL_GPU_BUFFERUSAGE_INDEX* = 0x00000002'u32
  SDL_GPU_BUFFERUSAGE_INDIRECT* = 0x00000004'u32
  SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ* = 0x00000008'u32
  SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ* = 0x00000020'u32
  SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE* = 0x00000040'u32

# Core functions
proc SDL_CreateGPUDevice*(formatFlags: uint32, debugMode: bool, name: cstring): SDL_GPUDevice 
  {.importc: "SDL_CreateGPUDevice", header: "SDL3/SDL_gpu.h".}

proc SDL_ClaimWindowForGPUDevice*(device: SDL_GPUDevice, window: pointer): bool 
  {.importc: "SDL_ClaimWindowForGPUDevice", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseWindowFromGPUDevice*(device: SDL_GPUDevice, window: pointer) 
  {.importc: "SDL_ReleaseWindowFromGPUDevice", header: "SDL3/SDL_gpu.h".}

proc SDL_GetGPUSwapchainTextureFormat*(device: SDL_GPUDevice, window: pointer): SDL_GPUTextureFormat 
  {.importc: "SDL_GetGPUSwapchainTextureFormat", header: "SDL3/SDL_gpu.h".}

proc SDL_AcquireGPUCommandBuffer*(device: SDL_GPUDevice): SDL_GPUCommandBuffer 
  {.importc: "SDL_AcquireGPUCommandBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_WaitAndAcquireGPUSwapchainTexture*(cmdBuf: SDL_GPUCommandBuffer, window: pointer,
  swapchainTexture: ptr SDL_GPUTexture, pWidth: ptr uint32, pHeight: ptr uint32): bool 
  {.importc: "SDL_WaitAndAcquireGPUSwapchainTexture", header: "SDL3/SDL_gpu.h".}

proc SDL_SubmitGPUCommandBuffer*(cmdBuf: SDL_GPUCommandBuffer): bool 
  {.importc: "SDL_SubmitGPUCommandBuffer", header: "SDL3/SDL_gpu.h".}

# Resource creation
proc SDL_CreateGPUBuffer*(device: SDL_GPUDevice, createInfo: ptr SDL_GPUBufferCreateInfo): SDL_GPUBuffer 
  {.importc: "SDL_CreateGPUBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_CreateGPUTransferBuffer*(device: SDL_GPUDevice, createInfo: ptr SDL_GPUTransferBufferCreateInfo): SDL_GPUTransferBuffer 
  {.importc: "SDL_CreateGPUTransferBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_CreateGPUShader*(device: SDL_GPUDevice, createInfo: ptr SDL_GPUShaderCreateInfo): SDL_GPUShader 
  {.importc: "SDL_CreateGPUShader", header: "SDL3/SDL_gpu.h".}

proc SDL_CreateGPUGraphicsPipeline*(device: SDL_GPUDevice, createInfo: ptr SDL_GPUGraphicsPipelineCreateInfo): SDL_GPUGraphicsPipeline 
  {.importc: "SDL_CreateGPUGraphicsPipeline", header: "SDL3/SDL_gpu.h".}

# Render pass
proc SDL_BeginGPURenderPass*(cmdBuf: SDL_GPUCommandBuffer, colorTargets: ptr SDL_GPUColorTargetInfo, 
  numColorTargets: uint32, depthStencilTarget: ptr SDL_GPUDepthStencilTargetInfo): SDL_GPURenderPass 
  {.importc: "SDL_BeginGPURenderPass", header: "SDL3/SDL_gpu.h".}

proc SDL_BindGPUGraphicsPipeline*(renderPass: SDL_GPURenderPass, pipeline: SDL_GPUGraphicsPipeline) 
  {.importc: "SDL_BindGPUGraphicsPipeline", header: "SDL3/SDL_gpu.h".}

proc SDL_BindGPUVertexBuffers*(renderPass: SDL_GPURenderPass, firstSlot: uint32, 
  bindings: ptr SDL_GPUBufferBinding, numBindings: uint32) 
  {.importc: "SDL_BindGPUVertexBuffers", header: "SDL3/SDL_gpu.h".}

proc SDL_BindGPUIndexBuffer*(renderPass: SDL_GPURenderPass, binding: ptr SDL_GPUBufferBinding, 
  indexElementSize: SDL_GPUIndexElementSize) 
  {.importc: "SDL_BindGPUIndexBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_SetGPUViewport*(renderPass: SDL_GPURenderPass, viewport: ptr SDL_GPUViewport) 
  {.importc: "SDL_SetGPUViewport", header: "SDL3/SDL_gpu.h".}

proc SDL_PushGPUVertexUniformData*(cmdBuf: SDL_GPUCommandBuffer, slotIndex: uint32, 
  data: pointer, dataLengthInBytes: uint32) 
  {.importc: "SDL_PushGPUVertexUniformData", header: "SDL3/SDL_gpu.h".}

proc SDL_PushGPUFragmentUniformData*(cmdBuf: SDL_GPUCommandBuffer, slotIndex: uint32, 
  data: pointer, dataLengthInBytes: uint32) 
  {.importc: "SDL_PushGPUFragmentUniformData", header: "SDL3/SDL_gpu.h".}

proc SDL_DrawGPUIndexedPrimitives*(renderPass: SDL_GPURenderPass, numIndices: uint32, 
  numInstances: uint32, firstIndex: uint32, vertexOffset: int32, firstInstance: uint32) 
  {.importc: "SDL_DrawGPUIndexedPrimitives", header: "SDL3/SDL_gpu.h".}

proc SDL_DrawGPUPrimitives*(renderPass: SDL_GPURenderPass, numVertices: uint32, 
  numInstances: uint32, firstVertex: uint32, firstInstance: uint32) 
  {.importc: "SDL_DrawGPUPrimitives", header: "SDL3/SDL_gpu.h".}

proc SDL_EndGPURenderPass*(renderPass: SDL_GPURenderPass) 
  {.importc: "SDL_EndGPURenderPass", header: "SDL3/SDL_gpu.h".}

# Data upload
proc SDL_MapGPUTransferBuffer*(device: SDL_GPUDevice, transferBuffer: SDL_GPUTransferBuffer, 
  cycle: bool): pointer 
  {.importc: "SDL_MapGPUTransferBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_UnmapGPUTransferBuffer*(device: SDL_GPUDevice, transferBuffer: SDL_GPUTransferBuffer) 
  {.importc: "SDL_UnmapGPUTransferBuffer", header: "SDL3/SDL_gpu.h".}

# Transfer buffer location
type SDL_GPUTransferBufferLocation* = object
  transferBuffer*: SDL_GPUTransferBuffer
  offset*: uint32

proc SDL_UploadToGPUBuffer*(cmdBuf: SDL_GPUCommandBuffer, source: ptr SDL_GPUTransferBufferLocation, 
  destination: ptr SDL_GPUBufferRegion, cycle: bool) 
  {.importc: "SDL_UploadToGPUBuffer", header: "SDL3/SDL_gpu.h".}

# Cleanup
proc SDL_ReleaseGPUBuffer*(device: SDL_GPUDevice, buffer: SDL_GPUBuffer) 
  {.importc: "SDL_ReleaseGPUBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseGPUTransferBuffer*(device: SDL_GPUDevice, buffer: SDL_GPUTransferBuffer) 
  {.importc: "SDL_ReleaseGPUTransferBuffer", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseGPUShader*(device: SDL_GPUDevice, shader: SDL_GPUShader) 
  {.importc: "SDL_ReleaseGPUShader", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseGPUGraphicsPipeline*(device: SDL_GPUDevice, pipeline: SDL_GPUGraphicsPipeline) 
  {.importc: "SDL_ReleaseGPUGraphicsPipeline", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseGPUTexture*(device: SDL_GPUDevice, texture: SDL_GPUTexture) 
  {.importc: "SDL_ReleaseGPUTexture", header: "SDL3/SDL_gpu.h".}

proc SDL_ReleaseGPUSampler*(device: SDL_GPUDevice, sampler: SDL_GPUSampler) 
  {.importc: "SDL_ReleaseGPUSampler", header: "SDL3/SDL_gpu.h".}

proc SDL_DestroyGPUDevice*(device: SDL_GPUDevice) 
  {.importc: "SDL_DestroyGPUDevice", header: "SDL3/SDL_gpu.h".}
