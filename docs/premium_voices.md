# Downloading Premium macOS Voices

## How to Download Better Voices

### Step 1: Open System Settings

1. Click **Apple menu** () → **System Settings**
2. Click **Accessibility** in the sidebar
3. Click **Spoken Content**
4. Click **System Voice** dropdown
5. At the bottom, click **Manage Voices...**

### Step 2: Download Premium Voices

In the voice list, look for voices marked with a **download icon** (cloud ↓):

**Best Realistic Male Voices (US English):**

1. **Reed (Premium Quality)** ⭐️⭐️⭐️⭐️⭐️
   - Most natural-sounding
   - Deep, mature male voice
   - Neural TTS quality
   - **RECOMMENDED for stoic videos**
   - Size: ~500 MB

2. **Nathan (Premium Quality)** ⭐️⭐️⭐️⭐️
   - Natural, conversational
   - Professional narrator tone
   - Size: ~350 MB

3. **Aaron (Premium Quality)** ⭐️⭐️⭐️⭐️
   - Clear, authoritative
   - Good for wisdom content
   - Size: ~350 MB

**UK English Alternatives:**

1. **Oliver (Premium Quality)** ⭐️⭐️⭐️⭐️⭐️
   - British accent
   - Sophisticated, calm
   - Excellent for stoic aesthetic

### Step 3: Download

1. Click the **download icon** next to the voice name
2. Wait for download to complete (may take 5-10 minutes for Premium voices)
3. Once downloaded, it will appear in the `say` command and AVSpeechSynthesizer

## Testing Premium Voices

After downloading, test them:

```bash
# Test Reed (Premium US male)
say -v Reed "True wisdom comes from questions"

# Test Nathan
say -v Nathan "True wisdom comes from questions"

# Test Aaron
say -v Aaron "True wisdom comes from questions"

# Test Oliver (Premium UK male)
say -v Oliver "True wisdom comes from questions"
```

## Voice Quality Comparison

| Voice | Quality | Natural | Authority | Best For |
|-------|---------|---------|-----------|----------|
| Reed | Premium | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ | **Stoic wisdom** ✓ |
| Nathan | Premium | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | Narration |
| Aaron | Premium | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | Professional |
| Oliver | Premium | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | British stoic |
| Alex | Standard | ⭐️⭐️⭐️ | ⭐️⭐️⭐️ | Default |
| Daniel | Standard | ⭐️⭐️⭐️ | ⭐️⭐️⭐️ | UK default |

## Using in Code

Once downloaded, use the voice name in AVSpeechSynthesizer:

```swift
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: quote)

// Use Reed (Premium male voice)
utterance.voice = AVSpeechSynthesisVoice(name: "Reed")

// Adjust for stoic delivery
utterance.rate = 0.45  // Slower, more authoritative
utterance.pitchMultiplier = 0.95
```

## Recommended Voice: Reed

**Reed is the best choice for stoic wisdom videos:**

- Deep, mature male voice
- Most natural-sounding of all macOS voices
- Neural TTS quality (sounds almost human)
- Authoritative but not robotic
- Perfect pacing for philosophical content

## Download Size Note

Premium voices are larger (300-500 MB each) but the quality difference is worth it for professional videos. You only need to download 1-2 voices.

---

**Next Step:** Download Reed, then we can test it with your first demo quote!
