#!/usr/bin/env swift

import Foundation
import AppKit

func generateGraphic() {
    let text = "True wisdom comes from questions"
    let width = 1080
    let height = 1920
    
    // Create NSImage (handles coordinates correctly)
    let image = NSImage(size: NSSize(width: width, height: height))
    
    image.lockFocus()
    
    // Background
    NSColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    
    // Text attributes
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.lineSpacing = 12
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "Georgia", size: 64) ?? NSFont.systemFont(ofSize: 64),
        .foregroundColor: NSColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0),
        .paragraphStyle: paragraphStyle
    ]
    
    // Draw text (NSAttributedString handles coordinates properly!)
    let textRect = NSRect(x: 216, y: 600, width: 648, height: 720)
    let attributedText = NSAttributedString(string: text, attributes: attributes)
    attributedText.draw(in: textRect)
    
    // Attribution
    let attrAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "Georgia", size: 28) ?? NSFont.systemFont(ofSize: 28),
        .foregroundColor: NSColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 1.0),
        .paragraphStyle: paragraphStyle
    ]
    
    let attrRect = NSRect(x: 216, y: 192, width: 648, height: 50)
    let attrText = NSAttributedString(string: "wisdombook.life", attributes: attrAttributes)
    attrText.draw(in: attrRect)
    
    image.unlockFocus()
    
    // Save as PNG
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("❌ Failed to create PNG")
        return
    }
    
    let outputPath = "/tmp/test_graphic.png"
    try? pngData.write(to: URL(fileURLWithPath: outputPath))
    
    print("✅ Graphic saved to: \(outputPath)")
    print("   This should be RIGHT-SIDE UP now!")
}

generateGraphic()
