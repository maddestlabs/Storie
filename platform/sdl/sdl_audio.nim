## SDL3 Audio Implementation
## Implements the audio interface for SDL3

import ../audio_interface
import sdl3_bindings

export audio_interface

type
  SdlAudioSystem* = ref object of AudioSystem
    devices*: seq[SdlAudioDevice]
    streams*: seq[SdlAudioStream]

  SdlAudioDevice* = ref object of AudioDevice
    sdlDeviceId*: sdl3_bindings.SDL_AudioDeviceID

  SdlAudioStream* = ref object of AudioStream
    sdlStream*: ptr sdl3_bindings.SDL_AudioStream
    boundDevice*: SdlAudioDevice

# ================================================================
# HELPER FUNCTIONS
# ================================================================

proc toSdlAudioFormat(format: AudioFormat): SDL_AudioFormat =
  ## Convert our format to SDL format
  case format
  of afU8: SDL_AUDIO_U8
  of afS8: SDL_AUDIO_S8
  of afS16: SDL_AUDIO_S16LE
  of afS32: SDL_AUDIO_S32LE
  of afF32: SDL_AUDIO_F32LE

proc toAudioFormat(sdlFormat: SDL_AudioFormat): AudioFormat =
  ## Convert SDL format to our format
  if sdlFormat == SDL_AUDIO_U8: afU8
  elif sdlFormat == SDL_AUDIO_S8: afS8
  elif sdlFormat == SDL_AUDIO_S16LE or sdlFormat == SDL_AUDIO_S16BE: afS16
  elif sdlFormat == SDL_AUDIO_S32LE or sdlFormat == SDL_AUDIO_S32BE: afS32
  else: afF32

proc toSdlAudioSpec(spec: AudioSpec): SDL_AudioSpec =
  ## Convert our spec to SDL spec
  result.format = toSdlAudioFormat(spec.format)
  result.channels = cint(spec.channels)
  result.freq = cint(spec.sampleRate)

# ================================================================
# AUDIO SYSTEM LIFECYCLE
# ================================================================

method initAudio*(sys: SdlAudioSystem): bool =
  ## Initialize SDL audio subsystem
  if (SDL_Init(SDL_INIT_AUDIO) and SDL_INIT_AUDIO) != 0:
    return false
  sys.initialized = true
  return true

method shutdownAudio*(sys: SdlAudioSystem) =
  ## Cleanup SDL audio
  # Close all devices
  for device in sys.devices:
    SDL_CloseAudioDevice(device.sdlDeviceId)
  sys.devices.setLen(0)
  
  # Destroy all streams
  for stream in sys.streams:
    if stream.sdlStream != nil:
      SDL_DestroyAudioStream(stream.sdlStream)
  sys.streams.setLen(0)
  
  sys.initialized = false

# ================================================================
# AUDIO DEVICE MANAGEMENT
# ================================================================

method openDevice*(sys: SdlAudioSystem, spec: AudioSpec, 
                   isCapture: bool = false): AudioDevice =
  ## Open an SDL audio device
  if not sys.initialized:
    if not sys.initAudio():
      return nil
  
  var sdlSpec = toSdlAudioSpec(spec)
  
  let defaultDeviceId = if isCapture: SDL_AUDIO_DEVICE_DEFAULT_RECORDING
                        else: SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
  
  let deviceId = SDL_OpenAudioDevice(defaultDeviceId, addr sdlSpec)
  if deviceId == 0:
    return nil
  
  var device = SdlAudioDevice()
  device.id = AudioDeviceID(deviceId)
  device.sdlDeviceId = deviceId
  device.spec = spec
  
  sys.devices.add(device)
  return device

method closeDevice*(sys: SdlAudioSystem, device: AudioDevice) =
  ## Close an SDL audio device
  let sdlDevice = SdlAudioDevice(device)
  SDL_CloseAudioDevice(sdlDevice.sdlDeviceId)
  
  # Remove from tracked devices
  for i in 0..<sys.devices.len:
    if cast[pointer](sys.devices[i]) == cast[pointer](device):
      sys.devices.delete(i)
      break

method pauseDevice*(sys: SdlAudioSystem, device: AudioDevice) =
  ## Pause SDL audio device
  let sdlDevice = SdlAudioDevice(device)
  discard SDL_PauseAudioDevice(sdlDevice.sdlDeviceId)

method resumeDevice*(sys: SdlAudioSystem, device: AudioDevice) =
  ## Resume SDL audio device
  let sdlDevice = SdlAudioDevice(device)
  discard SDL_ResumeAudioDevice(sdlDevice.sdlDeviceId)

# ================================================================
# AUDIO STREAM MANAGEMENT
# ================================================================

