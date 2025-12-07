# Google Fonts Integration in WASM

## Current Status: Framework Ready, Full Implementation Pending

The `platform/google_fonts.nim` module provides a **framework** for loading Google Fonts at runtime in WASM builds. However, full implementation requires additional work.

## Why Runtime Font Loading Is Complex

### The Challenge

1. **Font Format Mismatch**
   - Google Fonts CDN serves `.woff2` (web-optimized, compressed)
   - Raylib needs `.ttf` (TrueType) or raw font data
   - SDL3_ttf needs `.ttf` format

2. **Async/Sync Mismatch**
   - Browser `fetch()` is asynchronous (promises)
   - Raylib/SDL3 APIs are synchronous
   - Need Emscripten's ASYNCIFY to bridge

3. **Memory Management**
   - JavaScript ArrayBuffer → Emscripten heap → C/Nim pointer
   - Need proper allocation and cleanup

## Three Approaches (Pick One)

### Approach 1: CSS @font-face (Simplest, Working Now)

**How it works:**
```nim
# Load font into browser's font system
loadFontViaCSS("Roboto")

# Then use canvas text rendering
# (Your existing canvas-based text drawing)
```

**Pros:**
- ✅ Works immediately, no extra code
- ✅ Browser handles caching
- ✅ No ASYNCIFY needed
- ✅ No memory management

**Cons:**
- ❌ Only works for canvas text rendering
- ❌ Can't use with raylib's DrawText (needs TTF)
- ❌ Can't use with SDL3_ttf

**Best for:** Simple text rendering via HTML5 canvas

---

### Approach 2: Fetch + LoadFontFromMemory (Full Featured)

**Requirements:**
1. Add `-s ASYNCIFY` to Emscripten flags
2. Use Google Fonts `.ttf` URLs (not `.woff2`)
3. Implement proper memory bridging

**Implementation:**
```nim
# Fetch .ttf from URL
let fontData = fetchFontBlocking("https://.../Roboto.ttf")

# Load into raylib
let font = LoadFontFromMemory(".ttf", fontData.data, fontData.size, 20, nil, 0)

# Or SDL3
let rwops = SDL_RWFromMem(fontData.data, fontData.size)
let font = TTF_OpenFontRW(rwops, 1, 20)
```

**Build changes needed:**
```bash
# In build-web-full.sh and build-web-sdl-full.sh
export EMCC_CFLAGS="$EMCC_CFLAGS -s ASYNCIFY"
```

**Pros:**
- ✅ Full raylib/SDL3 TTF support
- ✅ Works with all text rendering APIs
- ✅ Proper font metrics

**Cons:**
- ❌ Adds ~50KB to WASM (ASYNCIFY overhead)
- ❌ Requires JavaScript ↔ C memory bridge
- ❌ Complex implementation

**Best for:** Full builds with proper TTF rendering

---

### Approach 3: Preload Popular Fonts (Hybrid)

**How it works:**
```bash
# Download a few popular fonts once
./setup-google-fonts.sh --preload Roboto Inter

# They're bundled in .data file
# Load normally at runtime
let font = LoadFont("/fonts/Roboto-Regular.ttf")
```

**Pros:**
- ✅ Works with all APIs
- ✅ No async complexity
- ✅ Reliable and simple

**Cons:**
- ❌ Increases .data file size (~100KB per font)
- ❌ Not truly "runtime" loading
- ❌ Fixed font set

**Best for:** Known set of fonts, offline capability

---

## ✅ Recommended Path: Two Build Variants

The **optimal approach** is two builds - minimal and full:

### Setup and Build:
```bash
# 1. Download fonts once (3 core fonts, ~300KB)
./build-font-packages.sh

# 2. Build two versions
./build-web.sh              # Minimal: ~500KB (no fonts, default font only)
./build-web-full.sh         # Full: ~1MB (all features + 3 Google Fonts)
```

### When to Use Each:

| Build | Size | Fonts | Use Case |
|-------|------|-------|----------|
| **Minimal** | ~500KB | Default only | Demos, GitHub Gists, quick prototypes |
| **Full** | ~1MB | 3 Google Fonts | Professional apps, production |

**Full build includes:**
- Roboto (sans-serif)
- Roboto Mono (monospace)
- Inter (modern UI font)

### Benefits:
- ✅ Simple - just two builds
- ✅ No runtime complexity (no ASYNCIFY needed)
- ✅ Fonts work immediately (preloaded)
- ✅ Reliable and production-ready
- ✅ Browser caches everything

## ✅ What Works Right Now

```bash
# Download fonts
./build-font-packages.sh

# Build with fonts
./build-web-full.sh
```

```nim
# Use Google Fonts in your code
let font = LoadFont("/assets/fonts/Roboto-Regular.ttf")
DrawTextEx(font, "Hello World!", Vector2(100, 100), 20, 1, WHITE)

# Safe fallback
var font = LoadFont("/assets/fonts/Roboto-Regular.ttf")
if font.texture.id == 0:  # Font not found
    font = GetFontDefault()
```

That's it! No async complexity, no runtime fetching - just preloaded fonts that work immediately.

## File Size Impact

| Approach | Size Added |
|----------|------------|
| CSS @font-face | 0 KB (fonts load separately) |
| ASYNCIFY (runtime) | ~50 KB |
| Preload 1 font | ~100 KB (.ttf) or ~15 KB (.woff2) |
| Preload 5 fonts | ~500 KB |

## Questions?

The framework is in place. Choose the approach that fits your needs:
- **Quick demo?** Use CSS approach (works now)
- **Offline support?** Preload fonts
- **Full featured?** Implement ASYNCIFY approach (2-3 hours work)
