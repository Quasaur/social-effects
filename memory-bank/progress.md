# Progress: Social Effects

## Current Status: ✅ Production Ready

The CLI tool is fully functional and generating professional-quality videos from wisdombook.life RSS feeds.

---

## What's Working

### Core Features
- [x] RSS feed integration (wisdombook.life)
- [x] Automated video generation pipeline
- [x] 1080x1920 vertical MP4 output
- [x] FFmpeg-based video composition
- [x] 10 ornate border styles with daily rotation
- [x] Cinematic timing (black screen → fades → narration)
- [x] Background music mixing at 14% volume
- [x] JSON output mode for programmatic use

### TTS System
- [x] Kokoro TTS integration (am_liam voice)
- [x] CTA outro generation with Kokoro
- [x] Audio merging (narration + CTA + music)
- [x] Voice quality consistent and high-quality

### AI Video Generation
- [x] Gemini Veo 3.1 API integration
- [x] Pika/Fal.ai API integration
- [x] 10 curated prompt templates
- [x] Async polling for generation status
- [x] Auto-download and save to backgrounds folder

### Graphics
- [x] CoreGraphics text overlay generation
- [x] 10 ornate border styles:
  - Art Deco, Classic Scroll, Sacred Geometry, Celtic Knot, Fleur-de-Lis
  - Baroque, Victorian, Golden Vine, Stained Glass, Modern Glow
- [x] Transparent PNG output for overlay
- [x] Scrim/gradient for text readability

### Infrastructure
- [x] Command-line interface with multiple commands
- [x] Environment variable configuration (.env support)
- [x] External drive integration with local fallback
- [x] Audio caching by content hash
- [x] RSS item caching for testing
- [x] HTTP API server (optional)

---

## What's Left to Build

### Short Term (Next 1-2 Weeks)
- [ ] Batch video generation from RSS (multiple items)
- [ ] Additional border styles beyond current 10
- [ ] Custom font support
- [ ] Voice selection (multiple Kokoro voices)
- [ ] Video thumbnail generation

### Medium Term (Next 1-2 Months)
- [ ] Social Marketer app integration
- [ ] Web UI for non-technical users
- [ ] Analytics/usage tracking
- [ ] More background video templates (20+)
- [ ] Alternative aspect ratios (1:1, 16:9)

### Long Term (Future)
- [ ] Cloud deployment option
- [ ] Additional AI providers (Runway, Kling, etc.)
- [ ] Custom prompt builder
- [ ] A/B testing for content performance
- [ ] Auto-posting to social platforms

---

## Known Issues

### Current Limitations
| Issue | Impact | Workaround |
|-------|--------|------------|
| FFmpeg stderr buffer can deadlock | Rare crash during long renders | Async reading implemented |
| External drive required for production | Local storage fallback available | Use `--output` flag |
| Gemini API quota (5/day) | Limits background generation | Use Pika/Fal.ai as backup |
| RSS fetch occasionally fails | Requires manual retry | Use `--fresh` flag to retry |
| No batch generation yet | One video at a time | Script multiple CLI calls |

### Technical Debt
- Legacy VideoRenderer.swift (AVAssetWriter) not actively used
- Some ElevenLabs/Google Cloud TTS code (fallbacks, rarely used)
- Blender scripts folder (experimental, unused)
- MLT integration abandoned but header files remain

---

## Evolution of Project Decisions

### Architecture Evolution
1. **Initial Approach**: MLT Framework (Shotcut libraries)
   - Complex C bridging required
   - Crashed at runtime
   - **Decision**: Abandoned

2. **Second Approach**: AVAssetWriter
   - Swift-native but limited effects
   - Complex filter implementation
   - **Decision**: Replaced by FFmpeg

3. **Current Approach**: FFmpeg command-line
   - Reliable, well-documented
   - Full filter_complex support
   - **Decision**: Production standard

### TTS Evolution
1. **Initial**: Apple Jamie Premium voice
   - Required macOS voice installation
   - Quality varied by system
   - **Decision**: Replaced

2. **Second**: ElevenLabs API
   - High quality but expensive
   - Network dependency
   - **Decision**: Fallback only

3. **Current**: Kokoro TTS (am_liam)
   - Consistent high quality
   - Local processing option
   - **Decision**: Primary voice

### Content Source Evolution
1. **Initial**: Hardcoded demo content
   - Limited variety
   - Manual updates required
   - **Decision**: Replaced

2. **Current**: wisdombook.life RSS feeds
   - Fresh content daily
   - Multiple feed options
   - **Decision**: Production standard

---

## Performance Metrics

### Video Generation Speed
- Background generation (AI): 3-5 minutes per video
- FFmpeg composition: 10-30 seconds
- Total pipeline (cached backgrounds): <1 minute

### Quality Metrics
- Output resolution: 1080x1920 (Full HD vertical)
- Audio: 192kbps AAC
- Video: H.264, CRF 23
- File size: ~5-15MB per video

### Reliability
- Success rate: >95% for RSS → video pipeline
- TTS success: ~99% with Kokoro
- Background generation: Depends on API availability

---

## Milestones Achieved

| Date | Milestone |
|------|-----------|
| Initial | Project started with MLT Framework |
| Phase 1 | Basic video generation working |
| Phase 2 | FFmpeg migration complete |
| Phase 3 | RSS integration added |
| Phase 4 | Kokoro TTS integrated |
| Current | Production-ready CLI tool |

---

## Next Milestone
**Social Marketer Integration**: Connect video generation to automated posting pipeline for hands-free content creation.
