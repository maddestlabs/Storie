#!/bin/bash
# Generate test audio files for WASM audio testing

set -e

OUTPUT_DIR="docs/assets/audio"

echo "Generating test audio files..."
echo ""

# Check if sox is available
if ! command -v sox &> /dev/null; then
    echo "Warning: sox not found. Cannot generate audio files."
    echo ""
    echo "Install sox:"
    echo "  Ubuntu/Debian: sudo apt-get install sox"
    echo "  macOS: brew install sox"
    echo "  Windows: Download from https://sox.sourceforge.net/"
    echo ""
    echo "Alternatively, place your own .wav files in $OUTPUT_DIR/"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Generate a short beep (440 Hz, 0.5 seconds)
echo "Generating beep.wav (440 Hz, 0.5s)..."
sox -n "$OUTPUT_DIR/beep.wav" synth 0.5 sine 440

# Generate a lower tone (220 Hz, 0.5 seconds)
echo "Generating low-beep.wav (220 Hz, 0.5s)..."
sox -n "$OUTPUT_DIR/low-beep.wav" synth 0.5 sine 220

# Generate a higher tone (880 Hz, 0.3 seconds)
echo "Generating high-beep.wav (880 Hz, 0.3s)..."
sox -n "$OUTPUT_DIR/high-beep.wav" synth 0.3 sine 880

# Generate a chord (C major: 261.63, 329.63, 392 Hz)
echo "Generating chord.wav (C major, 1s)..."
sox -n "$OUTPUT_DIR/chord.wav" synth 1.0 sine 261.63 sine 329.63 sine 392.00 remix 1,2,3

echo ""
echo "✓ Test audio files generated in $OUTPUT_DIR/"
echo ""
echo "Files created:"
ls -lh "$OUTPUT_DIR"/*.wav | awk '{print "  - " $9 " (" $5 ")"}'
echo ""
echo "Usage in Nim code:"
echo '  let sound = LoadSound("/assets/audio/beep.wav")'
echo '  PlaySound(sound)'
echo ""
echo "Now run: ./build-web.sh"
