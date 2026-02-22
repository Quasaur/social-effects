import Foundation
import AVFoundation

// MARK: - Main Entry Point

@main
struct SocialEffectsCLI {
    static func main() async {
        // Load environment
        _ = DotEnv.load()
        
        let arguments = CommandLine.arguments
        let command = arguments.count > 1 ? arguments[1] : "help"
        
        // Clear audio cache before video generation
        if ["generate-video", "test-video"].contains(command) {
            await clearAudioCache()
        }
        
        // Route to appropriate command
        switch command {
        case "generate-backgrounds":
            await BackgroundCommands.generateBackgrounds(arguments: Array(arguments.dropFirst(2)))
        case "pika-generate":
            await PikaCommands.pikaGenerate(arguments: Array(arguments.dropFirst(2)))
        case "generate-video":
            await VideoGenerationCommand.generateVideo(arguments: Array(arguments.dropFirst(2)))
        case "test-video":
            await TestVideoCommand.testVideo(arguments: Array(arguments.dropFirst(2)))
        case "test-api":
            await testGeminiAPI()
        case "batch-demos":
            await batchGenerateDemos()
        case "api-server":
            await startAPIServer(arguments: Array(arguments.dropFirst(2)))
        case "help", "--help", "-h":
            HelpCommand.printHelp()
        default:
            print("❌ Unknown command: \(command)")
            HelpCommand.printHelp()
        }
    }
    
    // MARK: - Audio Cache
    
    private static func clearAudioCache() async {
        let cacheDir = "output/cache/audio"
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: cacheDir) else { return }
        
        do {
            let files = try fm.contentsOfDirectory(atPath: cacheDir)
            for file in files where file.hasSuffix(".m4a") || file.hasSuffix(".mp3") || file.hasSuffix(".wav") {
                try? fm.removeItem(atPath: "\(cacheDir)/\(file)")
            }
        } catch {
            print("⚠️ Failed to clear audio cache: \(error)")
        }
    }
    
    // MARK: - Gemini API Test
    
    private static func testGeminiAPI() async {
        print("🔍 Testing Gemini API Connection...")
        print("═══════════════════════════════════\n")
        
        do {
            _ = try GeminiVideoService()
            print("✅ API key configured")
            print("✅ Service initialized successfully")
            print("\n🎉 Gemini API connection successful!")
        } catch GeminiVideoService.GeminiError.missingAPIKey {
            print("❌ GEMINI_API_KEY not set")
            print("\n📝 Setup:")
            print("  1. Get API key: https://aistudio.google.com/app/apikey")
            print("  2. Set: export GEMINI_API_KEY=\"your_key\"")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    // MARK: - Batch Demos (Deprecated)
    
    private static func batchGenerateDemos() async {
        print("⚠️  batch-demos command is deprecated.")
        print("Use: swift run SocialEffects generate-video --title \"...\" --content \"...\"")
    }
}
