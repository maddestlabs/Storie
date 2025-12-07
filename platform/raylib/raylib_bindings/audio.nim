## Raylib Audio Bindings - Direct C API bindings for raylib audio

import build_config
import types

export types

# Audio callback type (prefixed to avoid conflicts with interface)
type
  RlAudioCallback* = proc(bufferData: pointer, frames: cuint) {.cdecl.}

# Audio stream type (opaque, prefixed to avoid conflicts)
type
  RlAudioStream* {.importc: "AudioStream", header: "raylib.h".} = object
    buffer*: pointer        ## Pointer to internal data used by the audio system
    processor*: pointer     ## Pointer to internal data processor
    sampleRate*: cuint      ## Frequency (samples per second)
    sampleSize*: cuint      ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: cuint        ## Number of channels (1-mono, 2-stereo, ...)

# ================================================================
# AUDIO DEVICE MANAGEMENT
# ================================================================

proc InitAudioDevice*() {.importc, header: "raylib.h".}
  ## Initialize audio device

proc CloseAudioDevice*() {.importc, header: "raylib.h".}
  ## Close the audio device for all contexts

proc IsAudioDeviceReady*(): bool {.importc, header: "raylib.h".}
  ## Check if audio device has been initialized successfully

proc SetMasterVolume*(volume: cfloat) {.importc, header: "raylib.h".}
  ## Set master volume (listener)

proc GetMasterVolume*(): cfloat {.importc, header: "raylib.h".}
  ## Get master volume (listener)

# ================================================================
# AUDIO STREAM MANAGEMENT
# ================================================================

proc LoadAudioStream*(sampleRate: cuint, sampleSize: cuint, 
                      channels: cuint): RlAudioStream {.importc, header: "raylib.h".}
  ## Load audio stream (to stream raw audio pcm data)

proc UnloadAudioStream*(stream: RlAudioStream) {.importc, header: "raylib.h".}
  ## Unload audio stream and free memory

proc IsAudioStreamReady*(stream: RlAudioStream): bool {.importc, header: "raylib.h".}
  ## Checks if an audio stream is ready

proc UpdateAudioStream*(stream: RlAudioStream, data: pointer, 
                        frameCount: cint) {.importc, header: "raylib.h".}
  ## Update audio stream buffers with data

proc IsAudioStreamProcessed*(stream: RlAudioStream): bool {.importc, header: "raylib.h".}
  ## Check if any audio stream buffers requires refill

proc PlayAudioStream*(stream: RlAudioStream) {.importc, header: "raylib.h".}
  ## Play audio stream

proc PauseAudioStream*(stream: RlAudioStream) {.importc, header: "raylib.h".}
  ## Pause audio stream

proc ResumeAudioStream*(stream: RlAudioStream) {.importc, header: "raylib.h".}
  ## Resume audio stream

proc StopAudioStream*(stream: RlAudioStream) {.importc, header: "raylib.h".}
  ## Stop audio stream

proc IsAudioStreamPlaying*(stream: RlAudioStream): bool {.importc, header: "raylib.h".}
  ## Check if audio stream is playing

# ================================================================
# AUDIO STREAM PROPERTIES
# ================================================================

proc SetAudioStreamVolume*(stream: RlAudioStream, volume: cfloat) {.importc, header: "raylib.h".}
  ## Set volume for audio stream (1.0 is max level)

proc SetAudioStreamPitch*(stream: RlAudioStream, pitch: cfloat) {.importc, header: "raylib.h".}
  ## Set pitch for audio stream (1.0 is base level)

proc SetAudioStreamPan*(stream: RlAudioStream, pan: cfloat) {.importc, header: "raylib.h".}
  ## Set pan for audio stream (0.5 is centered)

proc SetAudioStreamBufferSizeDefault*(size: cint) {.importc, header: "raylib.h".}
  ## Default size for new audio streams

# ================================================================
# AUDIO STREAM CALLBACKS
# ================================================================

proc SetAudioStreamCallback*(stream: RlAudioStream, 
                              callback: RlAudioCallback) {.importc, header: "raylib.h".}
  ## Audio thread callback to request new data

proc AttachAudioStreamProcessor*(stream: RlAudioStream, 
                                  processor: RlAudioCallback) {.importc, header: "raylib.h".}
  ## Attach audio stream processor to stream, receives the samples as 'float'

proc DetachAudioStreamProcessor*(stream: RlAudioStream, 
                                  processor: RlAudioCallback) {.importc, header: "raylib.h".}
  ## Detach audio stream processor from stream

proc AttachAudioMixedProcessor*(processor: RlAudioCallback) {.importc, header: "raylib.h".}
  ## Attach audio stream processor to the entire audio pipeline, receives the samples as 'float'

proc DetachAudioMixedProcessor*(processor: RlAudioCallback) {.importc, header: "raylib.h".}
  ## Detach audio stream processor from the entire audio pipeline
