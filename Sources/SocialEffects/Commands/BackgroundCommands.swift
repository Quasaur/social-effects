import Foundation

// MARK: - Background Generation Commands

enum BackgroundCommands {
    
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
    
    // MARK: - Test Background
    
    private static func generateTestBackground() async {
        print("🧪 TEST MODE: Generating ONE test background video")
        print("═══════════════════════════════════════════════\n")
        
        do {
            let service = try GeminiVideoService()
            let outputDir = "output/backgrounds"
            
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
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
    
    // MARK: - All Backgrounds
    
    private static func generateAllBackgrounds() async {
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
            
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            var successCount = 0
            var failedPrompts: [String] = []
            
            for (index, prompt) in PromptTemplates.all.enumerated() {
                print("\n[\(index + 1)/10] ═══════════════════════════════")
                
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
            
            await createManifest(outputDir: outputDir)
            
        } catch GeminiVideoService.GeminiError.missingAPIKey {
            print("❌ GEMINI_API_KEY not set. Run: swift run SocialEffects test-api")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    // MARK: - Manifest
    
    private static func createManifest(outputDir: String) async {
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
}
