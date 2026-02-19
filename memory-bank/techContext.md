# Technical Context: Social Effects

## Technology Stack

### Core Language
- **Swift 5.9+** - Primary development language
- **Concurrency**: async/await throughout
- **Package Manager**: Swift Package Manager

### Video & Audio
- **FFmpeg** - Video composition and encoding
  - Location: `/opt/homebrew/bin/ffmpeg` or `/usr/local/bin/ffmpeg`
  - Used for: compositing, filtering, encoding
- **AVFoundation** - TTS generation, asset inspection
  - `AVSpeechSynthesizer.write()` for audio file output
  - `AVURLAsset` for duration calculations

### Graphics
- **CoreGraphics** - Text overlay generation
  - `NSGraphicsContext` for rendering
  - Transparent PNG output for overlay

### External APIs
- **Gemini Veo 3.1** - AI video generation
  - Requires `GEMINI_API_KEY`
  - Async polling model for generation status
  - 9:16 vertical output

- **Pika via Fal.ai** - Alternative AI video generation
  - Requires `FAL_KEY`
  - Free tier: 80 credits/month
  - Fallback when Gemini quota exceeded

- **Kokoro TTS** - Primary text-to-speech
  - Default voice: `am_liam`
  - Outputs WAV format
  - Used for both narration and CTA

## Dependencies

### Swift Packages
```swift
// Package.swift dependencies
dependencies: [
    // External packages if any
]
```

### System Dependencies
- **FFmpeg** (required) - Install via Homebrew: `brew install ffmpeg`
- **Shotcut** (optional) - Originally for MLT, currently unused

### Python Scripts (Auxiliary)
- `scripts/kokoro_tts.py` - Kokoro TTS integration
- `scripts/compare_audio.py` - Audio quality comparison
- Various test scripts for voice evaluation

## Development Setup

### Environment Variables
Required in `.env` or shell:
```bash
GEMINI_API_KEY="your_gemini_key"      # For Gemini Veo
FAL_KEY="your_fal_key"                # For Pika/Fal.ai
ELEVEN_LABS_API_KEY="optional"        # Fallback TTS (rarely used)
```

### Build Commands
```bash
swift build                           # Debug build
swift build -c release               # Release build
swift run SocialEffects <command>    # Run CLI
```

### Testing
```bash
swift run SocialEffects test-api                    # Test Gemini connection
swift run SocialEffects test-video                  # Generate test video
swift run SocialEffects test-video --fresh          # Force RSS refetch
swift run SocialEffects test-video --feed thoughts  # Use specific feed
```

## Project Structure

```
Sources/SocialEffects/
├── SocialEffects.swift           # Main CLI entry point
├── GeminiVideoService.swift      # Gemini Veo API integration
├── PikaVideoService.swift        # Pika/Fal.ai integration
├── RSSFetcher.swift              # RSS feed parsing
├── PromptTemplates.swift         # AI video prompt templates
├── DotEnv.swift                  # Environment file loader
├── APIServer.swift               # HTTP API server (optional)
├── Audio/
│   ├── KokoroVoice.swift         # Kokoro TTS service
│   ├── AppleVoice.swift          # Apple TTS (legacy)
│   ├── ElevenLabsVoice.swift     # ElevenLabs fallback
│   ├── GoogleCloudTTS.swift      # Google Cloud TTS
│   ├── AudioMerger.swift         # Audio mixing
│   └── RSASigner.swift           # JWT signing for Google APIs
├── Graphics/
│   ├── TextGraphicsGenerator.swift  # Text overlay rendering
│   └── BorderStyles.swift        # Border style implementations
├── Rendering/
│   └── VideoRenderer.swift       # Legacy AVAssetWriter renderer
└── Demos/
    └── ThoughtContent.swift      # Demo content data

scripts/                          # Helper scripts
blender_scripts/                  # 3D background generators (unused)
docs/                             # Documentation
output/                           # Generated assets
  ├── backgrounds/                # AI-generated backgrounds
  ├── rss_videos/                 # Final video output (local)
  └── cache/                      # RSS cache, temp audio
```

## Output Paths

### Primary (External Drive)
```
/Volumes/My Passport/social-media-content/social-effects/
├── video/                        # Final MP4 outputs
├── audio/                        # Audio assets (CTA, music)
├── graphics/                     # Generated PNG overlays
├── music/                        # Background music
└── output/backgrounds/           # AI backgrounds
```

### Fallback (Local)
```
output/
├── rss_videos/                   # Videos when external unavailable
├── backgrounds/                  # Background videos
└── cache/                        # RSS cache, temp files
```

## Tool Usage Patterns

### FFmpeg Filter Complex
Dynamic filter chain building based on available assets:
- Black screen generation with `color` filter
- Background scaling and fade-in
- Text overlay with alpha fade
- Audio delay and mixing

### TTS Caching Strategy
- SHA256 hash of content text = cache key
- Cache cleared at start of each video generation
- WAV format preserved for FFmpeg compatibility

### Border Rotation
```swift
let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
let borderStyle = approvedBorders[(dayOfYear - 1) % approvedBorders.count]
```

## Constraints & Limitations

### API Quotas
- Gemini Veo: ~5 videos/day on free tier
- Fal.ai: 80 credits/month on free tier
- Kokoro: Local/self-hosted, no quota limits

### System Requirements
- macOS (uses AVFoundation, AppKit)
- FFmpeg installed
- External drive for production (optional but recommended)

### Performance
- Video generation: 3-5 minutes per background (AI generation)
- FFmpeg composition: 10-30 seconds
- RSS fetch: <1 second
