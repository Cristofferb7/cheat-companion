import AppKit

// Renders the Cheat Companion app icon (1024x1024 PNG).
// Design: deep indigo->violet gradient, faint monospace hex rows as texture,
// amber lightning bolt (the classic "cheat power" glyph) with soft shadow.

let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("no context") }

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
}

// Background gradient
let colors = [color(0x241E5C), color(0x5B2EBE)] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: 0),
                       end: CGPoint(x: CGFloat(size), y: CGFloat(size)),
                       options: [])

// Faint hex-code texture rows
let mono = NSFont(name: "Menlo-Bold", size: 64) ?? NSFont.monospacedSystemFont(ofSize: 64, weight: .bold)
let rows = ["82025840 0044", "D8BAE4D9 4864", "94000130 FCFF", "509197D3 5429",
            "A86CDBA5 19BA", "B2101D40 0000", "010AA3CE 9100", "E6A003D6 8110"]
for (i, text) in rows.enumerated() {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: mono,
        .foregroundColor: NSColor(white: 1, alpha: 0.07)
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let x = CGFloat(i % 2 == 0 ? -40 : 60)
    let y = CGFloat(40 + i * 128)
    str.draw(at: NSPoint(x: x, y: y))
}

// Lightning bolt with soft shadow
func boltPath(in rect: CGRect) -> CGPath {
    let p = CGMutablePath()
    let pts: [(CGFloat, CGFloat)] = [
        (0.585, 0.94), (0.27, 0.46), (0.475, 0.46),
        (0.415, 0.06), (0.73, 0.55), (0.525, 0.55)
    ]
    let mapped = pts.map { CGPoint(x: rect.minX + $0.0 * rect.width,
                                   y: rect.minY + $0.1 * rect.height) }
    p.addLines(between: mapped)
    p.closeSubpath()
    return p
}

let boltRect = CGRect(x: 212, y: 132, width: 600, height: 760)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 60, color: color(0x000000, 0.45))
ctx.addPath(boltPath(in: boltRect))
ctx.setFillColor(color(0xFFB020))
ctx.fillPath()
ctx.restoreGState()

// Subtle top highlight on the bolt
ctx.addPath(boltPath(in: boltRect))
ctx.clip()
let shine = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [color(0xFFFFFF, 0.35), color(0xFFFFFF, 0.0)] as CFArray,
                       locations: [0, 0.45])!
ctx.drawLinearGradient(shine,
                       start: CGPoint(x: 0, y: CGFloat(size)),
                       end: CGPoint(x: 0, y: 0),
                       options: [])

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { fatalError("encode failed") }
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
