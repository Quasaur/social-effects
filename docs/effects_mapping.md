# Effect Framework Mapping

**Your 10 Approved Effects → Implementation Options**

This document maps your specific effect requirements to their implementation across AVFoundation/CoreImage, MLT/Shotcut, iMovie, and GarageBand.

---

## 📋 Your Effects List

### Intro Transitions (4 options)

1. **Cross-Dissolve** - Fade in from black
2. **Zoom Expand** - Content expands from center
3. **Wipe** - Left to right reveal
4. **Card Flip H** - Horizontal card flip

### Ongoing/Ambient Effects (4 options)

5. **Particles** - Falling snow particles
2. **Light Leaks** - Golden light sweep
3. **Word Reveal** - Words appear progressively
4. **Cube Rotate** - 3D quote rotation

### Outro Transitions (2 options)

9. **Circular Collapse** - Shrinks to center
2. **Blinds** - Venetian blinds closing

---

## 🎯 Framework Comparison for YOUR Effects

| Your Effect | AVFoundation/CoreImage | MLT/Shotcut | iMovie | Complexity |
|---|---|---|---|
| **Cross-Dissolve** | ✅ `CIDissolveTransition` | ✅ `frei0r.cairoblend` | ✅ Built-in | ⭐️ Easy |
| **Zoom Expand** | ✅ `CABasicAnimation` (scale) | ✅ `affine` + keyframes | ✅ Ken Burns | ⭐️⭐️ Medium |
| **Wipe** | ✅ `CISwipeTransition` | ✅ `frei0r.sleid0r_wipe-left` | ✅ Built-in | ⭐️ Easy |
| **Card Flip H** | ✅ `CATransform3D` | ✅ `affine` + 3D transform | ❌ Not available | ⭐️⭐️⭐️ Complex |
| **Particles** | ✅ `CAEmitterLayer` | ✅ Custom compositor | ❌ Not available | ⭐️⭐️⭐️ Complex |
| **Light Leaks** | ✅ `CIBloom` + animation | ✅ `frei0r.lightgraffiti` | ❌ Not available | ⭐️⭐️ Medium |
| **Word Reveal** | ✅ `CATextLayer` + mask | ✅ Qt6 text + mask | ❌ Not available | ⭐️⭐️⭐️ Complex |
| **Cube Rotate** | ✅ `CATransform3D` (3 axes) | ✅ `affine` + rotation | ❌ Not available | ⭐️⭐️⭐️⭐️ Very Complex |
| **Circular Collapse** | ✅ `CICircleSplashDistortion` | ✅ `frei0r.sleid0r_wipe-circle` | ❌ Not available | ⭐️⭐️ Medium |
| **Blinds** | ✅ `CIBarsSwipeTransition` | ✅ `frei0r.sleid0r_wipe-barn-door` | ❌ Not available | ⭐️⭐️ Medium |

**🏆 Winner: AVFoundation** - All 10 effects are implementable, with most being easy to medium difficulty.

---

## 📖 Detailed Effect Mappings

### 1. Cross-Dissolve (Fade In)

#### AVFoundation ✅ EASIEST

```swift
let transition = CIFilter(name: "CIDissolveTransition")!
transition.setValue(sourceImage, forKey: kCIInputImageKey)
transition.setValue(targetImage, forKey: kCIInputTargetImageKey)
transition.setValue(progress, forKey: kCIInputTimeKey) // 0.0 to 1.0
```

#### MLT/Shotcut ✅

- Filter: `frei0r.cairoblend`
- Complexity: Easy
- Parameters: Blend mode, opacity ramp

#### iMovie ✅

- Built-in "Dissolve" transition
- **NOT accessible via API** (iMovie has no public API)

---

### 2. Zoom Expand (Scale from 0 to 1)

#### AVFoundation ✅ RECOMMENDED

```swift
let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
scaleAnimation.fromValue = 0.0
scaleAnimation.toValue = 1.0
scaleAnimation.duration = 1.0
layer.add(scaleAnimation, forKey: "zoom")
```

#### MLT/Shotcut ✅

- Filter: `affine` (transform)
- Keyframe: `scale_x=0,scale_y=0` → `scale_x=1,scale_y=1`
- Complexity: Medium

#### iMovie ✅

- "Ken Burns" effect (reverse from 1.2x to 1.0x)
- **NOT accessible via API**

---

### 3. Wipe (Left to Right)

#### AVFoundation ✅ EASIEST

