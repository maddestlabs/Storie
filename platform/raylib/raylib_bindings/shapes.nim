## Raylib Shapes - 2D shape drawing functions
import build_config
import types
export types

# ================================================================
# BASIC SHAPES
# ================================================================

# Pixel
proc DrawPixel*(posX, posY: cint, color: Color) {.importc: "DrawPixel", header: "raylib.h".}
proc DrawPixelV*(position: Vector2, color: Color) {.importc: "DrawPixelV", header: "raylib.h".}

# Line
proc DrawLine*(startPosX, startPosY, endPosX, endPosY: cint, color: Color) {.importc: "DrawLine", header: "raylib.h".}
proc DrawLineV*(startPos, endPos: Vector2, color: Color) {.importc: "DrawLineV", header: "raylib.h".}
proc DrawLineEx*(startPos, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineEx", header: "raylib.h".}

# Circle
proc DrawCircle*(centerX, centerY: cint, radius: float32, color: Color) {.importc: "DrawCircle", header: "raylib.h".}
proc DrawCircleV*(center: Vector2, radius: float32, color: Color) {.importc: "DrawCircleV", header: "raylib.h".}
proc DrawCircleLines*(centerX, centerY: cint, radius: float32, color: Color) {.importc: "DrawCircleLines", header: "raylib.h".}

# Rectangle
proc DrawRectangle*(posX, posY, width, height: cint, color: Color) {.importc: "DrawRectangle", header: "raylib.h".}
proc DrawRectangleV*(position, size: Vector2, color: Color) {.importc: "DrawRectangleV", header: "raylib.h".}
proc DrawRectangleRec*(rec: Rectangle, color: Color) {.importc: "DrawRectangleRec", header: "raylib.h".}
proc DrawRectanglePro*(rec: Rectangle, origin: Vector2, rotation: float32, color: Color) {.importc: "DrawRectanglePro", header: "raylib.h".}
proc DrawRectangleLines*(posX, posY, width, height: cint, color: Color) {.importc: "DrawRectangleLines", header: "raylib.h".}
proc DrawRectangleLinesEx*(rec: Rectangle, lineThick: float32, color: Color) {.importc: "DrawRectangleLinesEx", header: "raylib.h".}

# Triangle
proc DrawTriangle*(v1, v2, v3: Vector2, color: Color) {.importc: "DrawTriangle", header: "raylib.h".}
proc DrawTriangleLines*(v1, v2, v3: Vector2, color: Color) {.importc: "DrawTriangleLines", header: "raylib.h".}

# Polygon
proc DrawPoly*(center: Vector2, sides: cint, radius, rotation: float32, color: Color) {.importc: "DrawPoly", header: "raylib.h".}
proc DrawPolyLines*(center: Vector2, sides: cint, radius, rotation: float32, color: Color) {.importc: "DrawPolyLines", header: "raylib.h".}
