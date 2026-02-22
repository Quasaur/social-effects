import Foundation

// MARK: - Border Selector

enum BorderSelector {
    static let approvedBorders: [TextGraphicsGenerator.BorderStyle] = [
        .artDeco, .classicScroll, .sacredGeometry, .celticKnot, .fleurDeLis,
        .baroque, .victorian, .goldenVine, .stainedGlass, .modernGlow
    ]
    
    static func dailyBorder() -> TextGraphicsGenerator.BorderStyle {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return approvedBorders[(dayOfYear - 1) % approvedBorders.count]
    }
}