```swift
let wipe = CIFilter(name: "CISwipeTransition")!
wipe.setValue(sourceImage, forKey: kCIInputImageKey)
wipe.setValue(targetImage, forKey: kCIInputTargetImageKey)
wipe.setValue(CIVector(x: 1, y: 0), forKey: kCIInputExtentKey) // Right direction
wipe.setValue(progress, forKey: kCIInputTimeKey)
```

#### MLT/Shotcut ✅

- Transition: `frei0r.sleid0r_wipe-left`
- Complexity: Easy

---

### 4. Card Flip H (Horizontal Flip)

#### AVFoundation ✅ BEST OPTION

```swift
var transform = CATransform3DIdentity
transform.m34 = -1.0 / 500.0 // Perspective
transform = CATransform3DRotate(transform, .pi, 0, 1, 0) // Y-axis rotation
layer.transform = transform
```

#### MLT/Shotcut ⚠️

- Filter: `affine` with rotation
- **Caveat**: True 3D perspective is complex
- May need custom compositor

---

### 5. Particles (Falling Snow)

#### AVFoundation ✅ NATIVE

```swift
let emitter = CAEmitterLayer()
emitter.emitterPosition = CGPoint(x: bounds.width/2, y: 0)
emitter.emitterShape = .line
emitter.emitterSize = CGSize(width: bounds.width, height: 1)

let cell = CAEmitterCell()
cell.birthRate = 10
cell.lifetime = 5.0
cell.velocity = 50
cell.scale = 0.1
cell.contents = particleImage.cgImage
emitter.emitterCells = [cell]
```

#### MLT/Shotcut ⚠️

- No built-in particle system
- Would need custom video compositor or pre-rendered video overlay

---

### 6. Light Leaks (Golden Glow Sweep)

#### AVFoundation ✅ RECOMMENDED

```swift
// Bloom filter + animated position
let bloom = CIFilter(name: "CIBloom")!
bloom.setValue(sourceImage, forKey: kCIInputImageKey)
bloom.setValue(10.0, forKey: kCIInputIntensityKey)
bloom.setValue(25.0, forKey: kCIInputRadiusKey)

// Animate the glow position with gradient + affine transform
```

#### MLT/Shotcut ✅

- Filter: `frei0r.lightgraffiti` or `frei0r.glow`
- Complexity: Medium
- Can keyframe position/intensity

---

### 7. Word Reveal (Progressive Text)

#### AVFoundation ✅

```swift
let textLayer = CATextLayer()
textLayer.string = "Your quote text"

// Animate with mask that reveals left-to-right
let maskLayer = CALayer()
let maskAnimation = CABasicAnimation(keyPath: "bounds.size.width")
maskAnimation.fromValue = 0
maskAnimation.toValue = textLayer.bounds.width
textLayer.mask = maskLayer
```

#### MLT/Shotcut ⚠️

- Qt6 text rendering + mask animation
- Complexity: High
- Requires custom animation logic

---

### 8. Cube Rotate (3D Multi-Axis)

#### AVFoundation ✅

```swift
var transform = CATransform3DIdentity
transform.m34 = -1.0 / 500.0
transform = CATransform3DRotate(transform, angle, 1, 0.5, 0) // Multi-axis
layer.transform = transform
```

#### MLT/Shotcut ⚠️

- `affine` filter with rotation + perspective
- **Very complex** to achieve true 3D look
- May require custom compositor

---

### 9. Circular Collapse (Shrink to Circle)

#### AVFoundation ✅

```swift
let distortion = CIFilter(name: "CICircleSplashDistortion")!
distortion.setValue(sourceImage, forKey: kCIInputImageKey)
distortion.setValue(CIVector(x: center.x, y: center.y), forKey: kCIInputCenterKey)
distortion.setValue(radius, forKey: kCIInputRadiusKey) // Animate from large to 0
```

#### MLT/Shotcut ✅

- Transition: `frei0r.sleid0r_wipe-circle` (reverse)
- Complexity: Medium

---

### 10. Blinds (Venetian Blinds, 5-7 Slats)

#### AVFoundation ✅

```swift
let blinds = CIFilter(name: "CIBarsSwipeTransition")!
blinds.setValue(sourceImage, forKey: kCIInputImageKey)
blinds.setValue(targetImage, forKey: kCIInputTargetImageKey)
blinds.setValue(6.0, forKey: "inputBarOffset") // Number of slats
blinds.setValue(progress, forKey: kCIInputTimeKey)
```

