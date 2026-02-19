#!/bin/bash
# Synthesize speech using Google Cloud TTS for a given voice and text
# Usage: bash synthesize_tts.sh <voice_name> <output_file>
# Requires: jq, curl

VOICE_NAME="$1"
OUTPUT_FILE="$2"
if [ -n "$3" ]; then
  TEXT="$3"
else
  TEXT="This is the ULTIMATE RSS sample."
fi

ACCESS_TOKEN=$(bash scripts/extract_token.sh /tmp/gcloud_token.json)
echo "Generated $OUTPUT_FILE for $VOICE_NAME"

if [ -n "$3" ]; then
  case "$TEXT" in
    "<speak>"*)
      INPUT_TYPE="ssml"
      ;;
    *)
      INPUT_TYPE="text"
      ;;
  esac
else
  INPUT_TYPE="text"
fi

if [ "$INPUT_TYPE" = "ssml" ]; then
  JSON_PAYLOAD=$(jq -n --arg ssml "$TEXT" --arg vname "$VOICE_NAME" '{input: {ssml: $ssml}, voice: {languageCode: "en-US", name: $vname}, audioConfig: {audioEncoding: "MP3", speakingRate: 0.85, pitch: -3.0}}')
else
  JSON_PAYLOAD=$(jq -n --arg txt "$TEXT" --arg vname "$VOICE_NAME" '{input: {text: $txt}, voice: {languageCode: "en-US", name: $vname}, audioConfig: {audioEncoding: "MP3", speakingRate: 0.85, pitch: -3.0}}')
fi

RESPONSE=$(curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data "$JSON_PAYLOAD" \
  "https://texttospeech.googleapis.com/v1/text:synthesize")

echo "$RESPONSE" > "${OUTPUT_FILE%.mp3}.json"
echo "[DEBUG] API response for $VOICE_NAME:"
cat "${OUTPUT_FILE%.mp3}.json"

echo "$RESPONSE" | jq -r .audioContent | base64 --decode > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE for $VOICE_NAME"