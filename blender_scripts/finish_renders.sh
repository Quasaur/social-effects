#!/bin/bash
# Final render and cleanup for videos 03 and 05

set -e

echo "🎬 Rendering final 2 videos and cleaning up..."

# Check if video 03 exists
if [ ! -f "output/backgrounds/03_origami_fold_cycle.mp4" ]; then
    echo "⏳ Waiting for video 03 to complete..."
    while [ ! -f "output/backgrounds/03_origami_fold_cycle.mp4" ]; do
        sleep 10
    done
fi

echo "✅ Video 03 complete!"
echo ""

# Render video 05
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 Rendering video 05: Holographic Data Stream"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

/Applications/Blender.app/Contents/MacOS/Blender --background \
    --python blender_scripts/05_holographic_data_stream.py -a \
    2>&1 | grep -E "(Rendering frame|Fra: 240|complete)" || true

echo "Converting to MP4..."
ffmpeg -y -framerate 30 \
    -i "output/backgrounds/05_data_stream/frame_%04d.png" \
    -c:v libx264 -pix_fmt yuv420p -crf 23 \
    output/backgrounds/05_holographic_data_stream.mp4 2>&1 | grep -E "(frame=|muxing)" || true

echo "✅ Video 05 complete!"
echo ""

# Clean up ALL PNG files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 Cleaning up PNG files..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Remove temporary frame directories
rm -rf output/backgrounds/03_origami/ 2>/dev/null || true
rm -rf output/backgrounds/05_data_stream/ 2>/dev/null || true

# Remove PNG files from video 01
rm -f output/backgrounds/01_expanding_hexagon_grid.mp4*.png 2>/dev/null || true

# Remove any remaining PNGs in /tmp
rm -f /tmp/*.png 2>/dev/null || true

echo "✅ Cleanup complete!"
echo ""

# Final status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 All 4 videos ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -lh output/backgrounds/*.mp4 | grep -E "(01_|03_|05_|06_)"
echo ""
echo "📊 Disk space check:"
du -sh output/backgrounds/*.mp4 | grep -E "(01_|03_|05_|06_)" | awk '{sum+=$1} END {print "Total: " sum}'
