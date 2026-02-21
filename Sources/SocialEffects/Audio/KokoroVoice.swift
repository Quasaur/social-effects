import Foundation
import CryptoKit

/// Kokoro 82M TTS Service
/// Locally-installed neural TTS with high-quality voices
/// Replaces Apple Voice as primary TTS provider
/// 
/// Storage: Uses external drive "/Volumes/My Passport/social-media-content/social-effects/"
/// Fallback: Local storage "~/Developer/social-effects/output/" if external drive unavailable
public actor KokoroVoice {
    
    // MARK: - Properties
    
    private let cacheDir: URL
    private let venvPython: String
    private let kokoroScript: String
    
    /// External drive base path (primary storage)
    private static let externalDrivePath = "/Volumes/My Passport/social-media-content/social-effects"
    /// Local fallback path
    private static let localFallbackPath = "output"
    
    /// Available American male voices (matching ElevenLabs Donovan profile)
    public static let americanMaleVoices = [
        "am_adam",   // Deep, mature - closest to Donovan
        "am_echo",   // Smooth, authoritative
        "am_eric",   // Clear, professional
        "am_fenrir", // Strong, commanding
        "am_liam"    // Warm, resonant
    ]
    
    /// Default voice - Liam (warm, resonant)
    public static let defaultVoice = "am_liam"
    
    // MARK: - Initialization
    
    public init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let fm = FileManager.default
        
        // Determine storage location: external drive primary, local fallback
        let externalAudioDir = URL(fileURLWithPath: Self.externalDrivePath).appendingPathComponent("audio")
        let isExternalAvailable = fm.isWritableFile(atPath: Self.externalDrivePath)
        
        if isExternalAvailable {
            // Use external drive
            self.cacheDir = externalAudioDir.appendingPathComponent("cache")
            // Ensure directory exists
            try? fm.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        } else {
            // Fallback to local storage
            self.cacheDir = homeDir
                .appendingPathComponent("Developer/social-effects")
                .appendingPathComponent("output/cache/audio")
            try? fm.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
        
        // Python virtual environment
        self.venvPython = homeDir
            .appendingPathComponent("Developer/social-effects/.venv/bin/python")
            .path
        
        // Kokoro TTS script path
        self.kokoroScript = homeDir
            .appendingPathComponent("Developer/social-effects/scripts/kokoro_tts.py")
            .path
    }
    
    /// Check if external drive is available
    public static func isExternalDriveAvailable() -> Bool {
        return FileManager.default.isWritableFile(atPath: externalDrivePath)
    }
    
    /// Get current storage location info
    public func getStorageInfo() -> (isExternal: Bool, path: String) {
        let isExternal = cacheDir.path.contains(Self.externalDrivePath)
        return (isExternal, cacheDir.path)
    }
    
    // MARK: - Public Methods
    
    /// Generate TTS audio for given text
    /// - Parameters:
    ///   - text: Text to synthesize
    ///   - voice: Voice to use (defaults to am_adam)
    ///   - useCache: Whether to use caching (default: true)
    /// - Returns: Path to generated audio file
    public func synthesize(
        text: String,
        voice: String = KokoroVoice.defaultVoice,
        useCache: Bool = true
    ) async throws -> String {
        
        // Generate cache key from text hash
        let cacheKey = makeCacheKey(for: text, voice: voice)
        let outputPath = cacheDir.appendingPathComponent("\(cacheKey).wav").path
        
        // Check cache if enabled
        if useCache && FileManager.default.fileExists(atPath: outputPath) {
            print("Kokoro: Using cached audio for \"\(text.prefix(30))...\"")
            return outputPath
        }
        
        // Generate audio using Python script
        print("Kokoro: Generating TTS for \"\(text.prefix(30))...\" with voice \(voice)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: venvPython)
        process.arguments = [kokoroScript, text, voice, outputPath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { process in
                if process.terminationStatus == 0 {
                    continuation.resume(returning: outputPath)
                } else {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let error = String(data: data, encoding: .utf8) ?? "Unknown error"
                    continuation.resume(throwing: KokoroError.generationFailed(error))
                }
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: KokoroError.processStartFailed(error.localizedDescription))
            }
        }
    }
    
    /// Generate TTS audio with error handling
    /// Note: Apple Voice fallback removed - Kokoro is now the sole TTS provider
    public func synthesizeWithFallback(
        text: String,
        voice: String = KokoroVoice.defaultVoice
    ) async -> String {
        do {
            return try await synthesize(text: text, voice: voice)
        } catch {
            print("Kokoro TTS failed: \(error)")
            return ""
        }
    }
    
    /// Pre-generate and cache audio for multiple texts
    public func prewarmCache(texts: [String], voice: String = KokoroVoice.defaultVoice) async {
        await withTaskGroup(of: Void.self) { group in
            for text in texts {
                group.addTask {
                    _ = try? await self.synthesize(text: text, voice: voice)
                }
            }
        }
    }
    
    /// Clear the audio cache
    public func clearCache() throws {
        let files = try FileManager.default.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil)
        for file in files {
            try FileManager.default.removeItem(at: file)
        }
    }
    
    /// Get cache statistics
    public func getCacheStats() -> (count: Int, totalSize: Int64) {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: [.fileSizeKey]) else {
            return (0, 0)
        }
        
        let totalSize = files.reduce(Int64(0)) { sum, file in
            let attributes = try? FileManager.default.attributesOfItem(atPath: file.path)
            let size = attributes?[.size] as? Int64 ?? 0
            return sum + size
        }
        
        return (files.count, totalSize)
    }
    
    // MARK: - CTA Generation
    
    /// The call-to-action outro text
    /// Using "dot" instead of "." ensures TTS pronounces it correctly
    public static let ctaText = "For more wisdom treasure, visit Wisdom Book dot Life!"
    
    /// Generate CTA outro audio using Kokoro TTS
    /// - Returns: Path to generated CTA audio file
    public func generateCTA(voice: String = KokoroVoice.defaultVoice) async throws -> String {
        let ctaCacheKey = "cta_outro_\(voice)"
        let ctaPath = cacheDir.appendingPathComponent("\(ctaCacheKey).wav")
        
        // Check if CTA is already cached
        if FileManager.default.fileExists(atPath: ctaPath.path) {
            print("🎙️ CTA outro: Using cached \(voice) voice")
            return ctaPath.path
        }
        
        print("🎙️ Generating CTA outro with \(voice) voice...")
        let path = try await synthesize(text: Self.ctaText, voice: voice, useCache: false)
        
        // Rename to standardized CTA filename
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            try? fm.moveItem(atPath: path, toPath: ctaPath.path)
        }
        
        return ctaPath.path
    }
    
    // MARK: - Private Methods
    
    private func makeCacheKey(for text: String, voice: String) -> String {
        let input = "\(text)|\(voice)"
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Errors

public enum KokoroError: Error {
    case generationFailed(String)
    case processStartFailed(String)
    case invalidOutput
}
