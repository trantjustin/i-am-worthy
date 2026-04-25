#!/usr/bin/env swift
// Generates a 1024x1024 AppIcon PNG for "I Am Worthy".
// Usage: swift scripts/generate-app-icon.swift <output.png>

import AppKit

// Required in headless `swift` scripts before creating NSGraphicsContext.
_ = NSApplication.shared

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write(Data("usage: generate-app-icon.swift <output.png>\n".utf8))
    exit(1)
}

let outPath = CommandLine.arguments[1]
let side: CGFloat = 1024

// Explicit 1024x1024 RGBA bitmap (NSGraphicsContext requires alpha channel).
// We draw an opaque gradient across the whole canvas so alpha is fully 1.0
// everywhere; `sips` strips the alpha channel after PNG encoding for the
// final App Store-compliant icon.
guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(side),
    pixelsHigh: Int(side),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 32
) else { fatalError("failed to create bitmap rep") }
rep.size = NSSize(width: side, height: side)

NSGraphicsContext.saveGraphicsState()
let nsCtx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = nsCtx
let ctx = nsCtx.cgContext

// 1. Diagonal gradient background — warm, uplifting palette.
let colors: [CGColor] = [
    NSColor(red: 0.42, green: 0.20, blue: 0.85, alpha: 1).cgColor, // deep violet
    NSColor(red: 0.93, green: 0.27, blue: 0.55, alpha: 1).cgColor, // rose
    NSColor(red: 1.00, green: 0.62, blue: 0.35, alpha: 1).cgColor  // warm orange
]
let locations: [CGFloat] = [0.0, 0.55, 1.0]
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: colors as CFArray,
                          locations: locations)!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: side),
                       end: CGPoint(x: side, y: 0),
                       options: [])

// 2. Soft radial highlight in the upper-left for depth.
let highlight = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: [NSColor.white.withAlphaComponent(0.22).cgColor,
                                    NSColor.white.withAlphaComponent(0.0).cgColor] as CFArray,
                           locations: [0, 1])!
ctx.drawRadialGradient(highlight,
                       startCenter: CGPoint(x: side * 0.25, y: side * 0.80),
                       startRadius: 0,
                       endCenter: CGPoint(x: side * 0.25, y: side * 0.80),
                       endRadius: side * 0.6,
                       options: [])

// 3. "I AM / WORTHY!" stacked on two lines in bold rounded white.
let text = "I AM\nWORTHY!" as NSString
let font = NSFont.systemFont(ofSize: 185, weight: .black).withRoundedDesign()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.25)
shadow.shadowBlurRadius = 18
shadow.shadowOffset = NSSize(width: 0, height: -6)

let style = NSMutableParagraphStyle()
style.alignment = .center
style.lineBreakMode = .byWordWrapping

let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white,
    .kern: -10,
    .shadow: shadow,
    .paragraphStyle: style
]
let attrStr = NSAttributedString(string: text as String, attributes: attrs)
let textBounds = attrStr.boundingRect(
    with: NSSize(width: side, height: side),
    options: [.usesLineFragmentOrigin, .usesFontLeading]
)
let rect = NSRect(x: 0,
                  y: (side - textBounds.height) / 2,
                  width: side,
                  height: textBounds.height)
text.draw(in: rect, withAttributes: attrs)

NSGraphicsContext.restoreGraphicsState()

// Re-render into an opaque (no-alpha) CGContext so the final PNG has no
// alpha channel — App Store icon validation rejects alpha.
guard let sourceCGImage = rep.cgImage else { fatalError("no CGImage") }
guard let opaqueCtx = CGContext(
    data: nil,
    width: Int(side), height: Int(side),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else { fatalError("failed to create opaque context") }

opaqueCtx.draw(sourceCGImage, in: CGRect(x: 0, y: 0, width: side, height: side))

guard let opaqueImage = opaqueCtx.makeImage() else { fatalError("makeImage failed") }
let finalRep = NSBitmapImageRep(cgImage: opaqueImage)

guard let png = finalRep.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode PNG")
}

try! png.write(to: URL(fileURLWithPath: outPath))
print("✅ Wrote \(outPath) (\(png.count / 1024) KB)")

// MARK: - Helpers

extension NSFont {
    /// Apply the rounded SF design to the current font, falling back gracefully.
    func withRoundedDesign() -> NSFont {
        let desc = fontDescriptor.withDesign(.rounded) ?? fontDescriptor
        return NSFont(descriptor: desc, size: pointSize) ?? self
    }
}
