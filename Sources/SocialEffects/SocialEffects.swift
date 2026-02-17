import Foundation
import AVFoundation
import CryptoKit

/// Main entry point - supports multiple commands
@main
struct SocialEffectsCLI {
    static func main() async {
        // Load API keys from .env file (won't overwrite shell-exported vars)
        let envCount = DotEnv.load()
        if envCount > 0 {
            // silent — keys loaded from .env
        }
        
        let arguments = CommandLine.arguments
        
        // Parse command
        let command = arguments.count > 1 ? arguments[1] : "help"
        
        switch command {
        case "generate-backgrounds":
            await generateBackgrounds(arguments: Array(arguments.dropFirst(2)))
        case "pika-generate":
            await pikaGenerate(arguments: Array(arguments.dropFirst(2)))
        case "generate-video":
            await generateVideoFromRSS(arguments: Array(arguments.dropFirst(2)))
        case "test-video":
            await testVideo(arguments: Array(arguments.dropFirst(2)))
        case "test-api":
            await testGeminiAPI()
        case "batch-demos":
            await batchGenerateDemos()
        case "help", "--help", "-h":
            printHelp()
        default:
            print("❌ Unknown command: \(command)")
            printHelp()
        }
    }
    
    static func printHelp() {
        print("""
        🎬 Social Effects - Video Generation CLI
        
        COMMANDS:
          generate-video                       Generate a video from explicit content
              --title "..."                    Content title
              --content "..."                  Quote/thought text
              --source "..."                   Attribution (default: wisdombook.life)
              --background auto|<path>         Background video (default: auto)
              --border gold|silver|minimal|art-deco|classic-scroll|sacred-geometry|celtic-knot|fleur-de-lis|baroque|victorian|golden-vine|stained-glass|modern-glow|none
                                               Border style (default: gold)
              --output <path>                  Output file (default: shared drive)
              --output-json                    JSON output for programmatic use
          
          test-video [--fresh]                 Fetch from wisdombook.life RSS and generate a test video
              --fresh                          Fetch new item (default: reuse cached item)
              --feed daily|wisdom|thoughts|quotes|passages  RSS feed to use
          
          generate-backgrounds [--test|--all]  Generate 3D looping backgrounds using Gemini Veo 3.1
              --test                           Generate ONE test video (prompt #1)
              --all                            Generate all 10 background videos
          
          pika-generate [--test|--all]         Generate backgrounds using Pika via Fal.ai (FREE tier)
              --test                           Generate ONE test video
              --all                            Generate 4 missing videos (slots 1,3,5,6)
          
          test-api                             Test Gemini API connection
          
          batch-demos                          Generate 10 demo wisdom videos (original functionality)
          
          help                                 Show this help message
        
        SETUP:
          Gemini: export GEMINI_API_KEY="your_key"
          Pika:   export FAL_KEY="your_fal_key"
        
        EXAMPLES:
          swift run SocialEffects test-video
          swift run SocialEffects test-video --fresh --feed thoughts
          swift run SocialEffects generate-video --title "My Quote" --content "Be the change."
          swift run SocialEffects pika-generate --test
        """)
    }
    

    
    static func sha256(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func testGeminiAPI() async {
        print("🔍 Testing Gemini API Connection...")
        print("═══════════════════════════════════\n")
        
        do {
            _ = try GeminiVideoService()
            print("✅ API key configured")
            print("✅ Service initialized successfully")
            print("\n🎉 Gemini API connection successful!")
            print("\n💡 Next step: swift run SocialEffects generate-backgrounds --test")
        } catch GeminiVideoService.GeminiError.missingAPIKey {
            print("❌ GEMINI_API_KEY environment variable not set")
            print("\n📝 Setup instructions:")
            print("  1. Get API key: https://aistudio.google.com/app/apikey")
            print("  2. Set in terminal: export GEMINI_API_KEY=\"your_key_here\"")
            print("  3. Run test again: swift run SocialEffects test-api")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func generateBackgrounds(arguments: [String]) async {
        let mode = arguments.first ?? "--help"
        
        switch mode {
        case "--test":
            await generateTestBackground()
        case "--all":
            await generateAllBackgrounds()
        default:
            print("❌ Invalid option: \(mode)")
            print("Usage: swift run SocialEffects generate-backgrounds [--test|--all]")
        }
    }
    
    static func generateTestBackground() async {
        print("🧪 TEST MODE: Generating ONE test background video")
        print("═══════════════════════════════════════════════\n")
        
        do {
            let service = try GeminiVideoService()
            let outputDir = "output/backgrounds"
            
            // Ensure output directory exists
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            // Generate FIRST prompt only
            let testPrompt = PromptTemplates.all[0]
            
            print("📋 Using prompt: \(testPrompt.name)")
            print("🎨 Category: \(testPrompt.category.rawValue)")
            print("⏰ This will take several minutes...\n")
            
            let videoPath = try await service.generateAndDownload(
                videoPrompt: testPrompt,
                outputDirectory: outputDir
            )
            
            print("\n✅ TEST COMPLETE!")
            print("📁 Video saved to: \(videoPath)")
            print("\n💡 Next step: swift run SocialEffects generate-backgrounds --all")
            
        } catch GeminiVideoService.GeminiError.missingAPIKey {
            print("❌ GEMINI_API_KEY not set. Run: swift run SocialEffects test-api")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func generateAllBackgrounds() async {
        print("🎬 Generating ALL 10 Background Videos")
        print("═══════════════════════════════════════\n")
        
        print("⚠️  This will take 30-60 minutes total")
        print("⚠️  Each video takes ~3-5 minutes to generate")
        print("⚠️  Check your API quota limits\n")
        
        print("Press ENTER to continue or Ctrl+C to cancel...")
        _ = readLine()
        
        do {
            let service = try GeminiVideoService()
            let outputDir = "output/backgrounds"
            
            // Ensure output directory exists
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            var successCount = 0
            var failedPrompts: [String] = []
            
            for (index, prompt) in PromptTemplates.all.enumerated() {
                print("\n[\(index + 1)/10] ═══════════════════════════════")
                
                // Check if already exists
                let expectedPath = "\(outputDir)/\(String(format: "%02d", prompt.id))_\(prompt.name).mp4"
                if FileManager.default.fileExists(atPath: expectedPath) {
                    print("⏭️  Skipping \(prompt.name) (already exists)")
                    successCount += 1
                    continue
                }
                
                do {
                    _ = try await service.generateAndDownload(
                        videoPrompt: prompt,
                        outputDirectory: outputDir
                    )
                    successCount += 1
                } catch {
                    print("❌ Failed: \(error)")
                    failedPrompts.append(prompt.name)
                }
            }
            
            print("\n\n🎉 BATCH GENERATION COMPLETE!")
            print("═══════════════════════════════════")
            print("✅ Successful: \(successCount)/10")
            if !failedPrompts.isEmpty {
                print("❌ Failed: \(failedPrompts.count)")
                print("   Failed prompts: \(failedPrompts.joined(separator: ", "))")
            }
            print("📁 Location: \(outputDir)/")
            
            // Create manifest
            await createManifest(outputDir: outputDir)
            
        } catch GeminiVideoService.GeminiError.missingAPIKey {
            print("❌ GEMINI_API_KEY not set. Run: swift run SocialEffects test-api")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func createManifest(outputDir: String) async {
        let manifestPath = "\(outputDir)/manifest.json"
        
        let manifest = PromptTemplates.all.map { prompt in
            [
                "id": prompt.id,
                "name": prompt.name,
                "category": prompt.category.rawValue,
                "filename": "\(String(format: "%02d", prompt.id))_\(prompt.name).mp4",
                "prompt": prompt.prompt,
                "aspectRatio": "9:16",
                "duration": 8
            ] as [String: Any]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
            try jsonData.write(to: URL(fileURLWithPath: manifestPath))
            print("\n📋 Manifest created: \(manifestPath)")
        } catch {
            print("⚠️  Could not create manifest: \(error)")
        }
    }
    
    static func batchGenerateDemos() async {
        // Original functionality preserved
        print("🎬 Batch Generating 10 Demo Videos")
        print("===================================\n")
        
        let demos = [
            (1, "True wisdom comes from questions. The wisest person is not the one with all the answers, but the one who asks the best questions."),
            (2, "Courage is not the absence of fear, but the triumph over it."),
            (3, "The obstacle is the path. Every challenge contains the seed of growth."),
            (4, "You cannot control what happens to you, but you can control how you respond."),
            (5, "Excellence is not a destination, it is a continuous journey."),
            (6, "The quality of your life is determined by the quality of your questions."),
            (7, "Discipline is choosing between what you want now and what you want most."),
            (8, "Character is revealed in how you treat those who can do nothing for you."),
            (9, "The meaning of life is found in the service of others, not in the pursuit of pleasure."),
            (10, "Your legacy is not what you accumulate, but what you give away.")
        ]
        
        let generator = TextGraphicsGenerator()
        let merger = AudioMerger()
        let renderer = VideoRenderer()
        
        let ctaPath = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/audio/cta_outro.mp3")
        
        var successCount = 0
        
        for (id, quote) in demos {
            print("[\(id)/10] Demo \(id)")
            print("─────────────────")
            
            do {
                // Paths
                let graphicPath = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/graphics/demo_\(String(format: "%02d", id)).png")
                let narrationPath = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/audio/demo_\(String(format: "%02d", id))_narration.mp3")
                let mergedAudioPath = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/audio/demo_\(String(format: "%02d", id))_with_cta.m4a")
                let videoPath = URL(fileURLWithPath: "/Volumes/My Passport/social-media-content/social-effects/video/demo_\(String(format: "%02d", id)).mp4")
                
                // Step 1: Generate graphic
                print("  🎨 Generating graphic...")
                _ = try generator.generate(text: quote, outputPath: graphicPath)
                
                // Step 2: Merge audio
                print("  🎙️ Merging audio + CTA...")
                let audioWithCTA = try await merger.merge(
                    audioFiles: [narrationPath, ctaPath],
                    outputPath: mergedAudioPath
                )
                
                // Step 3: Render video
                print("  🎥 Rendering video...")
                _ = try await renderer.render(
                    graphic: graphicPath,
                    audio: audioWithCTA,
                    effect: "cross-dissolve",
                    duration: 15,
                    output: videoPath
                )
                
                print("  ✅ Complete!\n")
                successCount += 1
                
            } catch {
                print("  ❌ Error: \(error)\n")
            }
        }
        
        print("═══════════════════════════════════")
        print("🎉 BATCH COMPLETE!")
        print("   Generated: \(successCount)/10 videos")
        print("   Location: /Volumes/My Passport/social-media-content/social-effects/video/")
        print("\n💰 YOU NOW HAVE 10 PROFESSIONAL WISDOM VIDEOS!")
    }
 
    // MARK: - Pika Video Generation
    
    static func pikaGenerate(arguments: [String]) async {
        let mode = arguments.first ?? "--help"
        
        switch mode {
        case "--test":
            await pikaGenerateTest()
        case "--all":
            await pikaGenerateAll()
        default:
            print("❌ Invalid option: \(mode)")
            print("Usage: swift run SocialEffects pika-generate [--test|--all]")
        }
    }
    
    static func pikaGenerateTest() async {
        print("🧪 PIKA TEST: Generating ONE test video")
        print("═══════════════════════════════════════════════\n")
        
        do {
            let service = try PikaVideoService()
            let outputDir = "output/backgrounds"
            
            // Ensure output directory exists
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            // Use FIRST prompt for test
            let testPrompt = PromptTemplates.all[0]
            
            print("📋 Testing with: \(testPrompt.name)")
            print("🎨 Category: \(testPrompt.category.rawValue)")
            print("⏰ This will take ~3-5 minutes...\n")
            
            let videoPath = try await service.generateAndDownload(
                videoPrompt: testPrompt,
                outputDirectory: outputDir
            )
            
            print("\n✅ TEST COMPLETE!")
            print("📁 Video saved to: \(videoPath)")
            print("\n💡 Review the video, then run: swift run SocialEffects pika-generate --all")
            
        } catch PikaVideoService.PikaError.missingAPIKey {
            print("❌ FAL_KEY not set")
            print("\n📝 Setup:")
            print("  1. Sign up at https://fal.ai")
            print("  2. Get API key from dashboard")
            print("  3. Run: export FAL_KEY=\"your_key_here\"")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func pikaGenerateAll() async {
        print("🎬 Generating 4 Missing Background Videos via Pika")
        print("═══════════════════════════════════════════════\n")
        
        // Slots to generate: 1, 3, 5, 6 (indices 0, 2, 4, 5)
        let slotsToGenerate = [0, 2, 4, 5]
        
        print("📊 Will generate:")
        for index in slotsToGenerate {
            let prompt = PromptTemplates.all[index]
            print("  • Slot \(String(format: "%02d", prompt.id)): \(prompt.name)")
        }
        print("\n⚠️  This will take ~15-20 minutes total")
        print("⚠️  Uses ~40-80 Fal.ai credits (FREE tier has 80/month)\n")
        
        print("Press ENTER to continue or Ctrl+C to cancel...")
        _ = readLine()
        
        do {
            let service = try PikaVideoService()
            let outputDir = "output/backgrounds"
            
            // Ensure output directory exists
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            var successCount = 0
            var failedPrompts: [String] = []
            
            for (counter, index) in slotsToGenerate.enumerated() {
                let prompt = PromptTemplates.all[index]
                print("\n[\(counter + 1)/4] ═══════════════════════════════")
                
                // Check if already exists
                let expectedPath = "\(outputDir)/\(String(format: "%02d", prompt.id))_\(prompt.name).mp4"
                if FileManager.default.fileExists(atPath: expectedPath) {
                    print("⏭️  Skipping \(prompt.name) (already exists)")
                    successCount += 1
                    continue
                }
                
                do {
                    _ = try await service.generateAndDownload(
                        videoPrompt: prompt,
                        outputDirectory: outputDir
                    )
                    successCount += 1
                } catch {
                    print("❌ Failed: \(error)")
                    failedPrompts.append(prompt.name)
                }
            }
            
            print("\n\n🎉 BATCH GENERATION COMPLETE!")
            print("═══════════════════════════════════")
            print("✅ Successful: \(successCount)/4")
            if !failedPrompts.isEmpty {
                print("❌ Failed: \(failedPrompts.count)")
                print("   Failed videos: \(failedPrompts.joined(separator: ", "))")
            }
            print("📁 Location: \(outputDir)/")
            
        } catch PikaVideoService.PikaError.missingAPIKey {
            print("❌ FAL_KEY not set. Setup first!")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    


// ... (existing code)

    // MARK: - Shared Paths
    
    static let sharedDrivePath = "/Volumes/My Passport/social-media-content/social-effects"
    static let backgroundMusicPath = "\(sharedDrivePath)/music/ImmunityThemeFINAL.m4a"
    static let testItemCachePath = "output/cache/test_rss_item.json"
    
    // MARK: - Test Video (RSS → Video in one command)
    
    /// Fetches an item from wisdombook.life RSS, caches it, and generates a video.
    /// On subsequent runs reuses the cached item unless --fresh is passed.
    static func testVideo(arguments: [String]) async {
        print("🧪 Test Video — wisdombook.life RSS → Video")
        print("═══════════════════════════════════════════\n")
        
        // Parse args
        let fresh = arguments.contains("--fresh")
        var feedName = "daily"
        if let idx = arguments.firstIndex(of: "--feed"), idx + 1 < arguments.count {
            feedName = arguments[idx + 1]
        }
        
        // Ensure cache directory exists
        let cacheDir = "output/cache"
        try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true)
        
        // Load or fetch the RSS item
        let item: RSSFetcher.FeedItem
        
        if !fresh, FileManager.default.fileExists(atPath: testItemCachePath) {
            // Reuse cached item
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: testItemCachePath))
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
            // Fetch from RSS
            let label = fresh ? "(--fresh)" : "(first run)"
            print("🌐 Fetching from wisdombook.life/feed/\(feedName).xml \(label)")
            do {
                item = try await RSSFetcher.fetchItem(feed: feedName)
                print("✅ Got: \"\(item.title)\"")
                print("   \(item.content.prefix(80))...")
                
                // Cache for future runs
                let data = try JSONEncoder().encode(item)
                try data.write(to: URL(fileURLWithPath: testItemCachePath))
                print("💾 Cached to \(testItemCachePath)\n")
            } catch {
                print("❌ RSS fetch failed: \(error.localizedDescription)")
                exit(1)
            }
        }
        
        // Build generate-video arguments using the fetched item
        let outputPath = "\(sharedDrivePath)/video/test/test_rss_video.mp4"
        let args = [
            "--title", item.title,
            "--content", item.content,
            "--source", item.source,
            "--border", "gold",
            "--output", outputPath
        ]
        
        print("") // spacing before generate-video output
        await generateVideoFromRSS(arguments: args)
    }
    
    // MARK: - RSS Video Generation
    
    static func generateVideoFromRSS(arguments: [String]) async {
        print("🎬 Generating Video from RSS Content")
        print("═══════════════════════════════════\n")
        
        // Parse arguments
        var title = ""
        var content = ""
        var source = "wisdombook.life"
        var backgroundArg = "auto"
        var borderArg = "gold"
        var outputJSON = false
        var outputPathArg: String? = nil
        
        var i = 0
        while i < arguments.count {
            let arg = arguments[i]
            if arg == "--title" && i + 1 < arguments.count {
                title = arguments[i+1]
                i += 2
            } else if arg == "--content" && i + 1 < arguments.count {
                content = arguments[i+1]
                i += 2
            } else if arg == "--source" && i + 1 < arguments.count {
                source = arguments[i+1]
                i += 2
            } else if arg == "--background" && i + 1 < arguments.count {
                backgroundArg = arguments[i+1]
                i += 2
            } else if arg == "--border" && i + 1 < arguments.count {
                borderArg = arguments[i+1]
                i += 2
            } else if arg == "--output" && i + 1 < arguments.count {
                outputPathArg = arguments[i+1]
                i += 2
            } else if arg == "--output-json" {
                outputJSON = true
                i += 1
            } else {
                i += 1
            }
        }
        
        // Validate
        if title.isEmpty || content.isEmpty {
            if outputJSON {
                print("{\"success\":false,\"error\":\"Missing --title or --content\"}")
            } else {
                print("❌ Error: Missing --title or --content")
            }
            exit(1)
        }
        
        // Setup Services
        let graphicsGenerator = TextGraphicsGenerator()
        let audioMerger = AudioMerger()
        // VideoRenderer replaced with FFmpeg
        
        let elevenLabsKey = ProcessInfo.processInfo.environment["ELEVEN_LABS_API_KEY"]
        
        // Voice providers: Apple Jamie (primary, free) + ElevenLabs (optional narration fallback)
        let voiceService: ElevenLabsVoice?
        let appleVoice: AppleVoice?
        
        // Apple Jamie is always preferred — also needed for CTA outro
        if AppleVoice.isAvailable() {
            appleVoice = AppleVoice()
            voiceService = nil
            if !outputJSON { print("🍎 Using Apple TTS (Jamie Premium)") }
        } else if let key = elevenLabsKey, !key.isEmpty {
            voiceService = ElevenLabsVoice(apiKey: key)
            appleVoice = nil
            if !outputJSON { print("🎙️ Using ElevenLabs (Jamie not available)") }
        } else {
            voiceService = nil
            appleVoice = nil
            if !outputJSON { print("⚠️ Warning: No voice provider available. Install Jamie Premium voice.") }
        }
        
        // Paths
        let tempDir = FileManager.default.temporaryDirectory
        let timestamp = Int(Date().timeIntervalSince1970)
        let baseFilename = "rss_video_\(timestamp)"
        
        let graphicPath = tempDir.appendingPathComponent("\(baseFilename)_graphic.png")
        let narrationPath = tempDir.appendingPathComponent("\(baseFilename)_narration.m4a")
        let mergedAudioPath = tempDir.appendingPathComponent("\(baseFilename)_audio.m4a")
        
        // Determine Output Path (shared drive primary, --output override, local fallback)
        let finalVideoPath: URL
        if let out = outputPathArg {
            finalVideoPath = URL(fileURLWithPath: out)
        } else {
            let sharedVideoDir = "\(sharedDrivePath)/video"
            if FileManager.default.isWritableFile(atPath: "/Volumes/My Passport/social-media-content/social-effects") {
                try? FileManager.default.createDirectory(atPath: sharedVideoDir, withIntermediateDirectories: true)
                finalVideoPath = URL(fileURLWithPath: "\(sharedVideoDir)/\(baseFilename).mp4")
            } else {
                let localDir = "output/rss_videos"
                try? FileManager.default.createDirectory(atPath: localDir, withIntermediateDirectories: true)
                finalVideoPath = URL(fileURLWithPath: "\(localDir)/\(baseFilename).mp4")
                if !outputJSON { print("⚠️ Shared drive not available, using local output") }
            }
        }
        
        do {
            // 1. Select Background
            let backgroundPath: URL
            if backgroundArg == "auto" {
                let slotIndex = (timestamp % 10) + 1
                let slotStr = String(format: "%02d", slotIndex)
                
                let bgDir = "output/backgrounds"
                let files = (try? FileManager.default.contentsOfDirectory(atPath: bgDir)) ?? []
                
                if let match = files.first(where: { $0.hasPrefix(slotStr) && $0.hasSuffix(".mp4") && !$0.contains("landscape") && !$0.contains("original") }) {
                    backgroundPath = URL(fileURLWithPath: "\(bgDir)/\(match)")
                    if !outputJSON { print("🎨 Background: \(match) (Slot \(slotStr))") }
                } else {
                    let extBgDir = "/Volumes/My Passport/social-media-content/social-effects/backgrounds"
                    let extFiles = (try? FileManager.default.contentsOfDirectory(atPath: extBgDir)) ?? []
                     if let match = extFiles.first(where: { $0.hasPrefix(slotStr) && $0.hasSuffix(".mp4") && !$0.contains("landscape") && !$0.contains("original") }) {
                        backgroundPath = URL(fileURLWithPath: "\(extBgDir)/\(match)")
                        if !outputJSON { print("🎨 Background (External): \(match)") }
                    } else if let firstMatch = files.first(where: { $0.hasSuffix(".mp4") && !$0.contains("landscape") && !$0.contains("original") }) {
                        backgroundPath = URL(fileURLWithPath: "\(bgDir)/\(firstMatch)")
                        if !outputJSON { print("⚠️ Slot \(slotStr) not found, falling back to \(firstMatch)") }
                    } else if let firstExt = extFiles.first(where: { $0.hasSuffix(".mp4") && !$0.contains("landscape") && !$0.contains("original") }) {
                        backgroundPath = URL(fileURLWithPath: "\(extBgDir)/\(firstExt)")
                        if !outputJSON { print("⚠️ Slot \(slotStr) not found, falling back to external \(firstExt)") }
                    } else {
                        throw NSError(domain: "SocialEffects", code: 1, userInfo: [NSLocalizedDescriptionKey: "No background videos found"])
                    }
                }
            } else {
                backgroundPath = URL(fileURLWithPath: backgroundArg)
            }
            
            // 2. Generate Graphic
            if !outputJSON { print("🖼️ Generating graphic...") }
            let borderStyle = TextGraphicsGenerator.BorderStyle(rawValue: borderArg) ?? .gold
            _ = try graphicsGenerator.generate(
                title: title,
                text: content,
                outputPath: graphicPath,
                border: borderStyle
            )
            
            // 3. Generate Voice
            let narrationText = content
            let contentHash = sha256(narrationText)
            let cacheDir = "output/cache/audio"
            try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true)
            
            let currentDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            let cachePath = currentDirURL.appendingPathComponent(cacheDir).appendingPathComponent("\(contentHash).m4a")
            
            // Check Cache first
            if FileManager.default.fileExists(atPath: cachePath.path) {
                if !outputJSON { print("📦 Using cached voice: \(contentHash).m4a") }
                try FileManager.default.copyItem(at: cachePath, to: narrationPath)
            } else {
                // Not in cache — generate with available provider
                if let voiceService = voiceService {
                    if !outputJSON { print("🎙️ Generating voice (ElevenLabs/Donovan)...") }
                    _ = try await voiceService.generateVoice(text: narrationText, outputPath: narrationPath)
                    
                    // Save to cache
                    if !outputJSON { print("💾 Caching voice to: \(cachePath.lastPathComponent)") }
                    try? FileManager.default.copyItem(at: narrationPath, to: cachePath)
                } else if let appleVoice = appleVoice {
                    if !outputJSON { print("🎙️ Generating voice (Apple/Jamie)...") }
                    _ = try appleVoice.generateVoice(text: narrationText, outputPath: narrationPath)
                    
                    // Save to cache
                    if !outputJSON { print("💾 Caching voice to: \(cachePath.lastPathComponent)") }
                    try? FileManager.default.copyItem(at: narrationPath, to: cachePath)
                } else {
                    if !outputJSON { print("⚠️ No voice provider available — cannot generate audio") }
                    throw NSError(domain: "SocialEffects", code: 3, userInfo: [NSLocalizedDescriptionKey: "No voice provider available. Install Jamie Premium voice or set ELEVEN_LABS_API_KEY."])
                }
            }
            
            // 4. Generate CTA outro with Jamie + merge
            let finalAudioPath: URL
            if !outputJSON { print("🎚️ Merging audio...") }
            if let appleVoice = appleVoice {
                let ctaPath = try appleVoice.generateCTA()
                if !outputJSON { print("🎙️ CTA outro: Jamie voice (cached)") }
                _ = try await audioMerger.merge(audioFiles: [narrationPath, ctaPath], outputPath: mergedAudioPath)
                finalAudioPath = mergedAudioPath
            } else {
                if !outputJSON { print("⚠️ No Apple voice for CTA, using narration only") }
                finalAudioPath = narrationPath
            }
            
            // 5. Render Video (FFmpeg)
            if !outputJSON { print("🎥 Rendering video with FFmpeg...") }
            let durationSeconds = try await AVURLAsset(url: finalAudioPath).load(.duration).seconds
            
            try FileManager.default.createDirectory(at: finalVideoPath.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            // FFmpeg command: Loop background, overlay transparent graphic, mix audio with background music
            let ffmpegProcess = Process()
            ffmpegProcess.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
            if !FileManager.default.fileExists(atPath: ffmpegProcess.executableURL!.path) {
                 ffmpegProcess.executableURL = URL(fileURLWithPath: "/usr/local/bin/ffmpeg")
            }
            
            // Check if background music is available
            let hasBgMusic = FileManager.default.fileExists(atPath: backgroundMusicPath)
            if !outputJSON {
                if hasBgMusic {
                    print("🎵 Background music: ImmunityThemeFINAL.m4a")
                } else {
                    print("⚠️ Background music not found, proceeding without music")
                }
            }
            
            // Build FFmpeg arguments dynamically based on music availability
            // Input 0: background video (loop, video-only — drop its audio track)
            var ffmpegArgs = ["-y", "-nostdin", "-stream_loop", "-1", "-an", "-i", backgroundPath.path]
            // Input 1: overlay graphic (loop single PNG for entire duration)
            ffmpegArgs += ["-loop", "1", "-i", graphicPath.path]
            // Input 2: narration + CTA audio
            ffmpegArgs += ["-i", finalAudioPath.path]
            
            if hasBgMusic {
                // Input 3: background music (loop)
                ffmpegArgs += ["-stream_loop", "-1", "-i", backgroundMusicPath]
                // Video: scale background to 1080x1920, overlay PNG with 1.5s fade-in
                // Audio: 2s silence before narration, mix with music (14% volume)
                ffmpegArgs += [
                    "-filter_complex",
                    "[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2[bg];" +
                    "[1:v]scale=1080:1920,format=rgba,fade=in:st=0:d=1.5:alpha=1[ovrl];" +
                    "[bg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                    "[2:a]adelay=2000|2000[narr];" +
                    "[3:a]volume=0.14[musiclow];" +
                    "[narr][musiclow]amix=inputs=2:duration=first:dropout_transition=2[aout]",
                    "-map", "[vout]", "-map", "[aout]"
                ]
            } else {
                // No music — video overlay with fade-in + delayed narration
                ffmpegArgs += [
                    "-filter_complex",
                    "[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2[bg];" +
                    "[1:v]scale=1080:1920,format=rgba,fade=in:st=0:d=1.5:alpha=1[ovrl];" +
                    "[bg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                    "[2:a]adelay=2000|2000[aout]",
                    "-map", "[vout]", "-map", "[aout]"
                ]
            }
            
            ffmpegArgs += [
                "-c:v", "libx264",
                "-preset", "medium",
                "-crf", "23",
                "-c:a", "aac",
                "-b:a", "192k",
                "-shortest",
                finalVideoPath.path
            ]
            
            ffmpegProcess.arguments = ffmpegArgs
            
            // Capture stderr asynchronously to avoid pipe buffer deadlock
            // (FFmpeg progress logs can exceed the 64KB pipe buffer, blocking the process)
            let errPipe = Pipe()
            var errData = Data()
            ffmpegProcess.standardOutput = FileHandle.nullDevice
            ffmpegProcess.standardError = errPipe
            
            errPipe.fileHandleForReading.readabilityHandler = { handle in
                let chunk = handle.availableData
                if !chunk.isEmpty { errData.append(chunk) }
            }
            
            try ffmpegProcess.run()
            ffmpegProcess.waitUntilExit()
            
            // Clean up handler
            errPipe.fileHandleForReading.readabilityHandler = nil
            
            if ffmpegProcess.terminationStatus != 0 {
                let output = String(data: errData, encoding: .utf8) ?? "Unknown FFmpeg error"
                throw NSError(domain: "SocialEffects", code: 2, userInfo: [NSLocalizedDescriptionKey: "FFmpeg failed: \(output)"])
            }
            
            // 6. Output
            if outputJSON {
                let result: [String: Any] = [
                    "success": true,
                    "videoPath": finalVideoPath.path,
                    "duration": durationSeconds,
                    "background": backgroundPath.lastPathComponent
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                if let jsonStr = String(data: jsonData, encoding: .utf8) { print(jsonStr) }
            } else {
                print("\n✅ Video Generated Successfully!")
                print("📂 Saved to: \(finalVideoPath.path)")
            }
            
            // Debug: save graphic for inspection
            let debugGraphicDst = URL(fileURLWithPath: "/tmp/debug_graphic.png")
            try? FileManager.default.removeItem(at: debugGraphicDst)
            try? FileManager.default.copyItem(at: graphicPath, to: debugGraphicDst)
            if !outputJSON { print("🔍 Debug graphic saved: /tmp/debug_graphic.png") }
            
            // Cleanup
            try? FileManager.default.removeItem(at: graphicPath)
            try? FileManager.default.removeItem(at: narrationPath)
            try? FileManager.default.removeItem(at: mergedAudioPath)
            
        } catch {
            if outputJSON {
                let result: [String: Any] = [
                    "success": false,
                    "error": error.localizedDescription
                ]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    if let jsonStr = String(data: jsonData, encoding: .utf8) { print(jsonStr) }
                } catch {
                     print("{\"success\":false,\"error\":\"JSON Serialization Failed\"}")
                }
            } else {
                print("\n❌ Error: \(error.localizedDescription)")
            }
            exit(1)
        }
    }
}
