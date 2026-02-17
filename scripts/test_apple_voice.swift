#!/usr/bin/swift
import AVFoundation
import Foundation

// Test text — same stoic content style as our videos
let testText = "The ultimate measure of a man is not where he stands in moments of comfort and convenience, but where he stands at times of challenge and controversy."

let outputDir = "/tmp/apple_voice_tests"
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

// Find Jamie voice
guard let jamieVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { 
    $0.name.contains("Jamie") && $0.quality.rawValue >= 2 
}) else {
    print("❌ Jamie Premium voice not found!")
    print("Available voices:")
    for v in AVSpeechSynthesisVoice.speechVoices().filter({ $0.language.starts(with: "en") }) {
        print("  \(v.name) (\(v.language)) quality=\(v.quality.rawValue)")
    }
    exit(1)
}

print("✅ Found: \(jamieVoice.name), quality=\(jamieVoice.quality.rawValue)")
print("═══════════════════════════════════════════════════")

// Parameter matrix to test
// Rate: 0.4 = slow/measured, 0.5 = default, 0.55 = slightly faster
// Pitch: 0.8 = deeper, 1.0 = normal, 1.2 = higher
// Donovan characteristics: slow, deep, measured, authoritative
struct VoiceConfig {
    let label: String
    let rate: Float      // 0.0-1.0 (default ~0.5)
    let pitch: Float     // 0.5-2.0 (default 1.0, lower = deeper)
}

let configs: [VoiceConfig] = [
    // Baseline
    VoiceConfig(label: "01_baseline",           rate: 0.5,  pitch: 1.0),
    
    // Deeper pitch variations
    VoiceConfig(label: "02_deep",               rate: 0.5,  pitch: 0.85),
    VoiceConfig(label: "03_very_deep",          rate: 0.5,  pitch: 0.75),
    
    // Slower + deeper (Donovan-like territory)
    VoiceConfig(label: "04_slow_deep",          rate: 0.42, pitch: 0.85),
    VoiceConfig(label: "05_slow_very_deep",     rate: 0.42, pitch: 0.75),
    VoiceConfig(label: "06_measured_deep",      rate: 0.45, pitch: 0.80),
    
    // Authoritative: slow, moderately deep
    VoiceConfig(label: "07_authoritative",      rate: 0.43, pitch: 0.82),
    VoiceConfig(label: "08_stoic_narrator",     rate: 0.40, pitch: 0.78),
    
    // Slightly faster but deep  
    VoiceConfig(label: "09_warm_deep",          rate: 0.48, pitch: 0.83),
    VoiceConfig(label: "10_conversational_deep", rate: 0.50, pitch: 0.80),
]

let synthesizer = AVSpeechSynthesizer()

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let semaphore = DispatchSemaphore(value: 0)
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        semaphore.signal()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        semaphore.signal()
    }
}

let delegate = SpeechDelegate()
synthesizer.delegate = delegate

print("\nGenerating 10 voice samples to: \(outputDir)/")
print("───────────────────────────────────────────────────\n")

for config in configs {
    let utterance = AVSpeechUtterance(string: testText)
    utterance.voice = jamieVoice
    utterance.rate = config.rate
    utterance.pitchMultiplier = config.pitch
    utterance.volume = 1.0
    // Pre/post delays for cleaner audio
    utterance.preUtteranceDelay = 0.3
    utterance.postUtteranceDelay = 0.3
    
    let outputPath = "\(outputDir)/jamie_\(config.label).aiff"
    let outputURL = URL(fileURLWithPath: outputPath)
    
    // Remove existing file
    try? FileManager.default.removeItem(at: outputURL)
    
    print("🎙️ \(config.label): rate=\(config.rate), pitch=\(config.pitch)")
    
    // Write to file
    synthesizer.write(utterance) { buffer in
        guard let pcmBuffer = buffer as? AVAudioPCMBuffer,
              pcmBuffer.frameLength > 0 else { return }
        
        // Create or append to audio file
        do {
            let audioFile: AVAudioFile
            if FileManager.default.fileExists(atPath: outputPath) {
                audioFile = try AVAudioFile(forWriting: outputURL, settings: pcmBuffer.format.settings, commonFormat: pcmBuffer.format.commonFormat, interleaved: pcmBuffer.format.isInterleaved)
            } else {
                audioFile = try AVAudioFile(forWriting: outputURL, settings: pcmBuffer.format.settings)
            }
            try audioFile.write(from: pcmBuffer)
        } catch {
            // File already exists, append
            if let audioFile = try? AVAudioFile(forWriting: outputURL, settings: pcmBuffer.format.settings, commonFormat: pcmBuffer.format.commonFormat, interleaved: pcmBuffer.format.isInterleaved) {
                try? audioFile.write(from: pcmBuffer)
            }
        }
    }
    
    delegate.semaphore.wait()
    
    // Convert to MP3 for easy playback
    let mp3Path = "\(outputDir)/jamie_\(config.label).mp3"
    let ffmpeg = Process()
    ffmpeg.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
    ffmpeg.arguments = ["-y", "-nostdin", "-i", outputPath, "-codec:a", "libmp3lame", "-qscale:a", "2", mp3Path]
    ffmpeg.standardOutput = FileHandle.nullDevice
    ffmpeg.standardError = FileHandle.nullDevice
    try? ffmpeg.run()
    ffmpeg.waitUntilExit()
    
    if FileManager.default.fileExists(atPath: mp3Path) {
        let size = (try? FileManager.default.attributesOfItem(atPath: mp3Path)[.size] as? Int) ?? 0
        print("   ✅ → \(config.label).mp3 (\(size / 1024)KB)")
    } else {
        print("   ⚠️  MP3 conversion failed, AIFF at: \(outputPath)")
    }
}

print("\n═══════════════════════════════════════════════════")
print("✅ Done! Listen to samples at: \(outputDir)/")
print("\nBest candidates for Donovan-like quality:")
print("  • jamie_04_slow_deep.mp3")
print("  • jamie_07_authoritative.mp3")
print("  • jamie_08_stoic_narrator.mp3")
print("\nPlay all with:")
print("  open \(outputDir)/jamie_*.mp3")
print("  # Or one at a time:")
print("  afplay \(outputDir)/jamie_07_authoritative.mp3")