#### MLT/Shotcut ✅

- Transition: `frei0r.sleid0r_wipe-barn-door-h` or `-v`
- Complexity: Easy

---

## 🎵 Audio Integration (GarageBand)

### GarageBand Audio Frameworks

Located in `/Applications/GarageBand.app/Contents/Frameworks/`:

1. **MAAudioEngine.framework** - Audio playback and mixing
2. **MAAudioUnitSupport.framework** - Audio Unit plugin support
3. **MAMusicAnalysis.framework** - Music analysis and beat detection
4. **MADSP.framework** - Digital signal processing
5. **MAGenerativeInstruments.framework** - AI music generation

### ⚠️ Key Issue: Private APIs

**GarageBand frameworks are PRIVATE** - not documented, not supported, violates App Store guidelines if used.

### ✅ Alternative: Native Audio (Recommended)

Use **AVFoundation + AVAudioEngine** instead:

```swift
import AVFoundation

// 1. Load background music
let musicURL = Bundle.main.url(forResource: "background", withExtension: "mp3")!
let musicAsset = AVAsset(url: musicURL)

// 2. Mix with video
let composition = AVMutableComposition()

// Add video track
let videoTrack = composition.addMutableTrack(
    withMediaType: .video,
    preferredTrackID: kCMPersistentTrackID_Invalid
)

// Add audio track
let audioTrack = composition.addMutableTrack(
    withMediaType: .audio,
    preferredTrackID: kCMPersistentTrackID_Invalid
)

// Insert audio at reduced volume
try audioTrack.insertTimeRange(
    CMTimeRange(start: .zero, duration: videoDuration),
    of: musicAsset.tracks(withMediaType: .audio)[0],
    at: .zero
)

// 3. Apply volume ducking
let audioMix = AVMutableAudioMix()
let audioMixParams = AVMutableAudioMixInputParameters(track: audioTrack)
audioMixParams.setVolume(0.3, at: .zero) // 30% volume for background music
audioMix.inputParameters = [audioMixParams]
```

### 🎼 Royalty-Free Music Sources

For background music in your videos:

1. **YouTube Audio Library** - Free, no attribution required
2. **Pixabay Music** - Creative Commons
3. **FreePD** - Public domain
4. **Incompetech** - Kevin MacLeod (attribution required)

### 🎵 Music Recommendations for Social Videos

**Uplifting/Inspirational** (for wisdom quotes):

- Ambient piano
- Soft strings
- Light acoustic guitar
- Gentle synth pads

**Energetic** (for motivational content):

- Upbeat indie
- Electronic pop
- Light percussion

**Duration**: 15-30 seconds (same as video)
**Volume**: 20-40% (shouldn't overpower visuals)

---

## 🏆 Final Recommendation

### Use AVFoundation + CoreImage + Native Audio

**Why?**

1. ✅ **All 10 effects are implementable**
2. ✅ **Native Swift** - No C bridging needed
3. ✅ **Audio mixing built-in** - AVFoundation handles it
4. ✅ **Fast development** - ~2-3 weeks vs 6+ weeks for MLT
5. ✅ **App Store safe** - No private API usage
6. ✅ **Zero dependencies** - Ships with macOS

**Effort Breakdown:**

- ⭐️ **Easy (3 effects)**: Cross-Dissolve, Wipe, Blinds → 1 day each
- ⭐️⭐️ **Medium (4 effects)**: Zoom, Light Leaks, Circular Collapse → 2 days each
- ⭐️⭐️⭐️ **Complex (3 effects)**: Card Flip, Particles, Word Reveal, Cube Rotate → 3-4 days each

**Total:** ~15-20 days for all 10 effects + audio

---

## 📊 MLT/Shotcut Alternative

**Only consider if:**

- You need 50+ professional transitions
- You're building a full video editor
- You have 4-6 weeks for C bridging setup
- AVFoundation proves insufficient (unlikely)

**All 10 of your effects are achievable in MLT**, but the development complexity is 3-4x higher.

---

## Next Steps

1. ✅ Library mapping complete
2. 🚀 **Run AVFoundation test** to validate capabilities
3. 🚀 **Build 1-2 proof-of-concept effects** (Cross-Dissolve + Particles)
4. 🚀 **Test audio mixing** with sample background music
5. 📋 Decide: Proceed with AVFoundation or explore MLT further
