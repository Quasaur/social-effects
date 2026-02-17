# Shotcut Library Map

## Executive Summary

Shotcut exports the **MLT Framework (v7.33.0)** - a powerful multimedia framework with 25 plugin modules for video/audio processing.

**Architecture:**

- Core: 2 main libraries (C and C++ APIs)
- Plugins: 25 modules providing hundreds of effects
- Dependencies: FFmpeg, OpenCV, Qt6, Frei0r

## Core Libraries

### 1. libmlt-7.7.dylib

- **Size:** 683 KB
- **Path:** `/Applications/Shotcut.app/Contents/Frameworks/libmlt-7.7.dylib`
- **Type:** Universal binary (x86_64 + arm64)
- **Version:** 7.33.0
- **Language:** C API
- **Purpose:** Core MLT framework - handles producers, filters, transitions, consumers

**Key Functions:**

- `mlt_factory_init()` - Initialize MLT framework
- `mlt_factory_producer()` - Create video/audio producers
- `mlt_factory_filter()` - Create effects/filters
- `mlt_factory_transition()` - Create transitions between clips
- `mlt_factory_consumer()` - Create output consumers (encoders)
- `mlt_repository_*()` - Query available plugins/effects

### 2. libmlt++-7.7.dylib

- **Size:** 584 KB
- **Path:** `/Applications/Shotcut.app/Contents/Frameworks/libmlt++-7.7.dylib`
- **Type:** Universal binary (x86_64 + arm64)
- **Version:** 7.33.0
- **Language:** C++ API
- **Purpose:** C++ wrapper around core MLT for easier usage

## Plugin Modules (25 Total)

All located in: `/Applications/Shotcut.app/Contents/PlugIns/mlt/`

### Core Functionality

#### libmltcore.so (550 KB)

- Essential MLT services
- Basic producers, filters, transitions
- Core data structures

#### libmltavformat.so (444 KB)

- FFmpeg integration
- Video/audio encoding and decoding
- Format support (MP4, MOV, etc.)
- Depends on: libavcodec, libavformat, libswscale

### Video Effects

#### libmltfrei0r.so (205 KB)

- **Frei0r plugin host**
- Provides access to 100+ Frei0r effects
- Popular effects: blur, glow, color correction, distortions

#### libmltopencv.so (172 KB)

- **OpenCV integration**
- Computer vision effects
- Face detection, tracking, stabilization
- Depends on: libopencv_core, libopencv_imgproc, libopencv_video, libopencv_tracking

#### libmltmovit.so (329 KB)

- **GPU-accelerated effects**
- High-performance filters using OpenGL
- Color correction, scaling, mixing

#### libmltvidstab.so (139 KB)

- **Video stabilization**
- Shaky footage correction
- Motion analysis and smoothing

#### libmltoldfilm.so (138 KB)

- **Old film effects**
- Grain, scratches, dust
- Vintage/retro looks

### Transitions & Compositing

#### libmltplus.so (527 KB)

- **Advanced transitions**
- Wipes, slides, zooms
- Compositing operations

#### libmltplusgpl.so (298 KB)

- **GPL-licensed transitions**
- Additional transition effects
- Special compositing modes

### Graphics & Animation

#### libmltqt6.so (848 KB)

- **Qt6 integration**
- Text rendering
- Graphics overlays
- UI element rendering

#### libmltglaxnimate-qt6.so (11 MB)

- **2D animation support**
- Lottie/vector animation
- Glaxnimate integration

#### libmltkdenlive.so (138 KB)

- **Kdenlive-specific effects**
- Waveform generators
- Specialized transitions

### Audio Processing

#### libmltresample.so (136 KB)

- **Audio resampling**
- Sample rate conversion
- Channel mixing

#### libmltsox.so (135 KB)

- **SoX audio effects**
- Equalizer, reverb, echo
- Audio filters

#### libmltjackrack.so (286 KB)

- **JACK audio integration**
- Real-time audio processing
- LADSPA plugin host

#### libmltladspa.so (214 KB)

- **LADSPA plugin support**
- Audio effect plugins
- Filters and processors

#### libmltrubberband.so (136 KB)

- **Time-stretching**
- Pitch shifting
- Tempo adjustment

#### libmltvorbis.so (135 KB)

- **Vorbis audio codec**
- OGG encoding/decoding

#### libmltspatialaudio.so (140 KB)

- **Spatial audio**
- Surround sound processing

### Audio/Video Output

#### libmltrtaudio.so (357 KB)

- **Real-time audio**
- Audio playback
- Device management

#### libmltsdl2.so (172 KB)

- **SDL2 integration**
- Video playback and preview
- Real-time rendering

#### libmltxine.so (202 KB)

- **Xine multimedia engine**
- Alternative playback backend

### Utilities

#### libmltnormalize.so (135 KB)

- **Audio normalization**
- Level adjustment
- Loudness control

#### libmltdecklink.so (234 KB)

- **Blackmagic DeckLink**
- Professional video I/O cards
- Broadcast hardware support

#### libmltxml.so (229 KB)

- **XML project files**
- Save/load MLT projects
- Shotcut project format

## Supporting Libraries

### FFmpeg Suite

- **libavcodec.62.dylib** (29 MB) - Video/audio codecs
- **libavformat.62.dylib** (4.9 MB) - Container formats
- **libswscale.9.dylib** (2.1 MB) - Image scaling/conversion

### OpenCV Suite

- **libopencv_core.413.dylib** (7.2 MB) - Core functionality
- **libopencv_imgproc.413.dylib** (8.3 MB) - Image processing
- **libopencv_video.413.dylib** (1.0 MB) - Video analysis
- **libopencv_tracking.413.dylib** (4.0 MB) - Object tracking
- **libopencv_plot.413.dylib** (154 KB) - Visualization

### Qt6 Framework

- Multiple Qt6 libraries (100+ MB total)
- QtCore, QtGui, QtQuick, QtMultimedia, etc.

## Usage from Swift

### Challenge: C/C++ Bridging Required

MLT is a C/C++ library. To use from Swift, you need:

1. **C Bridging Header** - Expose MLT C functions to Swift
2. **Module Map** - Define the module structure
3. **Type Conversions** - Map C types to Swift types

### Basic Integration Pattern

```swift
// 1. Initialize MLT
mlt_factory_init(nil)

// 2. Load repository (discovers all plugins)
let repo = mlt_factory_repository()

// 3. List available effects
// (requires iterating through repository)

// 4. Create a producer (video source)
let producer = mlt_factory_producer(repo, "avformat", "input.mp4")

// 5. Apply filters/effects
let filter = mlt_factory_filter(repo, "frei0r.glow", nil)
mlt_producer_attach(producer, filter)

// 6. Render output
let consumer = mlt_factory_consumer(repo, "avformat", "output.mp4")
mlt_consumer_connect(consumer, producer)
mlt_consumer_start(consumer)
```

## Next Steps

### Option A: MLT Integration (Complex)

1. Create C bridging header
2. Create module map
3. Write Swift wrapper classes
4. Test basic video generation

### Option B: AVFoundation (Recommended)

1. Native Swift/macOS
2. No C bridging needed
3. Proven effects already designed
4. Simpler integration

### Option C: Command-Line (Simplest)

1. Generate MLT XML scripts
2. Use `melt` command-line tool
3. Process outputs in Swift
