import Foundation

// MARK: - Background Selector

enum BackgroundSelector {
    
    static func select(backgroundArg: String, timestamp: Int, outputJSON: Bool) async throws -> URL {
        if backgroundArg == "auto" {
            return try await selectAutoBackground(timestamp: timestamp, outputJSON: outputJSON)
        } else {
            return URL(fileURLWithPath: backgroundArg)
        }
    }
    
    private static func selectAutoBackground(timestamp: Int, outputJSON: Bool) async throws -> URL {
        let slotIndex = (timestamp % 10) + 1
        let slotStr = String(format: "%02d", slotIndex)
        
        let extBgDir = "/Volumes/My Passport/social-media-content/social-effects/output/backgrounds"
        let localBgDir = "output/backgrounds"
        
        let extFiles = (try? FileManager.default.contentsOfDirectory(atPath: extBgDir)) ?? []
        let localFiles = (try? FileManager.default.contentsOfDirectory(atPath: localBgDir)) ?? []
        
        // Try external first
        if let match = findMatchingFile(in: extFiles, slotStr: slotStr) {
            if !outputJSON { print("🎨 Background: \(match) (Slot \(slotStr))") }
            return URL(fileURLWithPath: "\(extBgDir)/\(match)")
        }
        
        // Try local
        if let match = findMatchingFile(in: localFiles, slotStr: slotStr) {
            if !outputJSON { print("🎨 Background (Local): \(match) (Slot \(slotStr))") }
            return URL(fileURLWithPath: "\(localBgDir)/\(match)")
        }
        
        // Fallback to any external
        if let firstExt = extFiles.first(where: { isValidVideoFile($0) }) {
            if !outputJSON { print("⚠️ Slot \(slotStr) not found, using external \(firstExt)") }
            return URL(fileURLWithPath: "\(extBgDir)/\(firstExt)")
        }
        
        // Fallback to any local
        if let firstLocal = localFiles.first(where: { isValidVideoFile($0) }) {
            if !outputJSON { print("⚠️ Slot \(slotStr) not found, using local \(firstLocal)") }
            return URL(fileURLWithPath: "\(localBgDir)/\(firstLocal)")
        }
        
        throw NSError(domain: "SocialEffects", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "No background videos found"
        ])
    }
    
    private static func findMatchingFile(in files: [String], slotStr: String) -> String? {
        files.first { $0.hasPrefix(slotStr) && isValidVideoFile($0) }
    }
    
    private static func isValidVideoFile(_ filename: String) -> Bool {
        filename.hasSuffix(".mp4") && 
        !filename.contains("landscape") && 
        !filename.contains("original")
    }
}
