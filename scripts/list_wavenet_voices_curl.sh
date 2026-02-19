#!/bin/bash
# Use a valid OAuth2 token to list all WaveNet voices from Google Cloud TTS
# Requires: jq, curl

# Get access token from previous script or environment
ACCESS_TOKEN="$1"
if [ -z "$ACCESS_TOKEN" ]; then
  echo "Usage: $0 <access_token>"
  exit 1
fi

# List voices
RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://texttospeech.googleapis.com/v1/voices")

echo "$RESPONSE" | jq '.voices[] | select(.name | test("WaveNet")) | {name, languageCodes, ssmlGender, naturalSampleRateHertz}'
