import Foundation
import AppKit

// MARK: - Modern Glow Border

extension TextGraphicsGenerator {
    
    func drawModernGlowBorder(w: CGFloat, h: CGFloat) {
        for i in (0..<8).reversed() {
            let inset = CGFloat(12 + i * 6)
            let alpha = 0.08 + (1.0 - Double(i) / 7.0) * 0.92
            let lw = CGFloat(1 + (7 - i))
            NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: CGFloat(alpha)).setStroke()
            let path = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: w-inset*2, height: h-inset*2),
                                     xRadius: 8, yRadius: 8)
            path.lineWidth = lw; path.stroke()
        }
        
        Self.goldColor.setStroke()
        let inner = NSRect(x: 58, y: 58, width: w-116, height: h-116)
        let innerPath = NSBezierPath(roundedRect: inner, xRadius: 4, yRadius: 4)
        innerPath.lineWidth = 2; innerPath.stroke()
        
        for (cx, cy) in [(inner.minX, inner.minY), (inner.maxX, inner.minY),
                          (inner.minX, inner.maxY), (inner.maxX, inner.maxY)] {
            for (r, a) in [(CGFloat(14), CGFloat(0.1)), (CGFloat(9), CGFloat(0.3)),
                           (CGFloat(5), CGFloat(0.7)), (CGFloat(2.5), CGFloat(1.0))] {
                NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: a).setFill()
                NSBezierPath(ovalIn: NSRect(x: cx-r, y: cy-r, width: r*2, height: r*2)).fill()
            }
        }
    }
}
