# Aspect Ratio Preservation and Resize Handling

## Overview

Implemented aspect ratio-preserving resize that ensures content is **never clipped**, regardless of window/browser size. The solution uses letterboxing (black bars top/bottom) or pillarboxing (black bars left/right) to maintain the original aspect ratio.

## Problem Solved

**Before:**
- Browser resize would stretch/squish the canvas
- Content could be clipped at edges
- Different aspect ratios would distort the grid

**After:**
- Canvas maintains original aspect ratio
- Black bars added as needed (letterboxing/pillarboxing)
- Content always fully visible
- Grid dimensions stay constant

## Implementation Details

### 1. Platform Layer (SDL)

#### Added Aspect Ratio Tracking

```nim
type
  SdlPlatform* = ref object
    # ...
    baseGridWidth: int   # Original grid width in cells
    baseGridHeight: int  # Original grid height in cells
    aspectRatio: float   # Target aspect ratio to maintain
```

#### Viewport Calculation

The `updateAspectRatioViewport()` function:
- Calculates current window aspect ratio
- Compares to target aspect ratio
- Adds letterboxing or pillarboxing as needed
- Sets SDL viewport (native) or lets CSS handle it (WASM)

**Letterboxing Example** (window too tall):
```
Window: 800x1000
Target: 4:3
Result: 800x600 viewport with 200px black bars (100px top, 100px bottom)
```

**Pillarboxing Example** (window too wide):
```
Window: 1000x600
Target: 4:3
Result: 800x600 viewport with 200px black bars (100px left, 100px right)
```

### 2. Fixed Grid Size

**Key Insight:** The cell grid size is now **constant** (e.g., 80x30 cells).

- Window resizes don't change grid dimensions
- Only the viewport scale changes
- Content layout remains identical at all window sizes
- No need to handle dynamic layout

```nim
# In storie.nim - resize event now just maintains the grid
of ResizeEvent:
  echo "Window resized, maintaining grid at ", appState.width, "x", appState.height
  # No buffer resizing needed!
```

### 3. WASM/Browser Handling

#### CSS Approach

The canvas uses CSS object-fit to maintain aspect ratio:

```css
#canvas {
  max-width: 100%;
  max-height: calc(100vh - 40px);
  width: auto;
  height: auto;
  object-fit: contain;  /* Maintains aspect ratio */
}
```

#### JavaScript Resize Handler

```javascript
function setupAspectRatioResize() {
  const aspectRatio = canvas.width / canvas.height;
  
  function resizeCanvas() {
    const windowAspect = maxWidth / maxHeight;
    
    if (windowAspect > aspectRatio) {
      // Pillarboxing
      newHeight = maxHeight;
      newWidth = newHeight * aspectRatio;
    } else {
      // Letterboxing
      newWidth = maxWidth;
      newHeight = newWidth / aspectRatio;
    }
    
    canvas.style.width = newWidth + 'px';
    canvas.style.height = newHeight + 'px';
  }
}
```

## Benefits

### ✅ No Clipping Ever
Content is always fully visible regardless of window size or aspect ratio.

### ✅ Consistent Layout
Grid dimensions stay the same, so your code doesn't need to handle dynamic layouts.

### ✅ Professional Appearance
Black bars are standard for aspect ratio preservation (like watching 16:9 video on 4:3 display).

### ✅ Works Everywhere
- Native: SDL viewport handles it
- WASM: CSS and JavaScript handle it
- Mobile: Orientation changes handled

### ✅ Performant
No additional rendering cost - viewport is set once per frame.

## Usage

### Setting Custom Aspect Ratio

If you want a specific aspect ratio (e.g., 16:9 widescreen):

```nim
# In platform init
p.baseGridWidth = 160   # 16:9 ratio
p.baseGridHeight = 90
p.aspectRatio = 16.0 / 9.0
```

### Getting Current Grid Size

```nim
let (w, h) = platform.getSize()
# Always returns baseGridWidth x baseGridHeight
# Actual window size may be larger (with black bars)
```

### Disabling Aspect Ratio Preservation

If you want to fill the entire window (with distortion):

**Native:** Comment out viewport call in `display()`
```nim
# p.updateAspectRatioViewport()
```

**WASM:** Change CSS:
```css
#canvas {
  width: 100vw;
  height: 100vh;
  object-fit: fill;  /* Stretches to fill */
}
```

## Testing Scenarios

### Desktop Browser
1. Start with normal window
2. Make window very wide → See pillarboxing (side bars)
3. Make window very tall → See letterboxing (top/bottom bars)
4. Resize continuously → Canvas scales smoothly, no clipping

### Mobile Browser
1. Portrait mode → Likely letterboxing
2. Rotate to landscape → Likely pillarboxing
3. Content always visible

### Native Window
1. Resize window freely
2. Maximize window
3. Different monitor sizes/aspect ratios
All maintain aspect ratio with black bars as needed.

## Advanced: Dynamic Aspect Ratio

If you want to change aspect ratio at runtime:

```nim
proc setAspectRatio*(p: SdlPlatform, width, height: int) =
  p.baseGridWidth = width
  p.baseGridHeight = height
  p.aspectRatio = width.float / height.float
  # Recreate buffers if needed
```

## Comparison: Other Approaches

### ❌ Stretching (No Aspect Ratio)
- **Pro:** Uses full window
- **Con:** Distorts content, circles become ovals

### ❌ Clipping (Crop)
- **Pro:** No distortion
- **Con:** Content cut off, unusable at wrong sizes

### ✅ Letterboxing/Pillarboxing (Our Approach)
- **Pro:** No distortion, no clipping
- **Con:** Some screen space unused (black bars)

## Files Modified

1. `platform/sdl/sdl_platform.nim`
   - Added aspect ratio tracking fields
   - Implemented `updateAspectRatioViewport()`
   - Modified `getSize()` to return fixed grid
   - Initialize aspect ratio in `init()`

2. `platform/sdl/sdl3_bindings.nim`
   - Added `SDL_Rect` type
   - Added `SDL_SetRenderViewport()` function

3. `storie.nim`
   - Simplified resize event handling
   - Grid size now constant

4. `docs/index.html`
   - Updated CSS for aspect ratio preservation
   - Added JavaScript resize handler
   - Setup letterboxing/pillarboxing

## Summary

✅ Content never clipped
✅ Aspect ratio always maintained
✅ Professional black bar presentation
✅ Works on native and WASM
✅ Handles all window sizes and orientations
✅ Fixed grid size simplifies game logic
