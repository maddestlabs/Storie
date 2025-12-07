## Audio Interface - Platform-agnostic audio abstraction
##
## This module defines the common audio interface that all platform backends
## implement. It provides a unified API for audio playback, recording, and
## stream management across SDL3 and raylib.

type
  AudioFormat* = enum
    afU8       ## Unsigned 8-bit samples
    afS8       ## Signed 8-bit samples
    afS16      ## Signed 16-bit samples
    afS32      ## Signed 32-bit samples
    afF32      ## 32-bit floating point samples

  AudioSpec* = object
    ## Audio specification for streams and devices
    sampleRate*: int32     ## Sample rate (e.g., 44100, 48000)
    channels*: int32       ## Number of channels (1=mono, 2=stereo)
    format*: AudioFormat   ## Sample format
    bufferSize*: int32     ## Buffer size in frames (optional, 0 = default)

  AudioCallback* = proc(buffer: pointer; frames: int32) {.cdecl.}
    ## Callback for real-time audio processing
    ## buffer: pointer to audio data buffer
    ## frames: number of audio frames to process

  AudioDeviceID* = distinct uint32
    ## Opaque audio device identifier

  AudioStreamHandle* = distinct pointer
    ## Opaque audio stream handle

  AudioSystem* = ref object of RootObj
    ## Base audio system interface
    initialized*: bool

  AudioDevice* = ref object of RootObj
    ## Base audio device interface
    id*: AudioDeviceID
    spec*: AudioSpec

  AudioStream* = ref object of RootObj
    ## Base audio stream interface
    handle*: AudioStreamHandle
    spec*: AudioSpec

# ================================================================
# AUDIO SYSTEM LIFECYCLE
# ================================================================

method initAudio*(sys: AudioSystem): bool {.base.} =
  ## Initialize the audio system
  ## Returns true on success, false on failure
  quit "AudioSystem.initAudio() must be overridden"

method shutdownAudio*(sys: AudioSystem) {.base.} =
  ## Shutdown and cleanup the audio system
  quit "AudioSystem.shutdownAudio() must be overridden"

# ================================================================
# AUDIO DEVICE MANAGEMENT
# ================================================================

method openDevice*(sys: AudioSystem, spec: AudioSpec, 
                   isCapture: bool = false): AudioDevice {.base.} =
  ## Open an audio device with the given specification
  ## isCapture: true for recording device, false for playback
  ## Returns nil on failure
  quit "AudioSystem.openDevice() must be overridden"

method closeDevice*(sys: AudioSystem, device: AudioDevice) {.base.} =
  ## Close an audio device
  quit "AudioSystem.closeDevice() must be overridden"

method pauseDevice*(sys: AudioSystem, device: AudioDevice) {.base.} =
  ## Pause audio playback/recording
  quit "AudioSystem.pauseDevice() must be overridden"

method resumeDevice*(sys: AudioSystem, device: AudioDevice) {.base.} =
  ## Resume audio playback/recording
  quit "AudioSystem.resumeDevice() must be overridden"

# ================================================================
# AUDIO STREAM MANAGEMENT
# ================================================================

method createStream*(sys: AudioSystem, spec: AudioSpec): AudioStream {.base.} =
  ## Create an audio stream with the given specification
  ## Returns nil on failure
  quit "AudioSystem.createStream() must be overridden"

method destroyStream*(sys: AudioSystem, stream: AudioStream) {.base.} =
  ## Destroy an audio stream
  quit "AudioSystem.destroyStream() must be overridden"

method bindStream*(sys: AudioSystem, device: AudioDevice, 
                   stream: AudioStream): bool {.base.} =
  ## Bind a stream to a device (SDL3 style)
  ## Returns true on success
  quit "AudioSystem.bindStream() must be overridden"

method playStream*(sys: AudioSystem, stream: AudioStream) {.base.} =
  ## Start playing an audio stream (raylib style)
  quit "AudioSystem.playStream() must be overridden"

method stopStream*(sys: AudioSystem, stream: AudioStream) {.base.} =
  ## Stop an audio stream
  quit "AudioSystem.stopStream() must be overridden"

method pauseStream*(sys: AudioSystem, stream: AudioStream) {.base.} =
  ## Pause an audio stream
  quit "AudioSystem.pauseStream() must be overridden"

method resumeStream*(sys: AudioSystem, stream: AudioStream) {.base.} =
  ## Resume a paused audio stream
  quit "AudioSystem.resumeStream() must be overridden"

# ================================================================
# STREAM DATA OPERATIONS
# ================================================================

method putStreamData*(sys: AudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): bool {.base.} =
  ## Put audio data into the stream buffer
  ## Returns true on success
  quit "AudioSystem.putStreamData() must be overridden"

method getStreamData*(sys: AudioSystem, stream: AudioStream,
                      data: pointer, frames: int32): int32 {.base.} =
  ## Get audio data from the stream (for recording)
  ## Returns number of frames actually read
  quit "AudioSystem.getStreamData() must be overridden"

method getStreamAvailable*(sys: AudioSystem, stream: AudioStream): int32 {.base.} =
  ## Get number of frames available in the stream buffer
  quit "AudioSystem.getStreamAvailable() must be overridden"

method isStreamProcessed*(sys: AudioSystem, stream: AudioStream): bool {.base.} =
  ## Check if the stream has processed its current buffer (raylib)
  quit "AudioSystem.isStreamProcessed() must be overridden"

method updateStream*(sys: AudioSystem, stream: AudioStream,
                     data: pointer, frames: int32) {.base.} =
  ## Update stream with new audio data (raylib style)
  quit "AudioSystem.updateStream() must be overridden"

# ================================================================
# STREAM CALLBACKS
# ================================================================

method setStreamCallback*(sys: AudioSystem, stream: AudioStream,
                          callback: AudioCallback) {.base.} =
  ## Set a callback for real-time audio processing
  quit "AudioSystem.setStreamCallback() must be overridden"

# ================================================================
# STREAM PROPERTIES
# ================================================================

method setStreamVolume*(sys: AudioSystem, stream: AudioStream, 
                        volume: float32) {.base.} =
  ## Set stream volume (0.0 to 1.0)
  quit "AudioSystem.setStreamVolume() must be overridden"

method setStreamPan*(sys: AudioSystem, stream: AudioStream,
                     pan: float32) {.base.} =
  ## Set stream pan (-1.0 = left, 0.0 = center, 1.0 = right)
  quit "AudioSystem.setStreamPan() must be overridden"

method setStreamPitch*(sys: AudioSystem, stream: AudioStream,
                       pitch: float32) {.base.} =
  ## Set stream pitch multiplier (1.0 = normal)
  quit "AudioSystem.setStreamPitch() must be overridden"

# ================================================================
# HELPER FUNCTIONS
# ================================================================

proc getBytesPerSample*(format: AudioFormat): int32 =
  ## Get the size of one sample in bytes
  case format
  of afU8, afS8: 1
  of afS16: 2
  of afS32, afF32: 4

proc getBytesPerFrame*(spec: AudioSpec): int32 =
  ## Get the size of one frame (all channels) in bytes
  getBytesPerSample(spec.format) * spec.channels

proc getFrameSize*(spec: AudioSpec, bytes: int32): int32 =
  ## Calculate number of frames for a given byte count
  bytes div getBytesPerFrame(spec)
