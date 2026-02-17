# Setup Guide - Gemini Video Generation

## 1. Get Your Gemini API Key

1. Visit: <https://aistudio.google.com/app/apikey>
2. Sign in with your Google account (<devcalvinlm@gmail.com>)
3. Click **"Create API Key"**
4. Copy the generated key (starts with `AIzaSy...`)

## 2. Configure Environment

```bash
# Set the API key (temporary - for current terminal session)
export GEMINI_API_KEY="your_api_key_here"

# OR create a .env file (permanent - for this project)
echo 'GEMINI_API_KEY=your_api_key_here' > .env
source .env
```

## 3. Test API Connection

```bash
swift run SocialEffects test-api
```

You should see:

```
✅ API key configured
✅ Service initialized successfully
🎉 Gemini API connection successful!
```

## 4. Generate Test Video

```bash
swift run SocialEffects generate-backgrounds --test
```

This generates ONE test video (~3-5 minutes). It will be saved to:
`output/backgrounds/01_morphing_geometric_sphere.mp4`

## 5. Generate All 10 Backgrounds

```bash
swift run SocialEffects generate-backgrounds --all
```

⚠️ **Note**: This takes 30-60 minutes and may hit daily API limits (check your quota).

## Troubleshooting

### "GEMINI_API_KEY not set"

- Make sure you exported the variable: `echo $GEMINI_API_KEY`
- If empty, run the export command again

### API Quota Limits

- Gemini AI Pro may limit to 5 videos/day
- Generate in batches over multiple days, or
- Request quota increase in Google AI Studio

### Build Errors

```bash
swift build  # Should complete without errors
```

## Next Steps

After generating backgrounds, integrate them into your video pipeline:

```bash
swift run SocialEffects batch-demos  # Original wisdom video generation
```
