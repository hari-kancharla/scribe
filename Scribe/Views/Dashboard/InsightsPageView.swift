import SwiftData
import SwiftUI

/// Top-level Insights page: headline usage figures and the dictation streak.
///
/// Reads the same cached snapshot the dashboard uses, so switching between the
/// two never recomputes the whole history or shows two different sets of numbers.
struct InsightsPageView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var summary: DashboardStatsSummary
    @State private var hasLoadedSnapshot: Bool
    @State private var loadTask: Task<Void, Never>?

    init() {
        let cached = DashboardStatsCache.shared.currentSummary()
        _summary = State(initialValue: cached ?? .empty)
        _hasLoadedSnapshot = State(initialValue: cached != nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppScreenHeader(title: "Insights", subtitle: LocalizedStringKey(subtitle))

            GeometryReader { geometry in
                let contentWidth = DashboardLayout.contentWidth(for: geometry.size.width)

                ScrollView {
                VStack(alignment: .leading, spacing: DashboardLayout.sectionSpacing) {
                    if hasLoadedSnapshot && summary.totalCount > 0 {
                        statRow

                        HStack(alignment: .top, spacing: DashboardLayout.sectionSpacing) {
                            ModelShareCard(
                                models: summary.allTimeModelUsage.transcriptionModels
                            )
                            .frame(maxWidth: .infinity)

                            StreakCard(
                                currentStreak: summary.currentStreak,
                                longestStreak: summary.longestStreak,
                                dailyActivity: summary.dailyActivity
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    } else {
                        emptyState
                    }
                }
                .frame(width: contentWidth, alignment: .topLeading)
                .frame(
                    minHeight: max(0, geometry.size.height - DashboardLayout.contentBottomOffset),
                    alignment: .top
                )
                .padding(.vertical, DashboardLayout.pageVerticalPadding)
                .padding(.horizontal, DashboardLayout.pageHorizontalPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task { await loadSnapshot() }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No sessions yet")
                .font(.system(size: 16, weight: .semibold))
            Text("Dictate something and your usage and streak will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandCardBackground(cornerRadius: 14))
    }

    private var statRow: some View {
        HStack(alignment: .top, spacing: DashboardLayout.sectionSpacing) {
            InsightStatCard(
                value: wordsPerMinute.map(String.init) ?? "—",
                caption: String(localized: "Words per minute")
            ) {
                if let wordsPerMinute {
                    SpeedGauge(wordsPerMinute: wordsPerMinute)
                } else {
                    Text("Dictate a little more to measure your rate.")
                        .font(.system(size: 12))
                        .foregroundStyle(BrandPalette.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            InsightStatCard(
                value: Formatters.formattedCompactNumber(summary.totalWords),
                caption: String(localized: "Total words dictated")
            ) {
                InsightStatDetailRow(
                    value: "\(summary.totalCount)",
                    label: summary.totalCount == 1
                        ? String(localized: "session") : String(localized: "sessions")
                )
            }

            InsightStatCard(
                value: Formatters.formattedSavedTime(
                    DashboardTimeSaving.timeSaved(
                        words: summary.totalWords,
                        duration: summary.totalDuration
                    )
                ),
                caption: String(localized: "Time saved")
            ) {
                InsightStatDetailRow(
                    value: "\(summary.activeDayCount)",
                    label: summary.activeDayCount == 1
                        ? String(localized: "active day") : String(localized: "active days")
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var subtitle: String {
        guard summary.totalCount > 0 else {
            return String(localized: "Your dictation habits, measured over time.")
        }
        let days = summary.activeDayCount
        let dayText =
            days == 1 ? String(localized: "1 day") : String(localized: "\(days) days")
        return String(localized: "Across \(dayText) of dictation.")
    }

    /// Guarded so a very short amount of audio cannot produce an absurd rate.
    private var wordsPerMinute: Int? {
        let minutes = summary.totalDuration / 60
        guard minutes >= 0.5, summary.totalWords > 0 else { return nil }
        return Int((Double(summary.totalWords) / minutes).rounded())
    }

    private func loadSnapshot() async {
        // The dashboard writes the same snapshot, so only rescan when there is
        // nothing cached or the cache has been marked stale. A full scan walks
        // every session ever recorded and should not run on each visit.
        let cache = DashboardStatsCache.shared
        if let cached = cache.currentSummary() {
            summary = cached
            hasLoadedSnapshot = true
            guard cache.shouldRefreshSnapshotAutomatically() else { return }
        }

        loadTask?.cancel()
        let container = modelContext.container

        let task = Task {
            guard let loaded = try? await DashboardStatsLoader.load(from: container) else { return }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                _ = DashboardStatsCache.shared.update(loaded)
                summary = loaded
                hasLoadedSnapshot = true
            }
        }
        loadTask = task
        await task.value
    }
}
