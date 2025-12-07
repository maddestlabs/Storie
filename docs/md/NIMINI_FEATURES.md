# Nimini Language Features

## Overview

Nimini is a lightweight Nim-inspired scripting language designed for interactive applications. This document covers the language features available in Nimini.

## Type System

### Type Annotations

Variables, constants, and function parameters can have explicit type annotations:

```nim
var count: int = 0
let name: string = "Alice"
const MaxSize: int = 1024

proc calculate(x: int, y: float): float:
  return x * y
```

### Supported Types

- **Simple types**: `int`, `float`, `string`, `bool`
- **Pointer types**: `ptr int`, `ptr string`, etc.
- **Generic types**: `seq[int]`, `array[float]`, etc.
- **Procedure types**: `proc(int, string): bool`

## Constants

Constants are immutable values declared with `const`:

```nim
const MaxSamples = 512
const SampleRate: int = 44100
const Pi = 3.14159
```

Constants must be initialized at declaration and cannot be reassigned.

## Type Definitions

Create type aliases with the `type` keyword:

```nim
type AudioBuffer = seq[float]
type Callback = proc(int): int
type Point = tuple[x: float, y: float]
```

## Defer Statements

`defer` schedules a statement to execute when the current scope exits:

```nim
proc processFile(filename: string):
  var file = open(filename)
  defer: close(file)  # Always executed before function returns
  
  # Process file...
  if error:
    return  # defer still executes
  
  # Normal return - defer executes here too
```

Defer statements execute in LIFO order (last deferred executes first).

## Pointer Operations

### Address-of Operator (`addr`)

Get the address of a variable:

```nim
var value = 100
var ptr = addr value
```

### Dereference Operator (`[]` on pointers)

Access the value a pointer points to:

```nim
var x = 42
var p = addr x
print(p[])  # Prints 42
```

### Cast Expression

Convert between types explicitly:

```nim
var myValue = 32000
var casted = cast[int](myValue)

var ptr = cast[ptr byte](someAddress)
```

## Sequence Operations

Nimini provides built-in sequence (dynamic array) operations:

### Create a Sequence

```nim
var data = newSeq(100)  # Creates sequence with 100 nil elements
```

### Resize a Sequence

```nim
setLen(data, 200)  # Resize to 200 elements
```

### Get Length

```nim
var size = len(data)
```

### Add Elements

```nim
var numbers = newSeq(0)
add(numbers, 10)
add(numbers, 20)
add(numbers, 30)
```

### Delete Elements

```nim
delete(numbers, 1)  # Delete element at index 1
```

### Insert Elements

```nim
insert(numbers, 99, 0)  # Insert 99 at index 0
```

## Pragmas

Pragmas are compiler directives specified in `{. .}` blocks:

```nim
proc callback(data: ptr byte, size: int): int {.cdecl.}:
  # Function with C calling convention
  return 0

proc fastFunc(x: int): int {.inline.}:
  return x * 2
```

Common pragmas:
- `{.cdecl.}` - C calling convention (for callbacks)
- `{.inline.}` - Inline function hint
- `{.importc.}` - Import from C
- `{.exportc.}` - Export to C

## Control Flow

### If/Else

```nim
if x > 0:
  print("positive")
elif x < 0:
  print("negative")
else:
  print("zero")
```

### While Loop

```nim
while count < 10:
  print(count)
  count = count + 1
```

### For Loop

```nim
# Range-based for loop
for i in 0..<10:
  print(i)

# Iterate over sequence
for item in mySequence:
  print(item)
```

## Functions

### Function Declaration

```nim
proc add(a: int, b: int): int:
  return a + b

# Without return type
proc greet(name: string):
  print("Hello, " & name)
```

### Return Values

```nim
proc calculate(): int:
  return 42
```

Return exits the function immediately. All deferred statements execute before the return.

## Operators

### Arithmetic
- `+` Addition
- `-` Subtraction
- `*` Multiplication
- `/` Division
- `%` Modulo

### Comparison
- `==` Equal
- `!=` Not equal
- `<` Less than
- `<=` Less than or equal
- `>` Greater than
- `>=` Greater than or equal

### Logical
- `and` Logical AND
- `or` Logical OR
- `not` Logical NOT

### Bitwise
- `and` Bitwise AND
- `or` Bitwise OR
- `xor` Bitwise XOR

## Built-in Functions

### I/O
- `print(args...)` - Print values to stdout

### Type Conversions
- `int(x)` - Convert to integer
- `float(x)` - Convert to float
- `string(x)` - Convert to string

## Example: Audio Processing

```nim
# Audio buffer example combining multiple features
const BufferSize = 512
const SampleRate: int = 44100

type AudioCallback = proc(buffer: ptr float, frames: int): int

var audioData = newSeq(BufferSize)

proc processAudio(buffer: ptr float, frameCount: int): int {.cdecl.}:
  defer: print("Audio processing complete")
  
  for i in 0..<frameCount:
    var sample: float = 0.0
    # Process sample...
    audioData[i] = cast[float](sample)
  
  return frameCount

proc main():
  print("Initializing audio system...")
  var callback: AudioCallback = processAudio
  
  # Setup audio...
  print("Audio system ready")

main()
```

## Limitations

Current limitations of Nimini:

1. **No classes/objects**: Use tuples and procedures instead
2. **Limited type system**: No generics implementation yet (syntax parsed but not executed)
3. **No modules**: Everything is in global scope
4. **Simple error handling**: No exception system
5. **Limited standard library**: Only core operations available

## Future Enhancements

Planned features:

- Object-oriented programming support
- Exception handling (try/except/finally)
- Module system with imports
- Generic type implementation
- More comprehensive standard library
- Pattern matching
- Coroutines/async support

## Using Nimini in Your Application

```nim
import nimini

# Initialize runtime
initRuntime()

# Register native functions
proc myNativeFunc(env: ref Env; args: seq[Value]): Value =
  # Your implementation
  return valNil()

registerNative("myFunc", myNativeFunc)

# Register sequence operations
registerSeqOps()

# Parse and execute code
let code = """
  const Size = 100
  var data = newSeq(Size)
  myFunc()
"""

let tokens = tokenizeDsl(code)
let program = parseDsl(tokens)
execProgram(program, runtimeEnv)
```

## Code Generation

Nimini can also generate code in other languages:

```nim
import nimini
import nimini/backends/nim_backend

# Parse Nimini code
let tokens = tokenizeDsl(myCode)
let program = parseDsl(tokens)

# Generate Nim code
let ctx = initCodegenContext(getNimBackend())
let generatedCode = genProgram(program, ctx)

echo generatedCode  # Output Nim code
```

This allows using Nimini as a DSL that transpiles to Nim, Python, JavaScript, or other target languages.
