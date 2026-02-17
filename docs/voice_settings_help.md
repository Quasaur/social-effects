# Finding Voice Settings on macOS Sequoia/Sonoma

## Path 1: System Settings → Accessibility

Based on what you're seeing, try this:

1. **System Settings** → **Accessibility**
2. Look for **Spoken Content** (it might be under "Speech" section)
3. Click on it
4. Look for **System Voice** or **Voices**

## Path 2: System Settings → Siri (You have this!)

Since you see "General / Siri", try this:

1. **System Settings** → **Siri & Spotlight** (or just **Siri**)
2. Look for **Siri Voice** settings
3. Click **Manage Voices** or similar option
4. You should see a list of downloadable voices

## Path 3: Direct Download via Terminal

If the GUI isn't showing voice downloads, we can check what's available and download via command line:

```bash
# List all available voices (including downloadable ones)
ls /System/Library/Speech/Voices/

# Or check what voices the system knows about
defaults read com.apple.speech.voice.prefs
```

## Alternative: Check Your macOS Version

```bash
sw_vers
```

Let me know your macOS version and I can give you the exact path for your system.

## Fallback: Use Siri Voices

Actually, **Siri voices are high quality too!** Since you have "General / Siri", you might already have access to good voices.

Try these Siri-based voices:

```bash
# Test premium Siri voices (if available)
say -v "?" | grep -i "siri"
```

These are often the best quality neural voices on the system.
