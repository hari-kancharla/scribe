import SwiftUI

enum AppTheme {
    enum Accent {
        static let primary = BrandPalette.accent
        static let fillSubtle = primary.opacity(0.10)
        static let fill = primary.opacity(0.14)
        static let fillStrong = primary.opacity(0.28)
        static let border = primary.opacity(0.40)
        static let disabled = primary.opacity(0.50)
        static let foreground = primary.opacity(0.65)
        static let strong = primary.opacity(0.80)
        static let shadow = primary.opacity(0.20)
    }

    enum Surface {
        static let card = BrandPalette.card
        static let materialCard = BrandPalette.cardMuted
        static let subtle = BrandPalette.trackEmpty
        static let controlActive = BrandPalette.hover
        static let control = BrandPalette.cardMuted
        static let window = BrandPalette.canvas
        static let sidePanelOverlay = BrandPalette.canvas.opacity(0.60)
        static let clear = Color.clear
    }

    enum Border {
        static let subtle = BrandPalette.cardBorder
        static let card = BrandPalette.cardBorder
        static let control = BrandPalette.controlBorder
        static let tint = BrandPalette.cardBorder
        static let sidePanelOuter = Color.white.opacity(0.12)
    }

    enum Selection {
        static let fill = BrandPalette.hover
        static let border = BrandPalette.controlBorder
        static let foreground = BrandPalette.ink
    }

    enum Status {
        static let success = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.85)
        static let positive = Color(nsColor: .systemGreen)
        static let info = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.75)
        static let infoStrong = Color(nsColor: .systemBlue)
        static let warning = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.85)
        static let warningStrong = Color(nsColor: .systemOrange)
        static let error = Color(nsColor: .systemRed)
    }

    enum Data {
        static let transcript = BrandPalette.Chart.one
        static let audio = BrandPalette.Chart.two
        static let enhancement = BrandPalette.Chart.three
        static let purple = BrandPalette.Chart.five
        static let yellow = BrandPalette.Chart.three
        static let orange = BrandPalette.Chart.four
    }

    enum Sidebar {
        static let dashboard = BrandPalette.accent
        static let modes = BrandPalette.Chart.five
        static let models = BrandPalette.Chart.four
        static let audio = BrandPalette.Chart.two
        static let dictionary = BrandPalette.Chart.two
        static let transcribeAudio = BrandPalette.Chart.four
        static let fallback = BrandPalette.inkSecondary
        static let license = BrandPalette.accent
    }

    enum Waveform {
        static let hoverBubble = BrandPalette.ink.opacity(0.74)
        static let hoverMarker = BrandPalette.ink.opacity(0.68)
        static let playedLower = BrandPalette.accent
        static let playedUpper = BrandPalette.accent.opacity(0.80)
        static let unplayedLower = BrandPalette.ink.opacity(0.26)
        static let unplayedUpper = BrandPalette.ink.opacity(0.16)
    }

    enum Text {
        static let primary = BrandPalette.ink
        static let secondary = BrandPalette.inkSecondary
        static let muted = BrandPalette.inkSecondary.opacity(0.72)
        static let disabled = Color(nsColor: .disabledControlTextColor)
        static let onAccent = Color(nsColor: .alternateSelectedControlTextColor)
    }

    enum NativeText {
        static let primary = NSColor.labelColor
    }

    enum Action {
        static let primaryFill = Accent.primary
        static let primaryForeground = Text.onAccent
        static let secondaryForeground = Text.primary
        static let disabledFill = Surface.controlActive
        static let disabledForeground = Text.disabled
    }

    enum Radius {
        static let control: CGFloat = 14
        static let card: CGFloat = 12
        static let pill: CGFloat = 22
    }
}
