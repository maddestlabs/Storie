## Storie SDL3 - Main engine using SDL3 platform backend with markdown support
## This is the SDL3 equivalent of storie.nim

import strutils, times, os, math
import platform/platform_interface
import platform/pixel_types
import platform/sdl/sdl_platform
import storie_core
import src/nimini

# Emscripten support
when defined(emscripten):
  {.passL: "-s EXPORTED_FUNCTIONS=['_main']".}
  {.emit: """
  #include <emscripten.h>
  """.}

# ================================================================
# MARKDOWN PARSER
# ================================================================

type
  CodeBlock = object
    code: string
    lifecycle: string  # "render", "update", "init", "input", "shutdown"
    language: string

proc parseMarkdown(content: string): seq[CodeBlock] =
  ## Parse Markdown content and extract Nim code blocks with lifecycle hooks
  result = @[]
  var lines = content.splitLines()
  var i = 0
  
  while i < lines.len:
    let line = lines[i].strip()
    
    # Look for code block start: ```nim or ``` nim
    if line.startsWith("```") or line.startsWith("``` "):
      var headerParts = line[3..^1].strip().split()
      if headerParts.len > 0 and headerParts[0] == "nim":
        var lifecycle = ""
        var language = "nim"
        
        # Check for on:* attribute (e.g., on:render, on:update)
        for part in headerParts:
          if part.startsWith("on:"):
            lifecycle = part[3..^1]
            break
        
        # Extract code block content
        var codeLines: seq[string] = @[]
        inc i
        while i < lines.len:
          if lines[i].strip().startsWith("```"):
            break
          codeLines.add(lines[i])
          inc i
        
        # Add the code block
        let blk = CodeBlock(
          code: codeLines.join("\n"),
          lifecycle: lifecycle,
          language: language
        )
        result.add(blk)
    
    inc i

# ================================================================
# NIMINI CONTEXT
# ================================================================

type
  NiminiContext = ref object
    env: ref Env

# Helper to convert Value to int (handles both int and float values)
proc valueToInt(v: Value): int =
  case v.kind
  of vkInt: return v.i
  of vkFloat: return int(v.f)
  else: return 0

# ================================================================
# GLOBAL STATE
# ================================================================

type
  AppState = ref object
    platform: SdlPlatform
    width, height: int
    bgLayer: Layer
    fgLayer: Layer
    running: bool
    
    # Timing
    targetFps: float
    totalTime: float
    frameCount: int
    fps: float
    lastFpsUpdate: float

var appState: AppState
var niminiCtx: NiminiContext

# Global layer references for nimini bindings
var gBgLayer: Layer
var gFgLayer: Layer
var gCurrentColor: Color = Color(r: 255, g: 255, b: 255, a: 255)

# ================================================================
# NIMINI WRAPPERS - Bridge storie functions to Nimini
# ================================================================

# Type conversion functions
proc nimini_int(env: ref Env; args: seq[Value]): Value =
  if args.len > 0:
    case args[0].kind
    of vkInt: return args[0]
    of vkFloat: return valInt(args[0].f.int)
    of vkString: 
      try: return valInt(parseInt(args[0].s))
      except: return valInt(0)
    of vkBool: return valInt(if args[0].b: 1 else: 0)
    else: return valInt(0)
  return valInt(0)

proc nimini_float(env: ref Env; args: seq[Value]): Value =
  if args.len > 0:
    case args[0].kind
    of vkFloat: return args[0]
    of vkInt: return valFloat(args[0].i.float)
    of vkString: 
      try: return valFloat(parseFloat(args[0].s))
      except: return valFloat(0.0)
    of vkBool: return valFloat(if args[0].b: 1.0 else: 0.0)
    else: return valFloat(0.0)
  return valFloat(0.0)

proc nimini_str(env: ref Env; args: seq[Value]): Value =
  if args.len > 0:
    return valString($args[0])
  return valString("")

