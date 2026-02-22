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

### Utilities (`Utils/`)
- `Paths.swift` - Centralized path constants and helpers (external drive, local fallback)
- `Hashing.swift` - SHA256 hashing utilities (shared across TTS caching)
- `BorderSelector.swift` - Daily border rotation logic
- `BackgroundSelector.swift` - Auto-rotation background video selection
- `FFmpegRenderer.swift` - FFmpeg video composition with `VideoTiming` constants

## External Dependencies

- **FFmpeg** - Required at `/opt/homebrew/bin/ffmpeg` or `/usr/local/bin/ffmpeg` for video encoding
- **Shotcut** (optional) - `/Applications/Shotcut.app` provides MLT libraries (currently not used; AVFoundation approach active)

## Output Paths

- Local backgrounds: `output/backgrounds/`
- RSS videos: `output/rss_videos/` (fallback when external drive unavailable)
- Audio cache: `output/cache/audio/`
- External storage: `/Volumes/My Passport/social-media-content/social-effects/`

### ⚠️ CRITICAL: Video File Organization Rule

**All test/debug videos MUST be saved to `/test/` folder. Only production-ready videos go to `/api/`.**

| Folder | Purpose | Examples |
|--------|---------|----------|
| `video/api/` | Production videos for social media posting | RSS-generated content, scheduled posts |
| `video/test/` | Test/debug videos (NEVER post these) | `test_rss_video.mp4`, `thought-Test_*.mp4`, `thought-Debug_*.mp4` |

**When generating test videos:**
```bash
# CLI test command outputs to test folder
swift run SocialEffects test-video  # → video/test/test_rss_video.mp4

# Manual test videos should use test naming convention
swift run SocialEffects generate-video --title "Test" --content "..."  # → video/test/
```

**Violation of this rule causes test content to be accidentally posted to social media platforms.**

## Standard Production Video Pattern

**ALL uploaded videos MUST follow this exact pattern:**

```
0-3s:   Black screen with background music
3-7s:   Background video fades in (4 seconds)
7-8s:   1-second delay (background visible, text not yet showing)
8-12s:  Text overlay and border fade in (4 seconds)
12s:    Narration starts (text is fully visible)
End:    CTA outro: "For more wisdom treasure, visit Wisdom Book dot Life!"
```

**Technical Settings:**
- **Ping-pong background:** ENABLED (forward-reverse-forward seamless loop)
- **Background source:** External drive (`/Volumes/My Passport/.../backgrounds/`)
- **Minimum duration:** 15 seconds (extends if audio is longer)
- **Outro text:** "For more wisdom treasure, visit Wisdom Book dot Life!"

**Example Reference Video:**
```
/Volumes/My Passport/social-media-content/social-effects/video/test/test_rss_video.mp4
Duration: 23.6s | Background: 04_neon_tunnel_flight.mp4 | Border: classic-scroll
```

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
let borderStyle = BorderSelector.dailyBorder()
```

### Video Timing Constants
Standard production timing is defined in `VideoTiming` enum (FFmpegRenderer.swift):
```swift
VideoTiming.bgFadeStart      // 3 seconds
VideoTiming.bgFadeDuration   // 4 seconds
VideoTiming.textFadeStart    // 8 seconds
VideoTiming.textFadeDuration // 4 seconds
VideoTiming.narrationStart   // 12 seconds
VideoTiming.minDuration      // 15.0 seconds
```

### Voice Caching
TTS output is cached by SHA256 hash of content text to avoid regenerating identical audio.
Uses centralized `Hashing.sha256()` utility from `Utils/Hashing.swift`.
