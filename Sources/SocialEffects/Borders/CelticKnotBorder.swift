import Foundation
import AppKit

// MARK: - Celtic Knot Border

extension TextGraphicsGenerator {
    
    func drawCelticKnotBorder(w: CGFloat, h: CGFloat) {
        Self.goldColor.setStroke()
        
        for (inset, lw, radius) in [(CGFloat(25), CGFloat(3), CGFloat(20)),
                                     (CGFloat(40), CGFloat(1.5), CGFloat(14)),
                                     (CGFloat(55), CGFloat(3), CGFloat(8))] {
            let rect = NSRect(x: inset, y: inset, width: w-inset*2, height: h-inset*2)
            let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
            path.lineWidth = lw; path.stroke()
        }
        
        let ki: CGFloat = 40
        for (cx, cy) in [(ki, ki), (w-ki, ki), (ki, h-ki), (w-ki, h-ki)] {
            let knotR: CGFloat = 18
            let o1 = NSBezierPath(ovalIn: NSRect(x: cx-knotR, y: cy-knotR/2, width: knotR*2, height: knotR))
            o1.lineWidth = 2.5; o1.stroke()
            let o2 = NSBezierPath(ovalIn: NSRect(x: cx-knotR/2, y: cy-knotR, width: knotR, height: knotR*2))
            o2.lineWidth = 2.5; o2.stroke()
            Self.goldColor.setFill()
            NSBezierPath(ovalIn: NSRect(x: cx-4, y: cy-4, width: 8, height: 8)).fill()
        }
        
        let step: CGFloat = 55
        for x in stride(from: ki + step, to: w - ki, by: step) {
            drawKnotCross(at: NSPoint(x: x, y: 40))
            drawKnotCross(at: NSPoint(x: x, y: h - 40))
        }
        for y in stride(from: ki + step, to: h - ki, by: step) {
            drawKnotCross(at: NSPoint(x: 40, y: y))
            drawKnotCross(at: NSPoint(x: w - 40, y: y))
        }
    }
    
    private func drawKnotCross(at p: NSPoint) {
        let s: CGFloat = 10
        let path = NSBezierPath()
        path.move(to: NSPoint(x: p.x-s, y: p.y)); path.line(to: NSPoint(x: p.x+s, y: p.y))
        path.move(to: NSPoint(x: p.x, y: p.y-s)); path.line(to: NSPoint(x: p.x, y: p.y+s))
        path.lineWidth = 2; path.stroke()
        for (dx, dy) in [(-s, CGFloat(0)), (s, CGFloat(0)), (CGFloat(0), -s), (CGFloat(0), s)] {
            let oval = NSBezierPath(ovalIn: NSRect(x: p.x+dx-3, y: p.y+dy-3, width: 6, height: 6))
            oval.lineWidth = 1; oval.stroke()
        }
    }
}
