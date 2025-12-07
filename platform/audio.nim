## Unified Audio Module
## Exports the appropriate audio implementation based on the selected backend

import audio_interface
export audio_interface

when defined(sdl3) or defined(useSdl) or defined(useSdlGpu):
  # SDL3 backend
  import sdl/sdl_audio
  export sdl_audio
  
  proc createAudioSystem*(): AudioSystem =
    ## Create audio system for current backend (SDL3)
    createSdlAudioSystem()

else:
  # Default to Raylib (matches storie.nim backend selection)
  import raylib/raylib_audio
  export raylib_audio
  
  proc createAudioSystem*(): AudioSystem =
    ## Create audio system for current backend (Raylib)
    createRaylibAudioSystem()
