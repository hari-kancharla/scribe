import OSLog
import SwiftUI

enum ViewType: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case insights = "Insights"
    case modes = "Modes"
    case models = "AI Models"
    case transcribeAudio = "Transcribe Audio"
    case history = "History"
    case audio = "Audio"
    case dictionary = "Dictionary"
    case settings = "Settings"

    var id: String { rawValue }
}

final class MainWindowNavigation: ObservableObject {
    static let shared = MainWindowNavigation()

    @Published var selectedView: ViewType = .dashboard

    private init() {}

    func navigate(to destination: String) {
        guard let viewType = ViewType(rawValue: destination) else {
            return
        }

        navigate(to: viewType)
    }

    func navigate(to destination: ViewType) {
        selectedView = destination
    }
}

struct ContentView: View {
    private let logger = Logger(subsystem: "com.personal.scribe", category: "ContentView")
    private static let detailBackgroundTintOpacity = 0.97
    private static let panelCornerRadius: CGFloat = 14
    private static let panelInset: CGFloat = 12
    /// Matches the other insets. The traffic lights sit over the sidebar, so the
    /// panel has nothing to clear and an asymmetric top gap just reads as a mistake.
    private static let panelTopInset: CGFloat = Self.panelInset
    @EnvironmentObject private var navigation: MainWindowNavigation

    var body: some View {
        HStack(spacing: 0) {
            AppSidebar(selectedView: $navigation.selectedView)

            detailContent
        }
        .frame(
            minWidth: AppWindowLayout.minimumWidth,
            idealWidth: AppWindowLayout.width,
            maxWidth: .infinity,
            minHeight: AppWindowLayout.minimumHeight,
            idealHeight: AppWindowLayout.minimumHeight,
            maxHeight: .infinity
        )
        .onAppear {
            logger.notice("ContentView appeared")
        }
        .onDisappear {
            logger.notice("ContentView disappeared")
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDestination)) { notification in
            if let destination = notification.userInfo?["destination"] as? String {
                logger.notice("navigateToDestination received: \(destination, privacy: .public)")
                navigation.navigate(to: destination)
            }
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        // The content sits on the window as an inset panel rather than running
        // edge to edge. The margin is what separates a product surface from a
        // form: it gives the page a boundary and lets the window colour frame it.
        detailView(for: navigation.selectedView)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Self.panelCornerRadius, style: .continuous)
                    .fill(BrandPalette.panel)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: Self.panelCornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Self.panelCornerRadius, style: .continuous)
                    .strokeBorder(BrandPalette.cardBorder, lineWidth: 1)
            )
            .shadow(color: BrandPalette.cardShadow, radius: 18, y: 6)
            .padding(.top, Self.panelTopInset)
            .padding(.leading, Self.panelInset)
            .padding(.trailing, Self.panelInset)
            .padding(.bottom, Self.panelInset)
            .background(windowBackground)
    }

    private var windowBackground: some View {
        ZStack {
            VisualEffectView(
                material: .sidebar,
                blendingMode: .behindWindow
            )

            BrandPalette.canvas
                .opacity(Self.detailBackgroundTintOpacity)
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    @ViewBuilder
    private func detailView(for viewType: ViewType) -> some View {
        switch viewType {
        case .dashboard:
            DashboardView()
        case .insights:
            InsightsPageView()
        case .models:
            ModelManagementView()
        case .transcribeAudio:
            AudioTranscribeView()
        case .history:
            InlineHistoryView()
        case .audio:
            AudioSetupView()
        case .dictionary:
            DictionarySettingsView()
        case .modes:
            ModeView()
        case .settings:
            SettingsView()
        }
    }
}
