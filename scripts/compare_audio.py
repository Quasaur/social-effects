import librosa
import numpy as np
import sys

# Usage: python compare_audio.py <reference_audio> <tts_audio>

def analyze_audio(file_path):
    y, sr = librosa.load(file_path, sr=None)
    duration = librosa.get_duration(y=y, sr=sr)
    rms = np.mean(librosa.feature.rms(y=y))
    pitches, magnitudes = librosa.piptrack(y=y, sr=sr)
    pitch_values = pitches[magnitudes > np.median(magnitudes)]
    mean_pitch = np.mean(pitch_values) if len(pitch_values) > 0 else 0
    return {
        'duration': duration,
        'rms': rms,
        'mean_pitch': mean_pitch,
        'waveform': y
    }

def compare_waveforms(wave1, wave2):
    min_len = min(len(wave1), len(wave2))
    corr = np.corrcoef(wave1[:min_len], wave2[:min_len])[0, 1]
    return corr

def main():
    if len(sys.argv) != 3:
        print('Usage: python compare_audio.py <reference_audio> <tts_audio>')
        sys.exit(1)
    ref_file = sys.argv[1]
    tts_file = sys.argv[2]
    ref = analyze_audio(ref_file)
    tts = analyze_audio(tts_file)
    print(f"Reference duration: {ref['duration']:.2f}s")
    print(f"TTS duration: {tts['duration']:.2f}s")
    print(f"Reference RMS: {ref['rms']:.4f}")
    print(f"TTS RMS: {tts['rms']:.4f}")
    print(f"Reference mean pitch: {ref['mean_pitch']:.2f} Hz")
    print(f"TTS mean pitch: {tts['mean_pitch']:.2f} Hz")
    waveform_corr = compare_waveforms(ref['waveform'], tts['waveform'])
    print(f"Waveform similarity (correlation): {waveform_corr:.4f}")

if __name__ == '__main__':
    main()
