import Foundation
import AVFoundation

/// Merges multiple audio files into one
class AudioMerger {
    
    /// Concatenate multiple audio files
    /// - Parameters:
    ///   - audioFiles: Array of audio file URLs in order
    ///   - outputPath: Where to save merged audio
    /// - Returns: URL of merged audio file
    func merge(audioFiles: [URL], outputPath: URL) async throws -> URL {
        let composition = AVMutableComposition()
        guard let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw AudioError.trackCreationFailed
        }

        var insertTime = CMTime.zero
        var filesToMerge = audioFiles

        // Insert 0.7-second silence between narration and CTA outro
        if audioFiles.count >= 2 {
            let silenceURL = outputPath.deletingLastPathComponent().appendingPathComponent("_silence_0.7s.m4a")
            if !FileManager.default.fileExists(atPath: silenceURL.path) {
                try SilenceGenerator.generateSilence(duration: 0.7, outputURL: silenceURL)
            }
            filesToMerge = [audioFiles[0], silenceURL, audioFiles[1]] + audioFiles.dropFirst(2)
        }

        for audioFile in filesToMerge {
            let asset = AVURLAsset(url: audioFile)
            guard let assetTrack = try await asset.loadTracks(withMediaType: .audio).first else {
                throw AudioError.audioLoadFailed
            }
            let duration = try await asset.load(.duration)
            let timeRange = CMTimeRange(start: .zero, duration: duration)
            try audioTrack.insertTimeRange(timeRange, of: assetTrack, at: insertTime)
            insertTime = CMTimeAdd(insertTime, duration)
        }

        // Export
        guard let exporter = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw AudioError.exporterCreationFailed
        }

        try? FileManager.default.removeItem(at: outputPath)
        exporter.outputURL = outputPath
        exporter.outputFileType = .m4a

        await exporter.export()

        if exporter.status == .completed {
            return outputPath
        } else {
            throw AudioError.exportFailed(exporter.error?.localizedDescription ?? "Unknown")
        }
    }
    
    enum AudioError: LocalizedError {
        case trackCreationFailed
        case audioLoadFailed
        case exporterCreationFailed
        case exportFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .trackCreationFailed: return "Failed to create audio track"
            case .audioLoadFailed: return "Failed to load audio file"
            case .exporterCreationFailed: return "Failed to create exporter"
            case .exportFailed(let reason): return "Export failed: \(reason)"
            }
        }
    }
}
