#!/bin/bash
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/final3"
mkdir -p "$OUTDIR"

say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

# Step 1: slow down to 0.95 tempo first
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "atempo=0.95" "$OUTDIR/slowed.wav" 2>/dev/null

DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/slowed.wav")
echo "Slowed base: ${DUR}s"

# Normal (reference)
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/slowed.wav" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_normal.mp3" 2>/dev/null
echo "  normal pitch"

# Step 2: pitch shift the slowed audio using sox (pitch-only, no tempo change)
# sox approach: pitch shift in cents. -50 = -0.5 semitone, -100 = -1 semitone, etc.
# Check if sox is available
if command -v sox &>/dev/null; then
    for CENTS in 50 100 150 200; do
        SEMI=$(echo "scale=1; $CENTS / 100" | bc)
        sox "$OUTDIR/slowed.wav" "$OUTDIR/pitched_${CENTS}.wav" pitch -${CENTS}
        /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/pitched_${CENTS}.wav" \
            -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_deep_${CENTS}cents.mp3" 2>/dev/null
        DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_deep_${CENTS}cents.mp3")
        echo "  -${SEMI} semitone: ${DUR}s"
        rm -f "$OUTDIR/pitched_${CENTS}.wav"
    done
else
    echo "sox not found, installing..."
    brew install sox 2>/dev/null
    if command -v sox &>/dev/null; then
        for CENTS in 50 100 150 200; do
            SEMI=$(echo "scale=1; $CENTS / 100" | bc)
            sox "$OUTDIR/slowed.wav" "$OUTDIR/pitched_${CENTS}.wav" pitch -${CENTS}
            /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/pitched_${CENTS}.wav" \
                -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_deep_${CENTS}cents.mp3" 2>/dev/null
            DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_deep_${CENTS}cents.mp3")
            echo "  -${SEMI} semitone: ${DUR}s"
            rm -f "$OUTDIR/pitched_${CENTS}.wav"
        done
    else
        echo "Could not install sox. Using ffmpeg fallback..."
        # Fallback: use ffmpeg with careful filter chain
        # Key insight: asetrate changes pitch+speed, then atempo ONLY corrects the speed change
        SR=44100
        for entry in "50:0.9715" "100:0.9439" "150:0.9170" "200:0.8909"; do
            CENTS="${entry%%:*}"
            RATIO="${entry##*:}"
            SEMI=$(echo "scale=1; $CENTS / 100" | bc)
            # asetrate makes it deeper+slower, atempo=1/ratio restores ONLY the speed
            ATEMPO=$(python3 -c "print(round(1.0/$RATIO, 6))")
            /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/slowed.wav" \
                -af "asetrate=${SR}*${RATIO},aresample=${SR},atempo=${ATEMPO}" \
                -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_deep_${CENTS}cents.mp3" 2>/dev/null
            DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_deep_${CENTS}cents.mp3")
            echo "  -${SEMI} semitone: ${DUR}s"
        done
    fi
fi

rm -f "$OUTDIR/base.aiff" "$OUTDIR/slowed.wav"

echo ""
echo "Listen:"
for f in "$OUTDIR"/jamie_*.mp3; do echo "  afplay $f"; done
