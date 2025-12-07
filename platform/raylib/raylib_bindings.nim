## Raylib Bindings - Direct C API bindings for raylib
## Use this instead of the naylib package for full control
##
## This provides direct access to raylib's C API, similar to how
## we bind SDL3. It's simpler and more flexible than wrapper packages.

import raylib_bindings/build_config
import raylib_bindings/types
import raylib_bindings/core
import raylib_bindings/input
import raylib_bindings/shapes
import raylib_bindings/text
import raylib_bindings/models
import raylib_bindings/audio

export build_config
export types
export core
export input
export shapes
export text
export models
export audio

# Helper constructors
proc Color*(r, g, b, a: uint8): Color =
  result.r = r
  result.g = g
  result.b = b
  result.a = a

proc Vector2*(x, y: float32): Vector2 =
  result.x = x
  result.y = y

proc Vector3*(x, y, z: float32): Vector3 =
  result.x = x
  result.y = y
  result.z = z

proc Rectangle*(x, y, width, height: float32): Rectangle =
  result.x = x
  result.y = y
  result.width = width
  result.height = height
