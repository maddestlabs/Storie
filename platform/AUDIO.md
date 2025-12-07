# Storie Audio System

The Storie audio system provides a unified, platform-agnostic API for audio playback and recording that works across both **raylib** and **SDL3** backends.

## Architecture

The audio system follows the same pattern as the graphics/rendering system:

```
platform/
├── audio_interface.nim          # Platform-agnostic audio API
├── audio.nim                    # Unified export (selects backend at compile-time)
├── raylib/
│   ├── raylib_bindings/
│   │   └── audio.nim           # Direct raylib C bindings
│   └── raylib_audio.nim        # Raylib audio implementation
└── sdl/
    ├── sdl3_bindings/
    │   └── audio.nim           # Direct SDL3 C bindings  
    └── sdl_audio.nim           # SDL3 audio implementation
```

## Features

### Core Features (Both Backends)
- ✅ Audio device initialization and management
- ✅ Audio stream creation and playback
- ✅ Multiple audio formats (8-bit, 16-bit, 32-bit, float)
- ✅ Mono and stereo support
- ✅ Stream play/pause/stop/resume
- ✅ Stream data queuing

### Raylib-Specific Features
- ✅ Real-time audio callbacks
- ✅ Stream volume control
- ✅ Stream pan control (stereo positioning)
- ✅ Stream pitch control
- ✅ Buffer processing detection
- ✅ Audio stream processors

### SDL3-Specific Features
- ✅ Flexible stream binding to devices
- ✅ Audio format conversion
- ✅ Buffer availability queries
- ✅ Device enumeration

## Usage

### Basic Audio Playback

```nim
import platform/audio

# Create audio system (automatically selects backend)
let audioSys = createAudioSystem()

# Initialize
if not audioSys.initAudio():
  echo "Failed to initialize audio"
  return

defer: audioSys.shutdownAudio()

# Configure audio
var spec = AudioSpec(
  sampleRate: 44100,   # 44.1 kHz
  channels: 2,         # Stereo
  format: afS16        # 16-bit signed
)

# Open device
let device = audioSys.openDevice(spec)
let stream = audioSys.createStream(spec)

# For SDL3: bind stream to device
when defined(useSdl):
  discard audioSys.bindStream(device, stream)

# Queue audio data
discard audioSys.putStreamData(stream, audioData, frameCount)

# Start playback
audioSys.playStream(stream)
```

### Raylib-Style Callback Processing

```nim
proc audioCallback(buffer: pointer, frames: int32) {.cdecl.} =
  # Generate or process audio in real-time
  let samples = cast[ptr UncheckedArray[int16]](buffer)
  for i in 0..<frames:
    samples[i] = generateSample(i)

# Set the callback
audioSys.setStreamCallback(stream, audioCallback)
audioSys.playStream(stream)
```

### SDL3-Style Buffer Management

```nim
# Check available buffer space
let available = audioSys.getStreamAvailable(stream)

# Queue multiple buffers
discard audioSys.putStreamData(stream, buffer1, frames1)
discard audioSys.putStreamData(stream, buffer2, frames2)

# Start playback
audioSys.playStream(stream)
```

## Audio Formats

| Format | Description | Size |
|--------|-------------|------|
| `afU8` | Unsigned 8-bit | 1 byte |
| `afS8` | Signed 8-bit | 1 byte |
| `afS16` | Signed 16-bit | 2 bytes |
| `afS32` | Signed 32-bit | 4 bytes |
| `afF32` | 32-bit float | 4 bytes |

## API Reference

### AudioSystem Methods

#### Lifecycle
- `initAudio(): bool` - Initialize audio subsystem
- `shutdownAudio()` - Cleanup audio subsystem

#### Device Management
- `openDevice(spec: AudioSpec, isCapture = false): AudioDevice` - Open audio device
- `closeDevice(device: AudioDevice)` - Close audio device
- `pauseDevice(device: AudioDevice)` - Pause device playback
- `resumeDevice(device: AudioDevice)` - Resume device playback

