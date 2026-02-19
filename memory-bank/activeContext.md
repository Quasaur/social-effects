# Active Context: Social Effects

## Current Status
✅ **Production Ready** - CLI tool is fully functional and generating videos

## Recent Changes

### Latest Updates
- **Shutdown Endpoint**: Added `POST /shutdown` API endpoint for graceful shutdown
- **Codebase Cleanup**: Removed 2,300+ lines of obsolete code (unused TTS services, MLT, Blender scripts)
- **Kokoro TTS Integration**: Primary voice provider using `am_liam` voice
- **CTA Outro**: Now uses Kokoro TTS (am_liam) for consistent voice branding
- **Video Pipeline**: Stabilized FFmpeg-based composition
- **Audio Caching**: Cleared before each generation to ensure fresh, high-quality TTS
- **Memory Bank**: Initialized with 6 core documentation files

### Technical Decisions
- MLT Framework abandoned in favor of FFmpeg + AVFoundation
- Apple Jamie voice replaced by Kokoro for better quality/consistency
- Ping-pong background mode added for seamless looping
- Client (social-marketer) can now shut down service via API

## Current Work Focus

### Immediate Priorities
1. **Reliability**: Ensure consistent video generation without failures
2. **Voice Quality**: Maintain high TTS output with Kokoro
3. **Performance**: Optimize FFmpeg filter chains for faster rendering

### Active Development Areas
- Cinematic timing refinements (black screen → fade in → narration)
- Background video management and rotation
- Error handling and logging improvements

## Next Steps

### Short Term
- [ ] Monitor Kokoro TTS performance and reliability
- [ ] Add more border styles beyond current 10
- [ ] Implement batch generation from RSS feeds

### Medium Term
- [ ] Social Marketer app integration
- [ ] Custom font support
- [ ] Analytics and usage tracking

### Long Term
- [ ] Web UI for non-technical users
- [ ] Cloud deployment option
- [ ] Additional AI video providers

## Important Patterns & Preferences

### Code Organization
- Services pattern for external APIs (Gemini, Pika, Kokoro)
- Graphics generation isolated in dedicated classes
- FFmpeg filter chains built dynamically based on available assets

### Configuration
- Environment variables for API keys (`.env` file supported)
- Shared drive path for production assets
- Local fallback when external storage unavailable

### Asset Management
- Background videos stored in `output/backgrounds/`
- Cached RSS items in `output/cache/`
- Generated videos in `output/rss_videos/` (local) or shared drive

## Known Issues
- FFmpeg process can deadlock if stderr buffer fills (mitigated with async reading)
- External drive availability affects output location
- RSS fetch failures require manual retry

## Learnings
- FFmpeg filter_complex is more reliable than MLT for this use case
- WAV → M4A conversion handled automatically by AudioMerger
- Cinematic timing requires careful synchronization of fade delays and audio start
