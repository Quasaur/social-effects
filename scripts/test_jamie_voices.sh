#!/bin/bash
# Generate Jamie (Premium) voice samples with different rate and pitch settings
# Rate is controlled by `say`, pitch is post-processed with FFmpeg

TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests"
mkdir -p "$OUTDIR"

echo "═══════════════════════════════════════════════════"
echo "Generating Jamie (Premium) voice samples"
echo "═══════════════════════════════════════════════════"
echo ""

# Generate base recordings at different rates
# say -r = words per minute (default ~175-200, lower = slower/more deliberate)
declare -a RATES=(140 155 170 185)
declare -a RATE_LABELS=("very_slow" "slow" "measured" "normal")

for i in "${!RATES[@]}"; do
    RATE=${RATES[$i]}
    LABEL=${RATE_LABELS[$i]}
    BASE="$OUTDIR/jamie_${LABEL}_r${RATE}"
    
    echo "🎙️  Generating: rate=${RATE}wpm (${LABEL})..."
    say -v "Jamie (Premium)" -r "$RATE" -o "${BASE}_base.aiff" "$TEXT"
    
    # Normal pitch (just convert to mp3)
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "${BASE}_base.aiff" \
        -codec:a libmp3lame -qscale:a 2 \
        "${BASE}_pitch_normal.mp3" 2>/dev/null
    echo "   ✅ ${LABEL}_pitch_normal.mp3"
    
    # Lower pitch (-2 semitones, deeper)
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "${BASE}_base.aiff" \
        -af "asetrate=44100*0.89,aresample=44100,atempo=1.12" \
        -codec:a libmp3lame -qscale:a 2 \
        "${BASE}_pitch_deep.mp3" 2>/dev/null
    echo "   ✅ ${LABEL}_pitch_deep.mp3"
    
    # Even lower pitch (-4 semitones, very deep)
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "${BASE}_base.aiff" \
        -af "asetrate=44100*0.79,aresample=44100,atempo=1.26" \
        -codec:a libmp3lame -qscale:a 2 \
        "${BASE}_pitch_very_deep.mp3" 2>/dev/null
    echo "   ✅ ${LABEL}_pitch_very_deep.mp3"
    
    # Slightly lower pitch (-1 semitone, subtle)
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "${BASE}_base.aiff" \
        -af "asetrate=44100*0.944,aresample=44100,atempo=1.06" \
        -codec:a libmp3lame -qscale:a 2 \
        "${BASE}_pitch_slightly_deep.mp3" 2>/dev/null
    echo "   ✅ ${LABEL}_pitch_slightly_deep.mp3"
    
    # Clean up AIFF
    rm -f "${BASE}_base.aiff"
    echo ""
done

echo "═══════════════════════════════════════════════════"
echo "✅ Generated $(ls -1 $OUTDIR/*.mp3 | wc -l) samples in $OUTDIR/"
echo ""
echo "🎧 Best candidates for Donovan-like quality:"
echo "   afplay $OUTDIR/jamie_slow_r155_pitch_deep.mp3"
echo "   afplay $OUTDIR/jamie_measured_r170_pitch_slightly_deep.mp3"
echo "   afplay $OUTDIR/jamie_very_slow_r140_pitch_deep.mp3"
echo ""
echo "▶️  Play all in sequence:"
echo "   for f in $OUTDIR/*.mp3; do echo \"Playing: \$f\"; afplay \"\$f\"; sleep 1; done"
echo ""
echo "Rate guide:  140=very slow, 155=slow, 170=measured, 185=normal"
echo "Pitch guide: normal=as-is, slightly_deep=-1st, deep=-2st, very_deep=-4st"
