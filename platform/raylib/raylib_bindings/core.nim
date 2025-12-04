## Raylib Core - Window management and basic functionality
import build_config
import types
export types

# ================================================================
# WINDOW MANAGEMENT
# ================================================================

proc InitWindow*(width, height: cint, title: cstring) {.importc: "InitWindow", header: "raylib.h".}
proc CloseWindow*() {.importc: "CloseWindow", header: "raylib.h".}
proc WindowShouldClose*(): bool {.importc: "WindowShouldClose", header: "raylib.h".}
proc IsWindowReady*(): bool {.importc: "IsWindowReady", header: "raylib.h".}
proc IsWindowFullscreen*(): bool {.importc: "IsWindowFullscreen", header: "raylib.h".}
proc IsWindowHidden*(): bool {.importc: "IsWindowHidden", header: "raylib.h".}
proc IsWindowMinimized*(): bool {.importc: "IsWindowMinimized", header: "raylib.h".}
proc IsWindowMaximized*(): bool {.importc: "IsWindowMaximized", header: "raylib.h".}
proc IsWindowFocused*(): bool {.importc: "IsWindowFocused", header: "raylib.h".}
proc IsWindowResized*(): bool {.importc: "IsWindowResized", header: "raylib.h".}
proc IsWindowState*(flag: cuint): bool {.importc: "IsWindowState", header: "raylib.h".}
proc SetWindowState*(flags: cuint) {.importc: "SetWindowState", header: "raylib.h".}
proc ClearWindowState*(flags: cuint) {.importc: "ClearWindowState", header: "raylib.h".}
proc ToggleFullscreen*() {.importc: "ToggleFullscreen", header: "raylib.h".}
proc MaximizeWindow*() {.importc: "MaximizeWindow", header: "raylib.h".}
proc MinimizeWindow*() {.importc: "MinimizeWindow", header: "raylib.h".}
proc RestoreWindow*() {.importc: "RestoreWindow", header: "raylib.h".}
proc SetWindowTitle*(title: cstring) {.importc: "SetWindowTitle", header: "raylib.h".}
proc SetWindowPosition*(x, y: cint) {.importc: "SetWindowPosition", header: "raylib.h".}
proc SetWindowSize*(width, height: cint) {.importc: "SetWindowSize", header: "raylib.h".}
proc GetScreenWidth*(): cint {.importc: "GetScreenWidth", header: "raylib.h".}
proc GetScreenHeight*(): cint {.importc: "GetScreenHeight", header: "raylib.h".}
proc GetRenderWidth*(): cint {.importc: "GetRenderWidth", header: "raylib.h".}
proc GetRenderHeight*(): cint {.importc: "GetRenderHeight", header: "raylib.h".}

# ================================================================
# TIMING
# ================================================================

proc SetTargetFPS*(fps: cint) {.importc: "SetTargetFPS", header: "raylib.h".}
proc GetFPS*(): cint {.importc: "GetFPS", header: "raylib.h".}
proc GetFrameTime*(): float32 {.importc: "GetFrameTime", header: "raylib.h".}
proc GetTime*(): cdouble {.importc: "GetTime", header: "raylib.h".}

# ================================================================
# DRAWING
# ================================================================

proc BeginDrawing*() {.importc: "BeginDrawing", header: "raylib.h".}
proc EndDrawing*() {.importc: "EndDrawing", header: "raylib.h".}
proc ClearBackground*(color: Color) {.importc: "ClearBackground", header: "raylib.h".}

# ================================================================
# 3D MODE
# ================================================================

proc BeginMode3D*(camera: Camera3D) {.importc: "BeginMode3D", header: "raylib.h".}
proc EndMode3D*() {.importc: "EndMode3D", header: "raylib.h".}

# ================================================================
# MISC
# ================================================================

proc TakeScreenshot*(fileName: cstring) {.importc: "TakeScreenshot", header: "raylib.h".}
proc SetConfigFlags*(flags: cuint) {.importc: "SetConfigFlags", header: "raylib.h".}
proc TraceLog*(logLevel: cint, text: cstring) {.importc: "TraceLog", header: "raylib.h", varargs.}
