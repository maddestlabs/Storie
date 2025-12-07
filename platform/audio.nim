## Unified Audio Module
## Exports the appropriate audio implementation based on the selected backend

import audio_interface
export audio_interface

when defined(useRaylib):
  import raylib/raylib_audio
  export raylib_audio
  
  proc createAudioSystem*(): AudioSystem =
    ## Create audio system for current backend (Raylib)
    createRaylibAudioSystem()

elif defined(useSdl) or defined(useSdlGpu):
  import sdl/sdl_audio
  export sdl_audio
  
  proc createAudioSystem*(): AudioSystem =
    ## Create audio system for current backend (SDL3)
    createSdlAudioSystem()

else:
  {.error: "No audio backend selected. Define useRaylib or useSdl".}
