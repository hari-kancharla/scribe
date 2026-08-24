import AppKit
import SwiftUI

/// The app's colour foundation, taken from the mark: a warm off-white paper and a
/// near-black ink, with a single amber used for anything that carries data.
///
/// Every colour resolves per appearance rather than being a fixed value, so the
/// same token works in light and dark without a second set of names.
enum BrandPalette {
    /// Builds a colour that resolves differently in light and dark appearances.
    private static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(
            nsColor: NSColor(name: nil) { appearance in
                let isDark =
                    appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                return isDark ? dark : light
            }
        )
    }

    private static func srgb(_ hex: UInt32) -> NSColor {
        NSColor(
            srgbRed: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    // MARK: - Canvas and cards

    /// The page behind everything. Warm paper in light, a soft charcoal in dark —
    /// never pure white or pure black, both of which read as cheap.
    static let canvas = adaptive(light: srgb(0xEDEAE1), dark: srgb(0x161618))

    /// Cards sit *above* the canvas rather than being a wash over it, which is what
    /// gives the layout depth.
    static let card = adaptive(light: srgb(0xFFFFFF), dark: srgb(0x252528))

    /// Sidebar sits a shade deeper than the canvas so the content area reads as
    /// the lit surface, while keeping the same warm family.
    static let sidebar = adaptive(light: srgb(0xE7E4DA), dark: srgb(0x121214))

    /// A quieter card for secondary information.
    static let cardMuted = adaptive(light: srgb(0xFBFAF7), dark: srgb(0x212124))

    /// Hairline around cards, warm rather than a neutral grey.
    static let cardBorder = adaptive(
        light: NSColor(srgbRed: 0.10, green: 0.09, blue: 0.06, alpha: 0.10),
        dark: NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.09)
    )

    /// Soft lift under cards. Kept very low so it reads as paper, not as a drop shadow.
    static let cardShadow = adaptive(
        light: NSColor(srgbRed: 0.20, green: 0.17, blue: 0.10, alpha: 0.07),
        dark: NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.32)
    )

    // MARK: - Ink

    static let ink = adaptive(light: srgb(0x1A1A18), dark: srgb(0xF2F1EC))
    static let inkSecondary = adaptive(
        light: NSColor(srgbRed: 0.10, green: 0.10, blue: 0.08, alpha: 0.58),
        dark: NSColor(srgbRed: 0.95, green: 0.95, blue: 0.92, alpha: 0.60)
    )

    // MARK: - Accent

    /// A single warm amber. Used for data and for the one thing on a screen that
    /// should be looked at first — never as general decoration.
    static let accent = adaptive(light: srgb(0xB9722C), dark: srgb(0xD98E3F))
    static let accentQuiet = adaptive(
        light: NSColor(srgbRed: 0.73, green: 0.45, blue: 0.17, alpha: 0.14),
        dark: NSColor(srgbRed: 0.85, green: 0.56, blue: 0.25, alpha: 0.20)
    )

    /// Empty cells in the contribution graph: visible as structure, quiet enough
    /// that a single active day still reads instantly.
    static let trackEmpty = adaptive(
        light: NSColor(srgbRed: 0.10, green: 0.09, blue: 0.06, alpha: 0.07),
        dark: NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.08)
    )

    /// The inset content panel: a touch lighter than the canvas so the page reads
    /// as a surface laid on the window rather than the window itself.
    static let panel = adaptive(light: srgb(0xFAF8F4), dark: srgb(0x1F1F22))

    /// Text and glyphs sitting on the accent fill.
    static let onAccent = adaptive(light: srgb(0xFFFFFF), dark: srgb(0x1A1815))

    /// Neutral hover/pressed wash. Deliberately not tinted — tinting every hover
    /// amber turns the accent into background noise.
    static let hover = adaptive(
        light: NSColor(srgbRed: 0.10, green: 0.09, blue: 0.06, alpha: 0.06),
        dark: NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.07)
    )

    /// A firmer edge for controls that need to read as separate from their surface.
    static let controlBorder = adaptive(
        light: NSColor(srgbRed: 0.10, green: 0.09, blue: 0.06, alpha: 0.18),
        dark: NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.16)
    )

    // MARK: - Categorical data

    /// A small harmonised set for charts. Amber leads; the others are chosen to sit
    /// beside it on warm paper rather than fighting it, which the stock system
    /// indigo/teal/mint did.
    enum Chart {
        static let one = BrandPalette.accent
        static let two = adaptive(light: srgb(0x4A6670), dark: srgb(0x7EA0AC))
        static let three = adaptive(light: srgb(0x7B7A4A), dark: srgb(0xB0AE74))
        static let four = adaptive(light: srgb(0x8C5A4B), dark: srgb(0xC08C7A))
        static let five = adaptive(light: srgb(0x5E5A6B), dark: srgb(0x9A94AB))
    }
}

/// Card surface with real elevation: a filled shape lifted off the canvas by a
/// hairline border and a soft shadow, rather than a translucent wash.
struct BrandCardBackground: View {
    var cornerRadius: CGFloat = 14
    var muted: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(muted ? BrandPalette.cardMuted : BrandPalette.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(BrandPalette.cardBorder, lineWidth: 1)
            )
            .shadow(color: BrandPalette.cardShadow, radius: 10, y: 3)
    }
}
