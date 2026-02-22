import Foundation
import AppKit

// MARK: - Stained Glass Border

extension TextGraphicsGenerator {
    
    func drawStainedGlassBorder(w: CGFloat, h: CGFloat) {
        Self.goldColor.setStroke()
        
        let archR = (w - 60) / 2
        let archCY = h - 60 - archR
        
        let outer = NSBezierPath()
        outer.move(to: NSPoint(x: 30, y: 60))
        outer.line(to: NSPoint(x: 30, y: archCY))
        outer.appendArc(withCenter: NSPoint(x: w/2, y: archCY), radius: archR, startAngle: 180, endAngle: 0)
        outer.line(to: NSPoint(x: w-30, y: 60))
        outer.close()
        outer.lineWidth = 4; outer.stroke()
        
        let innerR = archR - 22
        let innerFrame = NSBezierPath()
        innerFrame.move(to: NSPoint(x: 52, y: 72))
        innerFrame.line(to: NSPoint(x: 52, y: archCY))
        innerFrame.appendArc(withCenter: NSPoint(x: w/2, y: archCY), radius: innerR, startAngle: 180, endAngle: 0)
        innerFrame.line(to: NSPoint(x: w-52, y: 72))
        innerFrame.close()
        innerFrame.lineWidth = 2; innerFrame.stroke()
        
        Self.goldColor.withAlphaComponent(0.4).setStroke()
        let ac = NSPoint(x: w/2, y: archCY)
        for i in 1..<8 {
            let angle = CGFloat(i) * .pi / 8
            let line = NSBezierPath()
            line.move(to: NSPoint(x: ac.x + innerR*cos(angle), y: ac.y + innerR*sin(angle)))
            line.line(to: NSPoint(x: ac.x + archR*cos(angle), y: ac.y + archR*sin(angle)))
            line.lineWidth = 1.5; line.stroke()
        }
        for r in stride(from: innerR + 30, to: archR, by: CGFloat(30)) {
            let arc = NSBezierPath()
            arc.appendArc(withCenter: ac, radius: r, startAngle: 15, endAngle: 165)
            arc.lineWidth = 1; arc.stroke()
        }
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        NSBezierPath(rect: NSRect(x: 30, y: 52, width: w-60, height: 5)).fill()
    }
}
