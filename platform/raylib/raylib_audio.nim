## Raylib Audio Implementation
## Implements the audio interface for raylib

import ../audio_interface
import raylib_bindings

export audio_interface

type
  RaylibAudioSystem* = ref object of AudioSystem
    devices*: seq[RaylibAudioDevice]
    streams*: seq[RaylibAudioStream]

  RaylibAudioDevice* = ref object of AudioDevice
    isCapture*: bool

  RaylibAudioStream* = ref object of AudioStream
    raylibStream*: raylib_bindings.RlAudioStream
    callback*: audio_interface.AudioCallback

# ================================================================
# AUDIO SYSTEM LIFECYCLE
# ================================================================

method initAudio*(sys: RaylibAudioSystem): bool =
  ## Initialize raylib audio device
  InitAudioDevice()
  sys.initialized = IsAudioDeviceReady()
  return sys.initialized

method shutdownAudio*(sys: RaylibAudioSystem) =
  ## Cleanup raylib audio device
  CloseAudioDevice()
  sys.initialized = false

# ================================================================
# AUDIO DEVICE MANAGEMENT
# ================================================================

method openDevice*(sys: RaylibAudioSystem, spec: AudioSpec, 
                   isCapture: bool = false): AudioDevice =
  ## Open audio device (raylib has single global device)
  if not sys.initialized:
    if not sys.initAudio():
      return nil
  
  var device = RaylibAudioDevice()
  device.id = AudioDeviceID(1)  # Raylib uses single device
  device.spec = spec
  device.isCapture = isCapture
  
  sys.devices.add(device)
  return device

method closeDevice*(sys: RaylibAudioSystem, device: AudioDevice) =
  ## Close device (no-op for raylib, uses global device)
  discard

method pauseDevice*(sys: RaylibAudioSystem, device: AudioDevice) =
  ## Pause all streams (raylib doesn't have device-level pause)
  for stream in sys.streams:
    PauseAudioStream(stream.raylibStream)

method resumeDevice*(sys: RaylibAudioSystem, device: AudioDevice) =
  ## Resume all streams
  for stream in sys.streams:
    ResumeAudioStream(stream.raylibStream)

# ================================================================
# AUDIO STREAM MANAGEMENT
# ================================================================

proc toRaylibSampleSize(format: AudioFormat): cuint =
  case format
  of afU8, afS8: 8
  of afS16: 16
  of afS32, afF32: 32

method createStream*(sys: RaylibAudioSystem, spec: AudioSpec): AudioStream =
  ## Create a raylib audio stream
  let sampleSize = toRaylibSampleSize(spec.format)
  let rlStream = LoadAudioStream(
    cuint(spec.sampleRate),
    sampleSize,
    cuint(spec.channels)
  )
  
  if not IsAudioStreamValid(rlStream):
    return nil
  
  var stream = RaylibAudioStream()
  stream.handle = AudioStreamHandle(cast[pointer](unsafeAddr rlStream))
  stream.spec = spec
  stream.raylibStream = rlStream
  stream.callback = nil
  
  sys.streams.add(stream)
  return stream

method destroyStream*(sys: RaylibAudioSystem, stream: AudioStream) =
  ## Destroy a raylib audio stream
  let rlStream = RaylibAudioStream(stream)
  UnloadAudioStream(rlStream.raylibStream)
  
  # Remove from tracked streams
  for i in 0..<sys.streams.len:
    if cast[pointer](sys.streams[i]) == cast[pointer](stream):
      sys.streams.delete(i)
      break

method bindStream*(sys: RaylibAudioSystem, device: AudioDevice, 
                   stream: AudioStream): bool =
  ## Bind stream to device (automatic in raylib)
  return true

method playStream*(sys: RaylibAudioSystem, stream: AudioStream) =
  ## Start playing audio stream
  let rlStream = RaylibAudioStream(stream)
  PlayAudioStream(rlStream.raylibStream)

method stopStream*(sys: RaylibAudioSystem, stream: AudioStream) =
  ## Stop audio stream
  let rlStream = RaylibAudioStream(stream)
  StopAudioStream(rlStream.raylibStream)

method pauseStream*(sys: RaylibAudioSystem, stream: AudioStream) =
  ## Pause audio stream
  let rlStream = RaylibAudioStream(stream)
  PauseAudioStream(rlStream.raylibStream)

method resumeStream*(sys: RaylibAudioSystem, stream: AudioStream) =
  ## Resume audio stream
  let rlStream = RaylibAudioStream(stream)
  ResumeAudioStream(rlStream.raylibStream)

# ================================================================
# STREAM DATA OPERATIONS
# ================================================================

method putStreamData*(sys: RaylibAudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): bool =
  ## Update stream with audio data (not directly available in raylib)
  ## Use updateStream instead
  return false

method getStreamData*(sys: RaylibAudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): int32 =
  ## Get audio data (not supported in raylib for playback streams)
  return 0

method getStreamAvailable*(sys: RaylibAudioSystem, stream: AudioStream): int32 =
  ## Raylib doesn't expose buffer status directly
  return 0

method isStreamProcessed*(sys: RaylibAudioSystem, stream: AudioStream): bool =
  ## Check if stream needs more data
  let rlStream = RaylibAudioStream(stream)
  return IsAudioStreamProcessed(rlStream.raylibStream)

method updateStream*(sys: RaylibAudioSystem, stream: AudioStream,
                     data: pointer, frames: int32) =
  ## Update stream with new audio data (raylib style)
  let rlStream = RaylibAudioStream(stream)
  UpdateAudioStream(rlStream.raylibStream, data, cint(frames))

# ================================================================
# STREAM CALLBACKS
# ================================================================

method setStreamCallback*(sys: RaylibAudioSystem, stream: AudioStream,
                          callback: AudioCallback) =
  ## Set callback for real-time audio processing
  let rlStream = RaylibAudioStream(stream)
  rlStream.callback = callback
  # Cast our AudioCallback to RlAudioCallback (they have same signature)
  let rlCallback = cast[raylib_bindings.RlAudioCallback](callback)
  SetAudioStreamCallback(rlStream.raylibStream, rlCallback)

# ================================================================
# STREAM PROPERTIES
# ================================================================

method setStreamVolume*(sys: RaylibAudioSystem, stream: AudioStream, 
                        volume: float32) =
  ## Set stream volume
  let rlStream = RaylibAudioStream(stream)
  SetAudioStreamVolume(rlStream.raylibStream, cfloat(volume))

method setStreamPan*(sys: RaylibAudioSystem, stream: AudioStream,
                     pan: float32) =
  ## Set stream pan (raylib expects 0.0-1.0, we convert from -1.0 to 1.0)
  let rlStream = RaylibAudioStream(stream)
  let rlPan = (pan + 1.0) * 0.5  # Convert -1..1 to 0..1
  SetAudioStreamPan(rlStream.raylibStream, cfloat(rlPan))

method setStreamPitch*(sys: RaylibAudioSystem, stream: AudioStream,
                       pitch: float32) =
  ## Set stream pitch
  let rlStream = RaylibAudioStream(stream)
  SetAudioStreamPitch(rlStream.raylibStream, cfloat(pitch))

# ================================================================
# CONSTRUCTOR
# ================================================================

proc createRaylibAudioSystem*(): AudioSystem =
  ## Create a new raylib audio system
  result = RaylibAudioSystem()
  result.initialized = false
