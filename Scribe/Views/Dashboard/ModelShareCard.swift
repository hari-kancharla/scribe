import SwiftUI

/// Which transcription models actually did the work, as a share of recorded audio.
///
/// Bars are proportional to the busiest model rather than to the total, so a
/// dominant model fills its row and everything else reads relative to it — the
/// comparison worth making is "how much of my dictation goes through this one".
struct ModelShareCard: View {
    let models: [TranscriptionModelUsage]

    private var ranked: [TranscriptionModelUsage] {
        models
            .filter { $0.sessionCount > 0 }
            .sorted { $0.totalAudioDuration > $1.totalAudioDuration }
    }

    private var busiestDuration: TimeInterval {
        ranked.first?.totalAudioDuration ?? 0
    }

    private var totalSessions: Int {
        ranked.reduce(0) { $0 + $1.sessionCount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("Models used")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BrandPalette.ink)

                Spacer(minLength: 12)

                Text("SESSIONS | \(totalSessions)")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.7)
                    .foregroundStyle(BrandPalette.inkSecondary)
            }

            if ranked.isEmpty {
                Text("No transcription recorded yet.")
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.inkSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(ranked.prefix(5)) { model in
                        row(for: model)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BrandCardBackground(cornerRadius: 14))
    }

    private func row(for model: TranscriptionModelUsage) -> some View {
        let fraction =
            busiestDuration > 0 ? model.totalAudioDuration / busiestDuration : 0

        return VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text(model.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(BrandPalette.ink)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(
                    model.sessionCount == 1
                        ? "1 session" : "\(model.sessionCount) sessions"
                )
                .font(.system(size: 11))
                .foregroundStyle(BrandPalette.inkSecondary)
                .fixedSize()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(BrandPalette.trackEmpty)
                    Capsule()
                        .fill(BrandPalette.accent)
                        // Keep a sliver of width at tiny shares so no row looks empty.
                        .frame(width: max(6, geometry.size.width * fraction))
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
    }
}
