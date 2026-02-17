import Foundation

/// Apple TTS Voice Provider — Free, offline, unlimited
///
/// Uses BlackHole virtual audio loopback to capture the real-time neural TTS engine
/// (same quality as System Settings preview). Falls back to `say -o` if BlackHole
/// is not installed.
///
/// Pipeline:
///   Neural (BlackHole): say (real-time neural) → BlackHole capture → trim silence → AAC 256k M4A
///   Fallback (say -o):  say -o (offline engine, 22kHz) → loudnorm → AAC 192k M4A
class AppleVoice {
    
    // MARK: - Configuration
    
    struct VoiceConfig {
        let voiceName: String        // macOS voice name
        /// Loudness normalization target (LUFS). Applied as final step.
        let loudnormFilter: String
        
        /// Jamie Premium — neural capture, loudness-matched to ElevenLabs Donovan
        static let jamie = VoiceConfig(
            voiceName: "Jamie (Premium)",
            loudnormFilter: "loudnorm=I=-23.8:TP=-4.0:LRA=11"
        )
    }
    
    private let config: VoiceConfig
    private let ffmpegPath: String
    
    /// Whether to use BlackHole neural capture (true) or say -o fallback (false)
    private(set) var useNeuralCapture: Bool
    
    init(config: VoiceConfig = .jamie) {
        self.config = config
        self.ffmpegPath = "/opt/homebrew/bin/ffmpeg"
        // Auto-detect BlackHole availability
        self.useNeuralCapture = Self.hasBlackHole()
        if useNeuralCapture {
            print("🎙️ Using neural capture (BlackHole) for Apple TTS")
        } else {
            print("⚠️ BlackHole not found — using say -o fallback (lower quality)")
        }
    }
    
    // MARK: - CTA Text
    
    /// The call-to-action outro spoken by Jamie at the end of each video
    static let ctaText = "For more wisdom treasure, visit wisdom book dot life!"
    
    // MARK: - Generate Voice
    
    /// Generates audio from text using Apple's neural TTS
    /// - Neural path: say (real-time) → BlackHole capture → trim silence → loudnorm → AAC 256k
    /// - Fallback path: say -o (offline 22kHz) → loudnorm → AAC 192k
    func generateVoice(text: String, outputPath: URL) throws -> URL {
        if useNeuralCapture {
            return try generateVoiceNeuralCapture(text: text, outputPath: outputPath)
        } else {
            return try generateVoiceSayFallback(text: text, outputPath: outputPath)
        }
    }
    
    // MARK: - Neural Capture (BlackHole)
    
    /// Captures real-time neural TTS via BlackHole virtual audio loopback.
    /// This produces the same quality as System Settings voice preview.
    private func generateVoiceNeuralCapture(text: String, outputPath: URL) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let id = UUID().uuidString.prefix(8)
        let rawCapture = tempDir.appendingPathComponent("neural_capture_\(id).wav")
        
        defer {
            try? FileManager.default.removeItem(at: rawCapture)
        }
        
        // Save and switch audio output to BlackHole
        let originalOutput = try switchAudioOutput(to: "BlackHole 2ch")
        
        defer {
            // Always restore original audio output
            if let original = originalOutput {
                try? switchAudioOutput(to: original)
            }
        }
        
        // Start FFmpeg capture from BlackHole in background
        let captureProcess = Process()
        captureProcess.executableURL = URL(fileURLWithPath: ffmpegPath)
        captureProcess.arguments = [
            "-y", "-nostdin",
            "-f", "avfoundation",
            "-i", ":BlackHole 2ch",
            "-ar", "48000",
            "-ac", "1",
            "-acodec", "pcm_s24le",
            rawCapture.path
        ]
        captureProcess.standardOutput = FileHandle.nullDevice
        captureProcess.standardError = FileHandle.nullDevice
        try captureProcess.run()
        
        // Small delay to ensure FFmpeg is listening
        Thread.sleep(forTimeInterval: 0.5)
        
        // Speak with real-time neural engine (NOT -o, which uses degraded offline engine)
        let sayProcess = Process()
        sayProcess.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        sayProcess.arguments = ["-v", config.voiceName, text]
        try sayProcess.run()
        sayProcess.waitUntilExit()
        
        guard sayProcess.terminationStatus == 0 else {
            captureProcess.terminate()
            throw AppleVoiceError.sayFailed(sayProcess.terminationStatus)
        }
        
        // Brief tail silence for clean ending
        Thread.sleep(forTimeInterval: 0.3)
        
        // Stop capture
        captureProcess.terminate()
        captureProcess.waitUntilExit()
        
