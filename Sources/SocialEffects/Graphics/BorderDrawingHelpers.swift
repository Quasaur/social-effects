import Foundation
import AppKit

// MARK: - Shared Border Drawing Helpers
// Extracted from BorderStyles.swift to reduce file size and improve organization

/// Gold color used across all ornate borders — RGB(212, 175, 55) / #D4AF37
let borderGoldColor = NSColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: 1.0)

// MARK: - Common Border Drawing Configuration

/// Standard line widths for border drawing
enum BorderLineWidth {
    static let thick: CGFloat = 2.5
    static let medium: CGFloat = 2.0
    static let standard: CGFloat = 1.8
    static let thin: CGFloat = 1.5
    static let hairline: CGFloat = 1.3
    static let fine: CGFloat = 1.2
    static let ultraFine: CGFloat = 1.0
}

/// Standard corner insets for border drawing
enum BorderInsets {
    static let tight: CGFloat = 28
    static let standard: CGFloat = 35
    static let loose: CGFloat = 42
}

// MARK: - NSBezierPath Extensions

extension NSBezierPath {
    /// Applies standard ornate styling (gold stroke, round caps)
    func applyOrnateStyle(lineWidth: CGFloat = BorderLineWidth.thick) {
        borderGoldColor.setStroke()
        self.lineWidth = lineWidth
        self.lineCapStyle = .round
    }
    
    /// Strokes the path with the specified gold color and width
    func strokeWithGold(width: CGFloat) {
        borderGoldColor.setStroke()
        self.lineWidth = width
        self.stroke()
    }
}

// MARK: - Corner Drawing Helpers

/// Draws a curved vine path with standard ornate styling
/// - Parameters:
///   - start: Starting point
///   - end: Ending point
///   - control1: First control point
///   - control2: Second control point
///   - width: Line width
func drawVinePath(
    start: NSPoint,
    end: NSPoint,
    control1: NSPoint,
    control2: NSPoint,
    width: CGFloat = BorderLineWidth.thick
) {
    let path = NSBezierPath()
    path.move(to: start)
    path.curve(to: end, controlPoint1: control1, controlPoint2: control2)
    path.applyOrnateStyle(lineWidth: width)
    path.stroke()
}

/// Draws a curved termination/curl at the end of a vine
/// - Parameters:
///   - endPoint: The end point of the vine
///   - dx: X direction multiplier (1 or -1)
///   - dy: Y direction multiplier (1 or -1)
///   - width: Line width
func drawVineCurl(
    at endPoint: NSPoint,
    dx: CGFloat,
    dy: CGFloat,
    width: CGFloat = BorderLineWidth.standard
) {
    let path = NSBezierPath()
    path.move(to: endPoint)
    path.curve(
        to: NSPoint(x: endPoint.x + dx * 12, y: endPoint.y - dy * 8),
        controlPoint1: NSPoint(x: endPoint.x + dx * 10, y: endPoint.y + dy * 10),
        controlPoint2: NSPoint(x: endPoint.x + dx * 15, y: endPoint.y + dy * 2)
    )
    path.applyOrnateStyle(lineWidth: width)
    path.stroke()
}

/// Draws the standard four corners for a border style
/// - Parameters:
///   - width: Canvas width
///   - height: Canvas height
///   - inset: Corner inset from edges
///   - drawCorner: Closure to draw a single corner
func drawFourCorners(
    width: CGFloat,
    height: CGFloat,
    inset: CGFloat,
    drawCorner: (NSPoint, CGFloat, CGFloat) -> Void
) {
    drawCorner(NSPoint(x: inset, y: inset), 1, 1)
    drawCorner(NSPoint(x: width - inset, y: inset), -1, 1)
    drawCorner(NSPoint(x: inset, y: height - inset), 1, -1)
    drawCorner(NSPoint(x: width - inset, y: height - inset), -1, -1)
}

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
