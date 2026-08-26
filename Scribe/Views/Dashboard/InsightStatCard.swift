import SwiftUI

/// A single headline figure with a small uppercase caption beneath it, and an
/// optional detail area under a hairline rule.
///
/// These read as a row of equal-height tiles: the number carries the weight, the
/// caption stays quiet, and anything supplementary sits below the rule so the
/// figures stay on one visual line across the row.
struct InsightStatCard<Detail: View>: View {
    let value: String
    let caption: String
    @ViewBuilder var detail: Detail

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(BrandPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(caption.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(BrandPalette.inkSecondary)
                .padding(.top, 6)

            if Detail.self != EmptyView.self {
                Rectangle()
                    .fill(BrandPalette.cardBorder)
                    .frame(height: 1)
                    .padding(.top, 14)

                detail
                    .padding(.top, 12)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BrandCardBackground(cornerRadius: 14))
    }
}

extension InsightStatCard where Detail == EmptyView {
    init(value: String, caption: String) {
        self.init(value: value, caption: caption) { EmptyView() }
    }
}

/// A labelled sub-figure used inside a stat card's detail area.
struct InsightStatDetailRow: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BrandPalette.ink)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(BrandPalette.inkSecondary)
            Spacer(minLength: 0)
        }
    }
}
