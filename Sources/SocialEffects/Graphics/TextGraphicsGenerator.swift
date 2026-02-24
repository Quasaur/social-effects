import Foundation
import AppKit

/// Generates stoic-aesthetic text graphics for video overlays
class TextGraphicsGenerator {
    
    // MARK: - Stoic Color Palette
    
    struct StoicColors {
        static let deepCharcoal = NSColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0) // #1a1a1a
        static let offWhite = NSColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0)     // #e8e8e8
        static let mutedGray = NSColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 1.0)    // #b8b8b8
    }
    
    // MARK: - Border Styles
    
    enum BorderStyle: String, CaseIterable {
        // Simple borders
        case none
        case gold
        case silver
        case minimal
        // Ornate borders (ported from Social Marketer)
        case artDeco = "art-deco"
        case classicScroll = "classic-scroll"
        case sacredGeometry = "sacred-geometry"
        case celticKnot = "celtic-knot"
        case fleurDeLis = "fleur-de-lis"
        case baroque
        case victorian
        case goldenVine = "golden-vine"
        case stainedGlass = "stained-glass"
        case modernGlow = "modern-glow"
        
        /// Whether this is an ornate (ported) border style
        var isOrnate: Bool {
            switch self {
            case .none, .gold, .silver, .minimal: return false
            default: return true
            }
        }
        
        /// Random ornate border
        static var randomOrnate: BorderStyle {
            let ornate: [BorderStyle] = [.artDeco, .classicScroll, .sacredGeometry, .celticKnot,
                                          .fleurDeLis, .baroque, .victorian, .goldenVine,
                                          .stainedGlass, .modernGlow]
            return ornate.randomElement()!
        }
    }
    
    // MARK: - Generate Graphic
    
    /// Generate a stoic-styled text graphic
    /// - Parameters:
    ///   - title: Content title displayed at top of frame
    ///   - text: Quote text to render
    ///   - source: Book name for quotes or Bible reference for passages (shown as attribution)
    ///   - outputPath: Where to save the PNG
    ///   - width: Image width (default: 1080 for vertical video)
    ///   - height: Image height (default: 1920 for vertical video)
    ///   - border: Border style to apply
    /// - Returns: URL of generated image
    func generate(
        title: String = "",
        text: String,
        source: String = "",
        outputPath: URL,
        width: Int = 1080,
        height: Int = 1920,
        border: BorderStyle = .none
    ) throws -> URL {
        
        let size = NSSize(width: width, height: height)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Transparent background — the looping video will show through
        NSColor.clear.setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()
        
        // Draw vertical gradient scrim behind text area for readability
        // Transparent at top/bottom edges → 70% opacity charcoal in center
        let scrimRect = NSRect(x: 0, y: 0, width: width, height: height)
        if let gradient = NSGradient(colorsAndLocations:
            (StoicColors.deepCharcoal.withAlphaComponent(0.0), 0.0),    // bottom: transparent
            (StoicColors.deepCharcoal.withAlphaComponent(0.50), 0.15),  // fade in
            (StoicColors.deepCharcoal.withAlphaComponent(0.70), 0.30),  // reach full opacity
            (StoicColors.deepCharcoal.withAlphaComponent(0.70), 0.75),  // hold through text area
            (StoicColors.deepCharcoal.withAlphaComponent(0.50), 0.88),  // fade out
            (StoicColors.deepCharcoal.withAlphaComponent(0.0), 1.0)     // top: transparent
        ) {
            gradient.draw(in: scrimRect, angle: 90)  // 90° = bottom to top
        }
        
        // Draw Border
        drawBorder(style: border, width: CGFloat(width), height: CGFloat(height))
        
        // Calculate content text width for font sizing (used by both title and content)
        let textWidth = CGFloat(width) * 0.60
        
        // Draw title at top of frame
        if !title.isEmpty {
            let titleWidth = CGFloat(width) * 0.70
            let titleX = (CGFloat(width) - titleWidth) / 2
            let titleY = CGFloat(height) * 0.78  // Upper area (AppKit y=0 is bottom)
            let titleHeight: CGFloat = 160  // Increased from 100 to allow multi-line titles
            
            let titleParagraph = NSMutableParagraphStyle()
            titleParagraph.alignment = .center
            titleParagraph.lineBreakMode = .byWordWrapping  // Enable word wrapping
            titleParagraph.lineSpacing = 8  // Tighter line spacing for titles
            
            // Calculate title font size based on content font size (always larger)
            let contentFontSize = calculateFontSize(for: text, width: textWidth)
            let titleFontSize = contentFontSize * 1.15  // Reduced from 1.25 to prevent overflow
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Georgia-Bold", size: titleFontSize) ?? NSFont.boldSystemFont(ofSize: titleFontSize),
                .foregroundColor: StoicColors.offWhite.withAlphaComponent(0.85),
                .paragraphStyle: titleParagraph
            ]
            
            let titleText = NSAttributedString(string: title.uppercased(), attributes: titleAttributes)
            let titleRect = NSRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
            titleText.draw(in: titleRect)
        }
        
        // Calculate text area (60% of width, centered)
        let textX = (CGFloat(width) - textWidth) / 2
        let textY = CGFloat(height) * 0.28 // Position from bottom (lowered from 0.35)
        let textHeight = CGFloat(height) * 0.40
        
        let textRect = NSRect(x: textX, y: textY, width: textWidth, height: textHeight)
        
        // Create attributed string with stoic styling
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 12
        
        let fontSize: CGFloat = calculateFontSize(for: text, width: textWidth)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Georgia", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize),
            .foregroundColor: StoicColors.offWhite,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.draw(in: textRect)
        
        // Attribution: only show source for QUOTE (book name) or PASSAGE (Bible reference)
        // THOUGHT types skip attribution entirely (wisdombook.life appears in CTA outro)
        if !source.isEmpty {
            let attribution = "— \(source)"
            let attrFontSize: CGFloat = 36  // Slightly smaller for book/Bible references
            let attrColor = StoicColors.mutedGray  // Muted gray for source attribution
            
            let attrAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Georgia-Bold", size: attrFontSize) ?? NSFont.boldSystemFont(ofSize: attrFontSize),
                .foregroundColor: attrColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let attrText = NSAttributedString(string: attribution, attributes: attrAttributes)
            let attrY = textY - 80  // Just below content area (adjusted for new content position)
            let attrRect = NSRect(x: textX, y: attrY, width: textWidth, height: 60)
            attrText.draw(in: attrRect)
        }
        
        image.unlockFocus()
        
        // Save as PNG
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw GraphicsError.pngConversionFailed
        }
        
        try pngData.write(to: outputPath)
        
        print("✅ Generated graphic: \(outputPath.lastPathComponent)")
        print("   Size: \(width)×\(height)")
        print("   Border: \(border.rawValue)")
        
        return outputPath
    }
    
    // MARK: - Helper Methods
    
    private func drawBorder(style: BorderStyle, width: CGFloat, height: CGFloat) {
        guard style != .none else { return }
        
        // Ornate borders delegate to BorderStyles.swift
        if style.isOrnate {
            drawOrnateBorder(style: style, width: width, height: height)
            return
        }
        
        // Simple borders: gold, silver, minimal
        let path = NSBezierPath()
        let inset: CGFloat = 40
        let rect = NSRect(x: inset, y: inset, width: width - (inset * 2), height: height - (inset * 2))
        
        path.appendRect(rect)
        path.lineWidth = 4
        
        switch style {
        case .gold:
            Self.goldColor.setStroke()
        case .silver:
            NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0).setStroke()
        case .minimal:
            NSColor(white: 1.0, alpha: 0.3).setStroke()
            path.lineWidth = 1
        default:
            return
        }
        
        path.stroke()
        
        if style == .gold || style == .silver {
            let innerPath = NSBezierPath()
            let innerInset: CGFloat = 50
            let innerRect = NSRect(x: innerInset, y: innerInset, width: width - (innerInset * 2), height: height - (innerInset * 2))
            innerPath.appendRect(innerRect)
            innerPath.lineWidth = 1
            innerPath.stroke()
        }
    }
    
    private func calculateFontSize(for text: String, width: CGFloat) -> CGFloat {
        let wordCount = text.split(separator: " ").count
        
        switch wordCount {
        case 0...10:
            return 64  // Short quotes - large text
        case 11...20:
            return 56  // Medium quotes
        case 21...30:
            return 48  // Longer quotes
        default:
            return 42  // Very long quotes (compact)
        }
    }
    
    // MARK: - Errors
    
    enum GraphicsError: LocalizedError {
        case pngConversionFailed
        
        var errorDescription: String? {
            switch self {
            case .pngConversionFailed:
                return "Failed to convert image to PNG"
            }
        }
    }
}
