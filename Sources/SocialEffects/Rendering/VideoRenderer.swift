import Foundation
import AVFoundation
import AppKit
import CoreMedia

/// Video renderer using AVAssetWriter for frame-by-frame rendering
class VideoRenderer {
    
    func render(
        graphic: URL,
        audio: URL,
        effect: String,
        duration: Int,
        output: URL
    ) async throws -> URL {
        
        print("🎥 Rendering video...")
        print("   Graphic: \(graphic.lastPathComponent)")
        print("   Audio: \(audio.lastPathComponent)")
        
        // Load image
        guard let image = NSImage(contentsOf: graphic),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw VideoError.imageLoadFailed
        }
        
        // Load audio to get duration
        let audioAsset = AVURLAsset(url: audio)
        let audioDuration = try await audioAsset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(audioDuration)
        
        print("   Duration: \(String(format: "%.1f", durationSeconds))s")
        
        // Video settings
        let width = 1080
        let height = 1920
        let fps: Int32 = 30
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        // Create video writer
        try? FileManager.default.removeItem(at: output)
        
        let writer = try AVAssetWriter(outputURL: output, fileType: .mp4)
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        // Render frames
        // Add extra seconds for music at the end
        let extraSeconds: Double = 4.0
        let totalFrames = Int((durationSeconds + extraSeconds) * Double(fps))
        var frameCount = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        
        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
            while frameCount < totalFrames && writerInput.isReadyForMoreMediaData {
                let presentationTime = CMTime(value: Int64(frameCount), timescale: fps)
                
                guard let pixelBuffer = self.createPixelBuffer(
                    from: cgImage,
                    width: width,
                    height: height
                ) else {
                    break
                }
                
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                frameCount += 1
                
                if frameCount % 30 == 0 {
                    print("   Rendered \(frameCount)/\(totalFrames) frames...")
                }
            }
            
            if frameCount >= totalFrames {
                writerInput.markAsFinished()
                writer.finishWriting {
                    semaphore.signal()
                }
            }
        }
        
        semaphore.wait()
        
        if writer.status == .completed {
            // Now add audio to the video
            return try await self.addAudio(audio: audio, to: output)
        } else {
            throw VideoError.exportFailed(writer.error?.localizedDescription ?? "Unknown error")
        }
    }
    
    private func createPixelBuffer(from cgImage: CGImage, width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            options as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
    }
    
    private func addAudio(audio: URL, to video: URL) async throws -> URL {
        let videoAsset = AVURLAsset(url: video)
        let audioAsset = AVURLAsset(url: audio)
        
        let composition = AVMutableComposition()
        
        // Add video track
        guard let videoTrack = try await videoAsset.loadTracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw VideoError.trackCreationFailed
        }
        
        let videoDuration = try await videoAsset.load(.duration)
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: videoDuration),
            of: videoTrack,
            at: .zero
        )
        
        // Add audio track
        guard let audioTrack = try await audioAsset.loadTracks(withMediaType: .audio).first,
              let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw VideoError.trackCreationFailed
        }
        
        let audioDuration = try await audioAsset.load(.duration)
        try compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: audioDuration),
            of: audioTrack,
            at: .zero
        )
        
        // Export combined
        let finalOutput = video.deletingLastPathComponent().appendingPathComponent("final_\(video.lastPathComponent)")
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoError.exporterCreationFailed
        }
        
        exporter.outputURL = finalOutput
        exporter.outputFileType = .mp4
        
        await exporter.export()
        
        if exporter.status == .completed {
            // Replace original with final
            try? FileManager.default.removeItem(at: video)
            try FileManager.default.moveItem(at: finalOutput, to: video)
            
            print("✅ Video rendered: \(video.lastPathComponent)")
            return video
        } else {
            throw VideoError.exportFailed(exporter.error?.localizedDescription ?? "Unknown")
        }
    }
    
    enum VideoError: LocalizedError {
        case trackCreationFailed
        case audioLoadFailed
        case imageLoadFailed
        case exporterCreationFailed
        case exportFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .trackCreationFailed: return "Failed to create track"
            case .audioLoadFailed: return "Failed to load audio"
            case .imageLoadFailed: return "Failed to load image"
            case .exporterCreationFailed: return "Failed to create exporter"
            case .exportFailed(let reason): return "Export failed: \(reason)"
            }
        }
    }
}
