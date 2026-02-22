import Foundation

// MARK: - Shared Paths

enum Paths {
    // Base paths
    static let sharedDrivePath = "/Volumes/My Passport/social-media-content/social-effects"
    static let localOutputPath = "output"
    
    // Audio paths
    static let backgroundMusicPath = "\(sharedDrivePath)/music/ImmunityThemeFINAL.m4a"
    static let externalAudioCachePath = "\(sharedDrivePath)/audio/cache"
    static let localAudioCachePath = "\(localOutputPath)/cache/audio"
    
    // Video paths
    static let externalVideoPath = "\(sharedDrivePath)/video"
    static let localVideoPath = "\(localOutputPath)/rss_videos"
    static let testVideoPath = "\(sharedDrivePath)/video/test/test_rss_video.mp4"
    
    // Background paths
    static let externalBackgroundsPath = "\(sharedDrivePath)/output/backgrounds"
    static let localBackgroundsPath = "\(localOutputPath)/backgrounds"
    
    // Cache paths
    static let testItemCachePath = "\(localOutputPath)/cache/test_rss_item.json"
    
    // MARK: - Path Helpers
    
    /// Returns the appropriate audio cache directory based on external drive availability
    static func audioCacheDirectory() -> URL {
        let fm = FileManager.default
        let externalURL = URL(fileURLWithPath: externalAudioCachePath)
        if fm.isWritableFile(atPath: sharedDrivePath) {
            return externalURL
        }
        return URL(fileURLWithPath: localAudioCachePath)
    }
    
    /// Returns the appropriate video output directory based on external drive availability
    static func videoOutputDirectory() -> URL {
        let fm = FileManager.default
        let externalURL = URL(fileURLWithPath: externalVideoPath)
        if fm.isWritableFile(atPath: sharedDrivePath) {
            try? fm.createDirectory(at: externalURL, withIntermediateDirectories: true)
            return externalURL
        }
        let localURL = URL(fileURLWithPath: localVideoPath)
        try? fm.createDirectory(at: localURL, withIntermediateDirectories: true)
        return localURL
    }
}
