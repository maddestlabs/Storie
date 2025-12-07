## Example: Audio Playback using Unified Audio Interface
##
## This example demonstrates how to use the unified audio interface
## that works with both raylib and SDL3 backends.

import ../platform/audio
import math

proc generateSineWave(frequency: float32, sampleRate: int32, 
                      numFrames: int32): seq[int16] =
  ## Generate a sine wave as 16-bit samples
  result = newSeq[int16](numFrames)
  for i in 0..<numFrames:
    let t = float32(i) / float32(sampleRate)
    let sample = sin(2.0 * PI * frequency * t)
    result[i] = int16(sample * 32000.0)

proc main() =
  echo "=== Unified Audio Example ==="
  echo ""
  
  # Create audio system (automatically uses correct backend)
  let audioSys = createAudioSystem()
  
  # Initialize audio
  if not audioSys.initAudio():
    echo "Failed to initialize audio system"
    return
  
  defer: audioSys.shutdownAudio()
  
  echo "Audio system initialized"
  
  # Set up audio specification
  var spec = AudioSpec(
    sampleRate: 44100,
    channels: 1,  # Mono
    format: afS16,  # 16-bit signed
    bufferSize: 4096
  )
  
  echo "Audio Spec:"
  echo "  Sample Rate: ", spec.sampleRate, " Hz"
  echo "  Channels: ", spec.channels, " (mono)"
  echo "  Format: 16-bit signed"
  echo ""
  
  # Open audio device
  let device = audioSys.openDevice(spec, isCapture = false)
  if device == nil:
    echo "Failed to open audio device"
    return
  
  defer: audioSys.closeDevice(device)
  
  echo "Audio device opened"
  
  # Create audio stream
  let stream = audioSys.createStream(spec)
  if stream == nil:
    echo "Failed to create audio stream"
    return
  
  defer: audioSys.destroyStream(stream)
  
  echo "Audio stream created"
  
  # For SDL3: bind stream to device
  when defined(useSdl) or defined(useSdlGpu):
    if not audioSys.bindStream(device, stream):
      echo "Failed to bind stream to device"
      return
    echo "Stream bound to device"
  
  # Generate a 440Hz sine wave (A note)
  echo ""
  echo "Generating 440Hz sine wave (A note)..."
  let sineWave = generateSineWave(440.0, spec.sampleRate, spec.sampleRate)
  
  # For raylib: set up callback or use updateStream
  when defined(useRaylib):
    echo "Using raylib audio backend"
    # Update the stream with generated audio
    audioSys.updateStream(stream, unsafeAddr sineWave[0], int32(sineWave.len))
    
    # Play the stream
    audioSys.playStream(stream)
    echo "Playing audio for 2 seconds..."
    
    # Simple delay (in real app, you'd integrate with your main loop)
    import os
    sleep(2000)
    
    audioSys.stopStream(stream)
  
  # For SDL3: put data in stream
  when defined(useSdl) or defined(useSdlGpu):
    echo "Using SDL3 audio backend"
    
    # Put audio data into stream
    if audioSys.putStreamData(stream, unsafeAddr sineWave[0], int32(sineWave.len)):
      echo "Audio data queued"
    else:
      echo "Failed to queue audio data"
      return
    
    # Start playback
    audioSys.playStream(stream)
    echo "Playing audio for 2 seconds..."
    
    # Simple delay
    import os
    sleep(2000)
    
    audioSys.stopStream(stream)
  
  echo ""
  echo "Audio playback complete!"

when isMainModule:
  main()
