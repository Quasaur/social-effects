# Social Effects

Experimental app for generating professional-quality 15-30 second videos using MLT Framework (Shotcut's video library).

## Goal

Create videos that "pop" with cinematic effects for Social Marketer integration.

## ⚠️ CRITICAL RULE: Video File Organization

**Test videos MUST be saved to `video/test/` - NEVER to `video/api/`**

| Folder | Purpose | Risk |
|--------|---------|------|
| `video/api/` | Production videos for social media posting | ⚠️ Social Marketer auto-posts these |
| `video/test/` | Test/debug videos | ✅ Safe for testing |

**Why this matters:** Social Marketer scans `video/api/` and will automatically post any video it finds there. Test videos (with names like `thought-Test_*.mp4`) in this folder will be accidentally published.

**Test command outputs to correct folder:**
```bash
swift run SocialEffects test-video  # → video/test/test_rss_video.mp4
```

## Tech Stack

- **Swift** - Main language
- **MLT Framework** - Professional video effects (via Shotcut)
- **AVFoundation** - Video I/O
- **CoreGraphics** - Graphics rendering

## MLT Integration

This app links to Shotcut's MLT libraries:

- `/Applications/Shotcut.app/Contents/Frameworks/libmlt-7.7.dylib`
- `/Applications/Shotcut.app/Contents/PlugIns/mlt/` (effects plugins)

## Build

```bash
swift build
swift run
```

## Status

🚧 Experimental - Not production ready
