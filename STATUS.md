# Social Effects - MLT Integration Status

## Current Status

✅ **Project Setup Complete**

- GitHub repo: <https://github.com/Quasaur/social-effects>
- Swift package builds successfully
- MLT libraries linked

❌ **Runtime MLT Access** - Needs C Bridging

- MLT is a C/C++ library
- Swift needs bridging header to call MLT functions
- Current approach: direct dylib linking crashes at runtime

## Next Steps

### Option 1: C Bridging Header (Complex but Complete)

Create C wrapper for MLT functions:

1. Write C header exposing MLT API
2. Create module.modulemap
3. Call from Swift

**Pro**: Full MLT access, all effects available
**Con**: Complex setup, C++/Swift interop challenges

### Option 2: Command-Line MLT (melt)

Use Shotcut's command-line tool if available:

1. Generate MLT XML scripts
2. Execute `melt` command
3. Process output videos

**Pro**: No bridging needed, simpler
**Con**: Requires MLT CLI tool installation

### Option 3: Stick with AVFoundation

Implement the 10 approved effects in Social Marketer:

- Cross-Dissolve, Zoom Expand, Wipe, Card Flip H
- Particles, Light Leaks, Word Reveal, Cube Rotate
- Circular Collapse, Blinds

**Pro**: Native, already designed, no dependencies
**Con**: Not as "pro" as MLT potentially

## Recommendation

**For 15-30 second "pop" videos:**

Start with **Option 3 (AVFoundation)** because:

1. We've already identified 10 solid effects
2. Can be implemented immediately in Social Marketer
3. No complex C++ bridging
4. Can layer multiple effects for professional look

Return to MLT later if AVFoundation doesn't deliver enough "wow factor".

## App Architecture (If Using Social Effects)

```
Social Marketer (Client)
    ↓ XPC/URL Scheme
Social Effects (MLT Server)
    ↓ C Bridging
MLT Framework (Shotcut)
```

## Deliverable

**Question for user**:
Should we:

1. Continue with MLT integration (complex, high upside)
2. Implement AVFoundation effects in Social Marketer (proven, faster)
3. Both in parallel?
