import Foundation
import AppKit

// MARK: - Sacred Geometry Border

extension TextGraphicsGenerator {
    
    func drawSacredGeometryBorder(w: CGFloat, h: CGFloat) {
        let circR: CGFloat = 16
        let positions: [(CGFloat, CGFloat)] = [
            (w/2, 35), (w/2, h-35), (35, h/2), (w-35, h/2),
            (80, 80), (w-80, 80), (80, h-80), (w-80, h-80)
        ]
        Self.goldColor.setStroke()
        for (cx, cy) in positions {
            strokeOval(center: NSPoint(x: cx, y: cy), radius: circR, lineWidth: 1.2)
            for i in 0..<6 {
                let a = CGFloat(i) * .pi / 3
                strokeOval(center: NSPoint(x: cx + circR * cos(a), y: cy + circR * sin(a)),
                          radius: circR, lineWidth: 0.8)
            }
        }
    }
}
