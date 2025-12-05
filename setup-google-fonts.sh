#!/bin/bash
# Google Fonts setup for Storie
# Creates directory structure for optional local font caching
# NOTE: Fonts are loaded from Google Fonts CDN at runtime by default!

set -e

FONTS_DIR="docs/assets/fonts"

echo "Setting up Google Fonts integration for Storie..."
echo ""

# Create fonts directory for optional local caching
mkdir -p "$FONTS_DIR"

# Create a README explaining the runtime approach
cat > "$FONTS_DIR/README.md" << 'EOF'
# Google Fonts in Storie

## Runtime Loading (Default)

Storie loads Google Fonts **at runtime from Google's CDN** - no downloads needed!

```nim
# In your Nimini code:
let font = loadGoogleFont("Roboto")
drawText("Hello World!", 100, 100, font)
```

Available fonts are listed in `platform/google_fonts.nim`.

## Why Runtime Loading?

- ✅ **Zero compile-time size** - fonts don't bloat your WASM
- ✅ **Always up-to-date** - uses latest font versions from Google
- ✅ **Browser caching** - fonts cached across websites
- ✅ **On-demand** - only loads fonts you actually use

## Optional: Local Font Caching

For offline development or custom fonts, you can place `.ttf` or `.woff2` files here:

```
docs/assets/fonts/
  MyCustomFont.ttf
  Roboto-Regular.ttf
```

Then preload them in your build script:
```bash
--preload-file docs/assets/fonts@/fonts
```

## Font Size Reference

If you do bundle fonts:
- `.woff2` format: ~15-50KB per font (recommended)
- `.ttf` format: ~80-200KB per font
- Variable fonts: ~100-500KB (all weights in one file)

Google Fonts uses `.woff2` for optimal compression.
EOF

echo "✓ Created $FONTS_DIR"
echo "✓ Created $FONTS_DIR/README.md"
echo ""
echo "Google Fonts integration is ready!"
echo ""
echo "Fonts will be loaded from Google CDN at runtime."
echo "No compilation step needed - just use loadGoogleFont() in your code."
echo ""
echo "See platform/google_fonts.nim for available fonts and usage."
