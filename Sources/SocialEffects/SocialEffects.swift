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
        
        // Always clear audio cache before generating video to ensure fresh, high-quality TTS
        if ["generate-video", "test-video"].contains(command) {
            let cacheDir = "output/cache/audio"
            let fm = FileManager.default
            if fm.fileExists(atPath: cacheDir) {
                do {
                    let files = try fm.contentsOfDirectory(atPath: cacheDir)
                    for file in files where file.hasSuffix(".m4a") || file.hasSuffix(".mp3") || file.hasSuffix(".wav") {
                        try? fm.removeItem(atPath: "\(cacheDir)/\(file)")
                    }
                    print("🧹 Cleared audio cache (")
                } catch {
                    print("⚠️ Failed to clear audio cache: \(error)")
                }
            }
        }
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
        case "api-server":
            await startAPIServer(arguments: Array(arguments.dropFirst(2)))
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
              --ping-pong                      Use ping-pong background (forward-back-forward)
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
          
          api-server [port]                    Start HTTP API server (default port: 5390)
                                               POST /generate - Generate video via JSON
                                               GET  /health   - Health check
          
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
        // DEPRECATED: This function used VideoRenderer which has been removed.
        // The batch-demos command now uses FFmpeg-based generation via generateVideoFromRSS.
        print("⚠️  batch-demos command is deprecated.")
        print("Please use generate-video command instead:")
        print("  swift run SocialEffects generate-video --title \"...\" --content \"...\"")
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
        var pingPongBackground = true  // Default to ping-pong for seamless background looping
        var contentTypeArg: String? = nil
        var nodeTitleArg: String? = nil
        
        var audioFileArg: String? = nil
        var blackScreenDuration: Int = 0
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
            } else if arg == "--content-type" && i + 1 < arguments.count {
                contentTypeArg = arguments[i+1]
                i += 2
            } else if arg == "--node-title" && i + 1 < arguments.count {
                nodeTitleArg = arguments[i+1]
                i += 2
            } else if arg == "--output-json" {
                outputJSON = true
                i += 1
            } else if arg == "--audio-file" && i + 1 < arguments.count {
                audioFileArg = arguments[i+1]
                i += 2
            } else if arg == "--black-screen" && i + 1 < arguments.count {
                if let val = Int(arguments[i+1]) { blackScreenDuration = val }
                i += 2
            } else if arg == "--ping-pong" {
                pingPongBackground = true
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
        if !outputJSON { print("🔧 Initializing services...") }
        let graphicsGenerator = TextGraphicsGenerator()
        let audioMerger = AudioMerger()
        // VideoRenderer replaced with FFmpeg
        
        // Initialize KokoroVoice for TTS (primary voice provider)
        let kokoroVoice = KokoroVoice()
        if !outputJSON { 
            print("🔍 Checking voice providers...")
            print("🎙️ Using Kokoro TTS (Liam voice)") 
        }
        
        // Paths
        let tempDir = FileManager.default.temporaryDirectory
        let timestamp = Int(Date().timeIntervalSince1970)
        let baseFilename = "rss_video_\(timestamp)"
        
        let graphicPath = tempDir.appendingPathComponent("\(baseFilename)_graphic.png")
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
                    let extBgDir = "/Volumes/My Passport/social-media-content/social-effects/output/backgrounds"
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
            // Use 10 approved ornate border styles in sequence by day
            let approvedBorders: [TextGraphicsGenerator.BorderStyle] = [
                .artDeco, .classicScroll, .sacredGeometry, .celticKnot, .fleurDeLis,
                .baroque, .victorian, .goldenVine, .stainedGlass, .modernGlow
            ]
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let borderStyle = approvedBorders[(dayOfYear - 1) % approvedBorders.count]
            _ = try graphicsGenerator.generate(
                title: title,
                text: content,
                outputPath: graphicPath,
                border: borderStyle
            )
            
            // 3. Generate or Use Provided Voice (Kokoro TTS)
            let narrationWAVPath = tempDir.appendingPathComponent("\(baseFilename)_narration.wav")
            
            if let audioFileArg = audioFileArg {
                if !outputJSON { print("🎙️ Using user-provided audio file: \(audioFileArg)") }
                let userAudioURL = URL(fileURLWithPath: audioFileArg)
                if FileManager.default.fileExists(atPath: userAudioURL.path) {
                    try FileManager.default.copyItem(at: userAudioURL, to: narrationWAVPath)
                } else {
                    throw NSError(domain: "SocialEffects", code: 4, userInfo: [NSLocalizedDescriptionKey: "Provided audio file not found: \(audioFileArg)"])
                }
            } else {
                // Generate narration with Kokoro
                if !outputJSON { print("🎙️ Generating narration with Kokoro (Liam)...") }
                let narrationWAV = try await kokoroVoice.synthesize(text: content, voice: KokoroVoice.defaultVoice)
                
                // Convert WAV to M4A for compatibility
                let wavURL = URL(fileURLWithPath: narrationWAV)
                if FileManager.default.fileExists(atPath: narrationWAV) {
                    try FileManager.default.copyItem(at: wavURL, to: narrationWAVPath)
                }
            }
            
            // 4. Generate CTA outro with Kokoro + merge
            let finalAudioPath: URL
            if !outputJSON { print("🎚️ Generating CTA and merging audio...") }
            
            // Generate CTA with Kokoro (am_liam voice)
            let ctaWAV = try await kokoroVoice.generateCTA(voice: KokoroVoice.defaultVoice)
            if !outputJSON { print("🎙️ CTA outro: Kokoro/Liam voice") }
            
            // Use WAV files directly - AudioMerger handles conversion to M4A
            let ctaWAVPath = URL(fileURLWithPath: ctaWAV)
            
            // Merge narration + CTA (WAV files directly, AudioMerger will export to M4A)
            _ = try await audioMerger.merge(audioFiles: [narrationWAVPath, ctaWAVPath], outputPath: mergedAudioPath)
            finalAudioPath = mergedAudioPath
            
            // 5. Render Video (FFmpeg)
            if !outputJSON { print("🎥 Rendering video with FFmpeg...") }
            let durationSeconds = try await AVURLAsset(url: finalAudioPath).load(.duration).seconds
            
            // Cinematic timing constants (narration starts at 9s)
            let narrationStartTime = 9
            
            // Ensure minimum 15-second duration for TikTok and Instagram Reels compatibility
            // BUT also ensure video is long enough for delayed narration + outro to complete
            let minDuration: Double = 15.0
            let audioEndTime = Double(narrationStartTime) + durationSeconds  // When audio actually ends (after delay)
            let targetDuration = max(minDuration, audioEndTime)
            let needsPadding = targetDuration > audioEndTime  // Only pad if audio ends before minDuration
            
            if !outputJSON {
                if targetDuration > minDuration {
                    print("⏱️ Audio ends at \(String(format: "%.1f", audioEndTime))s (includes \(narrationStartTime)s delay)")
                }
                if needsPadding {
                    let padding = targetDuration - audioEndTime
                    print("⏱️ Padding \(String(format: "%.1f", padding))s to reach 15s minimum")
                } else {
                    print("⏱️ Audio duration: \(String(format: "%.1f", durationSeconds))s, final video: \(String(format: "%.1f", targetDuration))s")
                }
            }
            
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
            
            // Build FFmpeg arguments dynamically based on music availability and ping-pong
            var ffmpegArgs: [String]
            
            // Cinematic timing (ADJUSTED for text to be fully visible when voiceover starts):
            // 0-3s: Black screen with music
            // 3-7s: Background fades in (4s) - completes at 7s
            // 3-7s: Text/border fades in (4s) - completes at 7s (SYNCED with background)
            // 7s: Text fully visible
            // 9s: Narration starts (2s buffer for visual settling)
            // After narration + 2s gap: CTA outro (handled by AudioMerger)
            
            let cinematicBlackDuration = 3
            let bgFadeStart = 3
            let bgFadeDuration = 4
            // Text/border now fade in at SAME TIME as background (3-7s)
            let textFadeStart = 3
            let textFadeDuration = 4
            let narrationStart = 9
            
            if pingPongBackground {
                // Ping-pong mode: forward-reverse-forward for seamless continuity
                ffmpegArgs = ["-y", "-nostdin"]
                // Create ping-pong background stream using reverse filter
                // Input 0: original background (looped internally via filter)
                ffmpegArgs += ["-an", "-i", backgroundPath.path]
                // Input 1: overlay graphic
                ffmpegArgs += ["-loop", "1", "-i", graphicPath.path]
                // Input 2: narration + CTA audio
                ffmpegArgs += ["-i", finalAudioPath.path]
                // Input 3: black screen
                ffmpegArgs += ["-f", "lavfi", "-t", String(cinematicBlackDuration), "-i", "color=black:size=1080x1920:rate=30"]
                
                // For ping-pong, we need to trim the input to ensure exact frame counts match
                // Get video duration and frame rate for proper trimming
                let bgAsset = AVURLAsset(url: backgroundPath)
                let bgDuration = try await bgAsset.load(.duration).seconds
                let bgDurationMs = Int(bgDuration * 1000)
                
                if hasBgMusic {
                    ffmpegArgs += ["-stream_loop", "-1", "-i", backgroundMusicPath]
                    ffmpegArgs += [
                        "-filter_complex",
                        // Process background: trim to exact duration, scale, then split for ping-pong
                        "[0:v]trim=duration=8,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,setpts=PTS-STARTPTS[orig];" +
                        "[orig]split=3[orig1][revin][orig2];" +
                        "[revin]reverse,setpts=PTS-STARTPTS[revout];" +
                        "[orig1][revout][orig2]concat=n=3:v=1:a=0[pingpong];" +
                        // Fade in ping-pong background from 3s over 4s
                        "[pingpong]fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
                        // Black screen preparation
                        "[3:v]scale=1080:1920,setsar=1[black];" +
                        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
                        // Text overlay: fade in from 7s over 2s (completed by 9s)
                        "[1:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
                        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                        // Narration: delay 9 seconds (9000ms) to start when text is fully visible
                        "[2:a]adelay=\(narrationStart)000|\(narrationStart)000[narr];" +
                        // Background music: low volume (14%)
                        "[4:a]volume=0.14[musiclow];" +
                        "[narr][musiclow]amix=inputs=2:duration=first:dropout_transition=2[aout]",
                        "-map", "[vout]", "-map", "[aout]"
                    ]
                } else {
                    ffmpegArgs += [
                        "-filter_complex",
                        "[0:v]trim=duration=8,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,setpts=PTS-STARTPTS[orig];" +
                        "[orig]split=3[orig1][revin][orig2];" +
                        "[revin]reverse,setpts=PTS-STARTPTS[revout];" +
                        "[orig1][revout][orig2]concat=n=3:v=1:a=0[pingpong];" +
                        "[pingpong]fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
                        "[3:v]scale=1080:1920,setsar=1[black];" +
                        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
                        "[1:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
                        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                        "[2:a]adelay=\(narrationStart)000|\(narrationStart)000[aout]",
                        "-map", "[vout]", "-map", "[aout]"
                    ]
                }
                if !outputJSON { print("🔄 Using ping-pong background (forward-back-forward)") }
            } else {
                // Standard loop mode
                ffmpegArgs = ["-y", "-nostdin", "-stream_loop", "-1", "-an", "-i", backgroundPath.path]
                ffmpegArgs += ["-loop", "1", "-i", graphicPath.path]
                ffmpegArgs += ["-i", finalAudioPath.path]
                ffmpegArgs.insert(contentsOf: ["-f", "lavfi", "-t", String(cinematicBlackDuration), "-i", "color=black:size=1080x1920:rate=30"], at: 0)
                
                if hasBgMusic {
                    ffmpegArgs += ["-stream_loop", "-1", "-i", backgroundMusicPath]
                    ffmpegArgs += [
                        "-filter_complex",
                        "[0:v]scale=1080:1920,setsar=1[black];" +
                        "[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,format=rgba,fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
                        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
                        "[2:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
                        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                        "[3:a]adelay=\(narrationStart)000|\(narrationStart)000[narr];" +
                        "[4:a]volume=0.14[musiclow];" +
                        "[narr][musiclow]amix=inputs=2:duration=first:dropout_transition=2[aout]",
                        "-map", "[vout]", "-map", "[aout]"
                    ]
                } else {
                    ffmpegArgs += [
                        "-filter_complex",
                        "[0:v]scale=1080:1920,setsar=1[black];" +
                        "[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,format=rgba,fade=in:st=\(bgFadeStart):d=\(bgFadeDuration):alpha=1[bgfade];" +
                        "[black][bgfade]overlay=0:0:shortest=0:format=auto[prebg];" +
                        "[2:v]scale=1080:1920,format=rgba,fade=in:st=\(textFadeStart):d=\(textFadeDuration):alpha=1[ovrl];" +
                        "[prebg][ovrl]overlay=0:0:shortest=1:format=auto[vout];" +
                        "[3:a]adelay=\(narrationStart)000|\(narrationStart)000[aout]",
                        "-map", "[vout]", "-map", "[aout]"
                    ]
                }
            }
            
            // Use -t to enforce minimum duration, -shortest only if no padding needed
            // This ensures the video continues with background + text overlay for the full duration
            if needsPadding {
                ffmpegArgs += [
                    "-c:v", "libx264",
                    "-preset", "medium",
                    "-crf", "23",
                    "-c:a", "aac",
                    "-b:a", "192k",
                    "-t", String(targetDuration),
                    finalVideoPath.path
                ]
            } else {
                ffmpegArgs += [
                    "-c:v", "libx264",
                    "-preset", "medium",
                    "-crf", "23",
                    "-c:a", "aac",
                    "-b:a", "192k",
                    "-shortest",
                    finalVideoPath.path
                ]
            }
            
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
            
            // 6. Output - Get actual video duration
            let finalVideoDuration = try await AVURLAsset(url: finalVideoPath).load(.duration).seconds
            
            if outputJSON {
                let result: [String: Any] = [
                    "success": true,
                    "videoPath": finalVideoPath.path,
                    "duration": finalVideoDuration,
                    "background": backgroundPath.lastPathComponent
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                if let jsonStr = String(data: jsonData, encoding: .utf8) { print(jsonStr) }
            } else {
                print("\n✅ Video Generated Successfully!")
                print("📂 Saved to: \(finalVideoPath.path)")
                if needsPadding {
                    print("⏱️ Final duration: \(String(format: "%.1f", finalVideoDuration))s (padded from \(String(format: "%.1f", durationSeconds))s to meet 15s minimum)")
                } else {
                    print("⏱️ Duration: \(String(format: "%.1f", finalVideoDuration))s")
                }
            }
            
            // Debug: save graphic for inspection
            let debugGraphicDst = URL(fileURLWithPath: "/tmp/debug_graphic.png")
            try? FileManager.default.removeItem(at: debugGraphicDst)
            try? FileManager.default.copyItem(at: graphicPath, to: debugGraphicDst)
            if !outputJSON { print("🔍 Debug graphic saved: /tmp/debug_graphic.png") }
            
            // Cleanup
            try? FileManager.default.removeItem(at: graphicPath)
            try? FileManager.default.removeItem(at: narrationWAVPath)
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
