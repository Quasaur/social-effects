# System Patterns: Social Effects

## Architecture Overview

Social Effects uses a modular service-oriented architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    SocialEffectsCLI                          │
│                    (Command Dispatcher)                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
┌───▼────┐      ┌───────▼───────┐    ┌──────▼──────┐
│ Video  │      │  Graphics     │    │   Audio     │
│Services│      │  Generator    │    │  Services   │
└───┬────┘      └───────┬───────┘    └──────┬──────┘
    │                   │                   │
    ▼                   ▼                   ▼
┌──────────┐      ┌──────────┐      ┌──────────┐
│GeminiVeo │      │Text      │      │KokoroTTS │
│Pika/Fal  │      │Graphics  │      │AudioMerge│
│          │      │Generator │      │          │
└──────────┘      └──────────┘      └──────────┘
                        │
                        ▼
                ┌──────────────┐
                │   FFmpeg     │
                │  Composition │
                └──────────────┘
```

## Key Design Patterns

### 1. Service Pattern
External APIs are encapsulated in service classes with consistent error handling:

```swift
// Example: GeminiVideoService
class GeminiVideoService {
    enum GeminiError: Error { case missingAPIKey, generationFailed }
    init() throws { /* validate API key */ }
    func generateAndDownload(...) async throws -> String
}
```

### 2. Template Pattern
Video generation prompts use a structured template system:

```swift
struct PromptTemplate {
    let id: Int
    let name: String
    let category: Category
    let prompt: String
}
```

### 3. Strategy Pattern
Border styles implement a strategy pattern for different visual treatments:

```swift
enum BorderStyle {
    case artDeco, classicScroll, sacredGeometry, celticKnot, ...
    // Each style has unique rendering logic
}
```

### 4. Pipeline Pattern
Video generation follows a fixed pipeline:

```
Content → Graphic Generation → TTS Generation → Audio Merge → FFmpeg Compose → Output
```

## Critical Implementation Paths

### Video Generation Pipeline (generateVideoFromRSS)

1. **Background Selection**
   - Auto-rotate based on timestamp % 10
   - Fallback chain: local → external → error

2. **Graphic Generation**
   - CoreGraphics rendering with ornate borders
   - Daily border rotation using day-of-year calculation
   - Transparent PNG output for overlay

3. **TTS Generation**
   - Primary: Kokoro TTS (am_liam voice)
   - Content hash-based caching (cleared per-run for quality)
   - WAV output for FFmpeg compatibility

4. **CTA Generation**
   - Separate Kokoro call for outro audio
   - Fixed CTA text with consistent voice

5. **Audio Merging**
   - Narration + CTA merged to M4A
   - Background music mixed at 14% volume

6. **FFmpeg Composition**
   - Filter_complex chains for:
     - Black screen intro (3s)
     - Background fade-in (4s starting at 3s)
     - Text overlay fade-in (2s starting at 7s)
     - Audio delay (9s for narration start)
   - Ping-pong mode for seamless background looping

## Component Relationships

### Dependencies
- `SocialEffectsCLI` → `GeminiVideoService`, `PikaVideoService`
- `SocialEffectsCLI` → `TextGraphicsGenerator`
- `SocialEffectsCLI` → `KokoroVoice`, `AudioMerger`
- `AudioMerger` → `AVFoundation`
- `TextGraphicsGenerator` → `CoreGraphics`

### Data Flow
1. RSS content parsed → `FeedItem` struct
2. FeedItem → graphic parameters + TTS text
3. Generated assets stored in temp directory
4. FFmpeg reads all inputs, writes final MP4
5. Temp files cleaned up on success

## Error Handling Strategy

### Service Initialization
- API keys validated at init, throw specific errors
- Graceful fallback when external drive unavailable

### Generation Pipeline
- Each step throws descriptive errors
- JSON output mode for programmatic error handling
- Non-zero exit codes for shell integration

### FFmpeg Specific
- Async stderr reading prevents deadlock
- Termination status checked explicitly
- Full error output captured for debugging

## State Management

### No Persistent State
- Stateless design: each run is independent
- Caching is opportunistic, not required
- RSS cache can be bypassed with --fresh flag

### Environment State
- `.env` file loaded at startup (doesn't overwrite shell vars)
- API keys must be present for respective services
- External drive presence affects output paths
