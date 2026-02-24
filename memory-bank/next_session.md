# Next Session: Sync with Social Marketer API Changes

## ✅ COMPLETED

All changes have been implemented and tested. See commit history for details.

## Summary of Changes

Social Effects now accepts and displays the `source` field from Social Marketer API requests:

| Content Type | Source Value | Video Display |
|--------------|--------------|---------------|
| `quote` | Book name (e.g., "The Narrow Way") | `— The Narrow Way` below content |
| `passage` | Bible reference (e.g., "Proverbs 3:34") | `— Proverbs 3:34` below content |
| `thought` | Empty string | No attribution line |

## Files Modified

1. **APIServer.swift** - Parse `source` from `/generate` requests and pass to video generation
2. **RSSFetcher.swift** - Extract `wisdom:source` for QUOTE and PASSAGE types
3. **TextGraphicsGenerator.swift** - Render source attribution with em-dash prefix and muted gray color
4. **VideoRenderer.swift** - Pass source to graphics generator based on content type
5. **STATUS.md** - Updated API documentation
6. **AGENTS.md** - Added source attribution pattern documentation

## API Request Format

```json
{
  "title": "Content Title",
  "content": "The actual content text...",
  "content_type": "quote",
  "node_title": "Content_Title",
  "source": "The Narrow Way",
  "ping_pong": true
}
```

## Related Social Marketer Commits

- `8309e22` - feat: Optimize RSS parsing and add source to Social Effects API
- `64878dd` - docs: Update STATUS and AGENTS with Social Effects integration details
