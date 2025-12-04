## Raylib Core Types - Common types used across all Raylib subsystems
import build_config

type
  # Vector types
  Vector2* {.importc, header: "raylib.h", bycopy.} = object
    x*, y*: float32
  
  Vector3* {.importc, header: "raylib.h", bycopy.} = object
    x*, y*, z*: float32
  
  Vector4* {.importc, header: "raylib.h", bycopy.} = object
    x*, y*, z*, w*: float32
  
  # Matrix type (OpenGL style 4x4 - column major, right-handed)
  Matrix* {.importc, header: "raylib.h", bycopy.} = object
    m0*, m4*, m8*, m12*: float32
    m1*, m5*, m9*, m13*: float32
    m2*, m6*, m10*, m14*: float32
    m3*, m7*, m11*, m15*: float32
  
  # Color type (RGBA)
  Color* {.importc, header: "raylib.h", bycopy.} = object
    r*, g*, b*, a*: uint8
  
  # Rectangle type
  Rectangle* {.importc, header: "raylib.h", bycopy.} = object
    x*, y*, width*, height*: float32
  
  # Image type (pixel data stored in CPU memory)
  Image* {.importc, header: "raylib.h", bycopy.} = object
    data*: pointer
    width*: cint
    height*: cint
    mipmaps*: cint
    format*: cint
  
  # Texture type (pixel data stored in GPU memory)
  Texture* {.importc, header: "raylib.h", bycopy.} = object
    id*: cuint
    width*: cint
    height*: cint
    mipmaps*: cint
    format*: cint
  
  Texture2D* = Texture
  
  # RenderTexture type (for texture rendering)
  RenderTexture* {.importc, header: "raylib.h", bycopy.} = object
    id*: cuint
    texture*: Texture
    depth*: Texture
  
  # Font type
  Font* {.importc, header: "raylib.h", bycopy.} = object
    baseSize*: cint
    glyphCount*: cint
    glyphPadding*: cint
    texture*: Texture2D
    recs*: ptr Rectangle
    glyphs*: pointer
  
  # Camera3D type
  Camera3D* {.importc, header: "raylib.h", bycopy.} = object
    position*: Vector3
    target*: Vector3
    up*: Vector3
    fovy*: float32
    projection*: cint
  
  Camera* = Camera3D
  
  # Camera2D type
  Camera2D* {.importc, header: "raylib.h", bycopy.} = object
    offset*: Vector2
    target*: Vector2
    rotation*: float32
    zoom*: float32
  
  # Mesh type
  Mesh* {.importc, header: "raylib.h", bycopy.} = object
    vertexCount*: cint
    triangleCount*: cint
    vertices*: ptr float32      # (x,y,z) per vertex
    texcoords*: ptr float32     # (u,v) per vertex
    texcoords2*: ptr float32    # (u,v) per vertex (for lightmaps)
    normals*: ptr float32       # (x,y,z) per vertex
    tangents*: ptr float32      # (x,y,z,w) per vertex
    colors*: ptr uint8          # (r,g,b,a) per vertex
    indices*: ptr uint16        # Triangle indices
    animVertices*: ptr float32  # Animated vertices
    animNormals*: ptr float32   # Animated normals
    boneIds*: ptr uint8         # Bone IDs
    boneWeights*: ptr float32   # Bone weights
    vaoId*: cuint               # OpenGL VAO id
    vboId*: ptr cuint           # OpenGL VBO ids
  
  # Shader type
  Shader* {.importc, header: "raylib.h", bycopy.} = object
    id*: cuint
    locs*: ptr cint
  
  # Material type
  Material* {.importc, header: "raylib.h", bycopy.} = object
    shader*: Shader
    maps*: pointer
    params*: array[4, float32]
  
  # Model type
  Model* {.importc, header: "raylib.h", bycopy.} = object
    transform*: Matrix
    meshCount*: cint
    materialCount*: cint
    meshes*: ptr Mesh
    materials*: ptr Material
    meshMaterial*: ptr cint
    boneCount*: cint
    bones*: pointer
    bindPose*: pointer

# Camera projection types
const
  CAMERA_PERSPECTIVE* = 0
  CAMERA_ORTHOGRAPHIC* = 1

# Predefined colors (some common ones)
var
  LIGHTGRAY* {.importc, header: "raylib.h".}: Color
  GRAY* {.importc, header: "raylib.h".}: Color
  DARKGRAY* {.importc, header: "raylib.h".}: Color
  YELLOW* {.importc, header: "raylib.h".}: Color
  GOLD* {.importc, header: "raylib.h".}: Color
  ORANGE* {.importc, header: "raylib.h".}: Color
  PINK* {.importc, header: "raylib.h".}: Color
  RED* {.importc, header: "raylib.h".}: Color
  MAROON* {.importc, header: "raylib.h".}: Color
  GREEN* {.importc, header: "raylib.h".}: Color
  LIME* {.importc, header: "raylib.h".}: Color
  DARKGREEN* {.importc, header: "raylib.h".}: Color
  SKYBLUE* {.importc, header: "raylib.h".}: Color
  BLUE* {.importc, header: "raylib.h".}: Color
  DARKBLUE* {.importc, header: "raylib.h".}: Color
  PURPLE* {.importc, header: "raylib.h".}: Color
  VIOLET* {.importc, header: "raylib.h".}: Color
  DARKPURPLE* {.importc, header: "raylib.h".}: Color
  BEIGE* {.importc, header: "raylib.h".}: Color
  BROWN* {.importc, header: "raylib.h".}: Color
  DARKBROWN* {.importc, header: "raylib.h".}: Color
  WHITE* {.importc, header: "raylib.h".}: Color
  BLACK* {.importc, header: "raylib.h".}: Color
  BLANK* {.importc, header: "raylib.h".}: Color
  MAGENTA* {.importc, header: "raylib.h".}: Color
  RAYWHITE* {.importc, header: "raylib.h".}: Color
