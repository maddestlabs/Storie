## Google Fonts Integration for WASM
## 
## Provides runtime font loading from Google Fonts CDN
## No compilation needed - fonts are fetched on-demand in the browser

when defined(emscripten):
  # Emscripten provides EM_ASM to run JavaScript inline
  proc emscripten_run_script*(script: cstring) {.importc, header: "<emscripten.h>".}
  proc emscripten_run_script_int*(script: cstring): cint {.importc, header: "<emscripten.h>".}
  
  # We'll use JavaScript's fetch() API via EM_ASM
  # Stores fetched font data in a global buffer accessible from C/Nim
  var fetchedFontBuffer*: seq[uint8] = @[]
  
  proc fetchFontDataJS(url: cstring): bool =
    ## Fetch font data using browser's fetch API (synchronous via Asyncify)
    ## Returns true if successful, data stored in fetchedFontBuffer
    when defined(emscripten):
      # JavaScript code to fetch font data
      let jsCode = """
        (async function() {
          try {
            const response = await fetch('""" & $url & """');
            if (!response.ok) return 0;
            
            const arrayBuffer = await response.arrayBuffer();
            const bytes = new Uint8Array(arrayBuffer);
            
            // Store in Emscripten heap
            const ptr = Module._malloc(bytes.length);
            Module.HEAPU8.set(bytes, ptr);
            
            // Store pointer and size for Nim to access
            Module.fontDataPtr = ptr;
            Module.fontDataSize = bytes.length;
            
            return 1;
          } catch(e) {
            console.error('Font fetch failed:', e);
            return 0;
          }
        })();
      """
      
      let success = emscripten_run_script_int(cstring(jsCode))
      return success == 1
    else:
      return false

# Google Fonts catalog - popular fonts with their URLs
const GoogleFonts* = {
  "Roboto": "https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxK.woff2",
  "RobotoMono": "https://fonts.gstatic.com/s/robotomono/v23/L0xuDF4xlVMF-BfR8bXMIhJHg45mwgGEFl0_3vq_ROW4.woff2",
  "OpenSans": "https://fonts.gstatic.com/s/opensans/v35/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjZ0B4gaVI.woff2",
  "Lato": "https://fonts.gstatic.com/s/lato/v24/S6uyw4BMUTPHjx4wXiWtFCc.woff2",
  "Montserrat": "https://fonts.gstatic.com/s/montserrat/v25/JTUSjIg1_i6t8kCHKm459WlhyyTh89Y.woff2",
  "SourceCodePro": "https://fonts.gstatic.com/s/sourcecodepro/v23/HI_diYsKILxRpg3hIP6sJ7fM7PqPMcMnZFqUwX28DMyQhM5hTXUcdJg.woff2",
  "Inter": "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hiA.woff2",
  "PlayfairDisplay": "https://fonts.gstatic.com/s/playfairdisplay/v36/nuFvD-vYSZviVYUb_rj3ij__anPXJzDwcbmjWBN2PKdFvUDQZNLo_U2r.woff2",
  "Poppins": "https://fonts.gstatic.com/s/poppins/v20/pxiEyp8kv8JHgFVrJJfecnFHGPc.woff2",
  "Ubuntu": "https://fonts.gstatic.com/s/ubuntu/v20/4iCs6KVjbNBYlgoKcg72j00.woff2",
}.toTable

type
  FontCache* = ref object
    ## Cache for loaded fonts to avoid re-downloading
    fonts*: Table[string, pointer]  # Font name -> Font handle

var globalFontCache* = FontCache(fonts: initTable[string, pointer]())

proc isGoogleFontAvailable*(fontName: string): bool =
  ## Check if a Google Font is available in the catalog
  return GoogleFonts.hasKey(fontName)

proc getGoogleFontURL*(fontName: string): string =
  ## Get the CDN URL for a Google Font
  if GoogleFonts.hasKey(fontName):
    return GoogleFonts[fontName]
  else:
    raise newException(KeyError, "Unknown Google Font: " & fontName)

proc listAvailableGoogleFonts*(): seq[string] =
  ## Get list of all available Google Fonts
  result = @[]
  for fontName in GoogleFonts.keys:
    result.add(fontName)

# Platform-specific font loading

