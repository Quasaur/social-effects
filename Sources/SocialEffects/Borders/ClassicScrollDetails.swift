import Foundation
import AppKit

// MARK: - Classic Scroll Details

extension TextGraphicsGenerator {
    
    func drawClassicLeavesAndDots(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        drawLeaf(at: NSPoint(x: o.x + dx * 15, y: o.y + dy * 40), angle: atan2(dy, dx) + .pi/3, size: 9)
        drawLeaf(at: NSPoint(x: o.x + dx * 8, y: o.y + dy * 70), angle: atan2(dy, dx) - .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 20, y: o.y + dy * 110), angle: atan2(dy, dx) + .pi/5, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 10, y: o.y + dy * 150), angle: atan2(dy, dx) - .pi/3, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 18, y: o.y + dy * 195), angle: atan2(dy, dx) + .pi/6, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 15, y: o.y + dy * 240), angle: atan2(dy, dx) - .pi/4, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 20, y: o.y + dy * 265), angle: atan2(dy, dx) + .pi/3, size: 5)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 40, y: o.y + dy * 15), angle: atan2(dy, dx) - .pi/3, size: 9)
        drawLeaf(at: NSPoint(x: o.x + dx * 70, y: o.y + dy * 8), angle: atan2(dy, dx) + .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 110, y: o.y + dy * 20), angle: atan2(dy, dx) - .pi/5, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 150, y: o.y + dy * 10), angle: atan2(dy, dx) + .pi/3, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 195, y: o.y + dy * 18), angle: atan2(dy, dx) - .pi/6, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 240, y: o.y + dy * 15), angle: atan2(dy, dx) + .pi/4, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 265, y: o.y + dy * 20), angle: atan2(dy, dx) - .pi/3, size: 5)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 30, y: o.y + dy * 28), angle: atan2(dy, dx), size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 60, y: o.y + dy * 55), angle: atan2(dy, dx) + .pi/2, size: 7)
        drawLeaf(at: NSPoint(x: o.x + dx * 85, y: o.y + dy * 88), angle: atan2(dy, dx) - .pi/4, size: 7)
        
        drawLeaf(at: NSPoint(x: o.x + dx * 45, y: o.y + dy * 130), angle: .pi/3, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 130, y: o.y + dy * 45), angle: -.pi/3, size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 30, y: o.y + dy * 215), angle: .pi/4, size: 5)
        drawLeaf(at: NSPoint(x: o.x + dx * 215, y: o.y + dy * 30), angle: -.pi/4, size: 5)
        
        let dotPositions: [(CGFloat, CGFloat)] = [
            (8, 25), (25, 8), (15, 15), (40, 40),
            (60, 60), (80, 80), (35, 55), (55, 35),
            (10, 90), (90, 10), (5, 130), (130, 5),
            (15, 170), (170, 15), (10, 210), (210, 10),
            (18, 250), (250, 18), (45, 100), (100, 45),
            (10, 70), (70, 10), (30, 120), (120, 30),
            (50, 160), (160, 50), (75, 200), (200, 75)
        ]
        for (px, py) in dotPositions {
            NSBezierPath(ovalIn: NSRect(x: o.x + dx*px - 2, y: o.y + dy*py - 2, width: 4, height: 4)).fill()
        }
    }
    
    func drawClassicCornerDecorations(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let ic1 = NSBezierPath()
        ic1.move(to: NSPoint(x: o.x + dx * 30, y: o.y + dy * 20))
        ic1.curve(to: NSPoint(x: o.x + dx * 55, y: o.y + dy * 50),
                  controlPoint1: NSPoint(x: o.x + dx * 48, y: o.y + dy * 18),
                  controlPoint2: NSPoint(x: o.x + dx * 52, y: o.y + dy * 38))
        ic1.lineWidth = 2; ic1.stroke()
        
        let ic2 = NSBezierPath()
        ic2.move(to: NSPoint(x: o.x + dx * 20, y: o.y + dy * 30))
        ic2.curve(to: NSPoint(x: o.x + dx * 50, y: o.y + dy * 55),
                  controlPoint1: NSPoint(x: o.x + dx * 18, y: o.y + dy * 48),
                  controlPoint2: NSPoint(x: o.x + dx * 38, y: o.y + dy * 52))
        ic2.lineWidth = 2; ic2.stroke()
        
        let id1 = NSBezierPath()
        id1.move(to: NSPoint(x: o.x + dx * 50, y: o.y + dy * 50))
        id1.curve(to: NSPoint(x: o.x + dx * 70, y: o.y + dy * 40),
                  controlPoint1: NSPoint(x: o.x + dx * 60, y: o.y + dy * 55),
                  controlPoint2: NSPoint(x: o.x + dx * 65, y: o.y + dy * 42))
        id1.lineWidth = 1.5; id1.stroke()
        let id2 = NSBezierPath()
        id2.move(to: NSPoint(x: o.x + dx * 50, y: o.y + dy * 50))
        id2.curve(to: NSPoint(x: o.x + dx * 40, y: o.y + dy * 70),
                  controlPoint1: NSPoint(x: o.x + dx * 55, y: o.y + dy * 60),
                  controlPoint2: NSPoint(x: o.x + dx * 42, y: o.y + dy * 65))
        id2.lineWidth = 1.5; id2.stroke()
    }
}
