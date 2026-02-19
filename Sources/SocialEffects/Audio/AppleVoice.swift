import Foundation
import AVFoundation

/// Apple TTS Voice Provider — Free, offline, unlimited
///
/// Uses AVSpeechSynthesizer.write() to capture audio buffers in-process,
/// bypassing the `say` CLI entirely. This avoids hangs caused by `say`
/// waiting for Neural Engine access in a CLI/terminal context.
///
/// Pipeline:
///   AVSpeechSynthesizer.write() → PCM WAV → trim silence → loudnorm → AAC 256k M4A
///
/// The `say` command is NOT used. BlackHole is NOT required.
/// AVSpeechSynthesizer handles Neural Engine access internally via AVFoundation.
class AppleVoice {
    
    // MARK: - Configuration
    
    struct VoiceConfig {
        let voiceName: String        // macOS voice name (e.g. "Jamie (Premium)")
        let rate: Float              // 0.0–1.0 (AVSpeechUtterance default ~0.5)
        let pitch: Float             // 0.5–2.0 (1.0 = normal)
        /// Loudness normalization target (LUFS). Applied as final step.
        let loudnormFilter: String
        
        /// Jamie Premium — authoritative, measured delivery
        static let jamie = VoiceConfig(
            voiceName: "Jamie (Premium)",
            rate: 0.45,
            pitch: 0.82,
            loudnormFilter: "loudnorm=I=-23.8:TP=-4.0:LRA=11"
        )
    }
    
    private let config: VoiceConfig
    private let ffmpegPath: String
    private let voice: AVSpeechSynthesisVoice?
    
    init(config: VoiceConfig = .jamie) {
        self.config = config
        self.ffmpegPath = "/opt/homebrew/bin/ffmpeg"
        
        // Resolve voice once at init time via AVFoundation (no subprocess)
        self.voice = AVSpeechSynthesisVoice.speechVoices().first { v in
            v.name == config.voiceName
        }
        
        if let v = voice {
            let qualityLabel: String
            switch v.quality {
            case .enhanced: qualityLabel = "Enhanced"
            case .premium:  qualityLabel = "Premium"
            default:        qualityLabel = "Default"
            }
            print("🎙️ Apple TTS: \(v.name) (\(qualityLabel))")
        } else {
            print("⚠️ Voice \"\(config.voiceName)\" not found — will attempt fallback")
        }
    }
    
    // MARK: - CTA Text
    
    /// The call-to-action outro spoken by Jamie at the end of each video
    static let ctaText = "For more wisdom treasure, visit wisdom book dot life!"
    
    // MARK: - Generate Voice
    
