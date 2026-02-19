# Social Effects - Project Status

## Current Status: ✅ Production Ready

**GitHub:** <https://github.com/Quasaur/social-effects>

The CLI tool is fully functional and generating videos from wisdombook.life RSS feeds.

## Implementation Stack

| Component | Technology | Status |
|-----------|------------|--------|
| Video Composition | FFmpeg | ✅ Working |
| Text Overlays | CoreGraphics (AppKit) | ✅ Working |
| TTS Narration | AVSpeechSynthesizer (Jamie Premium) | ✅ Working |
| TTS Fallback | ElevenLabs API | ✅ Available |
| Background Videos | Gemini Veo 3.1 / Pika (Fal.ai) | ✅ Working |
| RSS Integration | wisdombook.life feeds | ✅ Working |

## Architecture Decision

**MLT Framework was abandoned** in favor of FFmpeg + AVFoundation:

- MLT required complex C bridging that crashed at runtime
- FFmpeg provides equivalent compositing via command-line
- AVFoundation handles TTS natively without external dependencies
- Result: Simpler, more reliable, fully working

## Video Pipeline

```
RSS Feed (wisdombook.life)
    ↓
Text Overlay (CoreGraphics PNG)
    ↓
TTS Narration (Apple Jamie via AVSpeechSynthesizer.write())
    ↓
CTA Outro Audio (cached)
    ↓
FFmpeg Composition (loop background + overlay + mixed audio)
    ↓
Final MP4 (1080x1920, 9:16 vertical)
```

## Key Commands

```bash
# Quick test from RSS
swift run SocialEffects test-video

# Generate with explicit content
swift run SocialEffects generate-video --title "Quote" --content "Text here"

# Generate AI backgrounds
swift run SocialEffects generate-backgrounds --test
```

## What's Working

- ✅ 10 ornate border styles (daily rotation)
- ✅ Voice caching by content hash
- ✅ Auto-rotation of background videos
- ✅ Background music mixing (ImmunityThemeFINAL.m4a)
- ✅ External drive fallback to local storage
- ✅ JSON output mode for programmatic use

## Future Enhancements

- [ ] More border styles
- [ ] Custom font support
- [ ] Batch video generation from RSS
- [ ] Integration with Social Marketer app
