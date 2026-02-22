import Foundation
import AppKit

// MARK: - Victorian Border

extension TextGraphicsGenerator {
    
    func drawVictorianBorder(w: CGFloat, h: CGFloat) {
        Self.goldColor.setStroke()
        
        let outer = NSRect(x: 22, y: 22, width: w-44, height: h-44)
        let outerPath = NSBezierPath(roundedRect: outer, xRadius: 20, yRadius: 20)
        outerPath.lineWidth = 4; outerPath.stroke()
        let inner = NSRect(x: 50, y: 50, width: w-100, height: h-100)
        let innerPath = NSBezierPath(roundedRect: inner, xRadius: 14, yRadius: 14)
        innerPath.lineWidth = 2; innerPath.stroke()
        
        let ci: CGFloat = 36
        let fR: CGFloat = 50
        for (cx, cy, sa, ea) in [(ci, ci, CGFloat(0), CGFloat(90)),
                                   (w-ci, ci, CGFloat(90), CGFloat(180)),
                                   (w-ci, h-ci, CGFloat(180), CGFloat(270)),
                                   (ci, h-ci, CGFloat(270), CGFloat(360))] {
            for (r, lw) in [(fR, CGFloat(2.5)), (fR*0.55, CGFloat(1.5)), (fR*0.3, CGFloat(1))] {
                let arc = NSBezierPath()
                arc.appendArc(withCenter: NSPoint(x: cx, y: cy), radius: r, startAngle: sa, endAngle: ea)
                arc.lineWidth = lw; arc.stroke()
            }
            let midAngle = (sa + ea) / 2 * .pi / 180
            Self.goldColor.setFill()
            NSBezierPath(ovalIn: NSRect(x: cx + fR*0.7*cos(midAngle) - 5,
                                        y: cy + fR*0.7*sin(midAngle) - 5, width: 10, height: 10)).fill()
        }
        
        let step: CGFloat = 65
        for x in stride(from: outer.minX + 60, to: outer.maxX - 40, by: step) {
            drawSmallFlower(at: NSPoint(x: x, y: outer.minY + 14))
            drawSmallFlower(at: NSPoint(x: x, y: outer.maxY - 14))
        }
    }
    
    private func drawSmallFlower(at p: NSPoint) {
        Self.goldColor.setStroke()
        for i in 0..<4 {
            let a = CGFloat(i) * .pi / 2
            let petal = NSBezierPath(ovalIn: NSRect(x: p.x + 5*cos(a) - 3, y: p.y + 5*sin(a) - 3, width: 6, height: 6))
            petal.lineWidth = 1; petal.stroke()
        }
        Self.goldColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: p.x-2.5, y: p.y-2.5, width: 5, height: 5)).fill()
    }
}
