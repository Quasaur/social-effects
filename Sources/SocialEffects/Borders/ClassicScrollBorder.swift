import Foundation
import AppKit

// MARK: - Classic Scroll Border

extension TextGraphicsGenerator {
    
    func drawClassicScrollBorder(w: CGFloat, h: CGFloat) {
        strokeRect(NSRect(x: 35, y: 35, width: w-70, height: h-70), lineWidth: 1.5)
        
        drawIntroCorner(at: NSPoint(x: 35, y: 35), dx: 1, dy: 1)
        drawIntroCorner(at: NSPoint(x: w-35, y: 35), dx: -1, dy: 1)
        drawIntroCorner(at: NSPoint(x: 35, y: h-35), dx: 1, dy: -1)
        drawIntroCorner(at: NSPoint(x: w-35, y: h-35), dx: -1, dy: -1)
    }
    
    private func drawIntroCorner(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        
        let pv = NSBezierPath()
        pv.move(to: NSPoint(x: o.x, y: o.y + dy * 5))
        pv.curve(to: NSPoint(x: o.x + dx * 20, y: o.y + dy * 280),
                 controlPoint1: NSPoint(x: o.x + dx * 55, y: o.y + dy * 60),
                 controlPoint2: NSPoint(x: o.x - dx * 25, y: o.y + dy * 200))
        pv.lineWidth = 2.5; pv.lineCapStyle = .round; pv.stroke()
        
        let ph = NSBezierPath()
        ph.move(to: NSPoint(x: o.x + dx * 5, y: o.y))
        ph.curve(to: NSPoint(x: o.x + dx * 280, y: o.y + dy * 20),
                 controlPoint1: NSPoint(x: o.x + dx * 60, y: o.y + dy * 55),
                 controlPoint2: NSPoint(x: o.x + dx * 200, y: o.y - dy * 25))
        ph.lineWidth = 2.5; ph.lineCapStyle = .round; ph.stroke()
        
        let dv = NSBezierPath()
        dv.move(to: NSPoint(x: o.x + dx * 3, y: o.y + dy * 3))
        dv.curve(to: NSPoint(x: o.x + dx * 100, y: o.y + dy * 100),
                 controlPoint1: NSPoint(x: o.x + dx * 65, y: o.y + dy * 10),
                 controlPoint2: NSPoint(x: o.x + dx * 10, y: o.y + dy * 65))
        dv.lineWidth = 2.5; dv.lineCapStyle = .round; dv.stroke()
        
        let ds = NSBezierPath()
        let dTip = NSPoint(x: o.x + dx * 100, y: o.y + dy * 100)
        ds.move(to: dTip)
        ds.curve(to: NSPoint(x: dTip.x - dx * 15, y: dTip.y - dy * 5),
                 controlPoint1: NSPoint(x: dTip.x + dx * 10, y: dTip.y - dy * 12),
                 controlPoint2: NSPoint(x: dTip.x - dx * 5, y: dTip.y - dy * 15))
        ds.lineWidth = 2; ds.stroke()
        
        drawClassicSecondaryVines(at: o, dx: dx, dy: dy)
        drawClassicTertiaryVines(at: o, dx: dx, dy: dy)
        drawClassicAccentVines(at: o, dx: dx, dy: dy)
        drawClassicCornerDecorations(at: o, dx: dx, dy: dy)
        drawClassicLeavesAndDots(at: o, dx: dx, dy: dy)
    }
    
    private func drawClassicSecondaryVines(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let sv = NSBezierPath()
        sv.move(to: NSPoint(x: o.x + dx * 10, y: o.y + dy * 20))
        sv.curve(to: NSPoint(x: o.x + dx * 35, y: o.y + dy * 200),
                 controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 50),
                 controlPoint2: NSPoint(x: o.x - dx * 10, y: o.y + dy * 150))
        sv.lineWidth = 2; sv.lineCapStyle = .round; sv.stroke()
        let svc = NSBezierPath()
        let svEnd = NSPoint(x: o.x + dx * 35, y: o.y + dy * 200)
        svc.move(to: svEnd)
        svc.curve(to: NSPoint(x: svEnd.x + dx * 12, y: svEnd.y - dy * 10),
                  controlPoint1: NSPoint(x: svEnd.x + dx * 15, y: svEnd.y + dy * 8),
                  controlPoint2: NSPoint(x: svEnd.x + dx * 16, y: svEnd.y - dy * 2))
        svc.lineWidth = 1.8; svc.stroke()
        
