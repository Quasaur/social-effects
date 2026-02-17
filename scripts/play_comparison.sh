#!/bin/bash
# Play Donovan vs Jamie (tuned) samples back-to-back for comparison

echo "🎧 Playing DONOVAN (ElevenLabs)..."
afplay /tmp/donovan_sample.mp3

sleep 1

echo "🎧 Playing JAMIE (Apple, Donovan-matched)..."
afplay /tmp/jamie_tuned3.mp3

echo "✅ Done"
