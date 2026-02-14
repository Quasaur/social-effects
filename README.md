# Social Effects

Experimental app for generating professional-quality 15-30 second videos using MLT Framework (Shotcut's video library).

## Goal

Create videos that "pop" with cinematic effects for Social Marketer integration.

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