        let sh = NSBezierPath()
        sh.move(to: NSPoint(x: o.x + dx * 20, y: o.y + dy * 10))
        sh.curve(to: NSPoint(x: o.x + dx * 200, y: o.y + dy * 35),
                 controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 50),
                 controlPoint2: NSPoint(x: o.x + dx * 150, y: o.y - dy * 10))
        sh.lineWidth = 2; sh.lineCapStyle = .round; sh.stroke()
        let shc = NSBezierPath()
        let shEnd = NSPoint(x: o.x + dx * 200, y: o.y + dy * 35)
        shc.move(to: shEnd)
        shc.curve(to: NSPoint(x: shEnd.x - dx * 10, y: shEnd.y + dy * 12),
                  controlPoint1: NSPoint(x: shEnd.x + dx * 8, y: shEnd.y + dy * 15),
                  controlPoint2: NSPoint(x: shEnd.x - dx * 2, y: shEnd.y + dy * 16))
        shc.lineWidth = 1.8; shc.stroke()
    }
    
    private func drawClassicTertiaryVines(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let tv = NSBezierPath()
        tv.move(to: NSPoint(x: o.x + dx * 25, y: o.y + dy * 100))
        tv.curve(to: NSPoint(x: o.x + dx * 60, y: o.y + dy * 160),
                 controlPoint1: NSPoint(x: o.x + dx * 55, y: o.y + dy * 95),
                 controlPoint2: NSPoint(x: o.x + dx * 40, y: o.y + dy * 140))
        tv.lineWidth = 1.8; tv.stroke()
        let tvc = NSBezierPath()
        let tvEnd = NSPoint(x: o.x + dx * 60, y: o.y + dy * 160)
        tvc.move(to: tvEnd)
        tvc.curve(to: NSPoint(x: tvEnd.x + dx * 8, y: tvEnd.y - dy * 8),
                  controlPoint1: NSPoint(x: tvEnd.x + dx * 10, y: tvEnd.y + dy * 6),
                  controlPoint2: NSPoint(x: tvEnd.x + dx * 12, y: tvEnd.y - dy * 2))
        tvc.lineWidth = 1.5; tvc.stroke()
        
        let th = NSBezierPath()
        th.move(to: NSPoint(x: o.x + dx * 100, y: o.y + dy * 25))
        th.curve(to: NSPoint(x: o.x + dx * 160, y: o.y + dy * 60),
                 controlPoint1: NSPoint(x: o.x + dx * 95, y: o.y + dy * 55),
                 controlPoint2: NSPoint(x: o.x + dx * 140, y: o.y + dy * 40))
        th.lineWidth = 1.8; th.stroke()
        let thc = NSBezierPath()
        let thEnd = NSPoint(x: o.x + dx * 160, y: o.y + dy * 60)
        thc.move(to: thEnd)
        thc.curve(to: NSPoint(x: thEnd.x - dx * 8, y: thEnd.y + dy * 8),
                  controlPoint1: NSPoint(x: thEnd.x + dx * 6, y: thEnd.y + dy * 10),
                  controlPoint2: NSPoint(x: thEnd.x - dx * 2, y: thEnd.y + dy * 12))
        thc.lineWidth = 1.5; thc.stroke()
    }
    
    private func drawClassicAccentVines(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        let ov = NSBezierPath()
        ov.move(to: NSPoint(x: o.x + dx * 5, y: o.y + dy * 180))
        ov.curve(to: NSPoint(x: o.x + dx * 40, y: o.y + dy * 240),
                 controlPoint1: NSPoint(x: o.x + dx * 30, y: o.y + dy * 175),
                 controlPoint2: NSPoint(x: o.x + dx * 25, y: o.y + dy * 220))
        ov.lineWidth = 1.5; ov.stroke()
        let ovc = NSBezierPath()
        let ovEnd = NSPoint(x: o.x + dx * 40, y: o.y + dy * 240)
        ovc.move(to: ovEnd)
        ovc.curve(to: NSPoint(x: ovEnd.x + dx * 6, y: ovEnd.y - dy * 6),
                  controlPoint1: NSPoint(x: ovEnd.x + dx * 8, y: ovEnd.y + dy * 4),
                  controlPoint2: NSPoint(x: ovEnd.x + dx * 9, y: ovEnd.y - dy * 1))
        ovc.lineWidth = 1.3; ovc.stroke()
        
        let oh = NSBezierPath()
        oh.move(to: NSPoint(x: o.x + dx * 180, y: o.y + dy * 5))
        oh.curve(to: NSPoint(x: o.x + dx * 240, y: o.y + dy * 40),
                 controlPoint1: NSPoint(x: o.x + dx * 175, y: o.y + dy * 30),
                 controlPoint2: NSPoint(x: o.x + dx * 220, y: o.y + dy * 25))
        oh.lineWidth = 1.5; oh.stroke()
        let ohc = NSBezierPath()
        let ohEnd = NSPoint(x: o.x + dx * 240, y: o.y + dy * 40)
        ohc.move(to: ohEnd)
        ohc.curve(to: NSPoint(x: ohEnd.x - dx * 6, y: ohEnd.y + dy * 6),
                  controlPoint1: NSPoint(x: ohEnd.x + dx * 4, y: ohEnd.y + dy * 8),
                  controlPoint2: NSPoint(x: ohEnd.x - dx * 1, y: ohEnd.y + dy * 9))
        ohc.lineWidth = 1.3; ohc.stroke()
    }
    
}
