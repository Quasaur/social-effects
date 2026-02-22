import Foundation
import AppKit

// MARK: - Golden Vine Details

extension TextGraphicsGenerator {
    
    func drawVineLeavesAndDots(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        drawLeaf(at: NSPoint(x: o.x + dx * 12, y: o.y + dy * 35), angle: atan2(dy, dx) + .pi/3, size: 9)
        drawLeaf(at: NSPoint(x: o.x + dx * 5, y: o.y + dy * 55), angle: atan2(dy, dx) - .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 10, y: o.y + dy * 80), angle: atan2(dy, dx) + .pi/5, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 12, y: o.y + dy * 115), angle: atan2(dy, dx) - .pi/3, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 8, y: o.y + dy * 130), angle: atan2(dy, dx) + .pi/6, size: 6)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 35, y: o.y + dy * 12), angle: atan2(dy, dx) - .pi/3, size: 9)
        drawLeaf(at: NSPoint(x: o.x + dx * 55, y: o.y + dy * 5), angle: atan2(dy, dx) + .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 80, y: o.y + dy * 10), angle: atan2(dy, dx) - .pi/5, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 115, y: o.y + dy * 12), angle: atan2(dy, dx) + .pi/3, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 130, y: o.y + dy * 8), angle: atan2(dy, dx) - .pi/6, size: 6)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 25, y: o.y + dy * 22), angle: atan2(dy, dx), size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 50, y: o.y + dy * 48), angle: atan2(dy, dx) + .pi/2, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 68, y: o.y + dy * 72), angle: atan2(dy, dx) - .pi/4, size: 6)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 40, y: o.y + dy * 70), angle: .pi/3, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 70, y: o.y + dy * 40), angle: -.pi/3, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 30, y: o.y + dy * 108), angle: .pi/4, size: 5)
        drawLeaf(at: NSPoint(x: o.x + dx * 108, y: o.y + dy * 30), angle: -.pi/4, size: 5)
        
        let dotPositions: [(CGFloat, CGFloat)] = [
            (5, 20), (20, 5), (15, 45), (45, 15),
            (30, 30), (55, 55), (70, 70),
            (10, 70), (70, 10), (5, 95), (95, 5),
            (10, 125), (125, 10), (50, 80), (80, 50)
        ]
        for (px, py) in dotPositions {
            NSBezierPath(ovalIn: NSRect(x: o.x + dx*px - 2, y: o.y + dy*py - 2, width: 4, height: 4)).fill()
        }
    }
}
