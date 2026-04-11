//
//  MiniCalendarView.swift
//  quitly
//
//  35-day calendar grid showing sober (green) vs relapse (red) days.
//

import SwiftUI

struct MiniCalendarView: View {
    let habit: Habit
    @State private var relapseDates: Set<String> = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var days: [DayItem] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Start from 34 days ago → today = 35 days
        guard let startDate = cal.date(byAdding: .day, value: -34, to: today) else { return [] }

        // Align to start of week (Monday)
        let weekday = cal.component(.weekday, from: startDate)
        let offset = (weekday + 5) % 7  // Monday = 0
        guard let gridStart = cal.date(byAdding: .day, value: -offset, to: startDate) else { return [] }

        // Generate 42 days (6 weeks) for a nice grid
        var items: [DayItem] = []
        let streakStartDay = cal.startOfDay(for: habit.streakStart)

        for i in 0..<42 {
            guard let date = cal.date(byAdding: .day, value: i, to: gridStart) else { continue }
            let key = dateFormatter.string(from: date)
            let isToday = cal.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            let isBeforeStart = date < cal.startOfDay(for: habit.createdAt)
            let isRelapse = relapseDates.contains(key)

            let status: DayStatus
            if isFuture || isBeforeStart {
                status = .inactive
            } else if isRelapse {
                status = .relapse
            } else if date >= streakStartDay {
                status = .sober
            } else {
                // Before current streak — check if it was a sober day or unknown
                status = .pastUnknown
            }

            items.append(DayItem(date: date, day: cal.component(.day, from: date),
                                  isToday: isToday, status: status))
        }
        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.greenClean)

                Text(NSLocalizedString("calendar_title", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                // Legend
                HStack(spacing: 12) {
                    legendDot(color: .greenClean, label: NSLocalizedString("calendar_sober", comment: ""))
                    legendDot(color: .red.opacity(0.7), label: NSLocalizedString("calendar_slip", comment: ""))
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textMuted)
                        .frame(height: 16)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days) { item in
                    dayCell(item)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.greenClean.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            loadRelapseDates()
        }
        .onReceive(NotificationCenter.default.publisher(for: .relapseConfirmed)) { _ in
            loadRelapseDates()
        }
    }

    // MARK: - Day Cell
    @ViewBuilder
    private func dayCell(_ item: DayItem) -> some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 6)
                .fill(cellColor(for: item))
                .frame(height: 32)

            // Today ring
            if item.isToday {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.soberBlue, lineWidth: 2)
                    .frame(height: 32)
            }

            // Day number
            if item.status != .inactive {
                Text("\(item.day)")
                    .font(.system(size: 11, weight: item.isToday ? .bold : .medium, design: .rounded))
                    .foregroundStyle(textColor(for: item))
            } else {
                Text("\(item.day)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textMuted.opacity(0.3))
            }
        }
    }

    private func cellColor(for item: DayItem) -> Color {
        switch item.status {
        case .sober:       return Color.greenClean.opacity(0.18)
        case .relapse:     return Color.red.opacity(0.18)
        case .pastUnknown: return Color.white.opacity(0.03)
        case .inactive:    return Color.clear
        }
    }

    private func textColor(for item: DayItem) -> Color {
        switch item.status {
        case .sober:       return Color.greenClean
        case .relapse:     return Color.red
        case .pastUnknown: return Color.textMuted
        case .inactive:    return Color.textMuted.opacity(0.3)
        }
    }

    // MARK: - Legend
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textMuted)
        }
    }

    // MARK: - Helpers
    private var weekdayLabels: [String] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        // Reorder to Mon-Sun
        return Array(symbols[1...]) + [symbols[0]]
    }

    private func loadRelapseDates() {
        let records = RelapseStore.shared.records(for: habit.id)
        var dates = Set<String>()
        for record in records {
            dates.insert(dateFormatter.string(from: record.relapseDate))
        }
        relapseDates = dates
    }
}

// MARK: - Models
private enum DayStatus {
    case sober, relapse, pastUnknown, inactive
}

private struct DayItem: Identifiable {
    let id = UUID()
    let date: Date
    let day: Int
    let isToday: Bool
    let status: DayStatus
}
