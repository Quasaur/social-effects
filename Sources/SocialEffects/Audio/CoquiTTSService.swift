import Foundation

/// Coqui TTS Service - Free, open-source, local TTS
/// 
/// Coqui TTS provides high-quality neural text-to-speech synthesis
/// that runs locally on your machine. No API keys or internet required.
///
/// Installation required:
///   pip install TTS
///
/// The service uses the default model (tts_models/en/ljspeech/tacotron2-DDC) 
/// or can be configured to use other models.
class CoquiTTSService {
    
    // MARK: - Configuration
    
    struct Config {
        let modelName: String
        let vocoder: String?
        let speakerId: String?
        let languageId: String?
        
        /// Default English model - good quality, fast
        static let `default` = Config(
            modelName: "tts_models/en/ljspeech/tacotron2-DDC",
            vocoder: nil,
            speakerId: nil,
            languageId: nil
        )
        
        /// Multi-speaker model with better quality
        static let multiSpeaker = Config(
            modelName: "tts_models/en/vctk/vits",
            vocoder: nil,
            speakerId: "p225",  // Male voice (p225-p376 available)
            languageId: nil
        )
        
        /// High-quality female voice
        static let female = Config(
            modelName: "tts_models/en/ljspeech/glow-tts",
            vocoder: "vocoder_models/en/ljspeech/multiband-melgan",
            speakerId: nil,
            languageId: nil
        )
    }
    
    private let config: Config
    private let ffmpegPath: String
    
    enum CoquiError: Error, LocalizedError {
        case ttsNotInstalled
        case synthesisFailed(String)
        case ffmpegFailed(Int32)
        case fileNotGenerated
        
        var errorDescription: String? {
            switch self {
            case .ttsNotInstalled:
                return "Coqui TTS is not installed. Run: pip install TTS"
            case .synthesisFailed(let msg):
                return "TTS synthesis failed: \(msg)"
            case .ffmpegFailed(let code):
                return "FFmpeg processing failed with exit code \(code)"
            case .fileNotGenerated:
                return "Audio file was not generated"
            }
        }
    }
    
    init(config: Config = .multiSpeaker) throws {
        self.config = config
        self.ffmpegPath = "/opt/homebrew/bin/ffmpeg"
        
        // Check if TTS is installed
        let checkProcess = Process()
        checkProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        checkProcess.arguments = ["tts"]
        checkProcess.standardOutput = FileHandle.nullDevice
        checkProcess.standardError = FileHandle.nullDevice
        try? checkProcess.run()
        checkProcess.waitUntilExit()
        
        if checkProcess.terminationStatus != 0 {
            throw CoquiError.ttsNotInstalled
        }
    }
    
    // MARK: - Generate Voice
    
    /// Generates audio from text using Coqui TTS
    /// Pipeline: Coqui TTS → WAV → trim silence → loudnorm → AAC M4A
    func generateVoice(text: String, outputPath: URL) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let id = UUID().uuidString.prefix(8)
        let rawWAV = tempDir.appendingPathComponent("coqui_\(id).wav")
        
        defer {
            try? FileManager.default.removeItem(at: rawWAV)
        }
        
        print("🎙️ Generating voice with Coqui TTS...")
        print("   Model: \(config.modelName)")
        
        // Build TTS command
        var ttsArgs = [
            "--model_name", config.modelName,
            "--text", text,
            "--out_path", rawWAV.path
        ]
        
        if let vocoder = config.vocoder {
            ttsArgs += ["--vocoder_name", vocoder]
        }
        
        if let speakerId = config.speakerId {
            ttsArgs += ["--speaker_id", speakerId]
        }
        
        if let languageId = config.languageId {
            ttsArgs += ["--language_id", languageId]
        }
        
        // Run TTS
        let ttsProcess = Process()
        ttsProcess.executableURL = URL(fileURLWithPath: "/usr/local/bin/tts")
        ttsProcess.arguments = ttsArgs
        
        let errPipe = Pipe()
        ttsProcess.standardOutput = FileHandle.nullDevice
        ttsProcess.standardError = errPipe
        
        try ttsProcess.run()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        ttsProcess.waitUntilExit()
        
        if ttsProcess.terminationStatus != 0 {
            let errMsg = String(data: errData, encoding: .utf8) ?? "Unknown error"
            throw CoquiError.synthesisFailed(errMsg)
        }
        
        guard FileManager.default.fileExists(atPath: rawWAV.path) else {
            throw CoquiError.fileNotGenerated
        }
        
        print("✅ TTS synthesis complete")
        
        // Post-process: trim silence + loudnorm + encode to AAC M4A
        let loudnormFilter = "loudnorm=I=-23.8:TP=-4.0:LRA=11"
        
        let ffmpegProcess = Process()
        ffmpegProcess.executableURL = URL(fileURLWithPath: ffmpegPath)
        ffmpegProcess.arguments = [
            "-y", "-nostdin",
            "-i", rawWAV.path,
            "-af", "silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,silenceremove=start_periods=1:start_silence=0.05:start_threshold=-40dB,areverse,\(loudnormFilter)",
            "-ar", "48000",
            "-c:a", "aac",
            "-b:a", "256k",
            outputPath.path
        ]
        
        let ffmpegErrPipe = Pipe()
        ffmpegProcess.standardOutput = FileHandle.nullDevice
        ffmpegProcess.standardError = ffmpegErrPipe
        try ffmpegProcess.run()
        let ffmpegErrData = ffmpegErrPipe.fileHandleForReading.readDataToEndOfFile()
        ffmpegProcess.waitUntilExit()
        
        guard ffmpegProcess.terminationStatus == 0 else {
            let errMsg = String(data: ffmpegErrData, encoding: .utf8) ?? ""
            print("⚠️ FFmpeg error: \(errMsg.suffix(200))")
            throw CoquiError.ffmpegFailed(ffmpegProcess.terminationStatus)
        }
        
        guard FileManager.default.fileExists(atPath: outputPath.path) else {
            throw CoquiError.fileNotGenerated
        }
        
        if let attrs = try? FileManager.default.attributesOfItem(atPath: outputPath.path),
           let size = attrs[.size] as? Int {
            print("✅ Generated voice (Coqui TTS): \(outputPath.lastPathComponent) (\(size / 1024) KB)")
        }
        
        return outputPath
    }
    
    // MARK: - Availability Check
    
    static func isAvailable() -> Bool {
        let checkProcess = Process()
        checkProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        checkProcess.arguments = ["tts"]
        checkProcess.standardOutput = FileHandle.nullDevice
        checkProcess.standardError = FileHandle.nullDevice
        try? checkProcess.run()
        checkProcess.waitUntilExit()
        return checkProcess.terminationStatus == 0
    }
    
    // MARK: - List Available Models
    
    static func listModels() {
        print("📋 Listing available Coqui TTS models...")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/tts")
        process.arguments = ["--list_models"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }
}
