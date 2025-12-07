# Nimini Features Needed for Naylib Audio Example

We want to be able to support code from naylib like this:
```
import raylib, std/[math, strformat]

const
  screenWidth = 800
  screenHeight = 450

const
  MaxSamples = 512
  MaxSamplesPerUpdate = 4096

var
  frequency: float32 = 440 # Cycles per second (hz)
  audioFrequency: float32 = 440 # Audio frequency, for smoothing
  oldFrequency: float32 = 1 # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
  sineIdx: float32 = 0 # Index for audio rendering

proc audioInputCallback(buffer: pointer; frames: uint32) {.cdecl.} =
  # Audio input processing callback
  audioFrequency = frequency + (audioFrequency - frequency)*0.95'f32
  audioFrequency += 1
  audioFrequency -= 1
  let incr = audioFrequency/44100'f32
  let d = cast[ptr UncheckedArray[int16]](buffer)
  for i in 0..<frames:
    d[i] = int16(32000'f32*sin(2*PI*sineIdx))
    sineIdx += incr
    if sineIdx > 1: sineIdx -= 1

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [audio] example - raw audio streaming")
  defer: closeWindow() # Close window and OpenGL context

  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device (music streaming is automatically stopped)

  setAudioStreamBufferSizeDefault(MaxSamplesPerUpdate)
  # Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
  var stream = loadAudioStream(44100, 16, 1)
  setAudioStreamCallback(stream, audioInputCallback)
  # Buffer for the single cycle waveform we are synthesizing
  var data = newSeq[int16](MaxSamples)
  # Frame buffer, describing the waveform when repeated over the course of a frame
  var writeBuf = newSeq[int16](MaxSamplesPerUpdate)
  playAudioStream(stream)
  # Start processing stream buffer (no data loaded currently)
  # Position read in to determine next frequency
  var mousePosition = Vector2(x: -100, y: -100)
  # # Cycles per second (hz)
  # var frequency: float32 = 440
  # # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
  # var oldFrequency: float32 = 1
  # # Cursor to read and copy the samples of the sine wave buffer
  # var readCursor: int32 = 0
  # Computed size in samples of the sine wave
  var waveLength: int32 = 1
  var position: Vector2

  setTargetFPS(30) # Set our game to run at 30 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Sample mouse input.
    mousePosition = getMousePosition()
    if isMouseButtonDown(Left):
      let fp = mousePosition.y
      frequency = 40 + fp
      let pan = mousePosition.x/screenWidth
      setAudioStreamPan(stream, pan)
    if frequency != oldFrequency:
      # Compute wavelength. Limit size in both directions.
      # let oldWavelength = waveLength
      waveLength = int32(22050/frequency)
      if waveLength > MaxSamples div 2: waveLength = MaxSamples div 2
      if waveLength < 1: waveLength = 1
      for i in 0..<waveLength*2:
        data[i] = int16(sin(2*PI*i.float32/waveLength.float32)*32000)
      # Make sure the rest of the line is flat
      for j in waveLength*2..<MaxSamples:
        data[j] = int16(0)
      # Scale read cursor's position to minimize transition artifacts
      # readCursor = int32(readCursor.float32*(waveLength.float32/oldWavelength.float32))
      oldFrequency = frequency
    # # Refill audio stream if required
    # if isAudioStreamProcessed(stream):
    #   # Synthesize a buffer that is exactly the requested size
    #   var writeCursor: int32 = 0
    #   while writeCursor < MaxSamplesPerUpdate:
    #     # Start by trying to write the whole chunk at once
    #     var writeLength = MaxSamplesPerUpdate - writeCursor
    #     # Limit to the maximum readable size
    #     let readLength = waveLength - readCursor
    #     if writeLength > readLength: writeLength = readLength
    #     copyMem(addr writeBuf[writeCursor], addr data[readCursor], writeLength*sizeof(int16))
    #     # Update cursors and loop audio
    #     readCursor = (readCursor + writeLength) mod waveLength
    #     inc writeCursor, writeLength
    #   # Copy finished frame to audio stream
    #   updateAudioStream(stream, writeBuf)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText(&"sine frequency: {frequency.int32}", getScreenWidth() - 220, 10, 20, Red)
    drawText("click mouse button to change frequency or pan", 10, 10, 20, DarkGray)
    # Draw the current buffer state proportionate to the screen
    for i in 0..<screenWidth:
      position.x = float32(i)
      position.y = 250 + 50*data[i*MaxSamples div screenWidth].float32/32000
      drawPixel(position, Red)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
```


