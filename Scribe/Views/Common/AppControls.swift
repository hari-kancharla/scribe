import Foundation
import SwiftUI

struct AppIconButton: View {
    let systemName: String
    let help: LocalizedStringResource
    var size: CGFloat = 40
    var iconSize: CGFloat = 18
    var cornerRadius: CGFloat = AppTheme.Radius.pill
    var isDisabled = false
    let action: () -> Void

    init(
        systemName: String,
        help: LocalizedStringResource,
        size: CGFloat = 40,
        iconSize: CGFloat = 18,
        cornerRadius: CGFloat = AppTheme.Radius.pill,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.help = help
        self.size = size
        self.iconSize = iconSize
        self.cornerRadius = cornerRadius
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(isDisabled ? .secondary.opacity(0.45) : .primary.opacity(0.7))
                .frame(width: size, height: size)
                .background(
                    AppCardBackground(isSelected: false, cornerRadius: cornerRadius)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .help(help)
        .accessibilityLabel(help)
    }
}

struct AppPanelHeader: View {
    let title: LocalizedStringKey
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            AppIconButton(
                systemName: "xmark",
                help: "Close",
                size: 28,
                iconSize: 14,
                cornerRadius: AppTheme.Radius.control,
                action: onClose
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .overlay(Divider().opacity(0.5), alignment: .bottom)
        .zIndex(1)
    }
}

/// The one page header every screen uses. A subtitle is supported so a page can
/// say what it is in a line, which is what stops each screen from opening cold
/// straight onto controls.
struct AppScreenHeader<Trailing: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var infoMessage: LocalizedStringKey?
    var infoURL: String?
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.Text.primary)

                    if let infoMessage {
                        if let infoURL {
                            InfoTip(infoMessage, learnMoreURL: infoURL)
                        } else {
                            InfoTip(infoMessage)
                        }
                    }
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.Text.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            trailing()
        }
        .padding(.horizontal, AppScreenMetrics.horizontal)
        .padding(.top, AppScreenMetrics.top)
        .padding(.bottom, AppScreenMetrics.headerBottom)
        .frame(maxWidth: AppScreenMetrics.maxContentWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension AppScreenHeader where Trailing == EmptyView {
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        infoMessage: LocalizedStringKey? = nil,
        infoURL: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.infoMessage = infoMessage
        self.infoURL = infoURL
        self.trailing = { EmptyView() }
    }
}

/// Shared page rhythm so titles and content land on the same optical grid
/// everywhere instead of each screen inventing its own padding.
enum AppScreenMetrics {
    static let horizontal: CGFloat = 26
    static let top: CGFloat = 24
    static let headerBottom: CGFloat = 16
    /// Grouped Forms cap and centre themselves on macOS. Matching that width for
    /// headers and toolbars keeps every element of a page on one column instead of
    /// a full-width title sitting above a narrow centred body.
    static let maxContentWidth: CGFloat = 1040
}
