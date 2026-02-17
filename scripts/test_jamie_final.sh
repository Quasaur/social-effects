#!/bin/bash
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/final"
mkdir -p "$OUTDIR"

say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

# Tempo 0.95, with pitch variations
# Pitch shift via asetrate: lower ratio = deeper voice
# Then atempo compensates so final speed stays at 0.95 of original

# Baseline: 0.95 tempo, normal pitch
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "atempo=0.95" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_normal.mp3" 2>/dev/null
echo "  normal pitch (reference)"

# -0.5 semitone (subtle)
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "asetrate=44100*0.9715,aresample=44100,atempo=0.977" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_half_semi_deep.mp3" 2>/dev/null
echo "  -0.5 semitone"

# -1 semitone
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "asetrate=44100*0.9439,aresample=44100,atempo=1.006" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_1_semi_deep.mp3" 2>/dev/null
echo "  -1 semitone"

# -1.5 semitones
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "asetrate=44100*0.9170,aresample=44100,atempo=1.036" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_1.5_semi_deep.mp3" 2>/dev/null
echo "  -1.5 semitones"

# -2 semitones
/opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
    -af "asetrate=44100*0.8909,aresample=44100,atempo=1.066" \
    -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_2_semi_deep.mp3" 2>/dev/null
echo "  -2 semitones"

rm -f "$OUTDIR/base.aiff"

echo ""
echo "All at 0.95 tempo. Listen:"
echo "  afplay /tmp/apple_voice_tests/final/jamie_normal.mp3"
echo "  afplay /tmp/apple_voice_tests/final/jamie_half_semi_deep.mp3"
echo "  afplay /tmp/apple_voice_tests/final/jamie_1_semi_deep.mp3"
echo "  afplay /tmp/apple_voice_tests/final/jamie_1.5_semi_deep.mp3"
echo "  afplay /tmp/apple_voice_tests/final/jamie_2_semi_deep.mp3"
