import SwiftUI

/// A half-circle gauge showing dictation rate against typing speed.
///
/// The scale is anchored to something meaningful rather than an arbitrary maximum:
/// the track spans up to `referenceCeiling` words per minute, with the average
/// typing speed marked on it, so the arc answers "how much faster than typing is
/// this" at a glance instead of just restating the number below it.
struct SpeedGauge: View {
    let wordsPerMinute: Int
    /// Average sustained typing speed, the same figure the time-saved maths uses.
    var typingBaseline: Int = 40
    var referenceCeiling: Int = 200

    private var progress: Double {
        min(max(Double(wordsPerMinute) / Double(referenceCeiling), 0), 1)
    }

    private var baselineProgress: Double {
        min(max(Double(typingBaseline) / Double(referenceCeiling), 0), 1)
    }

    private var multiple: Double {
        guard typingBaseline > 0 else { return 0 }
        return Double(wordsPerMinute) / Double(typingBaseline)
    }

    var body: some View {
        ZStack {
            // Track
            GaugeArc(progress: 1)
                .stroke(BrandPalette.trackEmpty, style: .init(lineWidth: 9, lineCap: .round))

            // Value
            GaugeArc(progress: progress)
                .stroke(BrandPalette.accent, style: .init(lineWidth: 9, lineCap: .round))

            // Where ordinary typing would sit on the same scale
            GaugeTick(progress: baselineProgress)
                .stroke(BrandPalette.ink.opacity(0.30), style: .init(lineWidth: 1.5, lineCap: .round))

            VStack(spacing: 1) {
                Text(multipleText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BrandPalette.ink)
                Text("vs typing")
                    .font(.system(size: 9))
                    .foregroundStyle(BrandPalette.inkSecondary)
            }
            .offset(y: 10)
        }
        .frame(height: 62)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(wordsPerMinute) words per minute, \(multipleText) typing speed")
    }

    private var multipleText: String {
        multiple >= 10
            ? "\(Int(multiple.rounded()))×"
            : String(format: "%.1f×", multiple)
    }
}

/// Half circle from due west round to due east.
private struct GaugeArc: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height * 2) / 2 - 5
        let centre = CGPoint(x: rect.midX, y: rect.maxY - 4)
        path.addArc(
            center: centre,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(180 + 180 * progress),
            clockwise: false
        )
        return path
    }
}

/// A short radial tick across the track at a given position.
private struct GaugeTick: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height * 2) / 2 - 5
        let centre = CGPoint(x: rect.midX, y: rect.maxY - 4)
        let angle = Angle.degrees(180 + 180 * progress).radians
        let inner = radius - 7.5
        let outer = radius + 7.5

        var path = Path()
        path.move(
            to: CGPoint(x: centre.x + cos(angle) * inner, y: centre.y + sin(angle) * inner)
        )
        path.addLine(
            to: CGPoint(x: centre.x + cos(angle) * outer, y: centre.y + sin(angle) * outer)
        )
        return path
    }
}