    /// Generates audio from text using AVSpeechSynthesizer.write()
    /// Pipeline: AVSpeechSynthesizer → PCM WAV → trim silence → loudnorm → AAC M4A
    func generateVoice(text: String, outputPath: URL) throws -> URL {
        guard let voice = voice else {
            throw AppleVoiceError.voiceNotInstalled(config.voiceName)
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let id = UUID().uuidString.prefix(8)
        let rawWAV = tempDir.appendingPathComponent("avspeech_\(id).wav")
        
        defer {
            try? FileManager.default.removeItem(at: rawWAV)
        }
        
        // Build utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = config.rate
        utterance.pitchMultiplier = config.pitch
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.15
        
        // Synthesize to buffer using AVSpeechSynthesizer.write()
        let synthesizer = AVSpeechSynthesizer()
        let semaphore = DispatchSemaphore(value: 0)
        var audioFile: AVAudioFile?
        var writeError: Error?
        var bufferCount = 0
        
        synthesizer.write(utterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }
            
            // Empty buffer signals completion
            if pcmBuffer.frameLength == 0 {
                semaphore.signal()
                return
            }
            
            do {
                if audioFile == nil {
                    // Create the WAV file with the format from the first buffer
                    audioFile = try AVAudioFile(
                        forWriting: rawWAV,
                        settings: pcmBuffer.format.settings
                    )
                }
                try audioFile?.write(from: pcmBuffer)
                bufferCount += 1
            } catch {
                writeError = error
                semaphore.signal()
            }
        }
        
        // Wait for synthesis to complete (generous timeout for long text)
        let timeoutSeconds = max(30.0, Double(text.count) / 5.0)
        let result = semaphore.wait(timeout: .now() + timeoutSeconds)
        
        if result == .timedOut {
            print("⚠️ AVSpeechSynthesizer.write() timed out after \(Int(timeoutSeconds))s")
            throw AppleVoiceError.synthesisTimedOut
        }
        
        if let error = writeError {
            throw AppleVoiceError.synthesisFailed(error.localizedDescription)
        }
        
        guard bufferCount > 0, FileManager.default.fileExists(atPath: rawWAV.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        // Post-process: trim silence + loudnorm + encode to AAC M4A
        let ffmpegProcess = Process()
        ffmpegProcess.executableURL = URL(fileURLWithPath: ffmpegPath)
        ffmpegProcess.arguments = [
            "-y", "-nostdin",
            "-i", rawWAV.path,
            "-af", "silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,\(config.loudnormFilter)",
            "-ar", "48000",
            "-c:a", "aac",
            "-b:a", "256k",
            outputPath.path
        ]
        
        let errPipe = Pipe()
        ffmpegProcess.standardOutput = FileHandle.nullDevice
        ffmpegProcess.standardError = errPipe
        try ffmpegProcess.run()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        ffmpegProcess.waitUntilExit()
        
        guard ffmpegProcess.terminationStatus == 0 else {
            let errMsg = String(data: errData, encoding: .utf8) ?? ""
            print("⚠️ FFmpeg error: \(errMsg.suffix(200))")
            throw AppleVoiceError.ffmpegFailed(ffmpegProcess.terminationStatus)
        }
        
        guard FileManager.default.fileExists(atPath: outputPath.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        print("✅ Generated voice (Apple/\(config.voiceName)): \(outputPath.lastPathComponent) [\(bufferCount) buffers]")
        return outputPath
    }
    
    /// Generates the CTA outro with Jamie, caching it for reuse.
    /// Returns the cached file if it already exists.
    func generateCTA(cacheDir: String = "output/cache/audio") throws -> URL {
        try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true)
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let cachedCTA = cwd.appendingPathComponent(cacheDir).appendingPathComponent("cta_outro_jamie.m4a")
        
        if FileManager.default.fileExists(atPath: cachedCTA.path) {
            return cachedCTA
        }
        
        print("🎙️ Generating CTA outro (Apple/Jamie)...")
        _ = try generateVoice(text: Self.ctaText, outputPath: cachedCTA)
        return cachedCTA
    }
    
    // MARK: - Availability Checks
    
    /// Checks if a voice is installed via AVSpeechSynthesisVoice.speechVoices().
    /// Purely in-process — no subprocesses, no `say`, no hang risk.
    static func isAvailable(voiceName: String = "Jamie (Premium)") -> Bool {
        return AVSpeechSynthesisVoice.speechVoices().contains { $0.name == voiceName }
    }
    
    // MARK: - Error Types
    
    enum AppleVoiceError: Error, LocalizedError {
        case synthesisFailed(String)
        case synthesisTimedOut
        case ffmpegFailed(Int32)
        case fileNotGenerated
        case voiceNotInstalled(String)
        
        var errorDescription: String? {
            switch self {
            case .synthesisFailed(let msg):
                return "AVSpeechSynthesizer failed: \(msg)"
            case .synthesisTimedOut:
                return "AVSpeechSynthesizer.write() timed out — Neural Engine may not be accessible"
            case .ffmpegFailed(let code):
                return "FFmpeg processing failed with exit code \(code)"
            case .fileNotGenerated:
                return "Audio file was not generated"
            case .voiceNotInstalled(let name):
                return "Voice '\(name)' is not installed. Download it from System Settings → Accessibility → Spoken Content → Manage Voices"
            }
        }
    }
}
