import Foundation
import AppKit

// MARK: - Border Styles Dispatcher
// Individual border implementations have been extracted to separate files
// in the Borders/ directory to keep file sizes under 150 lines.

extension TextGraphicsGenerator {
    
    /// Gold color used across all ornate borders — RGB(212, 175, 55) / #D4AF37
    /// Reference: BorderDrawingHelpers.borderGoldColor for standalone functions
    static let goldColor = borderGoldColor
    
    /// Dispatches to the appropriate ornate border drawing method
    func drawOrnateBorder(style: BorderStyle, width w: CGFloat, height h: CGFloat) {
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        
        switch style {
        case .artDeco:          drawArtDecoBorder(w: w, h: h)
        case .classicScroll:    drawClassicScrollBorder(w: w, h: h)
        case .sacredGeometry:   drawSacredGeometryBorder(w: w, h: h)
        case .celticKnot:       drawCelticKnotBorder(w: w, h: h)
        case .fleurDeLis:       drawFleurDeLisBorder(w: w, h: h)
        case .baroque:          drawBaroqueBorder(w: w, h: h)
        case .victorian:        drawVictorianBorder(w: w, h: h)
        case .goldenVine:       drawGoldenVineBorder(w: w, h: h)
        case .stainedGlass:     drawStainedGlassBorder(w: w, h: h)
        case .modernGlow:       drawModernGlowBorder(w: w, h: h)
        default: break // gold, silver, minimal, none handled in TextGraphicsGenerator
        }
    }
}

// MARK: - Border Implementations
// Each border style is implemented in a separate file under Borders/:
// - ArtDecoBorder.swift
// - ClassicScrollBorder.swift + ClassicScrollDetails.swift
// - SacredGeometryBorder.swift
// - CelticKnotBorder.swift
// - FleurDeLisBorder.swift
// - BaroqueBorder.swift
// - VictorianBorder.swift
// - GoldenVineBorder.swift
// - StainedGlassBorder.swift
// - ModernGlowBorder.swift
