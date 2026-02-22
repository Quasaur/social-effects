# Shared External Storage Configuration

## Location

**My Passport SSD:** `/Volumes/My Passport/social-media-content/`

## Folder Structure

```
/Volumes/My Passport/social-media-content/
│
├── social-effects/          # Social Effects App (video rendering)
│   ├── audio/              # Voice narrations from ElevenLabs (MP3)
│   ├── video/              # Final rendered videos (MP4)
│   │   ├── api/            # ⚠️ PRODUCTION VIDEOS ONLY - for social media posting
│   │   └── test/           # ⚠️ TEST VIDEOS - never post these
│   └── graphics/           # Pre-rendered text overlays (PNG)
│
└── social-marketer/         # Social Marketer App (content management)
    ├── thoughts/           # Exported Thoughts content
    ├── quotes/             # Exported Quotes content
    ├── passages/           # Exported Passages content
    ├── images/             # Generated graphics (for posts)
    └── videos/             # Final videos ready to post
```

### ⚠️ CRITICAL RULE: Video File Organization

**TEST videos must NEVER be saved to `video/api/` - that folder is for production content only.**

| Folder | Purpose | Naming Convention |
|--------|---------|-------------------|
| `video/api/` | Production videos ready for social media posting | `thought-{Title}-{timestamp}.mp4`, `passage-{Title}-{timestamp}.mp4` |
| `video/test/` | Test/debug/development videos | `test_*.mp4`, `thought-Test_*.mp4`, `thought-Debug_*.mp4`, `thought-Api_Test-*.mp4` |

**Why this matters:** Social Marketer scans `video/api/` for content to post. Test videos in that folder will be accidentally published.

**Correct workflow:**
```bash
# Production video (goes to video/api/)
swift run SocialEffects generate-video --title "Wisdom Title" --content "..."

# Test video (explicitly use test naming or test command)
swift run SocialEffects test-video  # automatically saves to video/test/
```

## Integration Points

### Social Marketer → Social Effects Workflow

1. **User creates Thought** in social-marketer
2. **Social Marketer exports** to `/Volumes/My Passport/social-media-content/social-marketer/thoughts/`
3. **Social Effects reads** from that location
4. **Generates voice** via ElevenLabs API
5. **Saves audio** to `/Volumes/My Passport/social-media-content/social-effects/audio/`
6. **Renders video** with MLT
7. **Saves video** to `/Volumes/My Passport/social-media-content/social-effects/video/`
8. **Social Marketer reads** final video for posting

### Path Configuration

**social-effects uses centralized path management in `Utils/Paths.swift`:**

```swift
// Base paths
Paths.sharedDrivePath           // /Volumes/My Passport/social-media-content/social-effects
Paths.localOutputPath           // output/

// Audio cache with automatic fallback
let audioCacheDir = Paths.audioCacheDirectory()

// Video output with automatic fallback
let videoOutputDir = Paths.videoOutputDirectory()

// Specific path constants
Paths.externalAudioCachePath    // .../social-effects/audio/cache
Paths.localAudioCachePath       // output/cache/audio
Paths.externalVideoPath         // .../social-effects/video
Paths.localVideoPath            // output/rss_videos
Paths.testVideoPath             // .../social-effects/video/test/test_rss_video.mp4
```

**For other integrations:**

```swift
let exportPath = "\(Paths.sharedDrivePath)/social-marketer/thoughts/"
let finalVideosPath = Paths.externalVideoPath
```

## Benefits

✅ **Centralized storage** - All social media assets in one place  
✅ **Cross-app sharing** - Both apps access the same content  
✅ **Disk space savings** - Keeps main SSD free  
✅ **Easy backups** - One folder to backup  
✅ **Organized** - Clear separation by app and content type  

## Capacity Planning

**Current usage:** 1 MB (10 audio files)

**Projected at scale:**

- 1,000 videos = ~1 GB total (audio + video + graphics)
- 10,000 videos = ~10 GB total
- My Passport: 1.7 TB free = room for ~170,000 videos

## Fallback Strategy

If My Passport is not mounted, apps automatically fall back to local storage:

- **social-effects:** `output/` (local to project directory)
- **social-marketer:** `~/Developer/social-marketer/exports/`

The `Paths` utility automatically handles this fallback:

```swift
// Returns external path if available, local otherwise
let cacheDir = Paths.audioCacheDirectory()
let videoDir = Paths.videoOutputDirectory()

// Check external drive availability
let isExternalAvailable = FileManager.default.isWritableFile(atPath: Paths.sharedDrivePath)
```
