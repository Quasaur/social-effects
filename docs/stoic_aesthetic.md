# Stoic Video Aesthetic Guide

## Visual Reference

Based on popular stoic wisdom videos on YouTube, here's the aesthetic we're targeting:

### Color Palette

**Backgrounds:**

- Deep charcoal: `#1a1a1a`
- Ash gray: `#2d2d2d`
- Dark bronze: `#3d3028`
- Pure black: `#000000`

**Text:**

- Primary text: `#e8e8e8` (off-white, easier on eyes than pure white)
- Secondary text: `#b8b8b8` (muted gray for attributions)

**Accents:**

- Bronze glow: `#b87333`
- Soft gold: `#d4af37`
- Subtle copper: `#c77b4f`

### Typography

**Primary Font**: Serif (elegant, classic)

- Options: Georgia, Playfair Display, Crimson Text
- Size: 48-64pt for quotes
- Weight: Regular to Medium
- Letter spacing: Slight increase (+10%)

**Secondary Font**: Sans-serif (clean, minimal)

- Options: Helvetica Neue, SF Pro, Inter
- Size: 24-32pt for attribution
- Weight: Light

### Layout

**Quote Composition:**

```
┌─────────────────────────────┐
│                             │
│                             │
│      "Quote text here       │
│       centered, 2-3         │
│       lines max"            │
│                             │
│     — wisdombook.life       │
│                             │
│                             │
└─────────────────────────────┘
```

**Margins:**

- Top/Bottom: 15% of frame
- Left/Right: 10% of frame
- Safe area: 60px inset from edges

### Border Styles (Optional)

**Minimalist Approach:**

- NO thick borders (too busy)
- MAYBE: Single thin line (1-2px) in bronze/gold
- MAYBE: Corner accents (L-shaped, subtle)
- Focus: Let the quote breathe, negative space is good

**If using borders:**

```
╔═══════════════════════════╗  ← Too heavy, avoid
║                           ║
║        Quote              ║
║                           ║
╚═══════════════════════════╝

┌───────────────────────────┐  ← Simple, clean, OK
│                           │
│        Quote              │
│                           │
└───────────────────────────┘

    ╱─╲                         ← Corner accents only, BEST
   ╱   ╲
          Quote


   ╲   ╱
    ╲─╱
```

### Effects Style

**Philosophy: "Less is more, but what's there should be cinematic"**

1. **Cross-Dissolve** - Slow, elegant fade (1.5-2 seconds)
2. **Zoom Expand** - Subtle scale (1.05x → 1.0x, not dramatic)
3. **Wipe** - Smooth, directional reveal
4. **Light Leaks** - Golden/bronze glow, subtle sweep
5. **Particles** - Minimal, slow-moving dust motes (not snow)
6. **Word Reveal** - Text fades in word-by-word, elegant timing
7. **Circular Collapse** - Smooth, centered shrink
8. **Blinds** - Horizontal bars, 5-7 count

**Key Principles:**

- Transitions should be smooth, not jarring
- Effects should complement, not overpower
- Timing: Slower = more sophisticated
- Never combine more than 2 effects at once

### Animation Timing

For 15-second videos:

```
0s ──────► Intro effect (2-3s)
3s ──────► Quote fully visible
12s ─────► Start outro effect (3s)
15s ─────► End / fade to black
```

**Pacing:**

- Intro: 2-3 seconds
- Display: 9-10 seconds (let it breathe)
- Outro: 2-3 seconds

### Video Specs

- **Resolution**: 1080×1920 (vertical, 9:16)
- **Framerate**: 30fps
- **Format**: MP4 (H.264)
- **Duration**: Exactly 15 seconds
- **Bitrate**: High quality (8-10 Mbps)

---

## Example Compositions

### Demo 1: Cross-Dissolve (Minimalist)

```
Background: #1a1a1a (charcoal)
Border: None
Text: "True wisdom comes from questions"
Font: Georgia 56pt, #e8e8e8
Attribution: "wisdombook.life" - 28pt, #b8b8b8
Effect: Slow cross-dissolve from black (2s)
Display: 10s
Outro: Fade to black (3s)
```

### Demo 5: Light Leaks (Bronze Glow)

```
Background: #2d2d2d → #3d3028 (gradient)
Border: Thin bronze line (1px)
Text: "Kindness is contagious"
Accent: Bronze light sweep (diagonal, subtle)
Effect: MLT frei0r.lightgraffiti with bronze tones
Timing: Sweep takes 3s, then static quote
```

### Demo 9: Elegant Combo

```
Background: Pure black #000000
Border: Corner accents only (gold)
Text: "Patience is a superpower"
Effects:
  - Cross-dissolve intro (2s)
  - Golden light leak sweep (1s, at 4s mark)
  - Circular collapse outro (3s)
```

---

## MLT Filter Mapping

### For Stoic Aesthetic

**Backgrounds:**

- `color:` producer with hex values
- OR `frei0r.cairogradient` for subtle gradients

**Light Effects:**

- `frei0r.lightgraffiti` (golden light sweeps)
- `frei0r.glow` (subtle bronze glow)
- Adjust color temperature to warm (bronze/gold)

**Transitions:**

- `frei0r.cairoblend` (smooth dissolves)
- `frei0r.sleid0r_wipe-*` (directional wipes)

**Text:**

- Qt6 text rendering with custom fonts
- OR pre-rendered text images from Core Graphics

---

## Implementation Notes

1. **Pre-render text graphics** using Core Graphics (easier than Qt6)
   - macOS has beautiful font rendering
   - Export as PNG with transparency
   - MLT loads as image producer

2. **Color grading** is key
   - Adjust all effects to warm tones (bronze/gold)
   - Avoid cool blues/greens (not stoic)

3. **Test first video end-to-end** before building all 10
   - Validate the aesthetic
   - Adjust timings
   - Get user feedback
