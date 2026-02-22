import Foundation
import AppKit

// MARK: - Golden Vine Border

extension TextGraphicsGenerator {
    
    func drawGoldenVineBorder(w: CGFloat, h: CGFloat) {
        strokeRect(NSRect(x: 28, y: 28, width: w-56, height: h-56), lineWidth: 2)
        strokeRect(NSRect(x: 42, y: 42, width: w-84, height: h-84), lineWidth: 1)
        
        drawLushVineCorner(at: NSPoint(x: 28, y: 28), dx: 1, dy: 1)
        drawLushVineCorner(at: NSPoint(x: w-28, y: 28), dx: -1, dy: 1)
        drawLushVineCorner(at: NSPoint(x: 28, y: h-28), dx: 1, dy: -1)
        drawLushVineCorner(at: NSPoint(x: w-28, y: h-28), dx: -1, dy: -1)
    }
    
    private func drawLushVineCorner(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        
        let v1 = NSBezierPath()
        v1.move(to: NSPoint(x: o.x, y: o.y + dy * 8))
        v1.curve(to: NSPoint(x: o.x + dx * 15, y: o.y + dy * 140),
                 controlPoint1: NSPoint(x: o.x + dx * 55, y: o.y + dy * 30),
                 controlPoint2: NSPoint(x: o.x - dx * 20, y: o.y + dy * 110))
        v1.lineWidth = 2.5; v1.lineCapStyle = .round; v1.stroke()
        
        let v2 = NSBezierPath()
        v2.move(to: NSPoint(x: o.x + dx * 8, y: o.y))
        v2.curve(to: NSPoint(x: o.x + dx * 140, y: o.y + dy * 15),
                 controlPoint1: NSPoint(x: o.x + dx * 30, y: o.y + dy * 55),
                 controlPoint2: NSPoint(x: o.x + dx * 110, y: o.y - dy * 20))
        v2.lineWidth = 2.5; v2.lineCapStyle = .round; v2.stroke()
        
        let vd = NSBezierPath()
        vd.move(to: NSPoint(x: o.x + dx * 5, y: o.y + dy * 5))
        vd.curve(to: NSPoint(x: o.x + dx * 80, y: o.y + dy * 80),
                 controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 15),
                 controlPoint2: NSPoint(x: o.x + dx * 15, y: o.y + dy * 50))
        vd.lineWidth = 2; vd.lineCapStyle = .round; vd.stroke()
        
