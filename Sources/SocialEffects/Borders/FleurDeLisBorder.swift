import Foundation
import AppKit

// MARK: - Fleur-de-lis Border

extension TextGraphicsGenerator {
    
    func drawFleurDeLisBorder(w: CGFloat, h: CGFloat) {
        Self.goldColor.setStroke()
        
        let outer = NSBezierPath(roundedRect: NSRect(x: 25, y: 25, width: w-50, height: h-50), xRadius: 18, yRadius: 18)
        outer.lineWidth = 3; outer.stroke()
        let inner = NSBezierPath(roundedRect: NSRect(x: 50, y: 50, width: w-100, height: h-100), xRadius: 10, yRadius: 10)
        inner.lineWidth = 1.5; inner.stroke()
        
        drawFleurDeLis(at: NSPoint(x: 38, y: 38), size: 28, angle: .pi/4)
        drawFleurDeLis(at: NSPoint(x: w-38, y: 38), size: 28, angle: 3 * .pi/4)
        drawFleurDeLis(at: NSPoint(x: 38, y: h-38), size: 28, angle: -.pi/4)
        drawFleurDeLis(at: NSPoint(x: w-38, y: h-38), size: 28, angle: -3 * .pi/4)
        
        drawFleurDeLis(at: NSPoint(x: w/2, y: 32), size: 22, angle: 0)
        drawFleurDeLis(at: NSPoint(x: w/2, y: h-32), size: 22, angle: .pi)
        drawFleurDeLis(at: NSPoint(x: 32, y: h/2), size: 22, angle: -.pi/2)
        drawFleurDeLis(at: NSPoint(x: w-32, y: h/2), size: 22, angle: .pi/2)
        
        let step: CGFloat = 100
        for x in stride(from: CGFloat(120), to: w/2 - 40, by: step) {
            drawFleurDeLis(at: NSPoint(x: x, y: 37), size: 14, angle: 0)
            drawFleurDeLis(at: NSPoint(x: w-x, y: 37), size: 14, angle: 0)
            drawFleurDeLis(at: NSPoint(x: x, y: h-37), size: 14, angle: .pi)
            drawFleurDeLis(at: NSPoint(x: w-x, y: h-37), size: 14, angle: .pi)
        }
        for y in stride(from: CGFloat(120), to: h/2 - 40, by: step) {
            drawFleurDeLis(at: NSPoint(x: 37, y: y), size: 14, angle: -.pi/2)
            drawFleurDeLis(at: NSPoint(x: 37, y: h-y), size: 14, angle: -.pi/2)
            drawFleurDeLis(at: NSPoint(x: w-37, y: y), size: 14, angle: .pi/2)
            drawFleurDeLis(at: NSPoint(x: w-37, y: h-y), size: 14, angle: .pi/2)
        }
    }
    
    private func drawFleurDeLis(at center: NSPoint, size: CGFloat, angle: CGFloat) {
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.saveGState()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: angle)
        
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        
        let cp = NSBezierPath()
        cp.move(to: NSPoint(x: 0, y: -size * 0.15))
        cp.curve(to: NSPoint(x: 0, y: size * 0.9),
                 controlPoint1: NSPoint(x: -size * 0.25, y: size * 0.3),
                 controlPoint2: NSPoint(x: -size * 0.1, y: size * 0.7))
        cp.curve(to: NSPoint(x: 0, y: -size * 0.15),
                 controlPoint1: NSPoint(x: size * 0.1, y: size * 0.7),
                 controlPoint2: NSPoint(x: size * 0.25, y: size * 0.3))
        cp.fill()
        
        let lp = NSBezierPath()
        lp.move(to: NSPoint(x: 0, y: size * 0.1))
        lp.curve(to: NSPoint(x: -size * 0.55, y: size * 0.7),
                 controlPoint1: NSPoint(x: -size * 0.15, y: size * 0.4),
                 controlPoint2: NSPoint(x: -size * 0.6, y: size * 0.45))
        lp.curve(to: NSPoint(x: -size * 0.1, y: size * 0.35),
                 controlPoint1: NSPoint(x: -size * 0.45, y: size * 0.75),
                 controlPoint2: NSPoint(x: -size * 0.2, y: size * 0.55))
        lp.fill()
        
        let rp = NSBezierPath()
        rp.move(to: NSPoint(x: 0, y: size * 0.1))
        rp.curve(to: NSPoint(x: size * 0.55, y: size * 0.7),
                 controlPoint1: NSPoint(x: size * 0.15, y: size * 0.4),
                 controlPoint2: NSPoint(x: size * 0.6, y: size * 0.45))
        rp.curve(to: NSPoint(x: size * 0.1, y: size * 0.35),
                 controlPoint1: NSPoint(x: size * 0.45, y: size * 0.75),
                 controlPoint2: NSPoint(x: size * 0.2, y: size * 0.55))
        rp.fill()
        
        let band = NSBezierPath(rect: NSRect(x: -size * 0.28, y: -size * 0.05, width: size * 0.56, height: size * 0.12))
        band.fill()
        
        let stem = NSBezierPath(rect: NSRect(x: -size * 0.06, y: -size * 0.35, width: size * 0.12, height: size * 0.32))
        stem.fill()
        
        let base = NSBezierPath()
        base.move(to: NSPoint(x: -size * 0.2, y: -size * 0.35))
        base.line(to: NSPoint(x: size * 0.2, y: -size * 0.35))
        base.line(to: NSPoint(x: size * 0.15, y: -size * 0.42))
        base.line(to: NSPoint(x: -size * 0.15, y: -size * 0.42))
        base.close()
        base.fill()
        
        ctx.restoreGState()
    }
}
