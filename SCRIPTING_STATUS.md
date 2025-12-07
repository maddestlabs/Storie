# Making Storie Scripts Work with Audio

## Current Status

The audio implementation is **complete at the Nim level** but the **Nimini scripting layer** and **Storie markdown integration** need additional work.

## What Works Now

✅ **Full Nim Implementation:**
```nim
import platform/audio

let sys = newAudioSystem()
sys.initAudio()

let stream = sys.createStream(AudioSpec(
  sampleRate: 44100,
  channels: 1,
  format: afS16,
  bufferSize: 512
))

sys.playStream(stream)
```

## What Needs Implementation

### 1. Nimini Language Extensions

**Issue:** The script uses advanced features not in Nimini:
- `newSeq[int16]` - Typed sequences
- `cast[ptr UncheckedArray[T]]` - Pointer arrays
- Sized numeric types (`float32`, `int16`, `uint32`)

**Solution:** Either:
- A) Use simplified Nimini syntax (current capability)
- B) Extend Nimini with these features (significant work)
- C) Use full Nim for audio scripts (recommended)

### 2. Storie Markdown Integration

**Issue:** The `on:init`, `on:render`, `on:cleanup` syntax needs:
- Markdown parser for code blocks with metadata
- Event system to trigger callbacks
- Graphics context integration
- Input system integration

**Components Needed:**
```nim
# platform/storie_runtime.nim
type
  StorieScript* = object
    initCode*: proc()
    renderCode*: proc()
    cleanupCode*: proc()
    
proc parseStorieMarkdown*(md: string): StorieScript
proc executeStorieScript*(script: StorieScript)
```

### 3. Simplified Audio API for Scripts

**Current API:**
```nim
let sys = newAudioSystem()
sys.initAudio()
let stream = sys.createStream(spec)
sys.playStream(stream)
```

**Needed Script-Friendly API:**
```nim
# Simple functions that manage global state
proc initAudio()
proc createAudioStream(rate: int, bits: int, channels: int): AudioStreamHandle
proc setAudioCallback(stream: AudioStreamHandle, callback: proc)
proc playAudioStream(stream: AudioStreamHandle)
proc setAudioPan(stream: AudioStreamHandle, pan: float)
```

### 4. Graphics/Input Integration

The script uses graphics functions that need to be implemented:
- `clear()`, `setColor()`, `fillRect()`
- `drawText()`, `drawLine()`, `fillCircle()`
- `getMouseX()`, `getMouseY()`, `isMouseButtonDown()`
- `width`, `height`, `frameCount` globals

## Recommended Approach

### Option A: Full Nim Script (Works Today)

Write the example in full Nim instead of Nimini:

```nim
# examples/audio_sinewave.nim
import platform/audio
import platform/render3d  # For graphics
import platform/platform_interface  # For input

# ... full implementation with proper types
```

**Pros:** Works immediately with current implementation
**Cons:** Not as simple as markdown scripting

### Option B: Build Script Runtime Layer

Create a simplified scripting layer on top of the platform APIs:

```nim
# platform/script_api.nim
## Simplified API for Storie markdown scripts

var globalAudioSystem: AudioSystem
var globalRenderer: RenderSystem

proc initAudio*() =
  globalAudioSystem = newAudioSystem()
  discard globalAudioSystem.initAudio()

proc createAudioStream*(rate, bits, channels: int): int =
  # Return handle ID, manage streams in global table
  ...

# Register these with Nimini runtime
registerNative("initAudio", wrap(initAudio))
registerNative("createAudioStream", wrap(createAudioStream))
```

### Option C: Markdown Script System

Build a complete markdown scripting system:

```nim
# platform/storie_script.nim
import nimini

type
  StorieBlock = object
    language: string
    trigger: string  # "init", "render", "cleanup"
    code: string

proc parseStorieMd(mdContent: string): seq[StorieBlock]
proc compileStorieBlock(block: StorieBlock): Program
proc runStorieScript(blocks: seq[StorieBlock])
```

## Implementation Priority

### Phase 1: Script API Layer (High Priority)
1. Create `platform/script_api.nim` with simplified wrappers
2. Register functions with Nimini runtime
3. Test with Nimini console

### Phase 2: Markdown Parser (Medium Priority)  
1. Parse markdown code blocks with metadata
2. Extract `on:init`, `on:render`, `on:cleanup` sections
3. Compile each section with Nimini

### Phase 3: Event System (Medium Priority)
1. Hook init code to startup
2. Hook render code to frame loop
3. Hook cleanup code to shutdown

### Phase 4: Graphics/Input (Low Priority)
1. Expose graphics functions to Nimini
2. Expose input functions to Nimini
3. Expose window globals (width, height, frameCount)

## Minimal Working Example

Here's what WOULD work with current implementation:

```nim
# In Nimini console (if we add script API):

initAudio()
var stream = createAudioStream(44100, 16, 1)
var freq = 440.0
setStreamCallback(stream, proc (buf: int, frames: int):
  # Generate audio...
  return 0
)
playAudioStream(stream)
```

**But:** This still needs the script API layer to be built.

## Timeline Estimate

- **Script API Layer:** 2-4 hours
- **Markdown Parser:** 4-6 hours  
- **Event System:** 2-3 hours
- **Graphics/Input Binding:** 3-5 hours

**Total:** ~11-18 hours of development work

## Conclusion

The **audio system is ready**, but the **scripting integration layer** is missing. The example you showed would work if we:

1. ✅ Have audio system (DONE)
2. ❌ Need script API wrapper (TODO)
3. ❌ Need markdown parser (TODO)
4. ❌ Need graphics/input bindings (TODO)
5. ❌ Need event system (TODO)

**Recommendation:** Start with Option A (full Nim examples) for now, then build the scripting layer incrementally.
