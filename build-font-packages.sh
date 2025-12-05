#!/bin/bash
# Build separate font data packages for on-demand loading
# Creates multiple .data files that can be loaded via URL parameters

set -e

FONTS_DIR="docs/assets/fonts"
OUTPUT_DIR="docs"

echo "Building font data packages for Storie..."
echo ""

# Create font directories
mkdir -p "$FONTS_DIR/core"
mkdir -p "$FONTS_DIR/full"

# Download core fonts (3-5 popular, ~300KB total)
echo "Downloading core fonts..."
CORE_FONTS=(
  "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf:Roboto-Regular.ttf"
  "https://github.com/google/fonts/raw/main/apache/robotomono/static/RobotoMono-Regular.ttf:RobotoMono-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Regular.ttf:Inter-Regular.ttf"
)

for font_url in "${CORE_FONTS[@]}"; do
  IFS=':' read -r url filename <<< "$font_url"
  output="$FONTS_DIR/core/$filename"
  
  if [ -f "$output" ]; then
    echo "  ✓ $filename (cached)"
  else
    echo "  ⬇ $filename..."
    if curl -L -f -s -o "$output" "$url"; then
      size=$(du -h "$output" | cut -f1)
      echo "    ✓ $size"
    else
      echo "    ✗ Failed"
      rm -f "$output"
    fi
  fi
done

# Download full fonts (15-20 fonts, ~1.5MB total)
echo ""
echo "Downloading full fonts..."
FULL_FONTS=(
  "https://github.com/google/fonts/raw/main/apache/opensans/static/OpenSans-Regular.ttf:OpenSans-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf:Lato-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/montserrat/static/Montserrat-Regular.ttf:Montserrat-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/sourcecodepro/static/SourceCodePro-Regular.ttf:SourceCodePro-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-Regular.ttf:PlayfairDisplay-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf:Poppins-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ufl/ubuntu/Ubuntu-Regular.ttf:Ubuntu-Regular.ttf"
)

# Copy core fonts to full
cp "$FONTS_DIR/core"/*.ttf "$FONTS_DIR/full/" 2>/dev/null || true

for font_url in "${FULL_FONTS[@]}"; do
  IFS=':' read -r url filename <<< "$font_url"
  output="$FONTS_DIR/full/$filename"
  
  if [ -f "$output" ]; then
    echo "  ✓ $filename (cached)"
  else
    echo "  ⬇ $filename..."
    if curl -L -f -s -o "$output" "$url"; then
      size=$(du -h "$output" | cut -f1)
      echo "    ✓ $size"
    else
      echo "    ✗ Failed"
      rm -f "$output"
    fi
  fi
done

echo ""
echo "Font packages ready:"
echo ""

# Core fonts size
if ls "$FONTS_DIR/core"/*.ttf 1> /dev/null 2>&1; then
  core_size=$(du -sh "$FONTS_DIR/core" | cut -f1)
  core_count=$(ls "$FONTS_DIR/core"/*.ttf | wc -l)
  echo "  Core fonts:  $core_count fonts, $core_size"
else
  echo "  Core fonts:  (none downloaded)"
fi

# Full fonts size
if ls "$FONTS_DIR/full"/*.ttf 1> /dev/null 2>&1; then
  full_size=$(du -sh "$FONTS_DIR/full" | cut -f1)
  full_count=$(ls "$FONTS_DIR/full"/*.ttf | wc -l)
  echo "  Full fonts:  $full_count fonts, $full_size"
else
  echo "  Full fonts:  (none downloaded)"
fi

echo ""
echo "Now build with:"
echo "  ./build-web.sh             # No fonts (minimal)"
echo "  ./build-web-fonts-core.sh  # Core fonts only"
echo "  ./build-web-fonts-full.sh  # All fonts"
echo ""
echo "Or let build-web-full.sh choose via URL parameter:"
echo "  ?data=minimal     → No fonts"
echo "  ?data=corefonts   → Core fonts"
echo "  ?data=fullfonts   → All fonts"
