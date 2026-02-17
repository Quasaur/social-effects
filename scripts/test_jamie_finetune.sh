#!/bin/bash
# Fine-tune Jamie tempo around 0.70-0.80 range, normal pitch only
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/finetune"
mkdir -p "$OUTDIR"

echo "Generating base Jamie recording..."
say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

echo "Fine-tuning tempo (normal pitch only)..."

for TEMPO in 0.72 0.74 0.76 0.78; do
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "atempo=$TEMPO" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_tempo${TEMPO}.mp3" 2>/dev/null
    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_tempo${TEMPO}.mp3")
    echo "  tempo=${TEMPO}: ${DUR}s"
done

rm -f "$OUTDIR/base.aiff"

echo ""
echo "Listen:"
echo "  afplay /tmp/apple_voice_tests/finetune/jamie_tempo0.74.mp3"
echo "  afplay /tmp/apple_voice_tests/finetune/jamie_tempo0.76.mp3"
