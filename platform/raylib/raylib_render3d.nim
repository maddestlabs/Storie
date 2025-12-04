## Raylib 3D Renderer Implementation
## Provides raylib-based 3D rendering using direct C bindings

import ../render3d_interface
import raylib_bindings
import raylib_bindings/types as rl

export render3d_interface

# Alias raylib types to avoid conflicts
type
  RlCamera3D = rl.Camera3D
  RlVector3 = rl.Vector3
  RlColor = rl.Color

# ================================================================
# RAYLIB 3D RENDERER
# ================================================================

type
  RaylibRenderer3D* = ref object of Renderer3D
    camera*: RlCamera3D
    modelPosition*: RlVector3  # Simplified transform (position only for now)
    modelScale*: RlVector3
    inMode3D*: bool
    defaultMaterial*: Material

# ================================================================
# CONVERSION HELPERS
# ================================================================

proc toRlVec3(v: Vec3): RlVector3 =
  RlVector3(x: v.x, y: v.y, z: v.z)

proc toRlColor(v: Vec3): RlColor =
  RlColor(
    r: uint8(clamp(v.x, 0.0, 1.0) * 255.0),
    g: uint8(clamp(v.y, 0.0, 1.0) * 255.0),
    b: uint8(clamp(v.z, 0.0, 1.0) * 255.0),
    a: 255
  )

proc toRlCamera(cam: render3d_interface.Camera3D): RlCamera3D =
  result.position = toRlVec3(cam.position)
  result.target = toRlVec3(cam.target)
  result.up = toRlVec3(cam.up)
  result.fovy = cam.fov
  result.projection = CAMERA_PERSPECTIVE

# ================================================================
# RENDERER3D IMPLEMENTATION
# ================================================================

proc newRaylibRenderer3D*(): RaylibRenderer3D =
  result = RaylibRenderer3D()
  result.modelPosition = RlVector3(x: 0, y: 0, z: 0)
  result.modelScale = RlVector3(x: 1, y: 1, z: 1)
  result.inMode3D = false

method init3D*(r: RaylibRenderer3D): bool =
  r.defaultMaterial = LoadMaterialDefault()
  echo "Raylib 3D renderer initialized"
  return true

method shutdown3D*(r: RaylibRenderer3D) =
  UnloadMaterial(r.defaultMaterial)

method beginFrame3D*(r: RaylibRenderer3D, clearR, clearG, clearB: float32) =
  let bgColor = RlColor(
    r: uint8(clearR * 255.0),
    g: uint8(clearG * 255.0),
    b: uint8(clearB * 255.0),
    a: 255
  )
  ClearBackground(bgColor)
  BeginMode3D(r.camera)
  r.inMode3D = true

method endFrame3D*(r: RaylibRenderer3D) =
  if r.inMode3D:
    EndMode3D()
    r.inMode3D = false

method setCamera*(r: RaylibRenderer3D, cam: render3d_interface.Camera3D, aspect: float32) =
  r.camera = toRlCamera(cam)

method setModelTransform*(r: RaylibRenderer3D, mat: Mat4) =
  # Extract position and scale from matrix (simplified for now)
  # Full matrix support would require using raylib's matrix functions
  r.modelPosition = RlVector3(x: mat[12], y: mat[13], z: mat[14])
  # Scale extraction (approximate from diagonal)
  r.modelScale = RlVector3(x: mat[0], y: mat[5], z: mat[10])

method drawMesh*(r: RaylibRenderer3D, meshData: MeshData) =
  # Create a raylib mesh from our MeshData
  var mesh: Mesh
  mesh.vertexCount = (meshData.vertices.len div 6).cint
  mesh.triangleCount = (meshData.indices.len div 3).cint
  
  # Allocate and copy vertex data
  # Raylib expects separate arrays for positions, normals, colors, etc.
  # Our data is interleaved: x,y,z,r,g,b per vertex
  
  # For now, use raylib's built-in shapes (will be called from nimini wrappers)
  # TODO: Full mesh support with proper data conversion
  discard

method setViewport*(r: RaylibRenderer3D, x, y, width, height: int) =
  # Raylib doesn't require manual viewport setting
  # It handles this automatically based on window size
  discard

# ================================================================
# CONVENIENCE FUNCTIONS (use raylib's built-in shapes)
# ================================================================

proc drawCubeRaylib*(r: RaylibRenderer3D, size: float32, color: Vec3) =
  ## Draw a cube using raylib's built-in function
  let rlColor = toRlColor(color)
  DrawCube(r.modelPosition, size, size, size, rlColor)

proc drawSphereRaylib*(r: RaylibRenderer3D, radius: float32, segments: int, color: Vec3) =
  ## Draw a sphere using raylib's built-in function
  let rlColor = toRlColor(color)
  DrawSphereEx(r.modelPosition, radius, segments.cint, segments.cint, rlColor)
