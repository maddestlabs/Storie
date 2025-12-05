#!/bin/bash
# Generate binding metadata report
# Shows all registered bindings and their sizes

set -e

echo "Generating Storie binding metadata report..."
echo ""

# Compile the binding registry with metadata generation enabled
nim c -d:bindingMetadataGeneration \
  --hints:off \
  --warnings:off \
  -r \
  platform/binding_registry.nim

echo ""
echo "Report generation complete!"
