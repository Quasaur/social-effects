#!/bin/bash
# This script tests Google Cloud service account authentication for TTS
# Requires: jq, openssl, base64, curl

KEY_FILE="book-of-wisdom-482515-69d6b2d0ae77.json"

if [ ! -f "$KEY_FILE" ]; then
  echo "Service account JSON not found: $KEY_FILE"
  exit 1
fi

# Extract fields from JSON
CLIENT_EMAIL=$(jq -r .client_email "$KEY_FILE")

# Extract private key as a PEM block
PRIVATE_KEY=$(jq -r .private_key "$KEY_FILE")
echo "-----BEGIN PRIVATE KEY-----" > /tmp/gcloud_sa_key.pem
echo "$PRIVATE_KEY" | sed '/^-----/d' >> /tmp/gcloud_sa_key.pem
echo "-----END PRIVATE KEY-----" >> /tmp/gcloud_sa_key.pem
echo "[DEBUG] Extracted private key (first 5 lines):"
head -n 5 /tmp/gcloud_sa_key.pem

# JWT header
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
NOW=$(date +%s)
EXP=$((NOW+3600))
SCOPE="https://www.googleapis.com/auth/cloud-platform"
CLAIMS=$(printf '{"iss":"%s","scope":"%s","aud":"https://oauth2.googleapis.com/token","exp":%d,"iat":%d}' "$CLIENT_EMAIL" "$SCOPE" "$EXP" "$NOW")
CLAIMS_B64=$(echo -n "$CLAIMS" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
JWT_UNSIGNED="$HEADER.$CLAIMS_B64"

echo "[DEBUG] JWT header: $HEADER"
echo "[DEBUG] JWT claims: $CLAIMS"
echo "[DEBUG] JWT unsigned: $JWT_UNSIGNED"

# Sign JWT
SIGNATURE=$(echo -n "$JWT_UNSIGNED" | openssl dgst -sha256 -sign /tmp/gcloud_sa_key.pem | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
JWT="$JWT_UNSIGNED.$SIGNATURE"

# Request token
echo "OAuth2 response:"
echo "$RESPONSE"
RESPONSE=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$JWT" \
  https://oauth2.googleapis.com/token)

echo "[DEBUG] OAuth2 response:"
echo "$RESPONSE"
