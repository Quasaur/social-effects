#!/usr/bin/swift
import AVFoundation
import Foundation

// Text to generate
let ultimateText = "That which is Ultimate cannot be Ultimate unless \"it\" (He) is also PERSONAL."
let outputPath = "/Users/quasaur/Developer/social-effects/output/Jamie_Voice_Ultimate.m4a"

// Find Jamie Premium voice
 guard let jamieVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { 
    $0.name == "Jamie (Premium)"
}) else {
    print("❌ Jamie (Premium) voice not found!")
    print("Please install it from: System Settings → Accessibility → Spoken Content → System Voice")
    print("\nAvailable premium voices:")
    for v in AVSpeechSynthesisVoice.speechVoices().filter({ $0.quality == .premium && $0.language.starts(with: "en") }) {
        print("  • \(v.name)")
    }
    exit(1)
}

print("✅ Found: \(jamieVoice.name) (Premium)")
print("🎙️ Generating ULTIMATE text...")
print("═══════════════════════════════════════════════════")

// Create output directory if needed
try? FileManager.default.createDirectory(atPath: "/Users/quasaur/Developer/social-effects/output", withIntermediateDirectories: true)

// Remove existing file
try? FileManager.default.removeItem(atPath: outputPath)

// Settings optimized for authoritative, measured delivery (matching AppleVoice config)
let rate: Float = 0.45
let pitch: Float = 0.82

let utterance = AVSpeechUtterance(string: ultimateText)
utterance.voice = jamieVoice
utterance.rate = rate
utterance.pitchMultiplier = pitch
utterance.volume = 1.0
utterance.preUtteranceDelay = 0.15
utterance.postUtteranceDelay = 0.15

let tempDir = FileManager.default.temporaryDirectory
let rawWAV = tempDir.appendingPathComponent("jamie_ultimate_\(UUID().uuidString.prefix(8)).wav")

// Synthesize to buffer
let synthesizer = AVSpeechSynthesizer()
let semaphore = DispatchSemaphore(value: 0)
var audioFile: AVAudioFile?
var bufferCount = 0

synthesizer.write(utterance) { buffer in
    guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }
    
    if pcmBuffer.frameLength == 0 {
        semaphore.signal()
        return
    }
    
    do {
        if audioFile == nil {
            audioFile = try AVAudioFile(
                forWriting: rawWAV,
                settings: pcmBuffer.format.settings
            )
        }
        try audioFile?.write(from: pcmBuffer)
        bufferCount += 1
    } catch {
        print("⚠️ Write error: \(error)")
        semaphore.signal()
    }
}

let timeoutResult = semaphore.wait(timeout: .now() + 30)
if timeoutResult == .timedOut {
    print("❌ Synthesis timed out")
    exit(1)
}

guard bufferCount > 0, FileManager.default.fileExists(atPath: rawWAV.path) else {
    print("❌ No audio generated")
    exit(1)
}

print("✅ Synthesized \(bufferCount) buffers")

// Post-process with FFmpeg (trim silence + loudnorm + AAC)
let loudnormFilter = "loudnorm=I=-23.8:TP=-4.0:LRA=11"

let ffmpeg = Process()
ffmpeg.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
ffmpeg.arguments = [
    "-y", "-nostdin",
    "-i", rawWAV.path,
    "-af", "silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,\(loudnormFilter)",
    "-ar", "48000",
    "-c:a", "aac",
    "-b:a", "256k",
    outputPath
]

let errPipe = Pipe()
ffmpeg.standardOutput = FileHandle.nullDevice
ffmpeg.standardError = errPipe

do {
    try ffmpeg.run()
    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
    ffmpeg.waitUntilExit()
    
    // Clean up temp file
    try? FileManager.default.removeItem(at: rawWAV)
    
    if ffmpeg.terminationStatus == 0 {
        if let attrs = try? FileManager.default.attributesOfItem(atPath: outputPath),
           let size = attrs[.size] as? Int {
            print("\n✅ SUCCESS!")
            print("📁 Saved to: \(outputPath)")
            print("📊 Size: \(size / 1024) KB")
            print("🔧 Settings: rate=\(rate), pitch=\(pitch)")
            print("\n🎧 Play with:")
            print("   afplay \(outputPath)")
        }
    } else {
        let errMsg = String(data: errData, encoding: .utf8) ?? "Unknown error"
        print("❌ FFmpeg failed: \(errMsg.suffix(200))")
        exit(1)
    }
} catch {
    print("❌ Error: \(error)")
    exit(1)
}
