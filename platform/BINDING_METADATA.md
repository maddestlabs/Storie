# Binding Metadata System

This system provides automatic tracking and analysis of platform bindings for optimized builds.

## Overview

The binding metadata system enables:

1. **Automatic Import Analysis** - Detect which platform features are used
2. **Build Size Estimation** - Predict binary sizes before compilation
3. **Minimal vs. Full Builds** - Configure what's included in each build variant
4. **Native Export** - Generate optimized Nim code with minimal imports from Nimini

## Build Variants

### Raylib Builds

| Build | Script | Size | Features |
|-------|--------|------|----------|
| Minimal | `./build-web.sh` | ~500KB | Core 2D, shapes, text (default font) |
| Full | `./build-web-full.sh` | ~1.5MB | All features: 3D, models, audio, textures |

### SDL3 Builds

| Build | Script | Size | Features |
|-------|--------|------|----------|
| Minimal | `./build-web-sdl.sh` | ~800KB | Core rendering, basic shapes |
| Full | `./build-web-sdl-full.sh` | ~3-4MB | TTF, HarfBuzz, FreeType, image, audio |

## Architecture

### Binding Metadata Structure

Each binding module includes metadata:

```nim
const textBindingMetadata* = BindingMetadata(
  library: "raylib",           # Platform library
  module: "text",              # Module name
  features: @["fonts", "text_rendering"],  # Feature tags
  functions: @["DrawText", "LoadFont", ...],  # Exported functions
  minimalBuild: true,          # Include in minimal?
  estimatedSize: 45_000,       # Size in bytes
  dependencies: @["core"],     # Required modules
  description: "Font rendering"
)
```

### Registry System

The `BindingRegistry` indexes all metadata:

- **By function name** - Look up which module provides a function
- **By feature** - Find all modules implementing a feature
- **By library** - Get all modules for raylib or SDL3

### Import Analyzer

The `import_analyzer` module:

1. Parses Nimini code to AST
2. Extracts all function calls
3. Maps calls to required modules
4. Generates optimized import statements
5. Estimates final binary size

## Usage

### Adding Metadata to a Binding Module

```nim
## my_module.nim

# === BINDING METADATA ===
when defined(bindingMetadataGeneration):
  import ../../binding_metadata
  
  const myModuleMetadata* = BindingMetadata(
    library: "raylib",
    module: "my_module",
    features: @["my_feature"],
    functions: @["MyFunc1", "MyFunc2"],
    minimalBuild: false,
    estimatedSize: 100_000,
    dependencies: @["core"],
    description: "My module description"
  )
  
  static:
    getRegistry().registerBinding(myModuleMetadata)

# Regular binding code follows...
```

### Analyzing Nimini Code

```nim
import nimini/import_analyzer

let niminiCode = """
fillRect(100, 100, 50, 50)
drawText(120, 120, "Hello!")
playSound("beep.wav")
"""

# Print analysis
printAnalysisReport(niminiCode, "raylib")

# Generate native code
let (nativeCode, estimatedSize) = exportToNative(niminiCode, "raylib")
echo "Generated code:"
echo nativeCode
echo "Estimated size: ", estimatedSize
```

### Using the Registry Directly

```nim
import platform/binding_metadata

let registry = getRegistry()

# Get all minimal modules for raylib
let minimalModules = registry.getMinimalModules("raylib")

# Get module for a specific function
let meta = registry.getModuleForFunction("DrawText")

# Print all registered bindings
printRegistry(registry)
```

## Build Configuration

### Minimal Builds (Fast Prototyping)

**Raylib Minimal:**
- Core rendering
- Basic shapes (rectangles, circles, lines)
- Text rendering (built-in default font)
- No external assets needed (except user assets)

**SDL3 Minimal:**
- Core rendering
- Basic shapes
- NO text rendering (requires TTF)
- Smaller but limited

### Full Builds (Production)

**Raylib Full:**
- All 2D features
- 3D rendering and models
- Audio support
- Texture loading (PNG, JPG, GIF, BMP)
- Model loading (OBJ, GLTF)

**SDL3 Full:**
- All SDL3 features
- SDL3_ttf (TrueType fonts)
- FreeType (font rasterization)
- HarfBuzz (complex script shaping)
- PlutoSVG (color emoji)
- SDL3_image (image formats)
- SDL3_mixer (audio)

## Web Integration

### GitHub Gist Demo Flow

1. User pastes Gist URL with Nimini code
2. Web app fetches code
3. Code runs in minimal WASM (fast load)
4. User clicks "Export to Native"
5. Import analyzer determines requirements
6. Generates .nim file with optimized imports
7. User downloads and compiles natively

### Example Web API

```javascript
// In your web UI
async function exportToNative(niminiCode, targetLib) {
  const response = await fetch('/api/export', {
    method: 'POST',
    body: JSON.stringify({
      code: niminiCode,
      library: targetLib  // 'raylib' or 'sdl3'
    })
  });
  
  const result = await response.json();
  // result.code: Generated Nim code
  // result.size: Estimated binary size
  // result.imports: Required modules
  
  return result;
}
```

## Future Enhancements

1. **Automatic Feature Detection** - Parse function signatures automatically
2. **Build Profile Editor** - Web UI to customize minimal/full builds
3. **Dependency Graph Visualization** - Show module dependencies
4. **Size Optimization Suggestions** - "Remove X to save Y bytes"
5. **WebAssembly Split Loading** - Load features on-demand

## File Organization

```
platform/
  binding_metadata.nim           # Core metadata types and registry
  raylib/
    raylib_bindings/
      text.nim                   # With metadata
      shapes.nim                 # With metadata
      models.nim                 # With metadata
      ...
  sdl/
    sdl3_bindings/
      ttf.nim                    # With metadata
      render.nim                 # With metadata
      ...

src/nimini/
  import_analyzer.nim            # Nimini → Native export

build-web.sh                     # Raylib minimal
build-web-full.sh                # Raylib full
build-web-sdl.sh                 # SDL3 minimal
build-web-sdl-full.sh            # SDL3 full
```

## Contributing

When adding new binding modules:

1. Add metadata block at top of file
2. Register with `getRegistry().registerBinding()`
3. Set `minimalBuild` appropriately
4. Estimate size contribution realistically
5. Document features and dependencies

## License

Same as parent project.
