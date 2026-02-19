# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Social Effects is a macOS CLI tool for generating professional-quality 15-30 second videos with stoic aesthetics for social media. It combines AI-generated background videos, text-to-speech narration, and overlaid graphics into final video compositions.

## Build & Run

```bash
# Build
swift build

# Run CLI
swift run SocialEffects <command>

# Build for release
swift build -c release
```

## Key Commands

```bash
# Test video generation from wisdombook.life RSS
swift run SocialEffects test-video
swift run SocialEffects test-video --fresh --feed thoughts

# Generate video with explicit content
swift run SocialEffects generate-video --title "My Quote" --content "Be the change." --border gold

# Generate background videos using Gemini Veo
swift run SocialEffects generate-backgrounds --test
swift run SocialEffects generate-backgrounds --all

# Generate backgrounds using Pika/Fal.ai
swift run SocialEffects pika-generate --test

# Test API connection
swift run SocialEffects test-api

# View all commands
swift run SocialEffects help
```

## Environment Variables

Required in `.env` or shell environment:
- `GEMINI_API_KEY` - For Gemini Veo video generation
- `FAL_KEY` - For Pika video generation via Fal.ai (alternative to Gemini)
- `ELEVEN_LABS_API_KEY` - Optional: ElevenLabs TTS (fallback when Jamie Premium unavailable)

Apple's Jamie Premium voice is preferred for TTS and must be installed via System Settings → Accessibility → Spoken Content → System Voice.

## Architecture

### Entry Point
`Sources/SocialEffects/SocialEffects.swift` - Main CLI with command dispatcher. All commands are defined here with their argument parsing.

### Video Generation Services
- `GeminiVideoService.swift` - Gemini Veo 3.1 API integration (async polling model)
- `PikaVideoService.swift` - Pika via Fal.ai integration

### Audio Services (`Audio/`)
- `AppleVoice.swift` - Primary TTS using AVSpeechSynthesizer.write() (not the `say` command)
- `ElevenLabsVoice.swift` - Fallback TTS via ElevenLabs API
- `GoogleCloudTTS.swift` - Alternative Google Cloud TTS
- `AudioMerger.swift` - Merges narration + CTA audio

### Graphics (`Graphics/`)
- `TextGraphicsGenerator.swift` - Renders stoic-styled PNG overlays with CoreGraphics
- `BorderStyles.swift` - 10 ornate border style implementations

### Rendering
- `Rendering/VideoRenderer.swift` - AVAssetWriter-based video composition (legacy)
- Main video composition now uses FFmpeg directly (see `generateVideoFromRSS` in SocialEffects.swift)

### Templates
- `PromptTemplates.swift` - 10 curated AI video generation prompts (3 categories: Geometric Minimalist, Futuristic Kinetic, Abstract Fluid)
- `RSSFetcher.swift` - Minimal RSS parser for wisdombook.life feeds

### Supporting Files
- `DotEnv.swift` - Loads `.env` file into environment
- `Demos/ThoughtContent.swift` - Demo content data

## External Dependencies

- **FFmpeg** - Required at `/opt/homebrew/bin/ffmpeg` or `/usr/local/bin/ffmpeg` for video encoding
- **Shotcut** (optional) - `/Applications/Shotcut.app` provides MLT libraries (currently not used; AVFoundation approach active)

## Output Paths

- Local backgrounds: `output/backgrounds/`
- RSS videos: `output/rss_videos/` (fallback when external drive unavailable)
- Audio cache: `output/cache/audio/`
- External storage: `/Volumes/My Passport/social-media-content/social-effects/`

## Key Patterns

### Video Generation Pipeline (generateVideoFromRSS)
1. Select/auto-rotate background video
2. Generate text overlay PNG (transparent background with scrim)
3. Generate TTS narration (Apple Jamie preferred, cached by content hash)
4. Generate CTA outro audio
5. Merge audio tracks
6. Composite with FFmpeg: loop background + overlay graphic + mixed audio

### Border Style Rotation
Ornate borders rotate daily via day-of-year calculation:
```swift
let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
let borderStyle = approvedBorders[(dayOfYear - 1) % approvedBorders.count]
```

### Voice Caching
TTS output is cached by SHA256 hash of content text to avoid regenerating identical audio.
