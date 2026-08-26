import Foundation

/// Derives streak figures and contribution-graph cells from per-day session totals.
///
/// A day counts towards a streak when it contains at least one session, measured in
/// whole calendar days in the user's own time zone. The streak that is still running
/// survives a day that has not finished yet: if there is no session today but there
/// was one yesterday, the streak is alive and simply has not been extended.
struct StreakCalculation {
    /// How much history the contribution graph covers.
    static let graphDayCount = 371  // 53 whole weeks

    let currentStreak: Int
    let longestStreak: Int
    let activeDayCount: Int
    let hasSessionToday: Bool
    let dailyActivity: [DashboardDayActivity]

    init(
        wordsPerDay: [Date: Int],
        sessionsPerDay: [Date: Int],
        now: Date,
        calendar: Calendar
    ) {
        let todayStart = calendar.startOfDay(for: now)
        let activeDays = Set(sessionsPerDay.filter { $0.value > 0 }.keys)

        activeDayCount = activeDays.count
        hasSessionToday = activeDays.contains(todayStart)

        // Longest run of consecutive active days anywhere in history.
        var longest = 0
        var run = 0
        var previousDay: Date?
        for day in activeDays.sorted() {
            if let previousDay,
                let dayAfterPrevious = calendar.date(byAdding: .day, value: 1, to: previousDay),
                calendar.isDate(dayAfterPrevious, inSameDayAs: day)
            {
                run += 1
            } else {
                run = 1
            }
            longest = max(longest, run)
            previousDay = day
        }
        longestStreak = longest

        // Walk backwards from today (or yesterday, while today is still open).
        var streakDays: [Date] = []
        var cursor: Date? = activeDays.contains(todayStart)
            ? todayStart
            : calendar.date(byAdding: .day, value: -1, to: todayStart)

        while let day = cursor, activeDays.contains(day) {
            streakDays.append(day)
            cursor = calendar.date(byAdding: .day, value: -1, to: day)
        }
        currentStreak = streakDays.count
        let streakDaySet = Set(streakDays)

        // Four intensity steps scaled against the busiest day, so the ramp reads
        // correctly whether the user dictates 50 words a day or 5,000 — and so a
        // lone active day renders at full strength rather than the faintest shade.
        let busiestDay = wordsPerDay.filter { activeDays.contains($0.key) }.values.max() ?? 0

        // Emit a cell for every day in the window, including empty ones, so the
        // graph keeps a stable shape.
        guard
            let windowStart = calendar.date(
                byAdding: .day,
                value: -(Self.graphDayCount - 1),
                to: todayStart
            )
        else {
            dailyActivity = []
            return
        }

        var cells: [DashboardDayActivity] = []
        cells.reserveCapacity(Self.graphDayCount)
        var day = windowStart
        while day <= todayStart {
            let words = wordsPerDay[day] ?? 0
            let sessions = sessionsPerDay[day] ?? 0
            cells.append(
                DashboardDayActivity(
                    date: day,
                    words: words,
                    sessions: sessions,
                    intensity: sessions > 0 ? Self.intensity(for: words, busiestDay: busiestDay) : 0,
                    isInCurrentStreak: streakDaySet.contains(day)
                )
            )
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        dailyActivity = cells
    }

    /// Places a day on the four-step ramp relative to the busiest day recorded.
    /// Any active day is at least step 1, and the busiest day always reaches step 4.
    private static func intensity(for words: Int, busiestDay: Int) -> Int {
        guard busiestDay > 0 else { return 1 }
        let ratio = Double(words) / Double(busiestDay)
        if ratio > 0.75 { return 4 }
        if ratio > 0.50 { return 3 }
        if ratio > 0.25 { return 2 }
        return 1
    }
}