#### Stream Management
- `createStream(spec: AudioSpec): AudioStream` - Create audio stream
- `destroyStream(stream: AudioStream)` - Destroy audio stream
- `bindStream(device, stream): bool` - Bind stream to device (SDL3)
- `playStream(stream: AudioStream)` - Start playing stream
- `stopStream(stream: AudioStream)` - Stop stream playback
- `pauseStream(stream: AudioStream)` - Pause stream
- `resumeStream(stream: AudioStream)` - Resume stream

#### Data Operations
- `putStreamData(stream, data: pointer, frames: int32): bool` - Queue audio data
- `getStreamData(stream, data: pointer, frames: int32): int32` - Read audio data
- `getStreamAvailable(stream): int32` - Get available buffer frames
- `isStreamProcessed(stream): bool` - Check if stream needs data (raylib)
- `updateStream(stream, data: pointer, frames: int32)` - Update stream (raylib)

#### Callbacks and Properties
- `setStreamCallback(stream, callback: AudioCallback)` - Set processing callback
- `setStreamVolume(stream, volume: float32)` - Set volume (0.0 - 1.0)
- `setStreamPan(stream, pan: float32)` - Set pan (-1.0 left, 0.0 center, 1.0 right)
- `setStreamPitch(stream, pitch: float32)` - Set pitch (1.0 = normal)

## Examples

### Sine Wave Generator
See `examples/audio_unified_example.nim` for a complete example that:
- Initializes the audio system
- Creates an audio device and stream
- Generates a 440Hz sine wave
- Plays it for 2 seconds
- Works with both raylib and SDL3 backends

### Build and Run

**Raylib backend:**
```bash
./build-audio-example-raylib.sh
./build/audio_unified_example
```

**SDL3 backend:**
```bash
./build-audio-example-sdl.sh
./build/audio_unified_example
```

## Naylib Compatibility

To support the naylib audio example, you'll need:

### Language Features (Nimini)
- [ ] Const declarations with types
- [ ] Defer statements
- [ ] Type annotations (float32, int16, uint32)
- [ ] Pointer types and casting
- [ ] UncheckedArray support
- [ ] Pragma support ({.cdecl.})

### Runtime Integration
The current implementation provides the low-level audio bindings. To expose these to Nimini scripts, you would:

1. Create wrapper functions in `storie.nim`:
```nim
proc niminiInitAudio*(env: ref Env; args: seq[Value]): Value {.nimini.} =
  let audioSys = createAudioSystem()
  if audioSys.initAudio():
    # Store audioSys in environment or global
    return valBool(true)
  return valBool(false)
```

2. Register them with Nimini runtime:
```nim
registerNative("initAudio", niminiInitAudio)
registerNative("loadAudioStream", niminiLoadAudioStream)
registerNative("playAudioStream", niminiPlayAudioStream)
# etc...
```

3. Use simplified syntax in Nimini scripts:
```nim
# Nimini script
if initAudio():
  let stream = loadAudioStream(44100, 16, 1)
  playAudioStream(stream)
```

## Implementation Notes

### Raylib Backend
- Uses global audio device (single device model)
- Supports real-time callbacks natively
- Has built-in volume, pan, pitch controls
- Provides `IsAudioStreamProcessed()` for buffer management

### SDL3 Backend
- Multi-device support (can open multiple devices)
- Stream-based architecture (bind streams to devices)
- No built-in callbacks (would need separate thread implementation)
- No built-in volume/pan/pitch (would need audio processing layer)

### Backend Selection
The audio backend is selected at compile-time via:
- `-d:useRaylib` - Use raylib audio
- `-d:useSdl` or `-d:useSdlGpu` - Use SDL3 audio

## Future Enhancements

Potential additions:
- [ ] Audio file loading (WAV, MP3, OGG)
- [ ] 3D spatial audio support
- [ ] Audio effects (reverb, echo, filters)
- [ ] Audio recording/capture support
- [ ] Mixer for multiple concurrent sounds
- [ ] Music streaming for large audio files

## License

Same as Storie project.
