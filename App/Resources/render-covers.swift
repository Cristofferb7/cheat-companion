import AppKit

// Renders original cover-card art for each game (600x840 PNG).
// Run: swift render-covers.swift <output-dir>
// These are original, flat, game-evocative designs — NOT Nintendo box art.

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

func color(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

struct Cover {
    let slug: String
    let top: UInt32
    let bottom: UInt32
    let series: String
    let title: String
    let draw: (CGContext, CGRect) -> Void
}

let W: CGFloat = 600, H: CGFloat = 840

func poly(_ ctx: CGContext, _ pts: [(CGFloat, CGFloat)], _ fill: CGColor) {
    let p = CGMutablePath()
    p.addLines(between: pts.map { CGPoint(x: $0.0, y: $0.1) })
    p.closeSubpath()
    ctx.addPath(p)
    ctx.setFillColor(fill)
    ctx.fillPath()
}

let covers: [Cover] = [
    Cover(slug: "pokemon-firered-us", top: 0xF97316, bottom: 0xB91C1C,
          series: "POKÉMON", title: "FireRed") { ctx, r in
        // Flame: outer teardrop + inner core
        let cx = r.midX, base: CGFloat = 300, tipY: CGFloat = 640
        let flame = CGMutablePath()
        flame.move(to: CGPoint(x: cx, y: tipY))
        flame.addQuadCurve(to: CGPoint(x: cx + 120, y: base + 90),
                           control: CGPoint(x: cx + 130, y: tipY - 130))
        flame.addQuadCurve(to: CGPoint(x: cx, y: base),
                           control: CGPoint(x: cx + 120, y: base - 10))
        flame.addQuadCurve(to: CGPoint(x: cx - 120, y: base + 90),
                           control: CGPoint(x: cx - 120, y: base - 10))
        flame.addQuadCurve(to: CGPoint(x: cx, y: tipY),
                           control: CGPoint(x: cx - 150, y: tipY - 170))
        flame.closeSubpath()
        ctx.addPath(flame)
        ctx.setFillColor(color(0xFFC53D))
        ctx.fillPath()

        let core = CGMutablePath()
        core.move(to: CGPoint(x: cx - 6, y: tipY - 160))
        core.addQuadCurve(to: CGPoint(x: cx + 62, y: base + 110),
                          control: CGPoint(x: cx + 74, y: tipY - 240))
        core.addQuadCurve(to: CGPoint(x: cx - 60, y: base + 116),
                          control: CGPoint(x: cx, y: base + 40))
        core.addQuadCurve(to: CGPoint(x: cx - 6, y: tipY - 160),
                          control: CGPoint(x: cx - 78, y: tipY - 250))
        core.closeSubpath()
        ctx.addPath(core)
        ctx.setFillColor(color(0xFFF3C4))
        ctx.fillPath()
    },
    Cover(slug: "pokemon-emerald-us", top: 0x34D399, bottom: 0x065F46,
          series: "POKÉMON", title: "Emerald") { ctx, _ in
        // Emerald-cut gem: octagon with facets
        let o: [(CGFloat, CGFloat)] = [(210, 620), (390, 620), (460, 550),
                                       (460, 390), (390, 320), (210, 320),
                                       (140, 390), (140, 550)]
        poly(ctx, o, color(0x86EFC3))
        let i: [(CGFloat, CGFloat)] = [(245, 575), (355, 575), (405, 525),
                                       (405, 415), (355, 365), (245, 365),
                                       (195, 415), (195, 525)]
        poly(ctx, i, color(0x10B981))
        poly(ctx, [(245, 575), (355, 575), (300, 470)], color(0x059669, 0.85))
        poly(ctx, [(245, 365), (355, 365), (300, 470)], color(0x34D399, 0.9))
    },
    Cover(slug: "pokemon-crystal-us", top: 0x67E8F9, bottom: 0x1D4ED8,
          series: "POKÉMON", title: "Crystal") { ctx, _ in
        // Cluster of ice shards
        poly(ctx, [(300, 660), (365, 540), (300, 330), (235, 540)], color(0xE0F7FF))
        poly(ctx, [(300, 660), (300, 330), (235, 540)], color(0x9BD9F5, 0.9))
        poly(ctx, [(200, 560), (245, 470), (205, 360), (160, 470)], color(0xBFEDFF, 0.95))
        poly(ctx, [(400, 560), (440, 470), (398, 360), (356, 470)], color(0xBFEDFF, 0.95))
    },
    Cover(slug: "pokemon-platinum-us", top: 0xB8BEC9, bottom: 0x3A4150,
          series: "POKÉMON", title: "Platinum") { ctx, _ in
        // Layered metallic rhombus emblem
        poly(ctx, [(300, 660), (470, 480), (300, 300), (130, 480)], color(0xE7EAF0))
        poly(ctx, [(300, 610), (425, 480), (300, 350), (175, 480)], color(0x6E7686))
        poly(ctx, [(300, 555), (380, 480), (300, 405), (220, 480)], color(0xF5F7FA))
        poly(ctx, [(300, 660), (470, 480), (300, 555), (220, 480), (130, 480)],
             color(0xFFFFFF, 0.12))
    },
    Cover(slug: "pokemon-yellow-us", top: 0xFDE047, bottom: 0xD97706,
          series: "POKÉMON", title: "Yellow") { ctx, _ in
        // Lightning bolt, white on yellow
        poly(ctx, [(345, 660), (205, 445), (285, 445), (250, 310),
                   (400, 520), (315, 520)], color(0xFFFFFF))
        poly(ctx, [(330, 610), (250, 470), (300, 470), (280, 380),
                   (365, 500), (305, 500)], color(0xF59E0B, 0.55))
    },
    Cover(slug: "pokemon-ruby-us", top: 0xF87171, bottom: 0x7F1D1D,
          series: "POKÉMON", title: "Ruby") { ctx, _ in
        // Ruby gem: same emerald cut, red palette
        let o: [(CGFloat, CGFloat)] = [(210, 620), (390, 620), (460, 550),
                                       (460, 390), (390, 320), (210, 320),
                                       (140, 390), (140, 550)]
        poly(ctx, o, color(0xFECACA))
        let i: [(CGFloat, CGFloat)] = [(245, 575), (355, 575), (405, 525),
                                       (405, 415), (355, 365), (245, 365),
                                       (195, 415), (195, 525)]
        poly(ctx, i, color(0xDC2626))
        poly(ctx, [(245, 575), (355, 575), (300, 470)], color(0x991B1B, 0.85))
        poly(ctx, [(245, 365), (355, 365), (300, 470)], color(0xF87171, 0.9))
    },
    Cover(slug: "pokemon-heartgold-us", top: 0xFCD34D, bottom: 0x92400E,
          series: "POKÉMON", title: "HeartGold") { ctx, _ in
        // Heart: two circles + triangle, gold on amber
        let heart = CGMutablePath()
        heart.move(to: CGPoint(x: 300, y: 330))
        heart.addLine(to: CGPoint(x: 155, y: 505))
        heart.addArc(center: CGPoint(x: 228, y: 560), radius: 91,
                     startAngle: .pi * 1.25, endAngle: .pi * 0.25, clockwise: false)
        heart.addArc(center: CGPoint(x: 372, y: 560), radius: 91,
                     startAngle: .pi * 0.75, endAngle: .pi * 1.75, clockwise: false)
        heart.closeSubpath()
        ctx.addPath(heart)
        ctx.setFillColor(color(0xFFF7DB))
        ctx.fillPath()
    }
]

for cover in covers {
    let image = NSImage(size: NSSize(width: W, height: H))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError() }

    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [color(cover.bottom), color(cover.top)] as CFArray,
                          locations: [0, 1])!
    ctx.drawLinearGradient(grad, start: .zero, end: CGPoint(x: 0, y: H), options: [])

    // Subtle diagonal sheen
    poly(ctx, [(0, H), (W, H), (W, H - 320), (0, H - 120)], color(0xFFFFFF, 0.08))

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 36, color: color(0x000000, 0.35))
    cover.draw(ctx, CGRect(x: 0, y: 0, width: W, height: H))
    ctx.restoreGState()

    // Titles
    let series = NSAttributedString(string: cover.series, attributes: [
        .font: NSFont.systemFont(ofSize: 44, weight: .heavy),
        .foregroundColor: NSColor(white: 1, alpha: 0.75),
        .kern: 10
    ])
    series.draw(at: NSPoint(x: (W - series.size().width) / 2, y: 208))

    let title = NSAttributedString(string: cover.title, attributes: [
        .font: NSFont.systemFont(ofSize: 92, weight: .black),
        .foregroundColor: NSColor.white
    ])
    title.draw(at: NSPoint(x: (W - title.size().width) / 2, y: 96))

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { fatalError() }
    let path = "\(out)/cover-\(cover.slug).png"
    try! png.write(to: URL(fileURLWithPath: path))
    print("wrote \(path)")
}
