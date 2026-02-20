import Foundation
import AppKit

// MARK: - Shared Border Drawing Helpers
// Extracted from BorderStyles.swift to reduce file size and improve organization

/// Gold color used across all ornate borders — RGB(212, 175, 55) / #D4AF37
let borderGoldColor = NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: 1.0)

/// Strokes a rectangle with the given line width
func strokeRect(_ rect: NSRect, lineWidth: CGFloat) {
    let path = NSBezierPath(rect: rect)
    path.lineWidth = lineWidth
    borderGoldColor.setStroke()
    path.stroke()
}

/// Strokes an oval at the given center with radius
func strokeOval(center: NSPoint, radius: CGFloat, lineWidth: CGFloat) {
    let oval = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius,
                                            width: radius*2, height: radius*2))
    oval.lineWidth = lineWidth
    oval.stroke()
}

/// Fills a diamond shape at the given point
func fillDiamond(at p: NSPoint, size: CGFloat) {
    let d = NSBezierPath()
    d.move(to: NSPoint(x: p.x, y: p.y - size))
    d.line(to: NSPoint(x: p.x + size, y: p.y))
    d.line(to: NSPoint(x: p.x, y: p.y + size))
    d.line(to: NSPoint(x: p.x - size, y: p.y))
    d.close()
    borderGoldColor.setFill()
    d.fill()
}

/// Draws a leaf shape at the given center with angle and size
func drawLeaf(at center: NSPoint, angle: CGFloat, size: CGFloat) {
    let path = NSBezierPath()
    let tip = NSPoint(x: center.x + size * cos(angle), y: center.y + size * sin(angle))
    let base = NSPoint(x: center.x - size * 0.3 * cos(angle), y: center.y - size * 0.3 * sin(angle))
    let perpAngle = angle + .pi / 2
    let cp1 = NSPoint(x: center.x + size * 0.6 * cos(perpAngle), y: center.y + size * 0.6 * sin(perpAngle))
    let cp2 = NSPoint(x: center.x - size * 0.6 * cos(perpAngle), y: center.y - size * 0.6 * sin(perpAngle))
    path.move(to: base)
    path.curve(to: tip, controlPoint1: cp1, controlPoint2: NSPoint(x: tip.x + size*0.2*cos(perpAngle), y: tip.y + size*0.2*sin(perpAngle)))
    path.curve(to: base, controlPoint1: NSPoint(x: tip.x - size*0.2*cos(perpAngle), y: tip.y - size*0.2*sin(perpAngle)), controlPoint2: cp2)
    borderGoldColor.setFill()
    path.fill()
}

/// Draws an edge flourish at the given point
func drawEdgeFlourish(at p: NSPoint, horizontal: Bool) {
    let s: CGFloat = 15
    borderGoldColor.setFill()
    fillDiamond(at: p, size: 5)
    borderGoldColor.setStroke()
    if horizontal {
        let left = NSBezierPath()
        left.move(to: NSPoint(x: p.x - s, y: p.y))
        left.curve(to: NSPoint(x: p.x - s*2.5, y: p.y), controlPoint1: NSPoint(x: p.x - s*1.5, y: p.y + 8), controlPoint2: NSPoint(x: p.x - s*2, y: p.y + 5))
        left.lineWidth = 1.5; left.stroke()
        let right = NSBezierPath()
        right.move(to: NSPoint(x: p.x + s, y: p.y))
        right.curve(to: NSPoint(x: p.x + s*2.5, y: p.y), controlPoint1: NSPoint(x: p.x + s*1.5, y: p.y - 8), controlPoint2: NSPoint(x: p.x + s*2, y: p.y - 5))
        right.lineWidth = 1.5; right.stroke()
    } else {
        let up = NSBezierPath()
        up.move(to: NSPoint(x: p.x, y: p.y + s))
        up.curve(to: NSPoint(x: p.x, y: p.y + s*2.5), controlPoint1: NSPoint(x: p.x + 8, y: p.y + s*1.5), controlPoint2: NSPoint(x: p.x + 5, y: p.y + s*2))
        up.lineWidth = 1.5; up.stroke()
        let down = NSBezierPath()
        down.move(to: NSPoint(x: p.x, y: p.y - s))
        down.curve(to: NSPoint(x: p.x, y: p.y - s*2.5), controlPoint1: NSPoint(x: p.x - 8, y: p.y - s*1.5), controlPoint2: NSPoint(x: p.x - 5, y: p.y - s*2))
        down.lineWidth = 1.5; down.stroke()
    }
}