method createStream*(sys: SdlAudioSystem, spec: AudioSpec): AudioStream =
  ## Create an SDL audio stream
  var sdlSpec = toSdlAudioSpec(spec)
  
  let sdlStream = SDL_CreateAudioStream(addr sdlSpec, addr sdlSpec)
  if sdlStream == nil:
    return nil
  
  var stream = SdlAudioStream()
  stream.handle = AudioStreamHandle(sdlStream)
  stream.spec = spec
  stream.sdlStream = sdlStream
  stream.boundDevice = nil
  
  sys.streams.add(stream)
  return stream

method destroyStream*(sys: SdlAudioSystem, stream: AudioStream) =
  ## Destroy an SDL audio stream
  let sdlStream = SdlAudioStream(stream)
  
  # Unbind from device if bound
  if sdlStream.boundDevice != nil:
    SDL_UnbindAudioStream(sdlStream.sdlStream)
  
  SDL_DestroyAudioStream(sdlStream.sdlStream)
  
  # Remove from tracked streams
  for i in 0..<sys.streams.len:
    if cast[pointer](sys.streams[i]) == cast[pointer](stream):
      sys.streams.delete(i)
      break

method bindStream*(sys: SdlAudioSystem, device: AudioDevice, 
                   stream: AudioStream): bool =
  ## Bind stream to device
  let sdlDevice = SdlAudioDevice(device)
  let sdlStream = SdlAudioStream(stream)
  
  if SDL_BindAudioStream(sdlDevice.sdlDeviceId, sdlStream.sdlStream):
    sdlStream.boundDevice = sdlDevice
    return true
  return false

method playStream*(sys: SdlAudioSystem, stream: AudioStream) =
  ## Start playing (resume device if bound)
  let sdlStream = SdlAudioStream(stream)
  if sdlStream.boundDevice != nil:
    sys.resumeDevice(sdlStream.boundDevice)

method stopStream*(sys: SdlAudioSystem, stream: AudioStream) =
  ## Stop stream (pause device if bound)
  let sdlStream = SdlAudioStream(stream)
  if sdlStream.boundDevice != nil:
    sys.pauseDevice(sdlStream.boundDevice)

method pauseStream*(sys: SdlAudioSystem, stream: AudioStream) =
  ## Pause stream
  sys.stopStream(stream)

method resumeStream*(sys: SdlAudioSystem, stream: AudioStream) =
  ## Resume stream
  sys.playStream(stream)

# ================================================================
# STREAM DATA OPERATIONS
# ================================================================

method putStreamData*(sys: SdlAudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): bool =
  ## Put audio data into the stream
  let sdlStream = SdlAudioStream(stream)
  let bytes = frames * getBytesPerFrame(stream.spec)
  return SDL_PutAudioStreamData(sdlStream.sdlStream, data, cint(bytes))

method getStreamData*(sys: SdlAudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): int32 =
  ## Get audio data from stream
  let sdlStream = SdlAudioStream(stream)
  let bytes = frames * getBytesPerFrame(stream.spec)
  let bytesRead = SDL_GetAudioStreamData(sdlStream.sdlStream, data, cint(bytes))
  return getFrameSize(stream.spec, bytesRead)

method getStreamAvailable*(sys: SdlAudioSystem, stream: AudioStream): int32 =
  ## Get available frames in stream
  let sdlStream = SdlAudioStream(stream)
  let bytes = SDL_GetAudioStreamAvailable(sdlStream.sdlStream)
  return getFrameSize(stream.spec, bytes)

method isStreamProcessed*(sys: SdlAudioSystem, stream: AudioStream): bool =
  ## Check if stream needs more data (SDL3 doesn't have direct equivalent)
  ## Check if available data is low
  return sys.getStreamAvailable(stream) < (stream.spec.sampleRate div 10)  # Less than 0.1s

method updateStream*(sys: SdlAudioSystem, stream: AudioStream,
                     data: pointer, frames: int32) =
  ## Update stream (SDL3 uses putStreamData)
  discard sys.putStreamData(stream, data, frames)

# ================================================================
# STREAM CALLBACKS
# ================================================================

method setStreamCallback*(sys: SdlAudioSystem, stream: AudioStream,
                          callback: AudioCallback) =
  ## SDL3 doesn't support callbacks in the same way as raylib
  ## Would need to implement via a separate thread
  discard

# ================================================================
# STREAM PROPERTIES
# ================================================================

method setStreamVolume*(sys: SdlAudioSystem, stream: AudioStream, 
                        volume: float32) =
  ## SDL3 audio streams don't have direct volume control
  ## Would need to implement via audio processing
  discard

method setStreamPan*(sys: SdlAudioSystem, stream: AudioStream,
                     pan: float32) =
  ## SDL3 audio streams don't have direct pan control
  ## Would need to implement via audio processing
  discard

method setStreamPitch*(sys: SdlAudioSystem, stream: AudioStream,
                       pitch: float32) =
  ## SDL3 audio streams don't have direct pitch control
  ## Would need to implement via audio processing
  discard

# ================================================================
# CONSTRUCTOR
# ================================================================

proc createSdlAudioSystem*(): AudioSystem =
  ## Create a new SDL audio system
  result = SdlAudioSystem()
  result.initialized = false
