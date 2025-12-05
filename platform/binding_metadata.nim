## Binding Metadata System
## 
## This module provides a metadata framework for tracking platform bindings,
## their features, and dependencies. Used for:
## - Automatic import analysis
## - Build size estimation
## - Feature documentation
## - Minimal vs. full build configuration

import tables, sets, strutils

type
  BindingMetadata* = object
    ## Metadata describing a platform binding module
    library*: string              ## "raylib" or "sdl3"
    module*: string               ## Module name (e.g., "text", "audio")
    features*: seq[string]        ## Feature tags (e.g., "fonts", "3d_models")
    functions*: seq[string]       ## Function names exported by this module
    minimalBuild*: bool           ## Include in minimal WASM build?
    estimatedSize*: int           ## Estimated size contribution in bytes
    dependencies*: seq[string]    ## Other modules this depends on
    description*: string          ## Human-readable description

  BindingRegistry* = ref object
    ## Central registry of all binding metadata
    functionToModule*: Table[string, BindingMetadata]
    featureToModules*: Table[string, seq[string]]
    modulesByLibrary*: Table[string, seq[BindingMetadata]]

proc newBindingRegistry*(): BindingRegistry =
  ## Create a new binding registry
  result = BindingRegistry()
  result.functionToModule = initTable[string, BindingMetadata]()
  result.featureToModules = initTable[string, seq[string]]()
  result.modulesByLibrary = initTable[string, seq[BindingMetadata]]()

proc registerBinding*(r: BindingRegistry, meta: BindingMetadata) =
  ## Register a binding module and index its functions and features
  
  # Index by function name
  for fn in meta.functions:
    r.functionToModule[fn] = meta
  
  # Index by feature
  for feature in meta.features:
    if not r.featureToModules.hasKey(feature):
      r.featureToModules[feature] = @[]
    r.featureToModules[feature].add(meta.module)
  
  # Index by library
  if not r.modulesByLibrary.hasKey(meta.library):
    r.modulesByLibrary[meta.library] = @[]
  r.modulesByLibrary[meta.library].add(meta)

proc getModuleForFunction*(r: BindingRegistry, functionName: string): BindingMetadata =
  ## Get the binding metadata for a function name
  if r.functionToModule.hasKey(functionName):
    return r.functionToModule[functionName]
  else:
    raise newException(KeyError, "Unknown function: " & functionName)

proc getRequiredModules*(r: BindingRegistry, functionCalls: seq[string]): seq[BindingMetadata] =
  ## Given a list of function calls, return required binding modules
  var modules = initTable[string, BindingMetadata]()
  
  for fn in functionCalls:
    if r.functionToModule.hasKey(fn):
      let meta = r.functionToModule[fn]
      let key = meta.library & ":" & meta.module
      
      # Add this module
      modules[key] = meta
      
      # Add dependencies recursively
      for dep in meta.dependencies:
        let depKey = meta.library & ":" & dep
        if not modules.hasKey(depKey):
          # Find dependency metadata
          for m in r.modulesByLibrary[meta.library]:
            if m.module == dep:
              modules[depKey] = m
              break
  
  for meta in modules.values:
    result.add(meta)

proc getMinimalModules*(r: BindingRegistry, library: string): seq[BindingMetadata] =
  ## Get modules that should be included in minimal builds
  if not r.modulesByLibrary.hasKey(library):
    return @[]
  
  for meta in r.modulesByLibrary[library]:
    if meta.minimalBuild:
      result.add(meta)

proc getFullModules*(r: BindingRegistry, library: string): seq[BindingMetadata] =
  ## Get all modules for full builds
  if r.modulesByLibrary.hasKey(library):
    return r.modulesByLibrary[library]
  else:
    return @[]

proc estimateTotalSize*(modules: seq[BindingMetadata]): int =
  ## Estimate total size in bytes for a set of modules
  result = 0
  for meta in modules:
    result += meta.estimatedSize

proc formatSize*(bytes: int): string =
  ## Format size in human-readable format
  if bytes < 1024:
    return $bytes & " B"
  elif bytes < 1024 * 1024:
    return $(bytes div 1024) & " KB"
  else:
    return $(bytes div (1024 * 1024)) & " MB"

proc printModuleInfo*(meta: BindingMetadata) =
  ## Print information about a binding module
  echo "Module: ", meta.library, "/", meta.module
  echo "  Description: ", meta.description
  echo "  Size: ", formatSize(meta.estimatedSize)
  echo "  Minimal: ", meta.minimalBuild
  echo "  Features: ", meta.features.join(", ")
  echo "  Functions: ", meta.functions.len, " exported"
  if meta.dependencies.len > 0:
    echo "  Depends on: ", meta.dependencies.join(", ")

proc printRegistry*(r: BindingRegistry) =
  ## Print all registered bindings
  echo "=== Binding Registry ==="
  echo ""
  
  for library in ["raylib", "sdl3"]:
    if r.modulesByLibrary.hasKey(library):
      echo library.toUpperAscii(), " Bindings:"
      echo ""
      
      let modules = r.modulesByLibrary[library]
      let minimal = modules.filterIt(it.minimalBuild)
      let full = modules
      
      echo "  Minimal build: ", minimal.len, " modules, ~", formatSize(estimateTotalSize(minimal))
      echo "  Full build: ", full.len, " modules, ~", formatSize(estimateTotalSize(full))
      echo ""
      
      for meta in modules:
        echo "  - ", meta.module, " (", formatSize(meta.estimatedSize), ")"
        if meta.minimalBuild:
          echo "    [included in minimal]"
      echo ""

# Global registry instance
var globalRegistry* = newBindingRegistry()

proc getRegistry*(): BindingRegistry =
  ## Get the global binding registry
  return globalRegistry
