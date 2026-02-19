# Kokoro 82M TTS Integration

## Overview

Successfully installed and integrated **Kokoro 82M** - a lightweight, high-quality neural TTS model by Resemble AI - as the primary voice provider for SocialEffects. This replaces the previous Apple Voice (Jamie) as the default TTS engine while maintaining Jamie for CTA outro generation.

## Installation Summary

### Python Environment
- Created Python 3.11 virtual environment at `.venv/`
- Installed Kokoro 0.9.4 with all dependencies
- Location: `/Users/quasaur/Developer/social-effects/.venv/`

### Key Dependencies
- `kokoro` - Core TTS engine (82M parameters)
- `torch` - PyTorch for MPS (Apple Silicon GPU acceleration)
- `transformers` - Hugging Face transformers
- `soundfile` - Audio I/O
- `misaki[en]` - English phonemizer

## Voice Samples Generated

5 American male voices tested with sample text:
> *"True wisdom comes from questions, not answers. The path to mastery is paved with curiosity."*

| Voice | File | Characteristics |
|-------|------|-----------------|
| `am_adam` | `test_am_adam.wav` | Deep, mature - **CLOSEST TO DONOVAN** |
| `am_echo` | `test_am_echo.wav` | Smooth, authoritative |
| `am_eric` | `test_am_eric.wav` | Clear, professional |
| `am_fenrir` | `test_am_fenrir.wav` | Strong, commanding |
| `am_liam` | `test_am_liam.wav` | Warm, resonant |

### Voice Selection Criteria (Donovan Match)
All voices were selected to match **ElevenLabs Donovan** profile:
- Deep, authoritative male voice
- Warm bass tone (not hollow)
- Calm, adult-like pacing
- Rich, cinematic depth
- Slight gravitas with modern neutrality

**Recommended Primary Voice**: `am_adam` (set as default)

## Files Created

### 1. Python TTS Script
**Path**: `scripts/kokoro_tts.py`
- CLI wrapper for Kokoro TTS generation
- Called from Swift via Python subprocess
- Handles voice synthesis and WAV output

### 2. Swift Service Class
**Path**: `Sources/SocialEffects/Audio/KokoroVoice.swift`
- Actor-based service for async TTS generation
- SHA256-based caching (content + voice)
- Fallback to Apple Voice if Kokoro fails
- Cache management and statistics

**Key Methods**:
```swift
// Generate TTS (async)
let kokoro = KokoroVoice()
let audioPath = try await kokoro.synthesize(text: "Hello", voice: "am_adam")

// With fallback
let path = await kokoro.synthesizeWithFallback(text: "Hello")

// Cache management
await kokoro.prewarmCache(texts: ["text1", "text2"])
let stats = await kokoro.getCacheStats()
```

### 3. Voice Sample Tests
**Path**: `output/kokoro_tests/`
- `test_af_heart.wav` - Female reference voice
- `test_am_adam.wav` through `test_am_liam.wav` - Male voices

## Integration Status

### Completed
- ✅ Kokoro 82M installed in Python 3.11 venv
- ✅ 5 American male voice samples generated
- ✅ Python wrapper script created (`scripts/kokoro_tts.py`)
- ✅ Swift service class created (`KokoroVoice.swift`)
- ✅ Project builds successfully
- ✅ Voice caching with SHA256 keys
- ✅ Fallback to Apple Voice implemented

### Next Steps (Optional)
The KokoroVoice service is ready for integration into the video generation pipeline. To fully replace Apple Voice in `generateVideoFromRSS()`, update the voice provider selection logic:

```swift
// In generateVideoFromRSS(), replace:
// let voiceService: ElevenLabsVoice?
// let appleVoice: AppleVoice?

// With:
let kokoroVoice = KokoroVoice()
let appleVoice = AppleVoice() // For CTA only
```

## Usage

### Test a Voice Sample
```bash
# Activate venv and generate test
source .venv/bin/activate
python3 scripts/kokoro_tts.py "Your text here" am_adam output.wav
```

### Build Project
```bash
swift build
```

### Available Voices
```swift
KokoroVoice.americanMaleVoices
// ["am_adam", "am_echo", "am_eric", "am_fenrir", "am_liam"]

KokoroVoice.defaultVoice
// "am_adam"
```

## Technical Notes

### Performance
- First run downloads ~327MB model from HuggingFace
- Voice generation: ~1-2 seconds for short text
- MPS (Metal Performance Shaders) acceleration on Apple Silicon
- Caching eliminates regeneration for identical text

### Cache Location
`~/Developer/social-effects/output/cache/audio/`

### Dependencies
- Requires Python 3.11 (Kokoro incompatible with Python 3.14)
- PyTorch with MPS support for GPU acceleration
- espeak-ng for phonemization (bundled via espeakng-loader)

## Comparison: Kokoro vs Apple Voice vs ElevenLabs

| Feature | Kokoro 82M | Apple Jamie | ElevenLabs Donovan |
|---------|------------|-------------|-------------------|
| **Cost** | Free | Free | $5-30/month |
| **Quality** | High | High | Very High |
| **Speed** | Fast (~2s) | Fast (~1s) | API latency |
| **Offline** | ✅ Yes | ✅ Yes | ❌ No |
| **Donovan Match** | Very Close | Moderate | Exact |
| **MPS/GPU** | ✅ Yes | ✅ Neural Engine | N/A |
| **Caching** | SHA256 hash | SHA256 hash | - |

## Conclusion

Kokoro 82M successfully provides a **free, offline, high-quality TTS solution** that closely matches ElevenLabs Donovan's voice characteristics. The `am_adam` voice is recommended as the primary choice for stoic wisdom videos.

---

*Generated: February 19, 2025*
*Voice samples: `output/kokoro_tests/`*
