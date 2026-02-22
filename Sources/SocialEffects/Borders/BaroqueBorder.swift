import Foundation
import AppKit

// MARK: - Baroque Border

extension TextGraphicsGenerator {
    
    func drawBaroqueBorder(w: CGFloat, h: CGFloat) {
        Self.goldColor.setStroke()
        
        let outer = NSBezierPath(roundedRect: NSRect(x: 18, y: 18, width: w-36, height: h-36), xRadius: 24, yRadius: 24)
        outer.lineWidth = 5; outer.stroke()
        let inner = NSBezierPath(roundedRect: NSRect(x: 52, y: 52, width: w-104, height: h-104), xRadius: 12, yRadius: 12)
        inner.lineWidth = 1.5; inner.stroke()
        
        for (cx, cy, flipX, flipY) in [(CGFloat(18), CGFloat(18), false, false),
                                         (w-18, CGFloat(18), true, false),
                                         (CGFloat(18), h-18, false, true),
                                         (w-18, h-18, true, true)] {
            drawFiligreeScroll(at: NSPoint(x: cx, y: cy), flipX: flipX, flipY: flipY)
        }
        
        let step: CGFloat = 45
        let outerR = NSRect(x: 18, y: 18, width: w-36, height: h-36)
        for x in stride(from: outerR.minX + 80, to: outerR.maxX - 60, by: step) {
            drawOrnamentDot(at: NSPoint(x: x, y: outerR.minY))
            drawOrnamentDot(at: NSPoint(x: x, y: outerR.maxY))
        }
        for y in stride(from: outerR.minY + 80, to: outerR.maxY - 60, by: step) {
            drawOrnamentDot(at: NSPoint(x: outerR.minX, y: y))
            drawOrnamentDot(at: NSPoint(x: outerR.maxX, y: y))
        }
    }
    
    private func drawFiligreeScroll(at origin: NSPoint, flipX: Bool, flipY: Bool) {
        let dx: CGFloat = flipX ? -1 : 1
        let dy: CGFloat = flipY ? -1 : 1
        
        let s1 = NSBezierPath()
        s1.move(to: NSPoint(x: origin.x, y: origin.y + dy * 30))
        s1.curve(to: NSPoint(x: origin.x + dx * 55, y: origin.y + dy * 65),
                 controlPoint1: NSPoint(x: origin.x + dx * 40, y: origin.y + dy * 10),
                 controlPoint2: NSPoint(x: origin.x + dx * 18, y: origin.y + dy * 60))
        s1.lineWidth = 2.5; s1.stroke()
        
        let s2 = NSBezierPath()
        s2.move(to: NSPoint(x: origin.x + dx * 30, y: origin.y))
        s2.curve(to: NSPoint(x: origin.x + dx * 65, y: origin.y + dy * 55),
                 controlPoint1: NSPoint(x: origin.x + dx * 10, y: origin.y + dy * 40),
                 controlPoint2: NSPoint(x: origin.x + dx * 60, y: origin.y + dy * 18))
        s2.lineWidth = 2; s2.stroke()
        
        let curl = NSBezierPath()
        let ce = NSPoint(x: origin.x + dx * 55, y: origin.y + dy * 65)
        curl.move(to: ce)
        curl.curve(to: NSPoint(x: ce.x + dx*15, y: ce.y - dy*8),
                   controlPoint1: NSPoint(x: ce.x + dx*12, y: ce.y + dy*10),
                   controlPoint2: NSPoint(x: ce.x + dx*18, y: ce.y + dy*2))
        curl.lineWidth = 2; curl.stroke()
        
        let curl2 = NSBezierPath()
        let ce2 = NSPoint(x: origin.x + dx * 65, y: origin.y + dy * 55)
        curl2.move(to: ce2)
        curl2.curve(to: NSPoint(x: ce2.x - dx*8, y: ce2.y + dy*15),
                    controlPoint1: NSPoint(x: ce2.x + dx*10, y: ce2.y + dy*12),
                    controlPoint2: NSPoint(x: ce2.x + dx*2, y: ce2.y + dy*18))
        curl2.lineWidth = 1.5; curl2.stroke()
        
        Self.goldColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: origin.x + dx*24-4, y: origin.y + dy*24-5, width: 8, height: 10)).fill()
        NSBezierPath(ovalIn: NSRect(x: origin.x + dx*40-3, y: origin.y + dy*40-4, width: 6, height: 8)).fill()
    }
    
    private func drawOrnamentDot(at p: NSPoint) {
        Self.goldColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: p.x-3, y: p.y-3, width: 6, height: 6)).fill()
        Self.goldColor.setStroke()
        let ring = NSBezierPath(ovalIn: NSRect(x: p.x-8, y: p.y-8, width: 16, height: 16))
        ring.lineWidth = 1; ring.stroke()
    }
}
