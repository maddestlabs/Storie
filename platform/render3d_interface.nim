## 3D Rendering Interface - Backend-agnostic 3D rendering API
## This provides common types and math operations used by all 3D backends

import math

# ================================================================
# COMMON 3D TYPES (shared across all backends)
# ================================================================

type
  Vec3* = object
    x*, y*, z*: float32
  
  Vec4* = object
    x*, y*, z*, w*: float32
  
  Mat4* = array[16, float32]  # Column-major 4x4 matrix
  
  Camera3D* = ref object
    position*: Vec3
    target*: Vec3
    up*: Vec3
    fov*: float32       # Field of view in degrees
    near*: float32      # Near clipping plane
    far*: float32       # Far clipping plane

# ================================================================
# VECTOR OPERATIONS
# ================================================================

proc vec3*(x, y, z: float32): Vec3 =
  Vec3(x: x, y: y, z: z)

proc vec4*(x, y, z, w: float32): Vec4 =
  Vec4(x: x, y: y, z: z, w: w)

proc `+`*(a, b: Vec3): Vec3 =
  vec3(a.x + b.x, a.y + b.y, a.z + b.z)

proc `-`*(a, b: Vec3): Vec3 =
  vec3(a.x - b.x, a.y - b.y, a.z - b.z)

proc `*`*(a: Vec3, s: float32): Vec3 =
  vec3(a.x * s, a.y * s, a.z * s)

proc `/`*(a: Vec3, s: float32): Vec3 =
  vec3(a.x / s, a.y / s, a.z / s)

proc dot*(a, b: Vec3): float32 =
  a.x * b.x + a.y * b.y + a.z * b.z

proc cross*(a, b: Vec3): Vec3 =
  vec3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  )

proc length*(v: Vec3): float32 =
  sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

proc normalize*(v: Vec3): Vec3 =
  let len = v.length()
  if len > 0.0001:
    vec3(v.x / len, v.y / len, v.z / len)
  else:
    vec3(0, 0, 0)

# ================================================================
# MATRIX OPERATIONS
# ================================================================

proc identity*(): Mat4 =
  result[0] = 1.0; result[5] = 1.0; result[10] = 1.0; result[15] = 1.0

proc perspective*(fov, aspect, near, far: float32): Mat4 =
  let tanHalfFov = tan(fov * PI / 360.0)
  result = identity()
  result[0] = 1.0 / (aspect * tanHalfFov)
  result[5] = 1.0 / tanHalfFov
  result[10] = -(far + near) / (far - near)
  result[11] = -1.0
  result[14] = -(2.0 * far * near) / (far - near)
  result[15] = 0.0

proc lookAt*(eye, target, up: Vec3): Mat4 =
  let f = normalize(target - eye)
  let s = normalize(cross(f, up))
  let u = cross(s, f)
  
  result = identity()
  result[0] = s.x
  result[4] = s.y
  result[8] = s.z
  result[1] = u.x
  result[5] = u.y
  result[9] = u.z
  result[2] = -f.x
  result[6] = -f.y
  result[10] = -f.z
  result[12] = -dot(s, eye)
  result[13] = -dot(u, eye)
  result[14] = dot(f, eye)

proc translate*(x, y, z: float32): Mat4 =
  result = identity()
  result[12] = x
  result[13] = y
  result[14] = z

proc scale*(x, y, z: float32): Mat4 =
  result = identity()
  result[0] = x
  result[5] = y
  result[10] = z

proc rotateX*(angle: float32): Mat4 =
  let c = cos(angle)
  let s = sin(angle)
  result = identity()
  result[5] = c
  result[6] = s
  result[9] = -s
  result[10] = c

proc rotateY*(angle: float32): Mat4 =
  let c = cos(angle)
  let s = sin(angle)
  result = identity()
  result[0] = c
  result[2] = -s
  result[8] = s
  result[10] = c

proc rotateZ*(angle: float32): Mat4 =
  let c = cos(angle)
  let s = sin(angle)
  result = identity()
  result[0] = c
  result[1] = s
  result[4] = -s
  result[5] = c

proc `*`*(a, b: Mat4): Mat4 =
  for i in 0..3:
    for j in 0..3:
      result[i * 4 + j] = 0.0
      for k in 0..3:
        result[i * 4 + j] += a[k * 4 + j] * b[i * 4 + k]

# ================================================================
# CAMERA
# ================================================================

proc newCamera3D*(position, target: Vec3, fov: float32 = 60.0): Camera3D =
  Camera3D(
    position: position,
    target: target,
    up: vec3(0, 1, 0),
    fov: fov,
    near: 0.1,
    far: 1000.0
  )

