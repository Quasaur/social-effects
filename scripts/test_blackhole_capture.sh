#!/bin/bash
# Post-reboot test: Verify BlackHole capture of Jamie neural voice
# Run this after reboot to confirm the pipeline works

set -e

OUTDIR="/tmp/voice_quality_test"
mkdir -p "$OUTDIR"
FFMPEG="/opt/homebrew/bin/ffmpeg"
TEXT="That which is Ultimate cannot be Ultimate unless it is also personal."

echo "=== BlackHole Neural Capture Test ==="
echo ""

# 1. Verify BlackHole is visible
echo "Step 1: Checking BlackHole device..."
DEVICES=$($FFMPEG -f avfoundation -list_devices true -i "" 2>&1 || true)
if echo "$DEVICES" | grep -qi "BlackHole"; then
    echo "  ✅ BlackHole detected"
    BH_INDEX=$(echo "$DEVICES" | grep -i "BlackHole" | head -1 | sed 's/.*\[\([0-9]*\)\].*/\1/')
    echo "  Audio device index: $BH_INDEX"
else
    echo "  ❌ BlackHole NOT detected. Did you reboot?"
    echo "  Available audio devices:"
    echo "$DEVICES" | grep "audio" -A 10
    exit 1
fi

# 2. Set system audio output to BlackHole temporarily
echo ""
echo "Step 2: Setting audio output to BlackHole..."
# Use SwitchAudioSource if available, otherwise instruct user
if command -v SwitchAudioSource &>/dev/null; then
    ORIGINAL_OUTPUT=$(SwitchAudioSource -c)
    SwitchAudioSource -s "BlackHole 2ch" -t output
    echo "  ✅ Output set to BlackHole (was: $ORIGINAL_OUTPUT)"
else
    echo "  ⚠️  SwitchAudioSource not found. Installing..."
    brew install switchaudio-osx 2>/dev/null || true
    if command -v SwitchAudioSource &>/dev/null; then
        ORIGINAL_OUTPUT=$(SwitchAudioSource -c)
        SwitchAudioSource -s "BlackHole 2ch" -t output
        echo "  ✅ Output set to BlackHole (was: $ORIGINAL_OUTPUT)"
    else
        echo "  ❌ Could not install SwitchAudioSource."
        echo "  Please manually set System Settings → Sound → Output to 'BlackHole 2ch'"
        echo "  Then press Enter to continue..."
        read
    fi
fi

# 3. Start FFmpeg capture in background
echo ""
echo "Step 3: Starting capture + TTS..."
CAPTURE_FILE="$OUTDIR/18_neural_capture_raw.wav"
rm -f "$CAPTURE_FILE"

# Start ffmpeg capture from BlackHole (48kHz, 24-bit)
$FFMPEG -y -nostdin \
    -f avfoundation -i ":BlackHole 2ch" \
    -ar 48000 -ac 1 -acodec pcm_s24le \
    "$CAPTURE_FILE" &
FFMPEG_PID=$!

# Small delay to ensure FFmpeg is listening
sleep 0.5

# 4. Speak with Jamie neural engine (real-time, NOT -o file)
echo "  Speaking with Jamie (Premium) neural engine..."
say -v "Jamie (Premium)" "$TEXT"

# Small tail silence for clean ending
sleep 0.3

# 5. Stop capture
kill $FFMPEG_PID 2>/dev/null || true
wait $FFMPEG_PID 2>/dev/null || true
echo "  ✅ Capture stopped"

# 6. Restore audio output
echo ""
echo "Step 4: Restoring audio output..."
if command -v SwitchAudioSource &>/dev/null && [ -n "$ORIGINAL_OUTPUT" ]; then
    SwitchAudioSource -s "$ORIGINAL_OUTPUT" -t output
    echo "  ✅ Output restored to: $ORIGINAL_OUTPUT"
else
    echo "  ⚠️  Please restore your audio output in System Settings"
fi

# 7. Trim silence and convert to M4A
echo ""
echo "Step 5: Processing capture..."
TRIMMED="$OUTDIR/18_neural_capture.m4a"
$FFMPEG -y -nostdin \
    -i "$CAPTURE_FILE" \
    -af "silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse" \
    -ar 48000 -c:a aac -b:a 256k \
    "$TRIMMED" 2>/dev/null

# 8. Report
echo ""
echo "=== Results ==="
if [ -f "$TRIMMED" ]; then
    DURATION=$($FFMPEG -i "$TRIMMED" 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
    SIZE=$(ls -la "$TRIMMED" | awk '{print $5}')
    SAMPLE=$($FFMPEG -i "$CAPTURE_FILE" 2>&1 | grep "Stream" | head -1)
    echo "  Raw capture: $SAMPLE"
    echo "  Output: $TRIMMED"
    echo "  Duration: $DURATION"
    echo "  Size: $SIZE bytes"
    echo ""
    echo "Opening in QuickTime Player..."
    open -a "QuickTime Player" "$TRIMMED"
else
    echo "  ❌ Failed to create output"
fi

echo ""
echo "Done! Compare this with the say -o variants."
