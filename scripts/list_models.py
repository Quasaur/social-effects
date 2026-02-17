#!/usr/bin/env python3
from TTS.api import TTS
t = TTS()
mm = t.list_models()
# ModelManager object - try different access patterns
if hasattr(mm, 'models_dict'):
    for k in mm.models_dict:
        if 'xtts' in k.lower() or 'vits' in k.lower():
            print(k)
elif hasattr(mm, 'list_tts_models'):
    for m in mm.list_tts_models():
        print(m)
else:
    print("Attrs:", [a for a in dir(mm) if not a.startswith('_')])
