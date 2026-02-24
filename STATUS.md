# Social Effects - Project Status

## Current Status: ✅ Production Ready

**GitHub:** <https://github.com/Quasaur/social-effects>

The CLI tool is fully functional and generating videos from wisdombook.life RSS feeds. **Now integrated with Social Marketer for automated YouTube uploads!**

## Implementation Stack

| Component | Technology | Status |
|-----------|------------|--------|
| Video Composition | FFmpeg | ✅ Working |
| Text Overlays | CoreGraphics (AppKit) | ✅ Working |
| TTS Narration | Kokoro 82M (Liam voice) | ✅ Working |
| TTS Fallback | Apple AVSpeechSynthesizer | ✅ Available |
| Background Videos | Gemini Veo 3.1 / Pika (Fal.ai) | ✅ Working |
| RSS Integration | wisdombook.life feeds | ✅ Working |
| API Server | HTTP on port 5390 | ✅ Working |
| Social Marketer Integration | HTTP API | ✅ **LIVE** |

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
Text Overlay (CoreGraphics PNG with ornate borders)
    ↓
TTS Narration (Kokoro TTS - Liam voice)
    ↓
CTA Outro Audio (cached - "wisdom book dot life")
    ↓
FFmpeg Composition (loop background + overlay + mixed audio)
    ↓
Final MP4 (1080x1920, 9:16 vertical Shorts format)
```

## Integration with Social Marketer

Social Effects now runs as a **local API server** that Social Marketer calls for video generation:

```
Social Marketer (macOS app)
    ↓ HTTP POST /generate
Social Effects API (localhost:5390)
    ↓
Video Generation Pipeline
    ↓
MP4 File on External Drive
    ↓
YouTube Upload via YouTube Data API
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check - returns `{"status":"ok"}` |
| `/generate` | POST | Generate video from JSON payload |
| `/shutdown` | POST | Gracefully shutdown server |

### Generate Video Payload

```json
{
  "title": "TITLE",
  "content": "Quote or thought text here...",
  "content_type": "thought",
  "node_title": "Title_For_Filename",
  "source": "wisdombook.life",
  "ping_pong": false
}
```

**Field descriptions:**
- `title` - Display title (shown on video, e.g., "HEART OF THE KING")
- `content` - The quote/passage/thought text
- `content_type` - `"passage"`, `"thought"`, or `"quote"`
- `node_title` - Used for filename generation (sanitized to Initial_Caps_With_Underscores)
- `source` - For **passages**: Bible reference (e.g., "Proverbs 21:1"); for **quotes**: book name (e.g., "The Narrow Way"); for **thoughts**: empty (no attribution shown)
- `ping_pong` - Whether to use ping-pong background looping

**Source Attribution Display:**
| Content Type | Source Value | Video Attribution |
|--------------|--------------|-------------------|
| `quote` | Book name | `— Book Name` shown below content |
| `passage` | Bible reference | `— Proverbs 21:1` shown below content |
| `thought` | Empty / ignored | No attribution line (wisdombook.life in CTA outro is sufficient) |

## Key Commands

```bash
# Start API server (for Social Marketer integration)
swift run SocialEffects api-server

# Quick test from RSS
swift run SocialEffects test-video

# Generate with explicit content
swift run SocialEffects generate-video --title "Quote" --content "Text here"

# Generate AI backgrounds
swift run SocialEffects generate-backgrounds --test
```

## What's Working

- ✅ **Social Marketer Integration** - Automated video generation via HTTP API
- ✅ 14 ornate border styles (daily rotation)
- ✅ Voice caching by content hash
- ✅ Auto-rotation of background videos
- ✅ Background music mixing (ImmunityThemeFINAL.m4a)
- ✅ External drive fallback to local storage
- ✅ JSON output mode for programmatic use
- ✅ **YouTube Shorts format** (1080x1920 vertical)
- ✅ **Correct TTS pronunciation** - "wisdom book dot life"

## Recent Updates (February 2026)

- **API Server Mode**: Added HTTP API for Social Marketer integration
- **Kokoro TTS**: Replaced Apple TTS with Kokoro 82M for better quality
- **Debug Logging**: Added request/response logging for troubleshooting
- **CTA Fix**: Changed outro to say "dot" for correct URL pronunciation
- **Source Attribution**: Videos now display book name (quotes) or Bible reference (passages) below content; thoughts skip attribution

## Storage Locations

| Type | Primary | Fallback |
|------|---------|----------|
| Videos | `/Volumes/My Passport/social-media-content/social-effects/video/api/` | `~/output/` |
| Audio Cache | `/Volumes/My Passport/social-media-content/social-effects/audio/cache/` | `~/output/audio/cache/` |

## Future Enhancements

- [ ] More border styles
- [ ] Custom font support
- [ ] Batch video generation from RSS
- [x] **Integration with Social Marketer app** ✅ COMPLETE
