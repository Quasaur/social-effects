# Social Effects - CLI Service Guide

## Overview

Social Effects is a **command-line service** for generating professional stoic-aesthetic videos from text quotes. It combines:

- ElevenLabs voice narration (Donovan voice)
- MLT cinematic effects
- Core Graphics text rendering
- Automated video composition

## Installation

```bash
cd /Users/quasaur/Developer/social-effects
swift build -c release
sudo cp .build/release/social-effects /usr/local/bin/
```

## Commands

### 1. Generate Complete Video

```bash
social-effects generate \
  --text "True wisdom comes from questions" \
  --output "/path/to/output.mp4" \
  --effect "cross-dissolve" \
  --duration 15 \
  --api-key "sk_..."
```

**Options:**

- `--text` - Quote text to render
- `--output` - Output video file path
- `--effect` - Effect name (cross-dissolve, zoom, wipe, light-leaks, etc.)
- `--duration` - Video duration in seconds (default: 15)
- `--api-key` - ElevenLabs API key (optional if using existing audio)
- `--skip-voice` - Skip voice generation (use existing audio)
- `--audio-file` - Existing audio file path (required if --skip-voice)

### 2. Generate Voice Only

```bash
social-effects voice \
  --text "Courage is not the absence of fear" \
  --output "/path/to/audio.mp3" \
  --api-key "sk_..."
```

### 3. Batch Generate Videos

```bash
social-effects batch \
  --input "quotes.json" \
  --output-dir "/path/to/videos/" \
  --api-key "sk_..."
```

**quotes.json format:**

```json
[
  {
    "text": "True wisdom comes from questions",
    "effect": "cross-dissolve",
    "filename": "demo_01.mp4"
  },
  {
    "text": "Courage is not the absence of fear",
    "effect": "zoom",
    "filename": "demo_02.mp4"
  }
]
```

### 4. Test System Setup

```bash
social-effects test
```

Tests:

- My Passport SSD mount status
- MLT library availability
- Audio file storage
- System requirements

## Integration with Social Marketer

### From Swift Code

```swift
import Foundation

func generateVideo(quote: String, outputPath: String) async throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/social-effects")
    process.arguments = [
        "generate",
        "--text", quote,
        "--output", outputPath,
        "--effect", "cross-dissolve",
        "--api-key", ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
    ]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    try process.run()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        throw VideoGenerationError.failed(output)
    }
}
```

### From Python/Shell

```python
import subprocess

def generate_video(quote: str, output_path: str):
    result = subprocess.run([
        "/usr/local/bin/social-effects",
        "generate",
        "--text", quote,
        "--output", output_path,
        "--effect", "cross-dissolve",
        "--api-key", os.environ.get("ELEVENLABS_API_KEY", "")
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f"Video generation failed: {result.stderr}")
    
    return output_path
```

## Available Effects

1. **cross-dissolve** - Smooth fade transition
2. **zoom** - Zoom in/out effect
3. **wipe** - Directional wipe
4. **light-leaks** - Golden light sweep (Frei0r)
5. **particles** - Floating particles overlay
6. **circular-collapse** - Circular shrink outro
7. **blinds** - Venetian blinds transition

## Storage Paths

All files stored on My Passport SSD:

```
/Volumes/My Passport/social-media-content/
├── social-effects/
│   ├── audio/    # Voice narrations
│   ├── video/    # Final videos
│   └── graphics/ # Text overlays
```

## Environment Variables

```bash
export ELEVENLABS_API_KEY="sk_..."
export SOCIAL_EFFECTS_STORAGE="/Volumes/My Passport/social-media-content/social-effects"
```

## Error Codes

- `0` - Success
- `1` - General error
- `2` - Missing API key
- `3` - Storage not available
- `4` - MLT initialization failed
- `5` - Voice generation failed
- `6` - Video rendering failed

## Examples

### Quick Test

```bash
# Generate voice only
social-effects voice \
  --text "Hello world" \
  --output "test.mp3" \
  --api-key "sk_..."

# Test setup
social-effects test
```

### Production Workflow

```bash
# 1. Generate 10 demo videos
social-effects batch \
  --input demos.json \
  --output-dir "/Volumes/My Passport/social-media-content/social-effects/video/" \
  --api-key "$ELEVENLABS_API_KEY"

# 2. Verify outputs
ls -lh "/Volumes/My Passport/social-media-content/social-effects/video/"
```

## Performance

- Voice generation: ~2-3 seconds per quote
- Video rendering: ~5-10 seconds (15s video)
- Total: ~7-13 seconds per video
- Batch processing: ~10 videos/minute

## Troubleshooting

### "My Passport not found"

```bash
# Check mount
df -h | grep Passport

# Mount manually if needed
diskutil mount "My Passport"
```

### "MLT libraries not found"

```bash
# Verify Shotcut installation
ls -la /Applications/Shotcut.app/Contents/Frameworks/libmlt*
```

### "API key invalid"

```bash
# Test API key
curl -H "xi-api-key: sk_..." https://api.elevenlabs.io/v1/voices
```
