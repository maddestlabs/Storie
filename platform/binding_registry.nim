## Binding Registry Initialization
## 
## This module registers all platform bindings when compiled with
## -d:bindingMetadataGeneration flag. Used for:
## - Generating binding documentation
## - Import analysis
## - Build size estimation

when defined(bindingMetadataGeneration):
  import binding_metadata
  
  # Import all binding modules to trigger registration
  # Raylib bindings
  import raylib/raylib_bindings/core
  import raylib/raylib_bindings/input
  import raylib/raylib_bindings/shapes
  import raylib/raylib_bindings/text
  import raylib/raylib_bindings/models
  
  # SDL3 bindings
  import sdl/sdl3_bindings/core
  import sdl/sdl3_bindings/render
  import sdl/sdl3_bindings/events
  import sdl/sdl3_bindings/audio
  import sdl/sdl3_bindings/ttf
  
  # Export the registry
  export binding_metadata
  export getRegistry, printRegistry
  
  proc generateBindingReport*() =
    ## Generate a comprehensive report of all bindings
    let registry = getRegistry()
    printRegistry(registry)
    
    echo ""
    echo "=== Build Size Comparison ==="
    echo ""
    
    # Raylib minimal vs full
    let raylibMinimal = registry.getMinimalModules("raylib")
    let raylibFull = registry.getFullModules("raylib")
    
    echo "Raylib:"
    echo "  Minimal: ", raylibMinimal.len, " modules, ", formatSize(estimateTotalSize(raylibMinimal))
    echo "  Full:    ", raylibFull.len, " modules, ", formatSize(estimateTotalSize(raylibFull))
    echo ""
    
    # SDL3 minimal vs full
    let sdl3Minimal = registry.getMinimalModules("sdl3")
    let sdl3Full = registry.getFullModules("sdl3")
    
    echo "SDL3:"
    echo "  Minimal: ", sdl3Minimal.len, " modules, ", formatSize(estimateTotalSize(sdl3Minimal))
    echo "  Full:    ", sdl3Full.len, " modules, ", formatSize(estimateTotalSize(sdl3Full))
    echo ""
    
    echo "=== Minimal Build Modules ==="
    echo ""
    echo "Raylib Minimal:"
    for meta in raylibMinimal:
      echo "  ✓ ", meta.module, " (", formatSize(meta.estimatedSize), ")"
    echo ""
    
    echo "SDL3 Minimal:"
    for meta in sdl3Minimal:
      echo "  ✓ ", meta.module, " (", formatSize(meta.estimatedSize), ")"
    echo ""
    
    echo "=== Full Build Additional Modules ==="
    echo ""
    echo "Raylib Full (additional):"
    for meta in raylibFull:
      if not meta.minimalBuild:
        echo "  + ", meta.module, " (", formatSize(meta.estimatedSize), ")"
    echo ""
    
    echo "SDL3 Full (additional):"
    for meta in sdl3Full:
      if not meta.minimalBuild:
        echo "  + ", meta.module, " (", formatSize(meta.estimatedSize), ")"
    echo ""
  
  proc generateFunctionIndex*() =
    ## Generate an alphabetical index of all functions
    let registry = getRegistry()
    
    echo "=== Function Index ==="
    echo ""
    
    var allFunctions: seq[tuple[name: string, module: string, library: string]] = @[]
    
    for library in ["raylib", "sdl3"]:
      if registry.modulesByLibrary.hasKey(library):
        for meta in registry.modulesByLibrary[library]:
          for fn in meta.functions:
            allFunctions.add((fn, meta.module, meta.library))
    
    # Sort by function name
    allFunctions.sort(proc(a, b: auto): int = cmp(a.name, b.name))
    
    for item in allFunctions:
      echo item.name, " → ", item.library, "/", item.module
  
  when isMainModule:
    # Run report generation when executed directly
    echo "Storie Binding Metadata Report"
    echo "=" .repeat(50)
    echo ""
    
    generateBindingReport()
    
    echo ""
    echo "=" .repeat(50)
    echo ""
    
    # generateFunctionIndex()  # Uncomment for full function listing

else:
  # When not generating metadata, this module does nothing
  discard
