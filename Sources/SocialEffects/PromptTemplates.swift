import Foundation

/// Curated prompts for generating 10 distinct 3D looping background animations
/// Organized by visual mood: Geometric Minimalist, Futuristic Kinetic, Abstract Fluid
struct VideoPrompt {
    let id: Int
    let name: String
    let prompt: String
    let negativePrompt: String
    let audioHint: String
    let category: Category
    
    enum Category: String {
        case geometricMinimalist = "Geometric Minimalist"
        case futuristicKinetic = "Futuristic Kinetic"
        case abstractFluid = "Abstract Fluid"
    }
}

enum PromptTemplates {
    /// All 10 curated video prompts with acceptable variety
    static let all: [VideoPrompt] = [
        // GEOMETRIC MINIMALIST (soft, calming, pastel aesthetic)
        VideoPrompt(
            id: 1,
            name: "crystalline_polygon_morph",
            prompt: "Seamless loop of faceted crystalline polyhedrons slowly transforming between shapes, soft coral and sage green gradient, ethereal glow, minimalist 3D rendering, perfect geometric transitions, ambient lighting, 8 seconds, perfect loop",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, realistic crystals",
            audioHint: "crystalline tones, gentle shimmer",
            category: .geometricMinimalist
        ),
        VideoPrompt(
            id: 2,
            name: "unfolding_flower_pattern",
            prompt: "An intricate 3D geometric form that unfolds and refolds like a mathematical flower, lavender and white palette, high-quality rendering, satisfying smooth transitions, perfect loop, generative art style, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, realistic flowers",
            audioHint: "subtle crystalline chimes, meditative atmosphere",
            category: .geometricMinimalist
        ),
        VideoPrompt(
            id: 3,
            name: "rotating_prism_array",
            prompt: "Array of geometric prisms rotating in synchronized harmony, pastel peach and sky blue tones, soft shadows, clean minimalist composition, hypnotic smooth rotation, seamless loop, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, chaotic motion",
            audioHint: "gentle mechanical hum, soft clicks",
            category: .geometricMinimalist
        ),
        
        // FUTURISTIC KINETIC (high-energy, neon, tunnel aesthetic)
        VideoPrompt(
            id: 4,
            name: "neon_tunnel_flight",
            prompt: "Flying through an endless futuristic geometric tunnel, vertical orientation, neon blue and purple lines, high-speed motion, metallic surfaces, cinematic sci-fi aesthetic, perfect seamless loop, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, slow motion",
            audioHint: "whooshing wind, electronic hum, subtle bass",
            category: .futuristicKinetic
        ),
        VideoPrompt(
            id: 5,
            name: "neon_vortex_spiral",
            prompt: "Spiraling vortex of glowing neon particles, electric blue and violet, hypnotic rotation toward center, dark sci-fi background, high-energy kinetic motion, seamless perfect loop, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, slow motion",
            audioHint: "swirling energy, electronic whoosh",
            category: .futuristicKinetic
        ),
        VideoPrompt(
            id: 6,
            name: "laser_grid_horizon",
            prompt: "Flying low over an infinite glowing laser grid extending to the horizon, neon cyan and hot pink beams, retro synthwave aesthetic, smooth forward glide, seamless loop, cinematic 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, static view",
            audioHint: "retro synthesizer, ambient drone",
            category: .futuristicKinetic
        ),
        
        // ABSTRACT FLUID (moody, dark, organic)
        VideoPrompt(
            id: 7,
            name: "black_liquid_waves",
            prompt: "Seamless loop of abstract moving black waves, liquid-like undulating surface, subtle glossy reflections, moody cinematic lighting, contemplative aesthetic, slow graceful movement, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, bright colors",
            audioHint: "deep bass undertones, subtle water sounds",
            category: .abstractFluid
        ),
        VideoPrompt(
            id: 8,
            name: "iridescent_oil_flow",
            prompt: "Abstract flowing liquid with iridescent oil-slick reflections, dark background, organic undulating patterns, smooth transitions, meditative movement, seamless loop, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, solid colors",
            audioHint: "ambient texture, gentle flowing sounds",
            category: .abstractFluid
        ),
        VideoPrompt(
            id: 9,
            name: "smoke_ink_tendrils",
            prompt: "Wisps of black smoke mixing with ink in water, slow graceful movement, high contrast, dark moody atmosphere, perfect loop transition, cinematic, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, bright colors, fire",
            audioHint: "ethereal whispers, deep atmospheric rumble",
            category: .abstractFluid
        ),
        VideoPrompt(
            id: 10,
            name: "monochrome_gradient_pulse",
            prompt: "Abstract gradient waves pulsing from dark to light gray, minimal geometric forms, depth perspective, meditative rhythm, seamless loop, cinematic, 8 seconds",
            negativePrompt: "cartoon, drawing, text, logos, watermarks, low quality, jarring cuts, color",
            audioHint: "rhythmic pulse, minimalist electronic tones",
            category: .abstractFluid
        )
    ]
    
    /// Get a specific prompt by ID (1-10)
    static func getPrompt(id: Int) -> VideoPrompt? {
        return all.first { $0.id == id }
    }
    
    /// Get all prompts for a specific category
    static func prompts(for category: VideoPrompt.Category) -> [VideoPrompt] {
        return all.filter { $0.category == category }
    }
}