proc getViewMatrix*(cam: Camera3D): Mat4 =
  lookAt(cam.position, cam.target, cam.up)

proc getProjectionMatrix*(cam: Camera3D, aspect: float32): Mat4 =
  perspective(cam.fov, aspect, cam.near, cam.far)

# ================================================================
# BACKEND INTERFACE (to be implemented by each backend)
# ================================================================

type
  Renderer3D* = ref object of RootObj
    ## Abstract base for 3D renderers
  
  MeshData* = object
    ## Platform-agnostic mesh data
    vertices*: seq[float32]  # Interleaved: x,y,z, r,g,b
    indices*: seq[uint16]

# Backend interface methods (must be implemented by SDL/raylib/etc)
method init3D*(r: Renderer3D): bool {.base.} =
  quit "Renderer3D.init3D() must be overridden"

method shutdown3D*(r: Renderer3D) {.base.} =
  quit "Renderer3D.shutdown3D() must be overridden"

method beginFrame3D*(r: Renderer3D, clearR, clearG, clearB: float32) {.base.} =
  quit "Renderer3D.beginFrame3D() must be overridden"

method endFrame3D*(r: Renderer3D) {.base.} =
  quit "Renderer3D.endFrame3D() must be overridden"

method setCamera*(r: Renderer3D, cam: Camera3D, aspect: float32) {.base.} =
  quit "Renderer3D.setCamera() must be overridden"

method setModelTransform*(r: Renderer3D, mat: Mat4) {.base.} =
  quit "Renderer3D.setModelTransform() must be overridden"

method drawMesh*(r: Renderer3D, mesh: MeshData) {.base.} =
  quit "Renderer3D.drawMesh() must be overridden"

method setViewport*(r: Renderer3D, x, y, width, height: int) {.base.} =
  quit "Renderer3D.setViewport() must be overridden"

# ================================================================
# PRIMITIVE MESH BUILDERS (backend-agnostic)
# ================================================================

proc createCubeMeshData*(size: float32 = 1.0, color: Vec3 = vec3(1, 1, 1)): MeshData =
  ## Create cube mesh data (backend-agnostic)
  let s = size / 2.0'f32
  result.vertices = @[
    # Front face
    -s, -s, s,  color.x, color.y, color.z,
    s, -s, s,   color.x, color.y, color.z,
    s, s, s,    color.x, color.y, color.z,
    -s, s, s,   color.x, color.y, color.z,
    # Back face
    -s, -s, -s, color.x, color.y, color.z,
    s, -s, -s,  color.x, color.y, color.z,
    s, s, -s,   color.x, color.y, color.z,
    -s, s, -s,  color.x, color.y, color.z,
  ]
  
  result.indices = @[
    0'u16, 1, 2, 2, 3, 0,  # Front
    1, 5, 6, 6, 2, 1,      # Right
    5, 4, 7, 7, 6, 5,      # Back
    4, 0, 3, 3, 7, 4,      # Left
    3, 2, 6, 6, 7, 3,      # Top
    4, 5, 1, 1, 0, 4       # Bottom
  ]

proc createSphereMeshData*(radius: float32 = 1.0, segments: int = 16, color: Vec3 = vec3(1, 1, 1)): MeshData =
  ## Create sphere mesh data (backend-agnostic)
  result.vertices = @[]
  result.indices = @[]
  
  # Generate vertices
  for lat in 0..segments:
    let theta = (lat.float32 / segments.float32) * PI
    let sinTheta = sin(theta)
    let cosTheta = cos(theta)
    
    for lon in 0..segments:
      let phi = (lon.float32 / segments.float32) * 2.0 * PI
      let sinPhi = sin(phi)
      let cosPhi = cos(phi)
      
      let x = cosPhi * sinTheta
      let y = cosTheta
      let z = sinPhi * sinTheta
      
      result.vertices.add(x * radius)
      result.vertices.add(y * radius)
      result.vertices.add(z * radius)
      result.vertices.add(color.x)
      result.vertices.add(color.y)
      result.vertices.add(color.z)
  
  # Generate indices
  for lat in 0..<segments:
    for lon in 0..<segments:
      let first = (lat * (segments + 1) + lon).uint16
      let second = first + (segments + 1).uint16
      
      result.indices.add(first)
      result.indices.add(second)
      result.indices.add(first + 1)
      
      result.indices.add(second)
      result.indices.add(second + 1)
      result.indices.add(first + 1)