# Print function
proc print(env: ref Env; args: seq[Value]): Value {.nimini.} =
  var output = ""
  for i, arg in args:
    if i > 0: output.add(" ")
    case arg.kind
    of vkInt: output.add($arg.i)
    of vkFloat: output.add($arg.f)
    of vkString: output.add(arg.s)
    of vkBool: output.add($arg.b)
    of vkNil: output.add("nil")
    else: output.add("<value>")
  echo output
  return valNil()

# Drawing functions - Pixel-based API
proc clear(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Clear background layer
  gBgLayer.renderBuffer.clearCommands()
  return valNil()

proc clearFg(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Clear foreground layer
  gFgLayer.renderBuffer.clearCommands()
  return valNil()

proc setColor(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Set current drawing color (r, g, b, [a])
  if args.len >= 3:
    let a = if args.len >= 4: valueToInt(args[3]).uint8 else: 255'u8
    gCurrentColor = Color(
      r: valueToInt(args[0]).uint8,
      g: valueToInt(args[1]).uint8,
      b: valueToInt(args[2]).uint8,
      a: a
    )
  return valNil()

proc fillRect(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw filled rectangle on background layer
  if args.len >= 4:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    let w = valueToInt(args[2])
    let h = valueToInt(args[3])
    gBgLayer.renderBuffer.fillRect(x, y, w, h, gCurrentColor)
  return valNil()

proc drawRect(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw rectangle outline on foreground layer
  if args.len >= 4:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    let w = valueToInt(args[2])
    let h = valueToInt(args[3])
    let lineWidth = if args.len >= 5: valueToInt(args[4]) else: 1
    gFgLayer.renderBuffer.drawRect(x, y, w, h, gCurrentColor, lineWidth)
  return valNil()

proc fillCircle(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw filled circle
  if args.len >= 3:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    let radius = valueToInt(args[2])
    gFgLayer.renderBuffer.fillCircle(x, y, radius, gCurrentColor)
  return valNil()

proc drawCircle(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw circle outline
  if args.len >= 3:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    let radius = valueToInt(args[2])
    let lineWidth = if args.len >= 4: valueToInt(args[3]) else: 1
    gFgLayer.renderBuffer.drawCircle(x, y, radius, gCurrentColor, lineWidth)
  return valNil()

proc drawLine(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw line from (x1, y1) to (x2, y2)
  if args.len >= 4:
    let x1 = valueToInt(args[0])
    let y1 = valueToInt(args[1])
    let x2 = valueToInt(args[2])
    let y2 = valueToInt(args[3])
    let lineWidth = if args.len >= 5: valueToInt(args[4]) else: 1
    gFgLayer.renderBuffer.drawLine(x1, y1, x2, y2, gCurrentColor, lineWidth)
  return valNil()

proc drawText(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw text at pixel coordinates
  if args.len >= 3:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    let text = args[2].s
    let size = if args.len >= 4: valueToInt(args[3]) else: 16
    gFgLayer.renderBuffer.drawText(x, y, text, gCurrentColor, size)
  return valNil()

proc drawPixel(env: ref Env; args: seq[Value]): Value {.nimini.} =
  ## Draw a single pixel
  if args.len >= 2:
    let x = valueToInt(args[0])
    let y = valueToInt(args[1])
    gFgLayer.renderBuffer.drawPixel(x, y, gCurrentColor)
  return valNil()

# Math functions
proc mathSin(env: ref Env; args: seq[Value]): Value {.nimini.} =
  if args.len > 0:
    let val = case args[0].kind
      of vkFloat: args[0].f
      of vkInt: args[0].i.float
      else: 0.0
    return valFloat(sin(val))
  return valFloat(0.0)

proc mathCos(env: ref Env; args: seq[Value]): Value {.nimini.} =
  if args.len > 0:
    let val = case args[0].kind
      of vkFloat: args[0].f
      of vkInt: args[0].i.float
      else: 0.0
    return valFloat(cos(val))
  return valFloat(0.0)

proc createNiminiContext(): NiminiContext =
  ## Create a Nimini interpreter context with exposed APIs
  initRuntime()
  
  # Register type conversion functions
  registerNative("int", nimini_int)
  registerNative("float", nimini_float)
  registerNative("str", nimini_str)
  
  # Auto-register all {.nimini.} pragma functions
  exportNiminiProcs(
    print,
    clear, clearFg, setColor,
    fillRect, drawRect, fillCircle, drawCircle, drawLine, drawText, drawPixel,
    mathSin, mathCos
  )
  
  # Register math aliases
  registerNative("sin", mathSin)
  registerNative("cos", mathCos)
  
  return NiminiContext(env: runtimeEnv)

proc executeCodeBlock(ctx: NiminiContext, blk: CodeBlock): bool =
  ## Execute a code block using Nimini
  if blk.code.strip().len == 0:
    return true
  
  try:
    # Build a wrapper that includes state access
    var scriptCode = ""
    
    # Add state field accessors as local variables
    scriptCode.add("var width = " & $appState.width & "\n")
    scriptCode.add("var height = " & $appState.height & "\n")
    scriptCode.add("var fps = " & formatFloat(appState.fps, ffDecimal, 2) & "\n")
    scriptCode.add("var frameCount = " & $appState.frameCount & "\n")
    scriptCode.add("\n")
    
    # Add user code
    scriptCode.add(blk.code)
    
    let tokens = tokenizeDsl(scriptCode)
    let program = parseDsl(tokens)
    execProgram(program, ctx.env)
    
    return true
  except Exception as e:
    echo "Error in ", blk.lifecycle, " block: ", e.msg
    return false

# ================================================================
# LIFECYCLE MANAGEMENT
# ================================================================

type
  StorieContext = ref object
    codeBlocks: seq[CodeBlock]
    
var storieCtx: StorieContext

proc loadAndParseMarkdown(): seq[CodeBlock] =
  ## Load index.md and parse it for code blocks
  when defined(emscripten):
    # In WASM, embed the markdown at compile time
    const mdContent = staticRead("index.md")
    return parseMarkdown(mdContent)
  else:
    # Native: read from file
    if fileExists("index.md"):
      let mdContent = readFile("index.md")
      return parseMarkdown(mdContent)
    else:
      echo "Warning: index.md not found"
      return @[]

proc initStorieContext() =
  ## Initialize the Storie context with markdown code blocks
  storieCtx = StorieContext(codeBlocks: loadAndParseMarkdown())
  
  echo "Loaded ", storieCtx.codeBlocks.len, " code blocks from index.md"
  
  # Show what we loaded
  for i, blk in storieCtx.codeBlocks:
    let lifecycle = if blk.lifecycle.len > 0: blk.lifecycle else: "none"
    echo "  Block ", i+1, ": lifecycle=", lifecycle, ", lines=", blk.code.countLines()

proc runLifecycleBlocks(lifecycle: string) =
  ## Execute all code blocks for a given lifecycle
  if storieCtx.isNil:
    return
  
  for blk in storieCtx.codeBlocks:
    if blk.lifecycle == lifecycle:
      discard executeCodeBlock(niminiCtx, blk)

# ================================================================
# NOTE: JavaScript text rendering hack removed
# Text is now rendered natively with SDL3_ttf on both platforms
# ================================================================

# ================================================================
# MAIN LOOP
# ================================================================

# Global timing state for main loop
var lastTime: float = 0.0
var accumulator: float = 0.0

proc mainLoopIteration() =
  ## Single iteration of the main loop (called by Emscripten or native loop)
  let currentTime = cpuTime()
  let deltaTime = if lastTime == 0.0: 0.0 else: currentTime - lastTime
  lastTime = currentTime
  
  if not appState.running:
    when defined(emscripten):
      # In Emscripten, we can't just quit - the loop will keep running
      # User needs to close the browser tab
      discard
    return
  
  let fixedDt = 1.0 / appState.targetFps
  
  # Handle events
  let events = appState.platform.pollEvents()
  for event in events:
    case event.kind
    of KeyEvent:
      if event.keyAction == Press:
        # ESC key is code 27
        if event.keyCode == 27:
          appState.running = false
        # Run input lifecycle blocks
        runLifecycleBlocks("input")
    of ResizeEvent:
      # Update dimensions on window resize
      appState.width = event.newWidth
      appState.height = event.newHeight
      echo "Window resized to ", appState.width, "x", appState.height, " pixels"
    else:
      discard
  
  # Fixed timestep update
  accumulator += deltaTime
  while accumulator >= fixedDt:
    # Update timing info
    appState.totalTime += fixedDt
    appState.frameCount += 1
    
    if appState.totalTime - appState.lastFpsUpdate >= 0.5:
      appState.fps = if deltaTime > 0.0: 1.0 / deltaTime else: 0.0
      appState.lastFpsUpdate = appState.totalTime
    
    # Run update lifecycle blocks
    runLifecycleBlocks("update")
    
    accumulator -= fixedDt
  
  # Clear layer commands
  appState.bgLayer.renderBuffer.clearCommands()
  appState.fgLayer.renderBuffer.clearCommands()
  
  # Run render lifecycle blocks
  runLifecycleBlocks("render")
  
  # Composite layers and display
  let compositeBuffer = newRenderBuffer(appState.width, appState.height)
  compositeBuffer.clear(black())
  
  # Merge all layer commands in z-order
  for cmd in appState.bgLayer.renderBuffer.commands:
    compositeBuffer.commands.add(cmd)
  for cmd in appState.fgLayer.renderBuffer.commands:
    compositeBuffer.commands.add(cmd)
  
  appState.platform.display(compositeBuffer)
  
  # Frame rate limiting (native only)
  when not defined(emscripten):
    appState.platform.sleepFrame(deltaTime)

when defined(emscripten):
  # Emscripten callback wrapper
  proc emMainLoop() {.cdecl, exportc.} =
    mainLoopIteration()

proc mainLoop() =
  ## Main loop - different implementation for native vs WASM
  when defined(emscripten):
    # Emscripten: 0 fps = use requestAnimationFrame (browser controls timing)
    {.emit: """
    emscripten_set_main_loop(emMainLoop, 0, 1);
    """.}
  else:
    # Native: traditional while loop
    while appState.running:
      mainLoopIteration()

proc initApp() =
  echo "Initializing Storie SDL3..."
  
  # Create SDL platform
  appState = AppState()
  appState.platform = SdlPlatform()
  appState.running = true
  appState.targetFps = 60.0
  appState.totalTime = 0.0
  appState.frameCount = 0
  appState.fps = 60.0
  appState.lastFpsUpdate = 0.0
  
  # Initialize platform
  if not appState.platform.init():
    echo "Failed to initialize SDL3 platform"
    quit(1)
  appState.platform.setTargetFps(appState.targetFps)
  
  let (w, h) = appState.platform.getSize()
  appState.width = w
  appState.height = h
  
  echo "Window size: ", w, "x", h, " pixels"
  
  # Create layers with pixel-based render buffers
  appState.bgLayer = Layer(id: "bg", z: 0, visible: true, renderBuffer: newRenderBuffer(appState.width, appState.height))
  appState.fgLayer = Layer(id: "fg", z: 1, visible: true, renderBuffer: newRenderBuffer(appState.width, appState.height))
  
  # Set global references for nimini bindings
  gBgLayer = appState.bgLayer
  gFgLayer = appState.fgLayer
  gCurrentColor = Color(r: 255, g: 255, b: 255, a: 255)
  
  # Create nimini context
  niminiCtx = createNiminiContext()
  
  # Initialize storie context (load markdown)
  initStorieContext()
  
  # Run init lifecycle blocks
  runLifecycleBlocks("init")
  
  echo "Storie SDL3 initialized successfully!"
  echo "Press ESC to quit"

proc shutdownApp() =
  echo "Shutting down Storie SDL3..."
  
  # Run shutdown lifecycle blocks
  runLifecycleBlocks("shutdown")
  
  # Shutdown platform
  if not appState.platform.isNil:
    appState.platform.shutdown()
  
  echo "Goodbye!"

# ================================================================
# ENTRY POINT
# ================================================================

when isMainModule:
  try:
    initApp()
    mainLoop()
  finally:
    shutdownApp()