when defined(raylib):
  import platform/raylib/raylib_bindings/text
  import platform/raylib/raylib_bindings/types
  
  proc loadGoogleFont*(fontName: string, fontSize: int = 20): Font =
    ## Load a Google Font at runtime (Raylib)
    ## Returns default font if download fails
    
    # Check cache first
    if globalFontCache.fonts.hasKey(fontName):
      return cast[Font](globalFontCache.fonts[fontName])
    
    when defined(emscripten):
      # Runtime download in browser using JavaScript fetch
      let url = getGoogleFontURL(fontName)
      echo "Loading Google Font: ", fontName
      
      # Use browser's fetch API to download font data
      # This requires Emscripten's ASYNCIFY for synchronous-looking async code
      if fetchFontDataJS(cstring(url)):
        # Font data is now in JavaScript Module.fontDataPtr
        # Use LoadFontFromMemory to load it
        # Note: This is a simplified version - real implementation needs proper memory management
        echo "Font fetched successfully: ", fontName
        # TODO: Call LoadFontFromMemory with the fetched data
        result = GetFontDefault()  # Fallback for now
      else:
        echo "Failed to fetch font: ", fontName
        result = GetFontDefault()
    else:
      # Native builds - cannot fetch from URL, use default
      echo "Google Fonts only available in WASM builds"
      result = GetFontDefault()
    
    globalFontCache.fonts[fontName] = cast[pointer](result)

when defined(sdl3):
  import platform/sdl/sdl3_bindings/ttf
  import platform/sdl/sdl3_bindings/types
  
  proc loadGoogleFont*(fontName: string, fontSize: int = 20): ptr TTF_Font =
    ## Load a Google Font at runtime (SDL3)
    ## Returns nil if download fails
    
    # Check cache first
    if globalFontCache.fonts.hasKey(fontName):
      return cast[ptr TTF_Font](globalFontCache.fonts[fontName])
    
    when defined(emscripten):
      # Runtime download in browser using JavaScript fetch
      let url = getGoogleFontURL(fontName)
      echo "Loading Google Font: ", fontName
      
      # Use browser's fetch API to download font data
      if fetchFontDataJS(cstring(url)):
        echo "Font fetched successfully: ", fontName
        # TODO: Use TTF_OpenFontRW or TTF_OpenFontFromMemory with fetched data
        result = nil  # Fallback for now
      else:
        echo "Failed to fetch font: ", fontName
        result = nil
    else:
      # Native builds - cannot fetch from URL
      echo "Google Fonts only available in WASM builds"
      result = nil
    
    if result != nil:
      globalFontCache.fonts[fontName] = cast[pointer](result)

# Alternative: Use browser's CSS @font-face (simpler but limited)
when defined(emscripten):
  proc loadFontViaCSS*(fontName: string) {.exportc.} =
    ## Inject @font-face CSS to load Google Font
    ## This makes the font available to canvas text rendering
    let url = getGoogleFontURL(fontName)
    let cssCode = """
      var style = document.createElement('style');
      style.textContent = '@font-face { font-family: """ & fontName & """; src: url(""" & url & """); }';
      document.head.appendChild(style);
      
      // Wait for font to load
      document.fonts.load('20px """ & fontName & """').then(function() {
        console.log('Font loaded: """ & fontName & """');
      });
    """
    emscripten_run_script(cstring(cssCode))

## Implementation Status
## 
## The current implementation is a **framework/skeleton** that shows the approach.
## Full implementation requires:
## 
## 1. **Emscripten ASYNCIFY flag** in build scripts:
##    Add to EMCC_CFLAGS: -s ASYNCIFY
##    This allows JavaScript async/await to work with Nim code
## 
## 2. **Proper memory bridging** between JavaScript and C/Nim:
##    - Allocate buffer in Emscripten heap
##    - Copy font data from JavaScript ArrayBuffer
##    - Pass pointer to LoadFontFromMemory / TTF_OpenFontRW
## 
## 3. **Font format handling**:
##    - Google Fonts serve .woff2 (web-optimized)
##    - Raylib/SDL3 need .ttf format
##    - May need conversion or use .ttf URLs instead
## 
## Alternative Simple Approach:
## Use CSS @font-face + canvas text rendering (loadFontViaCSS)
## This works immediately but only for canvas-based text, not TTF rendering

# Helper for common use case
proc useGoogleFont*(fontName: string): string =
  ## Returns CSS import string for HTML embedding
  ## Usage: Add this to your HTML <head>
  result = "<link href=\"https://fonts.googleapis.com/css2?family=" & 
           fontName.replace(" ", "+") & 
           "&display=swap\" rel=\"stylesheet\">"

# Example usage documentation
when isMainModule:
  echo "=== Storie Google Fonts Integration ==="
  echo ""
  echo "Available Google Fonts:"
  for font in listAvailableGoogleFonts():
    echo "  - ", font
  echo ""
  echo "Usage in Nimini:"
  echo "  let font = loadGoogleFont(\"Roboto\")"
  echo "  drawText(\"Hello World\", 100, 100, font)"
  echo ""
  echo "Or in HTML:"
  echo "  ", useGoogleFont("Roboto")
  echo "  (Then use CSS font-family: 'Roboto' in canvas text)"
