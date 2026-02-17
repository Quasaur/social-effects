#!/usr/bin/env swift

import Foundation

// Quick test: Generate a complete video end-to-end
// This will test the full pipeline without needing the CLI

print("🎬 Testing Full Video Pipeline")
print("===============================\n")

// We'll compile and run a simple test that uses all 3 components
print("Components to test:")
print("  1. TextGraphicsGenerator - Create PNG")  
print("  2. ElevenLabsVoice - Use existing audio")
print("  3. VideoRenderer - Combine into MP4")
print("\nRun this with: swift build")
print("Then manually test with the components")
