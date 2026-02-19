#!/usr/bin/env python3
"""
Kokoro TTS Service Script
Called from Swift to generate TTS audio using Kokoro 82M
"""

import sys
import os
import json
import hashlib
from pathlib import Path

def generate_tts(text, voice, output_path):
    """Generate TTS audio using Kokoro"""
    try:
        from kokoro import KPipeline
        import soundfile as sf
        
        # Initialize pipeline (American English)
        pipeline = KPipeline(lang_code='a')
        
        # Generate audio
        for i, (gs, ps, audio) in enumerate(pipeline(text, voice=voice)):
            sf.write(output_path, audio, 24000)
            return True
        
        return False
    except Exception as e:
        print(f"Error generating TTS: {e}", file=sys.stderr)
        return False

def main():
    if len(sys.argv) < 4:
        print("Usage: kokoro_tts.py <text> <voice> <output_path>")
        sys.exit(1)
    
    text = sys.argv[1]
    voice = sys.argv[2]
    output_path = sys.argv[3]
    
    # Ensure output directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    
    success = generate_tts(text, voice, output_path)
    
    if success:
        print(f"SUCCESS:{output_path}")
        sys.exit(0)
    else:
        print("FAILED")
        sys.exit(1)

if __name__ == "__main__":
    main()
