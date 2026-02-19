#!/bin/bash
# Extract the access token from the debug output file
# Usage: bash extract_token.sh /tmp/gcloud_token.json

FILE="$1"
grep -o '"access_token":"[^"]*"' "$FILE" | head -n1 | cut -d '"' -f4
