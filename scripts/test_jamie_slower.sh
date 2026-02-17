#!/bin/bash
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/slower"
mkdir -p "$OUTDIR"

echo "Generating slower Jamie samples (100-130 wpm)..."

for RATE in 100 110 120 130; do
    echo "rate=${RATE}wpm..."
    say -v "Jamie (Premium)" -r "$RATE" -o "$OUTDIR/jamie_r${RATE}_base.aiff" "$TEXT"

    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/jamie_r${RATE}_base.aiff" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_r${RATE}_normal.mp3" 2>/dev/null

    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/jamie_r${RATE}_base.aiff" \
        -af "asetrate=44100*0.944,aresample=44100,atempo=1.06" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_r${RATE}_slightly_deep.mp3" 2>/dev/null

    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/jamie_r${RATE}_base.aiff" \
        -af "asetrate=44100*0.89,aresample=44100,atempo=1.12" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_r${RATE}_deep.mp3" 2>/dev/null

    rm -f "$OUTDIR/jamie_r${RATE}_base.aiff"
    echo "   done"
done

echo ""
echo "12 slower samples in $OUTDIR/"
echo ""
echo "Listen:"
echo "  afplay $OUTDIR/jamie_r110_slightly_deep.mp3"
echo "  afplay $OUTDIR/jamie_r120_normal.mp3"
