import Foundation
import AVFoundation

// MARK: - Video Renderer

enum VideoRenderer {
    
    static func render(config: VideoConfig) async {
        let graphicsGenerator = TextGraphicsGenerator()
        let audioMerger = AudioMerger()
        let kokoroVoice = KokoroVoice()
        
        let tempDir = FileManager.default.temporaryDirectory
        let timestamp = Int(Date().timeIntervalSince1970)
        let baseFilename = "rss_video_\(timestamp)"
        
        let graphicPath = tempDir.appendingPathComponent("\(baseFilename)_graphic.png")
        let mergedAudioPath = tempDir.appendingPathComponent("\(baseFilename)_audio.m4a")
        
        let finalVideoPath = determineOutputPath(config: config, timestamp: timestamp)
        
        do {
            // 1. Background
            let backgroundPath = try await BackgroundSelector.select(
                backgroundArg: config.background,
                timestamp: timestamp,
                outputJSON: config.outputJSON
            )
            
            // 2. Graphic
            if !config.outputJSON { print("🖼️ Generating graphic...") }
            let borderStyle = BorderSelector.dailyBorder()
            
            // Only pass source for QUOTE and PASSAGE types, not for THOUGHT
            let shouldShowSource = config.contentType == "quote" || config.contentType == "passage"
            let sourceToShow = shouldShowSource ? config.source : ""
            
            _ = try graphicsGenerator.generate(
                title: config.title,
                text: config.content,
                source: sourceToShow,
                outputPath: graphicPath,
                border: borderStyle
            )
            
            // 3. Audio
            let narrationWAVPath = tempDir.appendingPathComponent("\(baseFilename)_narration.wav")
            
            if let audioFile = config.audioFile {
                try copyAudioFile(audioFile, to: narrationWAVPath)
            } else {
                if !config.outputJSON { print("🎙️ Generating narration...") }
                let narrationWAV = try await kokoroVoice.synthesize(
                    text: config.content,
                    voice: KokoroVoice.defaultVoice
                )
                try FileManager.default.copyItem(
                    at: URL(fileURLWithPath: narrationWAV),
                    to: narrationWAVPath
                )
            }
            
            // 4. Merge audio
            let ctaWAV = try await kokoroVoice.generateCTA(voice: KokoroVoice.defaultVoice)
            _ = try await audioMerger.merge(
                audioFiles: [narrationWAVPath, URL(fileURLWithPath: ctaWAV)],
                outputPath: mergedAudioPath
            )
            
            // 5. Render
            try await FFmpegRenderer.render(
                backgroundPath: backgroundPath,
                graphicPath: graphicPath,
                audioPath: mergedAudioPath,
                outputPath: finalVideoPath,
                config: config
            )
            
            outputResult(config: config, path: finalVideoPath)
            cleanup(tempFiles: [graphicPath, narrationWAVPath, mergedAudioPath])
            
        } catch {
            handleError(error, outputJSON: config.outputJSON)
        }
    }
    
    // MARK: - Helpers
    
    private static func determineOutputPath(config: VideoConfig, timestamp: Int) -> URL {
        if let out = config.outputPath {
            return URL(fileURLWithPath: out)
        }
        
        let videoDir = Paths.videoOutputDirectory()
        return videoDir.appendingPathComponent("rss_video_\(timestamp).mp4")
    }
    
    private static func copyAudioFile(_ source: String, to destination: URL) throws {
        let userAudioURL = URL(fileURLWithPath: source)
        if FileManager.default.fileExists(atPath: userAudioURL.path) {
            try FileManager.default.copyItem(at: userAudioURL, to: destination)
        } else {
            throw NSError(domain: "SocialEffects", code: 4, userInfo: [
                NSLocalizedDescriptionKey: "Provided audio file not found: \(source)"
            ])
        }
    }
    
    private static func outputResult(config: VideoConfig, path: URL) {
        if config.outputJSON {
            print("{\"success\":true,\"videoPath\":\"\(path.path)\"}")
        } else {
            print("✅ Video saved to: \(path.path)")
        }
    }
    
    private static func cleanup(tempFiles: [URL]) {
        for file in tempFiles {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    private static func handleError(_ error: Error, outputJSON: Bool) {
        if outputJSON {
            print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
        } else {
            print("❌ Error: \(error.localizedDescription)")
        }
        exit(1)
    }
}
