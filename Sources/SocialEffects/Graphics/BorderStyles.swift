import Foundation
import AppKit

// MARK: - Extended Border Styles (ported from Social Marketer QuoteGraphicGenerator)
// All 10 ornate border styles + helpers, adapted from 1080×1080 to work with any dimensions.
// Drawing uses NSBezierPath (AppKit) with gold color #D4AF37.

extension TextGraphicsGenerator {
    
    /// Gold color used across all ornate borders — RGB(212, 175, 55) / #D4AF37
    static let goldColor = NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: 1.0)
    
    // MARK: - Ornate Border Dispatcher
    
    func drawOrnateBorder(style: BorderStyle, width w: CGFloat, height h: CGFloat) {
        Self.goldColor.setStroke()
        Self.goldColor.setFill()
        
        switch style {
        case .artDeco:          drawArtDecoBorder(w: w, h: h)
        case .classicScroll:    drawClassicScrollBorder(w: w, h: h)
        case .sacredGeometry:   drawSacredGeometryBorder(w: w, h: h)
        case .celticKnot:       drawCelticKnotBorder(w: w, h: h)
        case .fleurDeLis:       drawFleurDeLisBorder(w: w, h: h)
        case .baroque:          drawBaroqueBorder(w: w, h: h)
        case .victorian:        drawVictorianBorder(w: w, h: h)
        case .goldenVine:       drawGoldenVineBorder(w: w, h: h)
        case .stainedGlass:     drawStainedGlassBorder(w: w, h: h)
        case .modernGlow:       drawModernGlowBorder(w: w, h: h)
        default: break // gold, silver, minimal, none handled in TextGraphicsGenerator
        }
    }
    
    // MARK: - 1. Art Deco
    
    private func drawArtDecoBorder(w: CGFloat, h: CGFloat) {
        strokeRect(NSRect(x: 30, y: 30, width: w-60, height: h-60), lineWidth: 2)
        strokeRect(NSRect(x: 50, y: 50, width: w-100, height: h-100), lineWidth: 1)
        
        let corners: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (30, 30, 1, 1),
            (w-30, 30, -1, 1),
            (30, h-30, 1, -1),
            (w-30, h-30, -1, -1)
        ]
        for (ox, oy, dx, dy) in corners {
            drawVineCorner(at: NSPoint(x: ox, y: oy), dx: dx, dy: dy)
        }
        
        let midX = w / 2, midY = h / 2
        for (mx, my, horizontal) in [(midX, CGFloat(30), true), (midX, h-30, true),
                                      (CGFloat(30), midY, false), (w-30, midY, false)] as [(CGFloat, CGFloat, Bool)] {
            drawEdgeFlourish(at: NSPoint(x: mx, y: my), horizontal: horizontal)
        }
    }
    
    private func drawVineCorner(at o: NSPoint, dx: CGFloat, dy: CGFloat) {
        Self.goldColor.setStroke()
        
        let vine1 = NSBezierPath()
        vine1.move(to: NSPoint(x: o.x, y: o.y + dy * 10))
        vine1.curve(to: NSPoint(x: o.x + dx * 20, y: o.y + dy * 90),
                    controlPoint1: NSPoint(x: o.x + dx * 50, y: o.y + dy * 20),
                    controlPoint2: NSPoint(x: o.x - dx * 10, y: o.y + dy * 70))
        vine1.lineWidth = 2.5; vine1.lineCapStyle = .round; vine1.stroke()
        
        let vine2 = NSBezierPath()
        vine2.move(to: NSPoint(x: o.x + dx * 10, y: o.y))
        vine2.curve(to: NSPoint(x: o.x + dx * 90, y: o.y + dy * 20),
                    controlPoint1: NSPoint(x: o.x + dx * 20, y: o.y + dy * 50),
                    controlPoint2: NSPoint(x: o.x + dx * 70, y: o.y - dy * 10))
        vine2.lineWidth = 2.5; vine2.lineCapStyle = .round; vine2.stroke()
        
        let tendril1 = NSBezierPath()
        tendril1.move(to: NSPoint(x: o.x + dx * 15, y: o.y + dy * 50))
        tendril1.curve(to: NSPoint(x: o.x + dx * 50, y: o.y + dy * 65),
                       controlPoint1: NSPoint(x: o.x + dx * 40, y: o.y + dy * 35),
                       controlPoint2: NSPoint(x: o.x + dx * 55, y: o.y + dy * 55))
        tendril1.lineWidth = 1.8; tendril1.stroke()
        
        let curl1 = NSBezierPath()
        let cEnd = NSPoint(x: o.x + dx * 50, y: o.y + dy * 65)
        curl1.move(to: cEnd)
        curl1.curve(to: NSPoint(x: cEnd.x + dx * 10, y: cEnd.y - dy * 6),
                    controlPoint1: NSPoint(x: cEnd.x + dx * 8, y: cEnd.y + dy * 8),
                    controlPoint2: NSPoint(x: cEnd.x + dx * 13, y: cEnd.y + dy * 2))
        curl1.lineWidth = 1.5; curl1.stroke()
        
        let tendril2 = NSBezierPath()
        tendril2.move(to: NSPoint(x: o.x + dx * 50, y: o.y + dy * 15))
        tendril2.curve(to: NSPoint(x: o.x + dx * 65, y: o.y + dy * 50),
                       controlPoint1: NSPoint(x: o.x + dx * 35, y: o.y + dy * 40),
                       controlPoint2: NSPoint(x: o.x + dx * 55, y: o.y + dy * 55))
        tendril2.lineWidth = 1.8; tendril2.stroke()
        
        let curl2 = NSBezierPath()
        let cEnd2 = NSPoint(x: o.x + dx * 65, y: o.y + dy * 50)
        curl2.move(to: cEnd2)
        curl2.curve(to: NSPoint(x: cEnd2.x - dx * 6, y: cEnd2.y + dy * 10),
                    controlPoint1: NSPoint(x: cEnd2.x + dx * 8, y: cEnd2.y + dy * 8),
                    controlPoint2: NSPoint(x: cEnd2.x + dx * 2, y: cEnd2.y + dy * 13))
        curl2.lineWidth = 1.5; curl2.stroke()
        
        Self.goldColor.setFill()
        drawLeaf(at: NSPoint(x: o.x + dx * 8, y: o.y + dy * 40), angle: atan2(dy, dx) + .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 40, y: o.y + dy * 8), angle: atan2(dy, dx) - .pi/4, size: 8)
        drawLeaf(at: NSPoint(x: o.x + dx * 30, y: o.y + dy * 45), angle: atan2(dy, dx), size: 6)
        drawLeaf(at: NSPoint(x: o.x + dx * 45, y: o.y + dy * 30), angle: atan2(dy, dx) + .pi/2, size: 6)
        
        for (px, py) in [(o.x + dx*5, o.y + dy*25), (o.x + dx*25, o.y + dy*5),
                          (o.x + dx*35, o.y + dy*35)] {
            NSBezierPath(ovalIn: NSRect(x: px-2, y: py-2, width: 4, height: 4)).fill()
        }
    }
    
    // MARK: - 2. Classic Scroll
    
    private func drawClassicScrollBorder(w: CGFloat, h: CGFloat) {
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
        
        // Leaves along vines
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
            (18, 250), (250, 18), (45, 100), (100, 45)
        ]
        for (px, py) in dotPositions {
            NSBezierPath(ovalIn: NSRect(x: o.x + dx*px - 2, y: o.y + dy*py - 2, width: 4, height: 4)).fill()
        }
    }
    
    // MARK: - 3. Sacred Geometry
    
    private func drawSacredGeometryBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 4. Celtic Knot
    
    private func drawCelticKnotBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 5. Fleur-de-lis
    
    private func drawFleurDeLisBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 6. Baroque
    
    private func drawBaroqueBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 7. Victorian
    
    private func drawVictorianBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 8. Golden Vine
    
    private func drawGoldenVineBorder(w: CGFloat, h: CGFloat) {
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
        
        // Leaves
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
    
    // MARK: - 9. Stained Glass
    
    private func drawStainedGlassBorder(w: CGFloat, h: CGFloat) {
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
    
    // MARK: - 10. Modern Glow
    
    private func drawModernGlowBorder(w: CGFloat, h: CGFloat) {
        for i in (0..<8).reversed() {
            let inset = CGFloat(12 + i * 6)
            let alpha = 0.08 + (1.0 - Double(i) / 7.0) * 0.92
            let lw = CGFloat(1 + (7 - i))
            NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: CGFloat(alpha)).setStroke()
            let path = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: w-inset*2, height: h-inset*2),
                                     xRadius: 8, yRadius: 8)
            path.lineWidth = lw; path.stroke()
        }
        
        Self.goldColor.setStroke()
        let inner = NSRect(x: 58, y: 58, width: w-116, height: h-116)
        let innerPath = NSBezierPath(roundedRect: inner, xRadius: 4, yRadius: 4)
        innerPath.lineWidth = 2; innerPath.stroke()
        
        for (cx, cy) in [(inner.minX, inner.minY), (inner.maxX, inner.minY),
                          (inner.minX, inner.maxY), (inner.maxX, inner.maxY)] {
            for (r, a) in [(CGFloat(14), CGFloat(0.1)), (CGFloat(9), CGFloat(0.3)),
                           (CGFloat(5), CGFloat(0.7)), (CGFloat(2.5), CGFloat(1.0))] {
                NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: a).setFill()
                NSBezierPath(ovalIn: NSRect(x: cx-r, y: cy-r, width: r*2, height: r*2)).fill()
            }
        }
    }
    
    // NOTE: Drawing helpers have been extracted to BorderDrawingHelpers.swift
    // to reduce file size and improve code organization.
    // Shared helpers: strokeRect, strokeOval, fillDiamond, drawLeaf, drawEdgeFlourish
}
