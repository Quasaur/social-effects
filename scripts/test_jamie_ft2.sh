#!/bin/bash
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/finetune2"
mkdir -p "$OUTDIR"

say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

for TEMPO in 0.82 0.85 0.88 0.90 0.92 0.95; do
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "atempo=$TEMPO" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_${TEMPO}.mp3" 2>/dev/null
    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_${TEMPO}.mp3")
    echo "  tempo=${TEMPO}: ${DUR}s"
done

rm -f "$OUTDIR/base.aiff"
echo ""
echo "afplay /tmp/apple_voice_tests/finetune2/jamie_0.88.mp3"
echo "afplay /tmp/apple_voice_tests/finetune2/jamie_0.90.mp3"