## Analysis of Missing Features

### Current Example Requirements

The naylib audio example uses these Nim features:

```nim
# 1. Sized numeric types
var frequency: float32 = 440
var data = newSeq[int16](MaxSamples)

# 2. Literal type suffixes
audioFrequency += 1'f32
let incr = audioFrequency/44100'f32

# 3. Unchecked array casting
let d = cast[ptr UncheckedArray[int16]](buffer)

# 4. Generic sequences with types
var data = newSeq[int16](MaxSamples)
var writeBuf = newSeq[int16](MaxSamplesPerUpdate)

# 5. String formatting
drawText(&"sine frequency: {frequency.int32}", ...)

# 6. Complex expressions
data[i*MaxSamples div screenWidth].float32/32000

# 7. Object field access
mousePosition.x
mousePosition.y

# 8. Enum values
if isMouseButtonDown(Left):
```

## Implementation Priority

### ✅ Already Implemented in Nimini

1. **Basic types**: `int`, `float`, `string`, `bool`
2. **Type annotations**: `var x: int = 5`
3. **Constants**: `const MaxSamples = 512`
4. **Type definitions**: `type X = Y`
5. **Sequences**: `newSeq(size)`, `add()`, `len()`, etc.
6. **Cast expressions**: `cast[int](value)`
7. **Pointer operations**: `addr x`
8. **Defer statements**: `defer: cleanup()`
9. **Pragmas**: `{.cdecl.}`
10. **For loops**: `for i in 0..<10:`
11. **Functions**: `proc name(args): returnType`

### ❌ Missing Features (Priority Order)

#### Priority 1: Critical for Audio Example

**1. Sized Numeric Types**
```nim
# Currently: only `int` and `float` (platform-dependent size)
# Needed:
float32, float64  # 32-bit and 64-bit floats
int8, int16, int32, int64  # Sized integers
uint8, uint16, uint32, uint64  # Unsigned integers
```

**Implementation:**
- Add to `ValueKind`: `vkFloat32`, `vkInt16`, etc.
- Or: Store size metadata in existing `vkInt`/`vkFloat`
- Update parser to recognize `float32`, `int16` in type annotations
- Update runtime to handle conversions

**Effort:** Medium (4-6 hours)

---

**2. Typed Generic Sequences**
```nim
# Currently: newSeq(size) - untyped
# Needed: newSeq[int16](size)
var data = newSeq[int16](MaxSamples)
```

**Implementation:**
- Parser: Handle `[T]` syntax in function calls
- Runtime: Store element type in array values
- Stdlib: Update `newSeq` to accept type parameter
- Type checking: Validate element types on access

**Effort:** Medium-High (6-8 hours)

---

**3. Numeric Literal Suffixes**
```nim
# Currently: 440.0 is parsed as float
# Needed: 440'f32, 100'i16, etc.
let x = 1.5'f32
let y = 32000'i16
```

**Implementation:**
- Tokenizer: Recognize `'` suffix in numbers
- Parser: Extract suffix and create sized literal
- Runtime: Store with appropriate size

**Effort:** Low-Medium (2-3 hours)

---

**4. String Interpolation**
```nim
# Currently: string concatenation with &
# Needed: &"text {expr} more"
drawText(&"frequency: {freq.int32}", x, y)
```

**Implementation:**
- Parser: Detect `&"..."` and parse `{expr}` sections
- Convert to: `"text " & $expr & " more"`
- Or: Add ekStringInterp expression kind

**Effort:** Medium (3-4 hours)

---

#### Priority 2: Important for Ergonomics

**5. Type Conversions in Expressions**
```nim
# Currently: Limited conversion support
# Needed: .float32, .int32 conversions
let x = myInt.float32
let y = myFloat.int16
```

**Implementation:**
- Parser: Handle `.typeName` as conversion operator
- Runtime: Apply appropriate conversion
- Could reuse cast machinery

**Effort:** Low (1-2 hours)

---

**6. Modulo Operator**
```nim
# Currently: Missing % operator
# Needed: a % b
let idx = (readCursor + writeLength) mod waveLength
```

**Implementation:**
- Tokenizer: Add `tkMod` or `tkPercent`
- Parser: Handle in binary operations
- Runtime: Implement modulo operation

**Effort:** Low (1 hour)

---

**7. Object/Tuple Field Access**
```nim
# Currently: Only map access with []
# Needed: obj.field syntax
mousePosition.x
mousePosition.y
```

