## Platform Module - Unified platform abstraction
## Import this to get the correct platform backend

when defined(emscripten):
  # Web/WASM: No platform backend needed
  const usePlatformAbstraction* = false
else:
  # Native: Use terminal platform for now
  const usePlatformAbstraction* = false  # Set to true when ready to migrate

# Re-export platform types for easy access
import platform/platform_types
export platform_types

when usePlatformAbstraction:
  # New architecture (not yet enabled)
  import platform/platform_interface
  import platform/terminal/terminal_platform
  export platform_interface, terminal_platform
  
  type
    DefaultPlatform* = TerminalPlatform
  
  proc createPlatform*(): DefaultPlatform =
    return newTerminalPlatform()
else:
  # Legacy: Keep existing code path
  # (storie.nim continues to work as before)
  discard
