# Simple parser test - no dependencies needed
import strutils

type
  CodeBlock = object
    code: string
    lifecycle: string
    language: string

proc parseMarkdown(content: string): seq[CodeBlock] =
  result = @[]
  var lines = content.splitLines()
  var i = 0
  
  while i < lines.len:
    let line = lines[i].strip()
    
    if line.startsWith("```") or line.startsWith("``` "):
      var headerParts = line[3..^1].strip().split()
      if headerParts.len > 0 and headerParts[0] == "nim":
        var lifecycle = ""
        var language = "nim"
        
        for part in headerParts:
          if part.startsWith("on:"):
            lifecycle = part[3..^1]
            break
        
        var codeLines: seq[string] = @[]
        inc i
        while i < lines.len:
          if lines[i].strip().startsWith("```"):
            break
          codeLines.add(lines[i])
          inc i
        
        let codeBlock = CodeBlock(
          code: codeLines.join("\n"),
          lifecycle: lifecycle,
          language: language
        )
        result.add(codeBlock)
    
    inc i

# Test with sample markdown
let testMd = """
# Test Document

Some intro text here.

``` nim on:render
# This is a render block
bgLayer.buffer.clearTransparent()
fgLayer.buffer.clearTransparent()

let fpsText = "FPS: " & $int(state.fps)
fgLayer.buffer.writeText(state.termWidth - fpsText.len - 2, 1, fpsText, textStyle)
```

More text between blocks.

``` nim on:update
# This is an update block
state.frameCount += 1
if state.totalTime > 10.0:
  state.running = false
```

Another paragraph.

``` nim on:init
# Initialization code
var myVariable = 42
echo "Starting up!"
```

``` nim on:input
# Input handling
if event.kind == KeyEvent and event.keyAction == Press:
  if event.keyCode == ord('q'):
    state.running = false
    return true
return false
```

End of document.
"""

echo "=" .repeat(60)
echo "Testing Markdown Parser"
echo "=" .repeat(60)
echo ""

let blocks = parseMarkdown(testMd)
echo "Found ", blocks.len, " code blocks"
echo ""

for i, block in blocks:
  echo "─" .repeat(60)
  echo "Block #", i + 1
  echo "  Lifecycle: ", if block.lifecycle.len > 0: block.lifecycle else: "(none)"
  echo "  Language:  ", block.language
  echo "  Code:"
  echo "  ┌" & "─" .repeat(56) & "┐"
  for line in block.code.splitLines():
    echo "  │ ", line
  echo "  └" & "─" .repeat(56) & "┘"
  echo ""

echo "=" .repeat(60)
echo "Parser test complete!"
echo "=" .repeat(60)
