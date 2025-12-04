## Raylib Models - 3D model loading and drawing
import build_config
import types
export types

# ================================================================
# 3D DRAWING - BASIC SHAPES
# ================================================================

proc DrawLine3D*(startPos, endPos: Vector3, color: Color) {.importc: "DrawLine3D", header: "raylib.h".}
proc DrawPoint3D*(position: Vector3, color: Color) {.importc: "DrawPoint3D", header: "raylib.h".}
proc DrawCircle3D*(center: Vector3, radius: float32, rotationAxis: Vector3, rotationAngle: float32, color: Color) {.importc: "DrawCircle3D", header: "raylib.h".}
proc DrawTriangle3D*(v1, v2, v3: Vector3, color: Color) {.importc: "DrawTriangle3D", header: "raylib.h".}
proc DrawCube*(position: Vector3, width, height, length: float32, color: Color) {.importc: "DrawCube", header: "raylib.h".}
proc DrawCubeV*(position, size: Vector3, color: Color) {.importc: "DrawCubeV", header: "raylib.h".}
proc DrawCubeWires*(position: Vector3, width, height, length: float32, color: Color) {.importc: "DrawCubeWires", header: "raylib.h".}
proc DrawCubeWiresV*(position, size: Vector3, color: Color) {.importc: "DrawCubeWiresV", header: "raylib.h".}
proc DrawSphere*(centerPos: Vector3, radius: float32, color: Color) {.importc: "DrawSphere", header: "raylib.h".}
proc DrawSphereEx*(centerPos: Vector3, radius: float32, rings, slices: cint, color: Color) {.importc: "DrawSphereEx", header: "raylib.h".}
proc DrawSphereWires*(centerPos: Vector3, radius: float32, rings, slices: cint, color: Color) {.importc: "DrawSphereWires", header: "raylib.h".}
proc DrawCylinder*(position: Vector3, radiusTop, radiusBottom, height: float32, slices: cint, color: Color) {.importc: "DrawCylinder", header: "raylib.h".}
proc DrawCylinderEx*(startPos, endPos: Vector3, startRadius, endRadius: float32, sides: cint, color: Color) {.importc: "DrawCylinderEx", header: "raylib.h".}
proc DrawCylinderWires*(position: Vector3, radiusTop, radiusBottom, height: float32, slices: cint, color: Color) {.importc: "DrawCylinderWires", header: "raylib.h".}
proc DrawCylinderWiresEx*(startPos, endPos: Vector3, startRadius, endRadius: float32, sides: cint, color: Color) {.importc: "DrawCylinderWiresEx", header: "raylib.h".}
proc DrawPlane*(centerPos: Vector3, size: Vector2, color: Color) {.importc: "DrawPlane", header: "raylib.h".}
proc DrawGrid*(slices: cint, spacing: float32) {.importc: "DrawGrid", header: "raylib.h".}

# ================================================================
# MESH MANAGEMENT
# ================================================================

proc GenMeshCube*(width, height, length: float32): Mesh {.importc: "GenMeshCube", header: "raylib.h".}
proc GenMeshSphere*(radius: float32, rings, slices: cint): Mesh {.importc: "GenMeshSphere", header: "raylib.h".}
proc GenMeshPlane*(width, length: float32, resX, resZ: cint): Mesh {.importc: "GenMeshPlane", header: "raylib.h".}
proc GenMeshCylinder*(radius, height: float32, slices: cint): Mesh {.importc: "GenMeshCylinder", header: "raylib.h".}

proc UploadMesh*(mesh: ptr Mesh, dynamic: bool) {.importc: "UploadMesh", header: "raylib.h".}
proc UpdateMeshBuffer*(mesh: Mesh, index: cint, data: pointer, dataSize, offset: cint) {.importc: "UpdateMeshBuffer", header: "raylib.h".}
proc UnloadMesh*(mesh: Mesh) {.importc: "UnloadMesh", header: "raylib.h".}
proc DrawMesh*(mesh: Mesh, material: Material, transform: Matrix) {.importc: "DrawMesh", header: "raylib.h".}
proc DrawMeshInstanced*(mesh: Mesh, material: Material, transforms: ptr Matrix, instances: cint) {.importc: "DrawMeshInstanced", header: "raylib.h".}

# ================================================================
# MODEL MANAGEMENT
# ================================================================

proc LoadModel*(fileName: cstring): Model {.importc: "LoadModel", header: "raylib.h".}
proc LoadModelFromMesh*(mesh: Mesh): Model {.importc: "LoadModelFromMesh", header: "raylib.h".}
proc UnloadModel*(model: Model) {.importc: "UnloadModel", header: "raylib.h".}
proc DrawModel*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModel", header: "raylib.h".}
proc DrawModelEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelEx", header: "raylib.h".}
proc DrawModelWires*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModelWires", header: "raylib.h".}
proc DrawModelWiresEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelWiresEx", header: "raylib.h".}

# ================================================================
# MATERIAL & SHADER
# ================================================================

proc LoadMaterialDefault*(): Material {.importc: "LoadMaterialDefault", header: "raylib.h".}
proc UnloadMaterial*(material: Material) {.importc: "UnloadMaterial", header: "raylib.h".}
proc SetMaterialTexture*(material: ptr Material, mapType: cint, texture: Texture2D) {.importc: "SetMaterialTexture", header: "raylib.h".}
