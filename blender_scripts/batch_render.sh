#!/bin/bash
# Batch render all 4 alternative background videos with Blender

set -e

BLENDER="/Applications/Blender.app/Contents/MacOS/Blender"
SCRIPTS_DIR="blender_scripts"

echo "🎬 Starting batch video generation..."
echo "⚡ Rendering 4 videos with optimized settings"
echo ""

# Video 01: Expanding Hexagon Grid
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 1/4: Expanding Hexagon Grid (mint & peach)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$BLENDER" --background --python "$SCRIPTS_DIR/01_expanding_hexagon_grid.py" -a
echo "✅ Video 01 complete!"
echo ""

# Video 03: Origami Fold Cycle
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 2/4: Origami Fold Cycle (lavender & cream)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$BLENDER" --background --python "$SCRIPTS_DIR/03_origami_fold_cycle.py" -a
echo "✅ Video 03 complete!"
echo ""

# Video 05: Holographic Data Stream
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 3/4: Holographic Data Stream (cyan & magenta)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$BLENDER" --background --python "$SCRIPTS_DIR/05_holographic_data_stream.py" -a
echo "✅ Video 05 complete!"
echo ""

# Video 06: Pulsing Energy Rings
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 4/4: Pulsing Energy Rings (purple & teal)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$BLENDER" --background --python "$SCRIPTS_DIR/06_pulsing_energy_rings.py" -a
echo "✅ Video 06 complete!"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 All 4 videos rendered successfully!"
echo "📁 Location: output/backgrounds/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
