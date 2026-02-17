#!/bin/bash
# Convert rendered PNG frame sequences to MP4 videos

set -e

echo "🎞️  Converting PNG frames to MP4 videos..."

# Video 01: Expanding Hexagon Grid
echo "Converting video 01..."
ffmpeg -y -framerate 30 -i /tmp/0%03d.png -c:v libx264 -pix_fmt yuv420p -crf 23 \
  output/backgrounds/01_expanding_hexagon_grid.mp4 2>&1 | grep -E "(frame=|Duration)" || true
echo "✅ 01_expanding_hexagon_grid.mp4"

# Clean /tmp before next video
rm /tmp/*.png 2>/dev/null || true

echo ""
echo "🎉 Conversion complete!"
ls -lh output/backgrounds/*.mp4
