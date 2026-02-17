#!/bin/bash

# Test RSS Video Generation CLI

echo "🚀 Testing RSS Video Generation..."

swift run SocialEffects generate-video \
  --title "Test Wisdom" \
  --content "The only true wisdom is in knowing you know nothing." \
  --source "Socrates" \
  --background "auto" \
  --border "gold"

echo "✅ Test Complete"
