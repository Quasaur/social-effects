import Foundation

// Sample Thoughts from wisdombook.life
// These will be used for the 10 demo videos

struct Thought: Codable {
    let title: String
    let content: String
    let source: String
    
    init(title: String, content: String, source: String = "wisdombook.life") {
        self.title = title
        self.content = content
        self.source = source
    }
}

// 10 Curated Thoughts for Demo Videos
let demoThoughts: [Thought] = [
    // Demo 1: Cross-Dissolve intro
    Thought(
        title: "True wisdom comes from questions",
        content: "The wisest person is not the one with all the answers, but the one who asks the best questions."
    ),
    
    // Demo 2: Zoom Expand intro
    Thought(
        title: "Courage is not absence of fear",
        content: "Courage isn't the lack of fear—it's feeling the fear and taking action anyway."
    ),
    
    // Demo 3: Wipe transition
    Thought(
        title: "Your thoughts shape your reality",
        content: "What you focus on expands. Choose your thoughts carefully—they become your world."
    ),
    
    // Demo 4: Card Flip H
    Thought(
        title: "Growth happens outside comfort",
        content: "The magic happens when you step beyond what's familiar. Discomfort is the price of transformation."
    ),
    
    // Demo 5: Light Leaks (Frei0r glow effect)
    Thought(
        title: "Kindness is contagious", 
        content: "A single act of kindness creates ripples that spread farther than you'll ever know."
    ),
    
    // Demo 6: Particles overlay
    Thought(
        title: "Progress over perfection",
        content: "Don't wait for the perfect moment—take the moment and make it perfect through action."
    ),
    
    // Demo 7: Word Reveal animation
    Thought(
        title: "Listen more, speak less",
        content: "True wisdom often comes from listening deeply, not from waiting for your turn to talk."
    ),
    
    // Demo 8: Circular Collapse outro
    Thought(
        title: "Time is your most precious resource",
        content: "You can always earn more money, but you can never get back lost time. Spend it wisely."
    ),
    
    // Demo 9: Elegant combo (Cross-Dissolve + Light Leaks + Circular Collapse)
    Thought(
        title: "Patience is a superpower",
        content: "In a world of instant gratification, the ability to wait and work consistently is rare and powerful."
    ),
    
    // Demo 10: Energetic combo (Zoom + Particles + Blinds)
    Thought(
        title: "Your energy attracts your tribe",
        content: "The vibe you put out into the world determines the people and opportunities that come your way."
    )
]

// Helper function to export as JSON
func exportThoughtsAsJSON() {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    if let jsonData = try? encoder.encode(demoThoughts),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
}
