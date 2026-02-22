import Foundation

// MARK: - Test Video Command

enum TestVideoCommand {
    
    static func testVideo(arguments: [String]) async {
        print("🧪 Test Video — wisdombook.life RSS → Video")
        print("═══════════════════════════════════════════\n")
        
        let fresh = arguments.contains("--fresh")
        var feedName = "daily"
        if let idx = arguments.firstIndex(of: "--feed"), idx + 1 < arguments.count {
            feedName = arguments[idx + 1]
        }
        
        let cacheDir = "output/cache"
        try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true)
        
        let item: RSSFetcher.FeedItem
        
        if !fresh, FileManager.default.fileExists(atPath: Paths.testItemCachePath) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: Paths.testItemCachePath))
                item = try JSONDecoder().decode(RSSFetcher.FeedItem.self, from: data)
                print("📦 Using cached test item: \"\(item.title)\"")
            } catch {
                print("⚠️ Cache read failed, fetching fresh item...")
                do {
                    item = try await RSSFetcher.fetchItem(feed: feedName)
                } catch {
                    print("❌ RSS fetch failed: \(error.localizedDescription)")
                    exit(1)
                }
            }
        } else {
            let label = fresh ? "(--fresh)" : "(first run)"
            print("🌐 Fetching from wisdombook.life/feed/\(feedName).xml \(label)")
            do {
                item = try await RSSFetcher.fetchItem(feed: feedName)
                print("✅ Got: \"\(item.title)\"")
                print("   \(item.content.prefix(80))...")
                
                let data = try JSONEncoder().encode(item)
                try data.write(to: URL(fileURLWithPath: Paths.testItemCachePath))
                print("💾 Cached to \(Paths.testItemCachePath)\n")
            } catch {
                print("❌ RSS fetch failed: \(error.localizedDescription)")
                exit(1)
            }
        }
        
        let outputPath = Paths.testVideoPath
        let args = [
            "--title", item.title,
            "--content", item.content,
            "--source", item.source,
            "--border", "gold",
            "--output", outputPath
        ]
        
        print("")
        await VideoGenerationCommand.generateVideo(arguments: args)
    }
}
