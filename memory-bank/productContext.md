# Product Context: Social Effects

## Why This Project Exists

Social Effects was created to solve a specific content creation challenge: producing a steady stream of high-quality, wisdom-focused social media videos without manual video editing. It's part of the broader Social Marketer ecosystem for automated content generation.

## Problems Solved

### 1. Content Consistency at Scale
- **Problem**: Creating daily wisdom videos manually is time-consuming
- **Solution**: Fully automated pipeline from RSS → final video in one command

### 2. Professional Quality Without Expertise
- **Problem**: Video editing requires specialized skills and software
- **Solution**: Cinematic templates with FFmpeg compositing, no manual editing needed

### 3. Voice Quality and Consistency
- **Problem**: Free TTS sounds robotic; premium TTS is expensive
- **Solution**: Kokoro TTS provides high-quality, consistent narration at low cost

### 4. Visual Variety
- **Problem**: Static backgrounds become repetitive
- **Solution**: AI-generated looping backgrounds with 10 unique templates, auto-rotation

### 5. Platform Optimization
- **Problem**: Different platforms need different formats
- **Solution**: Standardized 9:16 vertical format works across all major platforms

## User Experience Goals

### For Content Creators
- Run a single command to get a video ready for posting
- No video editing knowledge required
- Consistent branding through border styles and voice

### For Developers
- Clean, modular Swift codebase
- JSON API for programmatic integration
- Extensible architecture for new features

## Content Flow
```
wisdombook.life RSS Feed
        ↓
    Text Content
        ↓
    TTS Narration (Kokoro)
    CTA Outro (Kokoro)
    Text Graphic (CoreGraphics)
        ↓
    FFmpeg Composition
    (background + overlay + audio mix)
        ↓
    Final MP4 Output
```

## Brand Identity
- **Tone**: Stoic, contemplative, premium
- **Visual Style**: Ornate borders, minimalist text, sophisticated animations
- **Voice**: Male (am_liam), calm, authoritative
- **Target Audience**: Personal development, philosophy, and self-improvement communities

## Integration Points
- **wisdombook.life**: Primary content source via RSS
- **Social Marketer**: Planned integration for automated posting
- **External Storage**: `/Volumes/My Passport/social-media-content/social-effects/` for production assets
