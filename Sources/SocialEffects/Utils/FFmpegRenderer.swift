import Foundation
import AVFoundation

// MARK: - FFmpeg Renderer

enum FFmpegRenderer {
    
    static func render(
        backgroundPath: URL,
        graphicPath: URL,
        audioPath: URL,
        outputPath: URL,
        config: VideoConfig
    ) async throws {
        
        if !config.outputJSON { print("🎥 Rendering video with FFmpeg...") }
        
        let durationSeconds = try await AVURLAsset(url: audioPath).load(.duration).seconds
        let targetDuration = calculateTargetDuration(durationSeconds: durationSeconds)
        
        let ffmpegProcess = Process()
        ffmpegProcess.executableURL = findFFmpegPath()
        
        let hasBgMusic = FileManager.default.fileExists(atPath: Paths.backgroundMusicPath)
        
        ffmpegProcess.arguments = buildArguments(
            backgroundPath: backgroundPath,
            graphicPath: graphicPath,
            audioPath: audioPath,
            outputPath: outputPath,
            hasBgMusic: hasBgMusic,
            pingPong: config.pingPong,
            targetDuration: targetDuration,
            needsPadding: targetDuration > Double(12) + durationSeconds
        )
        
        try runFFmpeg(ffmpegProcess)
        
        if ffmpegProcess.terminationStatus != 0 {
            throw NSError(domain: "SocialEffects", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "FFmpeg failed"
            ])
        }
    }
    
    // MARK: - Helpers
    
    private static func findFFmpegPath() -> URL {
        let brewPath = "/opt/homebrew/bin/ffmpeg"
        return FileManager.default.fileExists(atPath: brewPath)
            ? URL(fileURLWithPath: brewPath)
            : URL(fileURLWithPath: "/usr/local/bin/ffmpeg")
    }
    
    private static func calculateTargetDuration(durationSeconds: Double) -> Double {
        let minDuration: Double = 15.0
        let audioEndTime = 12.0 + durationSeconds
        return max(minDuration, audioEndTime)
    }
    
    private static func buildArguments(
        backgroundPath: URL,
        graphicPath: URL,
        audioPath: URL,
        outputPath: URL,
        hasBgMusic: Bool,
        pingPong: Bool,
        targetDuration: Double,
        needsPadding: Bool
    ) -> [String] {
        
        var args = ["-y", "-nostdin"]
        
        if pingPong {
            args += ["-an", "-i", backgroundPath.path]
        } else {
            args += ["-stream_loop", "-1", "-an", "-i", backgroundPath.path]
        }
        
        args += ["-loop", "1", "-i", graphicPath.path]
        args += ["-i", audioPath.path]
        args += ["-f", "lavfi", "-t", "3", "-i", "color=black:size=1080x1920:rate=30"]
        
        if hasBgMusic {
            args += ["-stream_loop", "-1", "-i", Paths.backgroundMusicPath]
        }
        
        let filterComplex = buildFilterComplex(
            pingPong: pingPong,
            hasBgMusic: hasBgMusic
        )
        args += ["-filter_complex", filterComplex]
        args += ["-map", "[vout]", "-map", "[aout]"]
        
        args += ["-c:v", "libx264", "-preset", "medium", "-crf", "23"]
        args += ["-c:a", "aac", "-b:a", "192k"]
        
        if needsPadding {
            args += ["-t", String(targetDuration)]
        } else {
            args += ["-shortest"]
        }
        
        args += [outputPath.path]
        
        return args
    }
    
    private static func buildFilterComplex(pingPong: Bool, hasBgMusic: Bool) -> String {
        let bgFadeStart = 3
        let bgFadeDuration = 4
        let textFadeStart = 8
        let textFadeDuration = 4
        let narrationStart = 12
        
        if pingPong {
            let videoFilter = buildPingPongVideoFilter(
                bgFadeStart: bgFadeStart,
                bgFadeDuration: bgFadeDuration,
                textFadeStart: textFadeStart,
                textFadeDuration: textFadeDuration
            )
            let audioFilter = buildAudioFilter(
                narrationStart: narrationStart,
                hasBgMusic: hasBgMusic
            )
            return videoFilter + ";" + audioFilter
        } else {
            return buildStandardFilterComplex(
                bgFadeStart: bgFadeStart,
                bgFadeDuration: bgFadeDuration,
                textFadeStart: textFadeStart,
                textFadeDuration: textFadeDuration,
                narrationStart: narrationStart,
                hasBgMusic: hasBgMusic
            )
        }
    }
    
    private static func buildPingPongVideoFilter(
        bgFadeStart: Int,
        bgFadeDuration: Int,
        textFadeStart: Int,
        textFadeDuration: Int
    ) -> String {
        "[0:v]trim=duration=8,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,setpts=PTS-STARTPTS[orig];" +
        "[orig]split=3[orig1][revin][orig2];" +
        "[revin]reverse,setpts=PTS-STARTPTS[revout];" +
        "[orig1][revout][orig2]concat=n=3:v=1:a=0[pingpong];" +
        "[pingpong]fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
        "[3:v]scale=1080:1920,setsar=1[black];" +
        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
        "[1:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout]"
    }
    
    private static func buildAudioFilter(narrationStart: Int, hasBgMusic: Bool) -> String {
        if hasBgMusic {
            return "[2:a]adelay=\(narrationStart)000|\(narrationStart)000[narr];" +
                   "[4:a]volume=0.14[musiclow];" +
                   "[narr][musiclow]amix=inputs=2:duration=first:dropout_transition=2[aout]"
        } else {
            return "[2:a]adelay=\(narrationStart)000|\(narrationStart)000[aout]"
        }
    }
    
    private static func buildStandardFilterComplex(
        bgFadeStart: Int,
        bgFadeDuration: Int,
        textFadeStart: Int,
        textFadeDuration: Int,
        narrationStart: Int,
        hasBgMusic: Bool
    ) -> String {
        "[0:v]scale=1080:1920,setsar=1[black];" +
        "[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,format=rgba,fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
        "[2:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
        buildAudioFilter(narrationStart: narrationStart, hasBgMusic: hasBgMusic)
    }
    
    private static func runFFmpeg(_ process: Process) throws {
        let errPipe = Pipe()
        process.standardOutput = FileHandle.nullDevice
        process.standardError = errPipe
        
        try process.run()
        process.waitUntilExit()
    }
}
