import SwiftUI

/// Streak headline plus a contribution graph of daily dictation activity.
///
/// The graph is laid out the way calendar heatmaps conventionally are: one column
/// per week, weekdays running down each column, and month labels above the column
/// where each month starts. Paging moves a fixed-width window across the history.
struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    /// Days bucketed into calendar weeks once at init. `weeks` feeds the grid, the
    /// month labels and both paging checks, so recomputing it per access would walk
    /// a year of days several times on every render.
    private let weeks: [[DashboardDayActivity?]]

    /// Weeks visible at once before paging is needed.
    private static let visibleWeekCount = 18
    private static let cellSize: CGFloat = 11
    private static let cellSpacing: CGFloat = 3
    private static let weekdayLabelWidth: CGFloat = 28
    /// Columns a month label needs before the next one can be drawn without overlapping.
    private static let minimumMonthLabelGap = 3

    @State private var pageOffset = 0

    private var calendar: Calendar {
        DashboardPeriodWindows.dashboardCalendar()
    }

    init(currentStreak: Int, longestStreak: Int, dailyActivity: [DashboardDayActivity]) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak

        let calendar = DashboardPeriodWindows.dashboardCalendar()
        guard let first = dailyActivity.first else {
            self.weeks = []
            return
        }

        // Pad the leading and trailing partial weeks so every column holds seven
        // slots and weekdays line up across the whole graph.
        let leadingPad = (calendar.component(.weekday, from: first.date) - calendar.firstWeekday + 7) % 7
        var slots: [DashboardDayActivity?] = Array(repeating: nil, count: leadingPad)
        slots.append(contentsOf: dailyActivity.map { Optional($0) })
        if slots.count % 7 != 0 {
            slots.append(contentsOf: Array(repeating: nil, count: 7 - (slots.count % 7)))
        }
        self.weeks = stride(from: 0, to: slots.count, by: 7).map { Array(slots[$0..<$0 + 7]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if weeks.isEmpty {
                emptyState
            } else {
                graph
                legend
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandCardBackground(cornerRadius: 14))
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(currentStreak == 1 ? "1 day streak" : "\(currentStreak) day streak")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(BrandPalette.ink)

            Spacer(minLength: 12)

            Text("LONGEST STREAK | \(longestStreak) \(longestStreak == 1 ? "DAY" : "DAYS")")
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        Text("Dictate on any day to start a streak.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
    }

    // MARK: - Graph

    private var graph: some View {
        HStack(alignment: .top, spacing: 8) {
            pageButton(systemImage: "chevron.left", disabled: !canPageBackward) {
                pageOffset -= 1
            }

            VStack(alignment: .leading, spacing: 4) {
                monthLabels
                HStack(alignment: .top, spacing: Self.cellSpacing) {
                    weekdayLabels
                    ForEach(Array(visibleWeeks.enumerated()), id: \.offset) { _, week in
                        weekColumn(week)
                    }
                }
            }

            pageButton(systemImage: "chevron.right", disabled: !canPageForward) {
                pageOffset += 1
            }
        }
    }

    private func weekColumn(_ week: [DashboardDayActivity?]) -> some View {
        VStack(spacing: Self.cellSpacing) {
            ForEach(0..<7, id: \.self) { weekday in
                cell(week[weekday])
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: DashboardDayActivity?) -> some View {
        if let day {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(fill(for: day.intensity))
                .frame(width: Self.cellSize, height: Self.cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .strokeBorder(BrandPalette.ink.opacity(0.65), lineWidth: 1.2)
                        .opacity(day.isInCurrentStreak ? 1 : 0)
                )
                .help(tooltip(for: day))
        } else {
            // Padding cell before the first or after the last real day.
            Color.clear
                .frame(width: Self.cellSize, height: Self.cellSize)
        }
    }

    private func tooltip(for day: DashboardDayActivity) -> String {
        let date = day.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        guard day.isActive else { return "\(date) — no sessions" }
        let words = day.words == 1 ? "1 word" : "\(day.words) words"
        let sessions = day.sessions == 1 ? "1 session" : "\(day.sessions) sessions"
        return "\(date) — \(words) across \(sessions)"
    }

    private func fill(for intensity: Int) -> Color {
        switch intensity {
        case 4: return BrandPalette.accent
        case 3: return BrandPalette.accent.opacity(0.72)
        case 2: return BrandPalette.accent.opacity(0.48)
        case 1: return BrandPalette.accent.opacity(0.26)
        default: return BrandPalette.trackEmpty
        }
    }

    private var weekdayLabels: some View {
        VStack(spacing: Self.cellSpacing) {
            ForEach(0..<7, id: \.self) { weekday in
                Text(weekdayLabel(weekday))
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .frame(width: Self.weekdayLabelWidth, height: Self.cellSize, alignment: .leading)
            }
        }
    }

    /// Row labels follow the calendar's own first weekday, so a Monday-first
    /// locale reads Mon…Sun rather than being forced to Sun…Sat.
    private func weekdayLabel(_ row: Int) -> String {
        let symbols = calendar.shortWeekdaySymbols
        let index = (calendar.firstWeekday - 1 + row) % 7
        guard symbols.indices.contains(index) else { return "" }
        return symbols[index]
    }

    private var monthLabels: some View {
        // Labels are overlaid at their column's offset rather than laid out in the
        // grid, so a wide month name cannot push the columns out of alignment.
        ZStack(alignment: .topLeading) {
            Color.clear.frame(height: 11)
            ForEach(monthLabelPositions, id: \.column) { entry in
                Text(entry.title)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .offset(
                        x: Self.weekdayLabelWidth + Self.cellSpacing
                            + CGFloat(entry.column) * (Self.cellSize + Self.cellSpacing)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    /// The column index and title of each month boundary in the visible window.
    private var monthLabelPositions: [(column: Int, title: String)] {
        var result: [(column: Int, title: String)] = []
        var lastMonth: Int?

        for (index, week) in visibleWeeks.enumerated() {
            guard let firstDay = week.compactMap({ $0 }).first else { continue }
            let month = calendar.component(.month, from: firstDay.date)
            guard month != lastMonth else { continue }
            lastMonth = month

            // A month whose first column sits too close to the previous label would
            // overlap it, so it goes unlabelled rather than colliding.
            if let previous = result.last, index - previous.column < Self.minimumMonthLabelGap {
                continue
            }
            result.append(
                (column: index, title: firstDay.date.formatted(.dateTime.month(.abbreviated)))
            )
        }
        return result
    }

    private var legend: some View {
        HStack(spacing: 10) {
            Text("More")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)

            HStack(spacing: Self.cellSpacing) {
                ForEach([4, 3, 2, 1], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(fill(for: level))
                        .frame(width: Self.cellSize, height: Self.cellSize)
                }
            }

            Text("Less")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.clear)
                    .frame(width: Self.cellSize, height: Self.cellSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .strokeBorder(BrandPalette.ink.opacity(0.65), lineWidth: 1.2)
                    )
                Text("Current streak")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func pageButton(systemImage: String, disabled: Bool, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(disabled ? Color.secondary.opacity(0.35) : Color.secondary)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .padding(.top, 14)
    }

    // MARK: - Week bucketing

    private var visibleWeeks: [[DashboardDayActivity?]] {
        let all = weeks
        guard all.count > Self.visibleWeekCount else { return all }

        // pageOffset 0 shows the most recent window; negative pages go back in time.
        let end = max(Self.visibleWeekCount, min(all.count, all.count + pageOffset))
        let start = max(0, end - Self.visibleWeekCount)
        return Array(all[start..<end])
    }

    private var canPageBackward: Bool {
        weeks.count > Self.visibleWeekCount
            && (weeks.count + pageOffset - Self.visibleWeekCount) > 0
    }

    private var canPageForward: Bool {
        pageOffset < 0
    }
}
