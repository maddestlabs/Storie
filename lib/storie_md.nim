## Storie Markdown Parser
## Platform-agnostic markdown parsing library
## 
## Design principles:
## - Zero file I/O dependencies (caller handles I/O)
## - Pure string processing only
## - Platform-agnostic (no os module)
## - Testable in isolation

import strutils, tables

type
  CodeBlock* = object
    code*: string
    lifecycle*: string  # "render", "update", "init", "input", "shutdown"
    language*: string
  
  FrontMatter* = Table[string, string]
  
  MarkdownDocument* = object
    frontMatter*: FrontMatter
    codeBlocks*: seq[CodeBlock]

proc parseFrontMatter*(content: string): FrontMatter =
  ## Parse YAML-style front matter between --- delimiters
  ## 
  ## Example:
  ##   ---
  ##   targetFPS: 30
  ##   title: My App
  ##   ---
  result = initTable[string, string]()
  
  let lines = content.splitLines()
  if lines.len < 3:
    return
  
  if not lines[0].strip().startsWith("---"):
    return
  
  var i = 1
  while i < lines.len:
    let line = lines[i].strip()
    
    if line.startsWith("---"):
      break
    
    if line.len == 0 or line.startsWith("#"):
      inc i
      continue
    
    let colonPos = line.find(':')
    if colonPos > 0:
      let key = line[0..<colonPos].strip()
      let value = line[colonPos+1..^1].strip()
      result[key] = value
    
    inc i

proc parseMarkdownDocument*(content: string): MarkdownDocument =
  ## Parse complete markdown document with front matter and code blocks
  ## 
  ## This is the main entry point for parsing markdown with configuration.
  ## Returns both front matter (configuration) and code blocks.
  result.frontMatter = parseFrontMatter(content)
  result.codeBlocks = @[]
  
  var lines = content.splitLines()
  var i = 0
  
  # Skip front matter section if present
  if lines.len > 0 and lines[0].strip().startsWith("---"):
    inc i
    while i < lines.len:
      if lines[i].strip().startsWith("---"):
        inc i
        break
      inc i
  
  # Parse code blocks
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
        let codeBlock = CodeBlock(
          code: codeLines.join("\n"),
          lifecycle: lifecycle,
          language: language
        )
        result.codeBlocks.add(codeBlock)
    
    inc i

proc parseMarkdown*(content: string): seq[CodeBlock] =
  ## Convenience function - returns just code blocks without front matter
  ## 
  ## Use this for backward compatibility or when you don't need configuration.
  let doc = parseMarkdownDocument(content)
  return doc.codeBlocks