        guard FileManager.default.fileExists(atPath: rawCapture.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        // Trim silence + loudnorm + encode to AAC M4A
        let ffmpegProcess = Process()
        ffmpegProcess.executableURL = URL(fileURLWithPath: ffmpegPath)
        ffmpegProcess.arguments = [
            "-y", "-nostdin",
            "-i", rawCapture.path,
            "-af", "silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,\(config.loudnormFilter)",
            "-ar", "48000",
            "-c:a", "aac",
            "-b:a", "256k",
            outputPath.path
        ]
        ffmpegProcess.standardOutput = FileHandle.nullDevice
        ffmpegProcess.standardError = FileHandle.nullDevice
        try ffmpegProcess.run()
        ffmpegProcess.waitUntilExit()
        
        guard ffmpegProcess.terminationStatus == 0 else {
            throw AppleVoiceError.ffmpegFailed(ffmpegProcess.terminationStatus)
        }
        
        guard FileManager.default.fileExists(atPath: outputPath.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        print("✅ Generated voice (Apple/Jamie neural): \(outputPath.lastPathComponent)")
        return outputPath
    }
    
    // MARK: - Fallback (say -o)
    
    /// Fallback: uses `say -o` offline engine (22kHz, lower quality)
    private func generateVoiceSayFallback(text: String, outputPath: URL) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let id = UUID().uuidString.prefix(8)
        let rawCaf = tempDir.appendingPathComponent("apple_raw_\(id).caf")
        
        defer {
            try? FileManager.default.removeItem(at: rawCaf)
        }
        
        // Generate raw TTS with `say -o` (offline engine, 22kHz)
        let sayProcess = Process()
        sayProcess.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        sayProcess.arguments = [
            "-v", config.voiceName,
            "--file-format=caff",
            "--data-format=LEF32@48000",
            "-o", rawCaf.path,
            text
        ]
        try sayProcess.run()
        sayProcess.waitUntilExit()
        
        guard sayProcess.terminationStatus == 0 else {
            throw AppleVoiceError.sayFailed(sayProcess.terminationStatus)
        }
        
        guard FileManager.default.fileExists(atPath: rawCaf.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        // Loudnorm only (no pitch/tempo manipulation) → AAC M4A
        let ffmpegProcess = Process()
        ffmpegProcess.executableURL = URL(fileURLWithPath: ffmpegPath)
        ffmpegProcess.arguments = [
            "-y", "-nostdin",
            "-i", rawCaf.path,
            "-af", config.loudnormFilter,
            "-ar", "48000",
            "-c:a", "aac",
            "-b:a", "192k",
            outputPath.path
        ]
        ffmpegProcess.standardOutput = FileHandle.nullDevice
        ffmpegProcess.standardError = FileHandle.nullDevice
        try ffmpegProcess.run()
        ffmpegProcess.waitUntilExit()
        
        guard ffmpegProcess.terminationStatus == 0 else {
            throw AppleVoiceError.ffmpegFailed(ffmpegProcess.terminationStatus)
        }
        
        guard FileManager.default.fileExists(atPath: outputPath.path) else {
            throw AppleVoiceError.fileNotGenerated
        }
        
        print("✅ Generated voice (Apple/Jamie fallback): \(outputPath.lastPathComponent)")
        return outputPath
    }
    
    // MARK: - Audio Output Switching
    
    /// Switches macOS audio output device. Returns the previous output name.
    @discardableResult
    private func switchAudioOutput(to deviceName: String) throws -> String? {
        // Get current output
        let getCurrent = Process()
        getCurrent.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        getCurrent.arguments = ["SwitchAudioSource", "-c"]
        let currentPipe = Pipe()
        getCurrent.standardOutput = currentPipe
        getCurrent.standardError = FileHandle.nullDevice
        
        var previousOutput: String? = nil
        do {
            try getCurrent.run()
            getCurrent.waitUntilExit()
            let data = currentPipe.fileHandleForReading.readDataToEndOfFile()
            previousOutput = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            // SwitchAudioSource may not be installed yet
        }
        
        // Switch to target device
        let switchProc = Process()
        switchProc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        switchProc.arguments = ["SwitchAudioSource", "-s", deviceName, "-t", "output"]
        switchProc.standardOutput = FileHandle.nullDevice
        switchProc.standardError = FileHandle.nullDevice
        try switchProc.run()
        switchProc.waitUntilExit()
        
        guard switchProc.terminationStatus == 0 else {
            throw AppleVoiceError.audioSwitchFailed(deviceName)
        }
        
        return previousOutput
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
    
    /// Checks if Jamie (Premium) voice is installed
    static func isAvailable(voiceName: String = "Jamie (Premium)") -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        process.arguments = ["-v", "?"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.contains(voiceName)
        } catch {
            return false
        }
    }
    
    /// Checks if BlackHole virtual audio device is available
    static func hasBlackHole() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        process.arguments = ["-f", "avfoundation", "-list_devices", "true", "-i", ""]
        let pipe = Pipe()
        process.standardOutput = FileHandle.nullDevice
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.lowercased().contains("blackhole")
        } catch {
            return false
        }
    }
    
    /// Checks if SwitchAudioSource is installed (needed for neural capture)
    static var hasSwitchAudioSource: Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["SwitchAudioSource"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    // MARK: - Error Types
    
    enum AppleVoiceError: Error, LocalizedError {
        case sayFailed(Int32)
        case ffmpegFailed(Int32)
        case fileNotGenerated
        case voiceNotInstalled(String)
        case audioSwitchFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .sayFailed(let code):
                return "macOS say command failed with exit code \(code)"
            case .ffmpegFailed(let code):
                return "FFmpeg processing failed with exit code \(code)"
            case .fileNotGenerated:
                return "Audio file was not generated"
            case .voiceNotInstalled(let name):
                return "Voice '\(name)' is not installed. Download it from System Settings → Accessibility → Spoken Content"
            case .audioSwitchFailed(let device):
                return "Failed to switch audio output to '\(device)'. Is SwitchAudioSource installed? (brew install switchaudio-osx)"
            }
        }
    }
}
