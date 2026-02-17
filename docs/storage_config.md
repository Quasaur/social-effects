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
│   └── graphics/           # Pre-rendered text overlays (PNG)
│
└── social-marketer/         # Social Marketer App (content management)
    ├── thoughts/           # Exported Thoughts content
    ├── quotes/             # Exported Quotes content
    ├── passages/           # Exported Passages content
    ├── images/             # Generated graphics (for posts)
    └── videos/             # Final videos ready to post
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

### Configuration Updates Needed

**social-effects/Sources/.../ElevenLabsVoice.swift:**

```swift
let audioDir = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/audio")
```

**social-marketer (future integration):**

```swift
let exportPath = "/Volumes/My Passport/social-media-content/social-marketer/thoughts/"
let finalVideosPath = "/Volumes/My Passport/social-media-content/social-effects/video/"
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

If My Passport is not mounted, apps fall back to local storage:

- **social-effects:** `~/Developer/social-effects/output/`
- **social-marketer:** `~/Developer/social-marketer/exports/`

Apps should check mount status on startup and log warnings if external drive unavailable.