**Implementation:**
- Parser: Handle `.field` after identifier
- AST: Add ekFieldAccess expression kind
- Runtime: Translate to map access or add tuple support

**Effort:** Medium (3-4 hours)

---

**8. `UncheckedArray[T]` Type**
```nim
# Needed for low-level buffer access
let d = cast[ptr UncheckedArray[int16]](buffer)
for i in 0..<frames:
  d[i] = int16(...)
```

**Implementation:**
- TypeNode: Add support in tkGeneric
- Runtime: Treat as pointer with array-like access
- Could be simplified to just use sequences

**Effort:** Medium (3-4 hours)

---

#### Priority 3: Nice to Have

**9. Complex Expressions**
```nim
# Currently: Parser may struggle with nested operations
# Needed: Proper precedence for complex expressions
data[i*MaxSamples div screenWidth].float32/32000
```

**Implementation:**
- Review operator precedence
- Test and fix parsing of complex expressions
- May already work, needs testing

**Effort:** Low (1-2 hours for testing/fixes)

---

**10. Compound Assignment Operators**
```nim
# Currently: Only = supported
# Needed: +=, -=, *=, /=
frequency += 10
index -= 1
```

**Implementation:**
- Tokenizer: Add compound tokens
- Parser: Convert to `x = x + y`
- AST: Could add skCompoundAssign or desugar

**Effort:** Low (1-2 hours)

---

**11. Multiple Statements Per Line**
```nim
# Currently: One statement per line
# Needed: Semicolon separator
audioFrequency += 1; audioFrequency -= 1
```

**Implementation:**
- Parser: Use semicolon as statement separator
- Already common in C-style languages

**Effort:** Low (1 hour)

---

## Simplified Alternative: Script API Layer

Instead of implementing all these features in Nimini, create a **simplified API layer** that wraps the platform functions:

```nim
# platform/nimini_api.nim
## Simplified audio API for Nimini scripts

var globalAudioData: seq[int] = @[]
var globalFrequency: float = 440.0
var globalSineIdx: float = 0.0

proc niminiAudioCallback(buffer: pointer, frames: int) {.cdecl.} =
  let freq = globalFrequency
  let incr = freq / 44100.0
  var idx = globalSineIdx
  
  # Use int instead of int16
  for i in 0..<frames:
    let sample = int(32000.0 * sin(2.0 * PI * idx))
    globalAudioData[i] = sample
    idx += incr
    if idx > 1.0:
      idx -= 1.0
  
  globalSineIdx = idx

# Register with Nimini
proc setFrequency*(env: ref Env; args: seq[Value]): Value =
  globalFrequency = toFloat(args[0])
  return valNil()

proc initAudioScript*() =
  registerNative("setFrequency", setFrequency)
  # ... register other functions
```

This allows simpler Nimini scripts:
```nim
# Works with current Nimini!
const MaxSamples = 512
var frequency = 440.0

proc updateFrequency():
  setFrequency(frequency)

initAudio()
var stream = createAudioStream(44100, 16, 1)
playAudioStream(stream)
```

## Recommended Approach

### Phase 1: Script API (Fastest Path)
**Effort:** 4-6 hours
- Create wrapper functions that hide low-level details
- Use untyped sequences and basic int/float
- Provide simple callbacks that manage buffers internally

### Phase 2: Core Nimini Extensions (Better Language Support)
**Effort:** 15-20 hours
- Sized numeric types (float32, int16, etc.)
- Typed sequences (newSeq[T])
- Type conversion methods (.float32, .int16)
- Modulo operator (%)
- String interpolation (&"...")

### Phase 3: Advanced Features (Full Compatibility)
**Effort:** 10-15 hours
- Object field access (obj.field)
- UncheckedArray support
- Compound assignments (+=, -=)
- Complex expression improvements

## Total Implementation Time

- **Minimum viable (Script API):** 4-6 hours
- **Good language support:** 19-26 hours
- **Full feature parity:** 29-41 hours

## Testing Strategy

1. Create `tests/test_nimini_numeric.nim` - Test sized types
2. Create `tests/test_nimini_sequences.nim` - Test typed sequences
3. Create `examples/audio_simple_nimini.nim` - Test with simplified API
4. Create `examples/audio_full_nimini.nim` - Test with full features

## Conclusion

**To make the naylib audio example work in Nimini, you need:**

1. **Quick path (4-6 hours):** Build a script API layer that hides complexity
2. **Complete path (30-40 hours):** Implement all missing language features

**Recommendation:** Start with the script API layer to get working audio examples quickly, then incrementally add language features as needed.
