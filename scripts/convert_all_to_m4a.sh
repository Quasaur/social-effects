#!/bin/bash
# Convert all TTS mp3 samples to m4a using ffmpeg
# Usage: bash convert_all_to_m4a.sh

for f in output/en-US-Standard-*.mp3; do
  out="${f%.mp3}.m4a"
  ffmpeg -y -i "$f" -c:a aac "$out"
  echo "Converted $f to $out"
done
