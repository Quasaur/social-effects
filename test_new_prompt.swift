import Foundation

/// NEW Prompt for Video 01 - Improved concept
struct ImprovedVideoPrompt {
    let id: Int
    let name: String
    let prompt: String
    let negativePrompt: String
    
    // Better alternative for slot 01 - inspired by successful videos
    static let slot01 = ImprovedVideoPrompt(
        id: 1,
        name: "cascading_light_ribbons",
        prompt: "Seamless loop of ethereal light ribbons cascading downward in vertical flow, soft coral pink and mint green gradient, elegant flowing movement, 3D volumetric lighting, dreamy atmospheric glow, smooth transitions, perfect loop, cinematic 8 seconds, 9:16 portrait orientation",
        negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, static images, geometric shapes"
    )
}

// Test the prompt
print("New Video 01 Concept:")
print("Name: \(ImprovedVideoPrompt.slot01.name)")
print("Prompt: \(ImprovedVideoPrompt.slot01.prompt)")
