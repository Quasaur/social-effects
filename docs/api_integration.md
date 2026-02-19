# Social Effects API Integration

## Overview

Social Effects now provides an HTTP API for integration with Social Marketer and other services.

## Starting the API Server

```bash
swift run SocialEffects api-server [port]
```

**Default port:** 5390

**Example:**
```bash
# Start on default port 5390
swift run SocialEffects api-server

# Start on custom port
swift run SocialEffects api-server 8080
```

## API Endpoints

### POST /generate

Generate a video from text content.

**Request:**
```json
{
  "title": "THE ULTIMATE",
  "content": "That which is Ultimate cannot be Ultimate unless \"it\" (He) is also PERSONAL.",
  "ping_pong": true
}
```

**Parameters:**
- `title` (string, required): Video title
- `content` (string, required): Quote/text content
- `ping_pong` (boolean, optional): Use ping-pong background effect (forward-back-forward)

**Response:**
```json
{
  "success": true,
  "video_path": "/Volumes/My Passport/social-media-content/social-effects/video/api/video_1234567890.mp4"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Missing title or content"
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok"
}
```

## Example Usage (cURL)

```bash
# Health check
curl http://localhost:5390/health

# Generate video with ping-pong background
curl -X POST http://localhost:5390/generate \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Title",
    "content": "Test content for the video.",
    "ping_pong": true
  }'

# Generate video without ping-pong
curl -X POST http://localhost:5390/generate \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Simple Video",
    "content": "Just some text content."
  }'
```

## Video Timing

When using the API, videos follow this cinematic timing:
- **0-3s:** Black screen
- **3-7s:** Background fades in
- **7-9s:** Text overlay fades in (text fully visible by 9s)
- **9s:** Narration starts (text is fully visible when voiceover begins)
- **End:** CTA outro plays

## Integration with Social Marketer

Social Marketer should:
1. Start the API server: `swift run SocialEffects api-server`
2. Wait for server to be ready (poll `/health`)
3. POST to `/generate` with RSS item content
4. Poll or wait for video generation to complete
5. Use the returned `video_path` for posting

## Output Location

All API-generated videos are saved to:
```
/Volumes/My Passport/social-media-content/social-effects/video/api/
```

## Port Configuration

**Default:** 5390

The port can be customized by passing it as an argument:
```bash
swift run SocialEffects api-server 9090
```

When integrating with Social Marketer, ensure both services agree on the port number.
