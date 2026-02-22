import Foundation
import AVFoundation

// MARK: - Video Generation Command

enum VideoGenerationCommand {
    
    static func generateVideo(arguments: [String]) async {
        print("🎬 Generating Video from RSS Content")
        print("═══════════════════════════════════\n")
        
        let config = parseArguments(arguments)
        
        if config.title.isEmpty || config.content.isEmpty {
            if config.outputJSON {
                print("{\"success\":false,\"error\":\"Missing --title or --content\"}")
            } else {
                print("❌ Error: Missing --title or --content")
            }
            exit(1)
        }
        
        await VideoRenderer.render(config: config)
    }
    
    // MARK: - Argument Parsing
    
    private static func parseArguments(_ arguments: [String]) -> VideoConfig {
        var config = VideoConfig()
        var i = 0
        
        while i < arguments.count {
            let arg = arguments[i]
            switch arg {
            case "--title" where i + 1 < arguments.count:
                config.title = arguments[i+1]; i += 2
            case "--content" where i + 1 < arguments.count:
                config.content = arguments[i+1]; i += 2
            case "--source" where i + 1 < arguments.count:
                config.source = arguments[i+1]; i += 2
            case "--background" where i + 1 < arguments.count:
                config.background = arguments[i+1]; i += 2
            case "--border" where i + 1 < arguments.count:
                config.border = arguments[i+1]; i += 2
            case "--output" where i + 1 < arguments.count:
                config.outputPath = arguments[i+1]; i += 2
            case "--content-type" where i + 1 < arguments.count:
                config.contentType = arguments[i+1]; i += 2
            case "--node-title" where i + 1 < arguments.count:
                config.nodeTitle = arguments[i+1]; i += 2
            case "--audio-file" where i + 1 < arguments.count:
                config.audioFile = arguments[i+1]; i += 2
            case "--black-screen" where i + 1 < arguments.count:
                config.blackScreenDuration = Int(arguments[i+1]) ?? 0; i += 2
            case "--output-json":
                config.outputJSON = true; i += 1
            case "--ping-pong":
                config.pingPong = true; i += 1
            default:
                i += 1
            }
        }
        
        return config
    }
}

// MARK: - Video Configuration

struct VideoConfig {
    var title = ""
    var content = ""
    var source = "wisdombook.life"
    var background = "auto"
    var border = "gold"
    var outputPath: String? = nil
    var contentType: String? = nil
    var nodeTitle: String? = nil
    var audioFile: String? = nil
    var blackScreenDuration = 0
    var outputJSON = false
    var pingPong = true
}
