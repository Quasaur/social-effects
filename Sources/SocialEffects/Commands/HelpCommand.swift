import Foundation

// MARK: - Help Command

enum HelpCommand {
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
}
