#!/bin/bash
# Analyze and compare Donovan (ElevenLabs) vs Jamie (Apple) voice characteristics
# Uses ffmpeg/ffprobe to extract: fundamental frequency, spectral centroid, loudness, etc.

DONOVAN="$1"
JAMIE="$2"

if [ -z "$DONOVAN" ] || [ -z "$JAMIE" ]; then
    echo "Usage: $0 <donovan.mp3> <jamie.mp3>"
    exit 1
fi

echo "═══════════════════════════════════════════════════"
echo "Voice Comparison: Donovan vs Jamie"
echo "═══════════════════════════════════════════════════"
echo ""

# Duration
DUR_D=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$DONOVAN")
DUR_J=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$JAMIE")
echo "Duration:  Donovan=${DUR_D}s  Jamie=${DUR_J}s"

# Sample rate
SR_D=$(/opt/homebrew/bin/ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$DONOVAN")
SR_J=$(/opt/homebrew/bin/ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$JAMIE")
echo "Sample Rate: Donovan=${SR_D}Hz  Jamie=${SR_J}Hz"

# Loudness (integrated LUFS)
echo ""
echo "--- Loudness ---"
LOUD_D=$(/opt/homebrew/bin/ffmpeg -nostdin -i "$DONOVAN" -af "loudnorm=print_format=json" -f null /dev/null 2>&1 | grep -A1 "input_i" | head -2)
LOUD_J=$(/opt/homebrew/bin/ffmpeg -nostdin -i "$JAMIE" -af "loudnorm=print_format=json" -f null /dev/null 2>&1 | grep -A1 "input_i" | head -2)
echo "Donovan: $LOUD_D"
echo "Jamie:   $LOUD_J"

# Fundamental frequency (F0) analysis via astats
echo ""
echo "--- Volume Stats ---"
echo "Donovan:"
/opt/homebrew/bin/ffmpeg -nostdin -i "$DONOVAN" -af "astats=metadata=1:reset=0,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null /dev/null 2>&1 | grep "RMS_level" | tail -1
echo "Jamie:"
/opt/homebrew/bin/ffmpeg -nostdin -i "$JAMIE" -af "astats=metadata=1:reset=0,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null /dev/null 2>&1 | grep "RMS_level" | tail -1

# Spectral analysis - extract frequency bands energy
echo ""
echo "--- Frequency Band Energy ---"
echo "(Low=80-300Hz=chest, Mid=300-2kHz=clarity, High=2k-8kHz=brightness)"
echo ""

for VOICE_FILE in "$DONOVAN" "$JAMIE"; do
    NAME=$([ "$VOICE_FILE" = "$DONOVAN" ] && echo "Donovan" || echo "Jamie")
    
    # Low frequencies (80-300Hz) - bass/chest resonance
    LOW=$(/opt/homebrew/bin/ffmpeg -nostdin -i "$VOICE_FILE" -af "highpass=f=80,lowpass=f=300,astats=metadata=1:reset=0,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null /dev/null 2>&1 | grep "RMS_level" | tail -1 | awk -F= '{print $2}')
    
    # Mid frequencies (300-2000Hz) - vocal clarity
    MID=$(/opt/homebrew/bin/ffmpeg -nostdin -i "$VOICE_FILE" -af "highpass=f=300,lowpass=f=2000,astats=metadata=1:reset=0,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null /dev/null 2>&1 | grep "RMS_level" | tail -1 | awk -F= '{print $2}')
    
    # High frequencies (2000-8000Hz) - brightness/sibilance
    HIGH=$(/opt/homebrew/bin/ffmpeg -nostdin -i "$VOICE_FILE" -af "highpass=f=2000,lowpass=f=8000,astats=metadata=1:reset=0,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null /dev/null 2>&1 | grep "RMS_level" | tail -1 | awk -F= '{print $2}')
    
    echo "${NAME}:  Low=${LOW}dB  Mid=${MID}dB  High=${HIGH}dB"
done

# Speaking rate (words per duration)
WORDS=28  # "The ultimate measure..." is 28 words
RATE_D=$(echo "scale=1; $WORDS / $DUR_D * 60" | bc 2>/dev/null)
RATE_J=$(echo "scale=1; $WORDS / $DUR_J * 60" | bc 2>/dev/null)
echo ""
echo "--- Speaking Rate ---"
echo "Donovan: ${RATE_D} wpm"
echo "Jamie:   ${RATE_J} wpm"

echo ""
echo "═══════════════════════════════════════════════════"
echo "INTERPRETATION:"
echo "  - If Jamie's Low band is weaker → need more pitch shift (more negative cents)"
echo "  - If Jamie's High band is stronger → add lowpass filter to reduce brightness"
echo "  - If Jamie is faster → decrease atempo below 0.95"
echo "  - If Jamie is louder → normalize to match Donovan's LUFS"