        drawGoldenVineTendrils(at: o, dx: dx, dy: dy)
        drawGoldenVineDecorations(at: o, dx: dx, dy: dy)
        drawVineLeavesAndDots(at: o, dx: dx, dy: dy)
    }
    
    private func drawGoldenVineTendrils(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let t1 = NSBezierPath()
        t1.move(to: NSPoint(x: o.x + dx * 20, y: o.y + dy * 60))
        t1.curve(to: NSPoint(x: o.x + dx * 65, y: o.y + dy * 85),
                 controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 45),
                 controlPoint2: NSPoint(x: o.x + dx * 60, y: o.y + dy * 70))
        t1.lineWidth = 1.8; t1.stroke()
        
        let c1 = NSBezierPath()
        let ce1 = NSPoint(x: o.x + dx * 65, y: o.y + dy * 85)
        c1.move(to: ce1)
        c1.curve(to: NSPoint(x: ce1.x + dx * 12, y: ce1.y - dy * 8),
                 controlPoint1: NSPoint(x: ce1.x + dx * 10, y: ce1.y + dy * 10),
                 controlPoint2: NSPoint(x: ce1.x + dx * 15, y: ce1.y + dy * 2))
        c1.lineWidth = 1.5; c1.stroke()
        
        let t2 = NSBezierPath()
        t2.move(to: NSPoint(x: o.x + dx * 60, y: o.y + dy * 20))
        t2.curve(to: NSPoint(x: o.x + dx * 85, y: o.y + dy * 65),
                 controlPoint1: NSPoint(x: o.x + dx * 45, y: o.y + dy * 50),
                 controlPoint2: NSPoint(x: o.x + dx * 70, y: o.y + dy * 60))
        t2.lineWidth = 1.8; t2.stroke()
        
        let c2 = NSBezierPath()
        let ce2 = NSPoint(x: o.x + dx * 85, y: o.y + dy * 65)
        c2.move(to: ce2)
        c2.curve(to: NSPoint(x: ce2.x - dx * 8, y: ce2.y + dy * 12),
                 controlPoint1: NSPoint(x: ce2.x + dx * 10, y: ce2.y + dy * 10),
                 controlPoint2: NSPoint(x: ce2.x + dx * 2, y: ce2.y + dy * 15))
        c2.lineWidth = 1.5; c2.stroke()
    }
    
    private func drawGoldenVineDecorations(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let t3 = NSBezierPath()
        t3.move(to: NSPoint(x: o.x + dx * 5, y: o.y + dy * 100))
        t3.curve(to: NSPoint(x: o.x + dx * 45, y: o.y + dy * 120),
                 controlPoint1: NSPoint(x: o.x + dx * 30, y: o.y + dy * 90),
                 controlPoint2: NSPoint(x: o.x + dx * 40, y: o.y + dy * 105))
        t3.lineWidth = 1.5; t3.stroke()
        let c3 = NSBezierPath()
        let ce3 = NSPoint(x: o.x + dx * 45, y: o.y + dy * 120)
        c3.move(to: ce3)
        c3.curve(to: NSPoint(x: ce3.x + dx * 8, y: ce3.y - dy * 5),
                 controlPoint1: NSPoint(x: ce3.x + dx * 6, y: ce3.y + dy * 6),
                 controlPoint2: NSPoint(x: ce3.x + dx * 10, y: ce3.y + dy * 1))
        c3.lineWidth = 1.2; c3.stroke()
        
        let t4 = NSBezierPath()
        t4.move(to: NSPoint(x: o.x + dx * 100, y: o.y + dy * 5))
        t4.curve(to: NSPoint(x: o.x + dx * 120, y: o.y + dy * 45),
                 controlPoint1: NSPoint(x: o.x + dx * 90, y: o.y + dy * 30),
                 controlPoint2: NSPoint(x: o.x + dx * 105, y: o.y + dy * 40))
        t4.lineWidth = 1.5; t4.stroke()
        let c4 = NSBezierPath()
        let ce4 = NSPoint(x: o.x + dx * 120, y: o.y + dy * 45)
        c4.move(to: ce4)
        c4.curve(to: NSPoint(x: ce4.x - dx * 5, y: ce4.y + dy * 8),
                 controlPoint1: NSPoint(x: ce4.x + dx * 6, y: ce4.y + dy * 6),
                 controlPoint2: NSPoint(x: ce4.x + dx * 1, y: ce4.y + dy * 10))
        c4.lineWidth = 1.2; c4.stroke()
        
        let ti = NSBezierPath()
        ti.move(to: NSPoint(x: o.x + dx * 40, y: o.y + dy * 40))
        ti.curve(to: NSPoint(x: o.x + dx * 60, y: o.y + dy * 30),
                 controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 48),
                 controlPoint2: NSPoint(x: o.x + dx * 55, y: o.y + dy * 35))
        ti.lineWidth = 1.3; ti.stroke()
        
        let ti2 = NSBezierPath()
        ti2.move(to: NSPoint(x: o.x + dx * 40, y: o.y + dy * 40))
        ti2.curve(to: NSPoint(x: o.x + dx * 30, y: o.y + dy * 60),
                  controlPoint1: NSPoint(x: o.x + dx * 48, y: o.y + dy * 50),
                  controlPoint2: NSPoint(x: o.x + dx * 35, y: o.y + dy * 55))
        ti2.lineWidth = 1.3; ti2.stroke()
    }
}
