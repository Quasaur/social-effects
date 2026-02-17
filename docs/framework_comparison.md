# Video Effects Framework Comparison

## Executive Summary

For generating 15-30 second social media videos with "pop" effects, **AVFoundation + CoreImage** is the recommended approach.

| Framework | Complexity | Setup Time | Effects Available | Performance | Recommendation |
|-----------|-----------|------------|-------------------|-------------|----------------|
| **AVFoundation + CoreImage** | ⭐️ Low | ~1 week | 200+ | ⚡️ Native GPU | ✅ **BEST CHOICE** |
| iMovie/GarageBand APIs | ⭐️⭐️⭐️ Medium | ~2-3 weeks | Unknown (private) | ⚡️ Native | ⚠️ Not Public |
| MLT Framework (Shotcut) | ⭐️⭐️⭐️⭐️⭐️ Very High | ~4-6 weeks | 300+ filters, 70+ transitions | ⚡️ GPU | ⚠️ C Bridging Required |

---

## Option 1: AVFoundation + CoreImage ✅ RECOMMENDED

### Why This is the Best Choice

1. **Native macOS/Swift** - No C bridging, no external dependencies
2. **You already use it** - iMovie is built on AVFoundation
3. **Proven effects** - 200+ built-in CoreImage filters
4. **GPU-accelerated** - Fast rendering with Metal backend
5. **Great docs** - Extensive Apple Developer documentation

### Available Effects (Sample from 200+ Total)

#### Transitions

- **CIDissolveTransition** - Cross-dissolve
- **CISwipeTransition** - Directional wipe
- **CIFlashTransition** - Flash transition
- **CIBarsSwipeTransition** - Bars wipe
- **CICopyMachineTransition** - Copy machine effect
- **CIDisintegrateWithMaskTransition** - Particle disintegration
- **CIPageCurlTransition** - Page curl
- **CIRippleTransition** - Ripple effect

#### Stylizing Filters

- **CIBloom** - Glow/bloom effect (like light leaks)
- **CIGloom** - Hazy glow
- **CICrystallize** - Pixelated crystals
- **CIEdges** - Edge detection
- **CIPixellate** - Pixelation
- **CIPointillize** - Pointillism art effect
- **CIComicEffect** - Comic book style

#### Blur Effects

- **CIGaussianBlur** - Standard blur
- **CIMotionBlur** - Motion blur (directional)
- **CIZoomBlur** - Zoom blur
- **CIBoxBlur** - Fast box blur
- **CIDiscBlur** - Disc-shaped blur

#### Color Effects

- **CIPhotoEffectChrome** - Chrome effect
- **CIPhotoEffectFade** - Faded photo
- **CIPhotoEffectInstant** - Instant camera
- **CIPhotoEffectNoir** - Black & white noir
- **CIPhotoEffectProcess** - Process effect
- **CIPhotoEffectTonal** - Tonal effect
- **CISepiaTone** - Sepia tone
- **CIVignette** - Vignette darkening

#### Distortion Effects

- **CIBumpDistortion** - Bump effect
- **CIPinchDistortion** - Pinch effect
- **CITwirlDistortion** - Twirl/rotate effect
- **CICircleSplashDistortion** - Circle splash
- **CIGlassDistortion** - Glass distortion

### Implementation Example

```swift
import AVFoundation
import CoreImage

// 1. Load video
let asset = AVAsset(url: videoURL)

// 2. Create composition
let composition = AVMutableComposition()
composition.insertTimeRange(
    CMTimeRange(start: .zero, duration: asset.duration),
    of: asset, at: .zero
)

// 3. Apply filter
let filter = CIFilter(name: "CIBloom")!
filter.setValue(10.0, forKey: kCIInputIntensityKey)

let videoComposition = AVMutableVideoComposition(asset: composition) { request in
    let source = request.sourceImage.clampedToExtent()
    filter.setValue(source, forKey: kCIInputImageKey)
    let output = filter.outputImage!
    request.finish(with: output, context: nil)
}

// 4. Export
let exporter = AVAssetExportSession(
    asset: composition,
    presetName: AVAssetExportPreset1920x1080
)
exporter.videoComposition = videoComposition
exporter.outputURL = outputURL
exporter.exportAsynchronously { /* ... */ }
```

