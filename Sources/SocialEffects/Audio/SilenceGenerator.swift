import Foundation
import AVFoundation

/// Utility to generate a silent audio file of a given duration
class SilenceGenerator {
    /// Generates a silent .m4a file at the given URL
    /// - Parameters:
    ///   - duration: Duration of silence in seconds
    ///   - outputURL: Where to save the silent audio file
    static func generateSilence(duration: Double, outputURL: URL) throws {
        let sampleRate: Double = 44100
        let channels: AVAudioChannelCount = 1
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels)!
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        // Buffer is already zeroed (silence)
        let file = try AVAudioFile(forWriting: outputURL, settings: format.settings)
        try file.write(from: buffer)
    }
}
