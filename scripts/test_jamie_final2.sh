#!/bin/bash
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/final2"
mkdir -p "$OUTDIR"

say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

echo "Pass 1: pitch shift, Pass 2: slow to 0.95 tempo"

# Normal pitch at 0.95 (reference)
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "atempo=0.95" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/01_normal.mp3" 2>/dev/null
DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/01_normal.mp3")
echo "  01_normal: ${DUR}s"

# For each pitch depth: first pitch-shift to intermediate, then slow down
for entry in "0.5:0.9715" "1.0:0.9439" "1.5:0.9170" "2.0:0.8909"; do
    SEMI="${entry%%:*}"
    RATIO="${entry##*:}"
    LABEL=$(echo "$SEMI" | tr '.' '_')

    # Pass 1: pitch shift only (compensate tempo fully so pitch changes but speed stays original)
    COMPENSATE=$(echo "scale=6; 1.0 / $RATIO" | bc)
    # asetrate slows+deepens, then atempo=1/ratio restores original speed
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "asetrate=44100*${RATIO},aresample=44100,atempo=${COMPENSATE}" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/tmp_pitched.mp3" 2>/dev/null

    # Pass 2: slow down to 0.95
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/tmp_pitched.mp3" \
        -af "atempo=0.95" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/02_deep_${LABEL}semi.mp3" 2>/dev/null

    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/02_deep_${LABEL}semi.mp3")
    echo "  deep_${LABEL}semi (-${SEMI}st): ${DUR}s"
done

rm -f "$OUTDIR/base.aiff" "$OUTDIR/tmp_pitched.mp3"

echo ""
echo "All should be same speed. Listen:"
for f in "$OUTDIR"/*.mp3; do echo "  afplay $f"; done
