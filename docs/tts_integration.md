# Text-to-Speech Integration Guide

## macOS Built-in Voices

macOS has excellent built-in TTS voices that are perfect for stoic wisdom videos.

### Best Voices for Stoic Content

**Mature Male Voices (Recommended):**

1. **Alex** (US English)
   - Default high-quality male voice
   - Deep, authoritative tone
   - Natural pacing
   - **BEST for stoic wisdom**

2. **Daniel** (UK English)  
   - British accent, sophisticated
   - Clear enunciation
   - Calm, measured delivery
   - Good alternative to Alex

3. **Tom** (US English)
   - Deeper than Alex
   - Smooth, podcast-quality
   - Available in modern macOS versions

### Using AVSpeechSynthesizer

```swift
import AVFoundation

func generateVoiceover(text: String, outputPath: URL) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: text)
    
    // Use Alex voice (mature male, US English)
    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha")
    
    // Adjust speech rate for stoic delivery
    utterance.rate = 0.45 // Slower = more authoritative (0.0-1.0, default 0.5)
    utterance.pitchMultiplier = 0.9 // Slightly lower pitch
    utterance.volume = 1.0
    
    // Write to audio file
    synthesizer.write(utterance) { buffer in
        // Export to .m4a or .wav
    }
}
```

### Alternative: Command-Line TTS

```bash
# Generate audio file directly from command line
say -v Alex -o output.aiff "True wisdom comes from questions"

# Convert to MP3
afconvert output.aiff output.m4a -d aac -f m4af -b 128000
```

### Speech Parameters for Stoic Aesthetic

**Rate:** 0.40 - 0.50 (slower than normal)

- Stoic wisdom should be delivered with gravitas
- Gives listener time to reflect
- Matches slow, cinematic visual pacing

**Pitch:** 0.85 - 0.95 (slightly lower)

- Deeper voice = more authority
- Natural for mature male delivery

**Pauses:**

- Insert natural pauses with punctuation
- Use `[[slnc 500]]` markup for 500ms pause
- Break long quotes into breath groups

### Integration with MLT

**Workflow:**

1. Generate audio from quote text using AVSpeechSynthesizer
2. Save as `.m4a` or `.wav` file
3. Load into MLT as audio producer
4. Sync with video timeline
5. Mix with video track

**MLT Audio Producer:**

```c
mlt_producer audio_producer = mlt_factory_producer(profile, "avformat", audio_path);
mlt_playlist_append(playlist, audio_producer);
```

### Timing Considerations

For 15-second videos:

```
0s  ────► Intro visual effect (1-2s)
1s  ────► Voice starts: "True wisdom..."
        ► Visual effects complement voice
10s ────► Voice ends
11s ────► Visual holds for reflection (2-3s)
13s ────► Outro effect begins
15s ────► End
```

**Strategy:**

- Voice delivery: 8-10 seconds (depending on quote length)
- Leave 2-3 seconds before voice starts (visual intro)
- Leave 2-3 seconds after voice ends (reflection + outro)

### Quote Length Guidelines

For natural 8-10 second delivery:

- **Short quotes**: 10-15 words (8 seconds)
  - "True wisdom comes from asking the right questions."
  
- **Medium quotes**: 20-25 words (10 seconds)
  - "The wisest person is not the one with all the answers, but the one who asks the best questions."

- **Long quotes**: 30-35 words (12 seconds) - might feel rushed
  - Avoid if possible, or split across two cards

### Voice Testing

Test all candidate voices:

```swift
let testVoices = [
    "com.apple.eloquence.en-US.Rocko",    // Alex
    "com.apple.voice.compact.en-GB.Daniel", // Daniel  
    "com.apple.ttsbundle.siri_male_en-US_compact" // Tom
]

for voiceId in testVoices {
    generateVoiceover(text: sampleQuote, voice: voiceId)
}
```

Listen to each and choose the one that best matches the stoic gravitas.

### Audio Quality

- **Sample Rate**: 44.1 kHz (CD quality)
- **Bit Depth**: 16-bit
- **Format**: M4A (AAC) or WAV
- **Bitrate**: 128-192 kbps (for M4A)

### Implementation Notes

1. **Pre-generate audio** before video rendering
   - Faster than real-time synthesis
   - Can preview and adjust

2. **Normalize audio levels**
   - Ensure consistent volume across all 10 demos
   - Use -23 LUFS for YouTube/TikTok standards

3. **Add subtle reverb** (optional)
   - Small room reverb = warmth
   - Don't overdo it (stoic = clarity)

4. **Test on mobile devices**
   - Most viewers watch on phones
   - Ensure voice is clear even through phone speakers