### Resources

- [Apple CoreImage Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html)
- [AVFoundation Programming Guide](https://developer.apple.com/documentation/avfoundation)
- [CoreImage Tutorial (Kodeco)](https://www.kodeco.com/16328261-core-image-tutorial-getting-started)

---

## Option 2: iMovie/GarageBand APIs ⚠️ NOT RECOMMENDED

### Analysis

**GarageBand** has extensive audio frameworks:

- `MAAudioEngine.framework`
- `MAAudioUnitSupport.framework`
- `MAMusicAnalysis.framework`
- 30+ music/audio frameworks

**iMovie** frameworks are **not found** in `/Applications/iMovie.app` - it may use:

- Private frameworks (not accessible)
- System frameworks (AVFoundation)
- Cloud-based rendering

### Issues

1. **No public API** - These are private frameworks
2. **Apple restrictions** - Likely violates App Store guidelines
3. **Instability** - Private APIs can change without notice
4. **GarageBand is audio-focused** - Not useful for video effects

### Verdict

❌ **Not feasible for video generation**

---

## Option 3: MLT Framework (Shotcut) ⚠️ COMPLEX

### What is MLT?

MLT (Media Lovin' Toolkit) is a professional open-source multimedia framework used by:

- **Shotcut** (video editor)
- **Kdenlive** (Linux video editor)
- **Flowblade** (Python-based editor)

### Available Effects

#### Filters (300+ Total)

Via `mltframework.org/plugins/PluginsFilters/`:

**FFmpeg Filters** (via `avfilter.*` - 200+ filters):

- Color correction (curves, levels, hue/saturation)
- Blur, sharpen, denoise
- Chromakey, lumakey
- Distortion effects
- Vintage effects (film grain, vignette)

**Frei0r Filters** (100+ effects):

- Glow, bloom, light leaks
- Lens flares
- Distortions
- Color manipulation
- Kaleidoscope effects

**OpenCV Filters**:

- Face detection
- Motion tracking
- Stabilization
- Object tracking

**Qt6 Filters**:

- Text rendering
- Graphics overlays

#### Transitions (70+ Total)

Via `mltframework.org/plugins/PluginsTransitions/`:

- Dissolve, fade
- Wipes (all directions)
- 3D effects
- Particle effects
- Custom compositing

### Architecture

```
Your Swift App
    ↓ [C Bridging Header Required]
libmlt-7.7.dylib (C API)
    ↓
25 Plugin Modules (.so files)
    ↓
FFmpeg, OpenCV, Qt6, Frei0r
```

### Why It's Complex

1. **C Bridging Required**
   - MLT is C/C++, not Swift
   - Need bridging header + module map
   - Type conversion overhead

2. **Large Dependencies**
   - FFmpeg suite (~40 MB)
   - OpenCV (~20 MB)
   - Qt6 frameworks (~100 MB)

3. **Setup Complexity**
   - Plugin discovery at runtime
   - Repository initialization
   - Manual memory management (C pointers)

4. **Distribution Issues**
   - Cannot ship Shotcut.app with your app
   - Must bundle MLT separately
   - License compliance (LGPL)

### Implementation Example

```swift
// 1. Bridging header required
// mlt-bridge.h:
// #include <mlt/framework/mlt.h>

// 2. Initialize MLT
mlt_factory_init(nil)

// 3. Get repository
let repo = mlt_factory_repository()

// 4. List available filters
var count: CInt = 0
let filters = mlt_repository_filters(repo, &count)

// 5. Create producer (video source)
let producer = mlt_factory_producer(
    repo,
    "avformat",
    "input.mp4"
)

// 6. Create filter (effect)
let filter = mlt_factory_filter(
    repo,
    "frei0r.glow",
    nil
)

// 7. Attach filter to producer
mlt_producer_attach(producer, filter)

// 8. Create consumer (output)
let consumer = mlt_factory_consumer(
    repo,
    "avformat",
    "output.mp4"
)

// 9. Connect and render
mlt_consumer_connect(consumer, mlt_producer_service(producer))
mlt_consumer_start(consumer)

// Wait for completion...
mlt_consumer_stop(consumer)
mlt_consumer_close(consumer)
mlt_factory_close()
```

### Resources

- [MLT Framework Website](https://www.mltframework.org/)
- [MLT GitHub](https://github.com/mltframework/mlt)
- [Filter Catalog](https://www.mltframework.org/plugins/PluginsFilters/)
- [Transition Catalog](https://www.mltframework.org/plugins/PluginsTransitions/)

---

## Detailed Comparison

### Ease of Use

| Criterion | AVFoundation | GarageBand | MLT |
|-----------|-------------|------------|-----|
| Language | ✅ Swift | ❌ N/A | ❌ C/C++ |
| Bridging Needed | ✅ No | ❌ N/A | ❌ Yes |
| Documentation | ✅ Excellent | ❌ None | ⚠️ Good but C-focused |
| Code Examples | ✅ Many | ❌ None | ⚠️ Limited |
| Setup Time | ✅ 1 day | ❌ N/A | ❌ 1-2 weeks |

### Effects Quality

| Criterion | AVFoundation | GarageBand | MLT |
|-----------|-------------|------------|-----|
| Transitions | ✅ 10+ built-in | ❌ N/A | ✅ 70+ |
| Filters | ✅ 200+ | ❌ N/A | ✅ 300+ |
| GPU Acceleration | ✅ Metal | ⚠️ Unknown | ✅ OpenGL/GPU |
| Custom Shaders | ✅ Yes (CIKernel) | ❌ N/A | ✅ Yes (complex) |

### Performance

| Criterion | AVFoundation | GarageBand | MLT |
|-----------|-------------|------------|-----|
| Rendering Speed | ✅ Fast (native) | ❌ N/A | ⚠️ Good |
| Memory Usage | ✅ Efficient | ❌ N/A | ⚠️ Higher |
| Startup Time | ✅ Instant | ❌ N/A | ⚠️ Plugin loading |

### Distribution

| Criterion | AVFoundation | GarageBand | MLT |
|-----------|-------------|------------|-----|
| App Size | ✅ +0 MB | ❌ N/A | ❌ +150 MB |
| Dependencies | ✅ Built-in | ❌ N/A | ❌ Bundle MLT |
| License | ✅ Free | ❌ N/A | ⚠️ LGPL |
| App Store | ✅ No issues | ❌ Rejected | ⚠️ Verbose attribution |

---

## Recommendation

### For Your Use Case (15-30 second social videos)

**Use AVFoundation + CoreImage**

#### Why?

1. You already know iMovie, which uses the same frameworks
2. Native Swift - write code today, not in 2-3 weeks
3. 200+ effects is more than enough for social media
4. GPU-accelerated, fast rendering
5. Zero distribution issues

#### Quick Win Strategy

1. **Week 1:** Build basic video compositor with 3 effects
   - Cross-dissolve transition
   - Bloom/glow filter
   - Color grading
2. **Week 2:** Add 7 more effects from your original list
   - Wipe, zoom, particles, etc.
3. **Week 3:** Polish and integrate with Social Marketer

#### When to Consider MLT

- If you need 50+ professional transitions
- If you're building a full video editor
- If you have 4-6 weeks for C bridging setup
- If you need specific Frei0r or OpenCV effects

---

## Next Steps

1. ✅ **Library map created** - All options documented
2. 🚀 **Build AVFoundation test** - Prove basic video generation works
3. 🚀 **Test CoreImage filters** - Validate effects match your vision
4. 📋 **Compare MLT** (optional) - Only if AVFoundation insufficient
