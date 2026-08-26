import SwiftUI

struct AppSidebar: View {
    @Binding var selectedView: ViewType

    var body: some View {
        ZStack(alignment: .trailing) {
            sidebarBackground
            sidebarDivider
            sidebarContent
        }
        .frame(width: 220)
        .frame(maxHeight: .infinity)
        .onAppear {
            ViewType.assertSidebarItemsCoverAllCases()
        }
    }

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            brandLockup
                .padding(.horizontal, 18)
                .padding(.top, 34)
                .padding(.bottom, 18)

            sidebarSection(ViewType.primaryItems)

            Spacer(minLength: 16)

            sidebarSection(ViewType.secondaryItems)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Wordmark in the sidebar head. Without it the chrome carries no identity at
    /// all, which is what makes an app read as a settings panel rather than a product.
    private var brandLockup: some View {
        HStack(spacing: 9) {
            Image("menuBarIcon")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(height: 15)
                .foregroundStyle(BrandPalette.ink)

            Text(verbatim: "Scribe")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(BrandPalette.ink)

            Spacer(minLength: 0)
        }
    }

    private var sidebarBackground: some View {
        // Vibrancy underneath keeps the native feel; the warm tint on top stops the
        // sidebar reading as cold grey next to the warm content area.
        VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            .overlay(BrandPalette.sidebar.opacity(0.92))
            .ignoresSafeArea(.container, edges: .top)
    }

    private var sidebarDivider: some View {
        Rectangle()
            .fill(BrandPalette.cardBorder)
            .frame(width: 1)
            .ignoresSafeArea(.container, edges: .top)
    }

    private func sidebarSection(_ items: [ViewType]) -> some View {
        VStack(spacing: 3) {
            ForEach(items) { viewType in
                SidebarItemButton(
                    viewType: viewType,
                    isSelected: selectedView == viewType
                ) {
                    selectedView = viewType
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

private extension ViewType {
    var title: LocalizedStringKey {
        switch self {
        case .transcribeAudio:
            return "Transcribe"
        default:
            return LocalizedStringKey(rawValue)
        }
    }

    static let primaryItems: [ViewType] = [
        .dashboard,
        .insights,
        .modes,
        .transcribeAudio,
        .history,
        .dictionary,
        .models,
        .audio,
    ]

    static let secondaryItems: [ViewType] = [
        .settings,
    ]

    static func assertSidebarItemsCoverAllCases() {
        #if DEBUG
            let sidebarItems = primaryItems + secondaryItems
            assert(Set(sidebarItems) == Set(allCases) && sidebarItems.count == allCases.count)
        #endif
    }

    var icon: String {
        switch self {
        case .dashboard: return "house"
        case .insights: return "chart.bar"
        case .transcribeAudio: return "waveform"
        case .history: return "doc.text"
        case .models: return "cpu"
        case .modes: return "wand.and.stars"
        case .audio: return "mic"
        case .dictionary: return "book"
        case .settings: return "gearshape"
        }
    }

}

private struct SidebarItemButton: View {
    let viewType: ViewType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: viewType.icon)
                    .font(.system(size: 15, weight: .regular))
                    .symbolRenderingMode(.monochrome)
                    .frame(width: 20, height: 20)

                Text(viewType.title)
                    .font(.system(size: 13.5, weight: isSelected ? .semibold : .medium))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? selectedForegroundColor : BrandPalette.inkSecondary)
            .padding(.leading, 8)
            .padding(.trailing, 10)
            .frame(height: 38)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground)
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(viewType.title)
        .accessibilityLabel(viewType.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(rowBackgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(rowBorderColor, lineWidth: 1)
            }
    }

    private var rowBackgroundColor: Color {
        isSelected ? BrandPalette.card : .clear
    }

    private var rowBorderColor: Color {
        .clear
    }

    private var selectedForegroundColor: Color {
        BrandPalette.ink
    }
}

