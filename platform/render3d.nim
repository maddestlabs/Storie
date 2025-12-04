## DEPRECATED: This file is kept for backwards compatibility only
## 
## The 3D rendering system has been refactored:
##   - Use render3d_interface.nim for backend-agnostic types
##   - Use sdl/sdl_render3d.nim for SDL3+OpenGL implementation
##   - Use raylib/raylib_render3d.nim for Raylib implementation
##
## This file now re-exports the SDL3 implementation for compatibility.

{.deprecated: "Use render3d_interface or sdl/sdl_render3d instead".}

import render3d_interface
import sdl/sdl_render3d

export render3d_interface
export sdl_render3d

# Old code below preserved for reference but deprecated
when false:
  import math
  import sdl/sdl3_bindings/opengl

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
  
  Shader3D* = ref object
    program*: GLuint
    vertexShader*: GLuint
    fragmentShader*: GLuint
  
  Mesh3D* = ref object
    vao*: GLuint
    vbo*: GLuint
    ebo*: GLuint
    vertexCount*: int
    indexCount*: int

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
# SHADERS
# ================================================================

const defaultVertexShader = """
#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 aPosition;
attribute vec3 aColor;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

varying vec3 vColor;

void main() {
    vColor = aColor;
    gl_Position = uProjection * uView * uModel * vec4(aPosition, 1.0);
}
"""

const defaultFragmentShader = """
#ifdef GL_ES
precision mediump float;
#endif

varying vec3 vColor;

void main() {
    gl_FragColor = vec4(vColor, 1.0);
}
"""

proc compileShader(source: string, shaderType: GLenum): GLuint =
  result = glCreateShader(shaderType)
  var csource: cstring = source
  var length: GLint = source.len.GLint
  glShaderSource(result, 1, addr csource, addr length)
  glCompileShader(result)
  
  var success: GLint
  glGetShaderiv(result, GL_COMPILE_STATUS, addr success)
  if success == 0:
    var logLength: GLsizei
    var log: array[512, GLchar]
    glGetShaderInfoLog(result, 512, addr logLength, addr log[0])
    echo "Shader compilation failed: ", cast[cstring](addr log[0])

proc createShader*(vertexSrc, fragmentSrc: string): Shader3D =
  result = Shader3D()
  
  result.vertexShader = compileShader(vertexSrc, GL_VERTEX_SHADER)
  result.fragmentShader = compileShader(fragmentSrc, GL_FRAGMENT_SHADER)
  
  result.program = glCreateProgram()
  glAttachShader(result.program, result.vertexShader)
  glAttachShader(result.program, result.fragmentShader)
  glLinkProgram(result.program)
  
  var success: GLint
  glGetProgramiv(result.program, GL_LINK_STATUS, addr success)
  if success == 0:
    var logLength: GLsizei
    var log: array[512, GLchar]
    glGetProgramInfoLog(result.program, 512, addr logLength, addr log[0])
    echo "Shader linking failed: ", cast[cstring](addr log[0])

proc createDefaultShader*(): Shader3D =
  createShader(defaultVertexShader, defaultFragmentShader)

proc use*(shader: Shader3D) =
  glUseProgram(shader.program)

proc setUniformMat4*(shader: Shader3D, name: string, mat: Mat4) =
  let loc = glGetUniformLocation(shader.program, name.cstring)
  var matCopy = mat
  glUniformMatrix4fv(loc, 1.GLsizei, GL_FALSE.GLboolean, addr matCopy[0])

proc setUniformVec3*(shader: Shader3D, name: string, v: Vec3) =
  let loc = glGetUniformLocation(shader.program, name.cstring)
  glUniform3f(loc, v.x, v.y, v.z)

proc cleanup*(shader: Shader3D) =
  glDeleteShader(shader.vertexShader)
  glDeleteShader(shader.fragmentShader)
  glDeleteProgram(shader.program)

# ================================================================
# MESH CREATION
# ================================================================

proc createMesh*(vertices: openArray[float32], indices: openArray[uint16]): Mesh3D =
  result = Mesh3D()
  result.vertexCount = vertices.len div 6  # 3 pos + 3 color
  result.indexCount = indices.len
  
  glGenVertexArrays(1.GLsizei, addr result.vao)
  glGenBuffers(1.GLsizei, addr result.vbo)
  glGenBuffers(1.GLsizei, addr result.ebo)
  
  glBindVertexArray(result.vao)
  
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glBufferData(GL_ARRAY_BUFFER, (vertices.len * sizeof(float32)).GLsizei, unsafeAddr vertices[0], GL_STATIC_DRAW)
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, result.ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, (indices.len * sizeof(uint16)).GLsizei, unsafeAddr indices[0], GL_STATIC_DRAW)
  
  # Position attribute
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE.GLboolean, (6 * sizeof(float32)).GLsizei, nil)
  
  # Color attribute
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 3, cGL_FLOAT, GL_FALSE.GLboolean, (6 * sizeof(float32)).GLsizei, cast[pointer](3 * sizeof(float32)))
  
  glBindVertexArray(0)

proc drawMesh*(mesh: Mesh3D) =
  glBindVertexArray(mesh.vao)
  glDrawElements(GL_TRIANGLES, mesh.indexCount.GLsizei, cGL_UNSIGNED_SHORT, nil)
  glBindVertexArray(0)

proc cleanup*(mesh: Mesh3D) =
  glDeleteVertexArrays(1.GLsizei, addr mesh.vao)
  glDeleteBuffers(1.GLsizei, addr mesh.vbo)
  glDeleteBuffers(1.GLsizei, addr mesh.ebo)

# ================================================================
# PRIMITIVE BUILDERS
# ================================================================

proc createCubeMesh*(size: float32 = 1.0, color: Vec3 = vec3(1, 1, 1)): Mesh3D =
  let s = size / 2.0'f32
  let vertices: array[48, float32] = [
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
  
  let indices: array[36, uint16] = [
    0'u16, 1, 2, 2, 3, 0,  # Front
    1, 5, 6, 6, 2, 1,      # Right
    5, 4, 7, 7, 6, 5,      # Back
    4, 0, 3, 3, 7, 4,      # Left
    3, 2, 6, 6, 7, 3,      # Top
    4, 5, 1, 1, 0, 4       # Bottom
  ]
  
  createMesh(vertices, indices)

proc createSphereMesh*(radius: float32 = 1.0, segments: int = 16, color: Vec3 = vec3(1, 1, 1)): Mesh3D =
  var vertices: seq[float32] = @[]
  var indices: seq[uint16] = @[]
  
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
      
      vertices.add(x * radius)
      vertices.add(y * radius)
      vertices.add(z * radius)
      vertices.add(color.x)
      vertices.add(color.y)
      vertices.add(color.z)
  
  # Generate indices
  for lat in 0..<segments:
    for lon in 0..<segments:
      let first = (lat * (segments + 1) + lon).uint16
      let second = first + (segments + 1).uint16
      
      indices.add(first)
      indices.add(second)
      indices.add(first + 1)
      
      indices.add(second)
      indices.add(second + 1)
      indices.add(first + 1)
  
  createMesh(vertices, indices)
