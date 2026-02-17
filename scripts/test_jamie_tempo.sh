#!/bin/bash
# Generate Jamie samples with FFmpeg-based speed control (since say -r is ignored by Premium voices)
TEXT="The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."
OUTDIR="/tmp/apple_voice_tests/tempo"
mkdir -p "$OUTDIR"

echo "Generating base Jamie recording..."
say -v "Jamie (Premium)" -o "$OUTDIR/base.aiff" "$TEXT"

echo "Applying tempo and pitch variations..."

# atempo < 1.0 = slower, pitch shift via asetrate
# Tempo: 0.7 = 30% slower, 0.8 = 20% slower, 0.6 = 40% slower

# Normal pitch, various speeds
for TEMPO in 0.60 0.65 0.70 0.75 0.80 0.85; do
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "atempo=$TEMPO" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_tempo${TEMPO}_normal.mp3" 2>/dev/null
    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_tempo${TEMPO}_normal.mp3")
    echo "  tempo=${TEMPO} normal pitch: ${DUR}s"
done

echo ""

# Slightly deeper (-1 semitone) at best tempos
for TEMPO in 0.65 0.70 0.75 0.80; do
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "asetrate=44100*0.944,aresample=44100,atempo=$TEMPO" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_tempo${TEMPO}_slight_deep.mp3" 2>/dev/null
    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_tempo${TEMPO}_slight_deep.mp3")
    echo "  tempo=${TEMPO} slightly deep: ${DUR}s"
done

echo ""

# Deeper (-2 semitones) at best tempos
for TEMPO in 0.65 0.70 0.75 0.80; do
    /opt/homebrew/bin/ffmpeg -y -nostdin -i "$OUTDIR/base.aiff" \
        -af "asetrate=44100*0.89,aresample=44100,atempo=$TEMPO" \
        -codec:a libmp3lame -qscale:a 2 "$OUTDIR/jamie_tempo${TEMPO}_deep.mp3" 2>/dev/null
    DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTDIR/jamie_tempo${TEMPO}_deep.mp3")
    echo "  tempo=${TEMPO} deep: ${DUR}s"
done

rm -f "$OUTDIR/base.aiff"

echo ""
echo "Done! $(ls -1 $OUTDIR/*.mp3 | wc -l | tr -d ' ') samples in $OUTDIR/"
echo ""
echo "Top picks:"
echo "  afplay $OUTDIR/jamie_tempo0.70_normal.mp3"
echo "  afplay $OUTDIR/jamie_tempo0.75_slight_deep.mp3"
echo "  afplay $OUTDIR/jamie_tempo0.70_deep.mp3"
