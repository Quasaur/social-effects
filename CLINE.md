# Cline Context Memory

## Project State

### Current Status: ✅ Production Ready

The CLI tool is fully functional and generating videos from wisdombook.life RSS feeds.

### Recent Changes
- Kokoro TTS integration (am_liam voice) for narration and CTA
- CTA outro audio now uses am_liam voice (Kokoro)
- Video generation pipeline stabilized with FFmpeg

### Important Notes
- CTA outro MUST use am_liam voice (Kokoro TTS)
- External drive output: `/Volumes/My Passport/social-media-content/social-effects/`
- Cached RSS items stored at: `output/cache/test_rss_item.json`
