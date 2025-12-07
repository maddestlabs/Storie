## SDL3 + OpenGL 3D Renderer Implementation
## Provides OpenGL-based 3D rendering for SDL3 backend

import ../render3d_interface

# Only import OpenGL when not using SDL_GPU
when not defined(sdlgpu):
  import sdl3_bindings/opengl

export render3d_interface

# ================================================================
# SDL/OPENGL SPECIFIC TYPES
# ================================================================

type
  SdlRenderer3D* = ref object of Renderer3D
    shader*: Shader3D
    currentCamera*: Camera3D
    currentAspect*: float32
    modelMatrix*: Mat4
  
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
# MESH MANAGEMENT
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

proc drawMeshGL*(mesh: Mesh3D) =
  glBindVertexArray(mesh.vao)
  glDrawElements(GL_TRIANGLES, mesh.indexCount.GLsizei, cGL_UNSIGNED_SHORT, nil)
  glBindVertexArray(0)

proc cleanup*(mesh: Mesh3D) =
  glDeleteVertexArrays(1.GLsizei, addr mesh.vao)
  glDeleteBuffers(1.GLsizei, addr mesh.vbo)
  glDeleteBuffers(1.GLsizei, addr mesh.ebo)

# ================================================================
# RENDERER3D IMPLEMENTATION
# ================================================================

proc newSdlRenderer3D*(): SdlRenderer3D =
  result = SdlRenderer3D()
  result.modelMatrix = identity()

method init3D*(r: SdlRenderer3D): bool =
  # Initialize OpenGL state
  glEnable(GL_DEPTH_TEST)
  glDepthFunc(GL_LEQUAL)
  glEnable(GL_CULL_FACE)
  glCullFace(GL_BACK)
  glFrontFace(GL_CCW)
  
  # Create default shader
  r.shader = createDefaultShader()
  
  echo "SDL OpenGL 3D renderer initialized"
  return true

method shutdown3D*(r: SdlRenderer3D) =
  if not r.shader.isNil:
    r.shader.cleanup()

method beginFrame3D*(r: SdlRenderer3D, clearR, clearG, clearB: float32) =
  glClearColor(clearR, clearG, clearB, 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  
  # Note: Viewport should be set by the platform before calling this
  # but we keep the OpenGL state setup here
  glEnable(GL_DEPTH_TEST)
  glDepthFunc(GL_LEQUAL)
  glEnable(GL_CULL_FACE)
  glCullFace(GL_BACK)
  glFrontFace(GL_CCW)

method endFrame3D*(r: SdlRenderer3D) =
  # Nothing needed for OpenGL - platform handles swap
  discard

method setCamera*(r: SdlRenderer3D, cam: Camera3D, aspect: float32) =
  r.currentCamera = cam
  r.currentAspect = aspect
  
  r.shader.use()
  r.shader.setUniformMat4("uView", cam.getViewMatrix())
  r.shader.setUniformMat4("uProjection", cam.getProjectionMatrix(aspect))

method setModelTransform*(r: SdlRenderer3D, mat: Mat4) =
  r.modelMatrix = mat
  r.shader.use()
  r.shader.setUniformMat4("uModel", mat)

method drawMesh*(r: SdlRenderer3D, meshData: MeshData) =
  # Create temporary mesh from data and draw it
  let mesh = createMesh(meshData.vertices, meshData.indices)
  
  r.shader.use()
  r.shader.setUniformMat4("uModel", r.modelMatrix)
  
  mesh.drawMeshGL()
  mesh.cleanup()

method setViewport*(r: SdlRenderer3D, x, y, width, height: int) =
  glViewport(x.GLint, y.GLint, width.GLsizei, height.GLsizei)

# ================================================================
# CONVENIENCE FUNCTIONS (OpenGL-specific primitives)
# ================================================================

proc createCubeMesh*(size: float32 = 1.0, color: Vec3 = vec3(1, 1, 1)): Mesh3D =
  let data = createCubeMeshData(size, color)
  createMesh(data.vertices, data.indices)

proc createSphereMesh*(radius: float32 = 1.0, segments: int = 16, color: Vec3 = vec3(1, 1, 1)): Mesh3D =
  let data = createSphereMeshData(radius, segments, color)
  createMesh(data.vertices, data.indices)

# ================================================================
# DIRECT OPENGL ACCESS (for advanced users)
# ================================================================

proc glViewport*(x, y, width, height: int) =
  opengl.glViewport(x.GLint, y.GLint, width.GLsizei, height.GLsizei)
