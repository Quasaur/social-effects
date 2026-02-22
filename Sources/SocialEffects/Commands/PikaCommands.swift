import Foundation

// MARK: - Pika Video Generation Commands

enum PikaCommands {
    
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
    
    // MARK: - Test
    
    private static func pikaGenerateTest() async {
        print("🧪 PIKA TEST: Generating ONE test video")
        print("═══════════════════════════════════════════════\n")
        
        do {
            let service = try PikaVideoService()
            let outputDir = "output/backgrounds"
            
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
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
    
    // MARK: - All
    
    private static func pikaGenerateAll() async {
        print("🎬 Generating 4 Missing Background Videos via Pika")
        print("═══════════════════════════════════════════════\n")
        
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
            
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            
            var successCount = 0
            var failedPrompts: [String] = []
            
            for (counter, index) in slotsToGenerate.enumerated() {
                let prompt = PromptTemplates.all[index]
                print("\n[\(counter + 1)/4] ═══════════════════════════════")
                
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
}
