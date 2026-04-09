//
//  QuitlyWidget.swift
//  QuitlyWidget
//

import WidgetKit
import SwiftUI

// MARK: - Shared keys
private let appGroupID      = "group.com.quitly.QuitlyWidget"
private let userDefaultsKey = "quitly_widget_data"
private let lockedKey       = "quitly_widget_locked"

// MARK: - Colors (can't import DesignSystem in widget target)
private let bgTop    = Color(red: 0.051, green: 0.051, blue: 0.102)
private let bgBottom = Color(red: 0.102, green: 0.063, blue: 0.208)
private let orange   = Color(red: 1.0,   green: 0.42,  blue: 0.208)
private let purple   = Color(red: 0.659, green: 0.333, blue: 0.969)
private let green    = Color(red: 0.063, green: 0.725, blue: 0.506)
private let secondary = Color(red: 0.612, green: 0.639, blue: 0.686)

private let fireBG = LinearGradient(colors: [bgTop, bgBottom],
                                    startPoint: .topLeading, endPoint: .bottomTrailing)
private let fireGrad = LinearGradient(colors: [orange, purple],
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
private let moneyGrad = LinearGradient(colors: [orange, Color(red: 1.0, green: 0.239, blue: 0.0)],
                                       startPoint: .leading, endPoint: .trailing)

// MARK: - Widget Data Model
struct QuitlyWidgetData: Codable {
    var habitName: String
    var habitEmoji: String
    var streakStart: Date
    var dailyCostAmount: Double
    var currencySymbol: String
    
    // Pre-localized strings
    var textDaysClean: String
    var textSaved: String
    var textKeepGoing: String
    var textGoPremium: String
    var textKeepWidget: String

    // Placeholder shown before main app writes real data — shows 0 days.
    static var placeholder: QuitlyWidgetData {
        QuitlyWidgetData(
            habitName: NSLocalizedString("onboarding_smoking", bundle: .main, comment: ""),
            habitEmoji: "wind",
            streakStart: Date(),   // today = 0 days clean
            dailyCostAmount: 0.0,  // 0 cost until app runs
            currencySymbol: "₺",
            textDaysClean: NSLocalizedString("widget_days_clean", bundle: .main, comment: ""),
            textSaved: NSLocalizedString("widget_saved", bundle: .main, comment: ""),
            textKeepGoing: NSLocalizedString("widget_keep_going", bundle: .main, comment: ""),
            textGoPremium: NSLocalizedString("widget_go_premium", bundle: .main, comment: ""),
            textKeepWidget: NSLocalizedString("widget_keep_widget", bundle: .main, comment: "")
        )
    }
}

// MARK: - Timeline Entry
struct QuitlyEntry: TimelineEntry {
    let date: Date
    let data: QuitlyWidgetData
    var isLocked: Bool = false
}

// MARK: - Provider
struct QuitlyProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuitlyEntry {
        QuitlyEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuitlyEntry) -> Void) {
        completion(QuitlyEntry(date: .now, data: load() ?? .placeholder, isLocked: loadLocked()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuitlyEntry>) -> Void) {
        let data     = load() ?? .placeholder
        let locked   = loadLocked()
        let now      = Date()
        var entries: [QuitlyEntry] = []

        // One entry per hour for next 24h — widget recalculates streak at each entry.date
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            entries.append(QuitlyEntry(date: entryDate, data: data, isLocked: locked))
        }

        // After 24h, ask WidgetKit to call getTimeline again (picks up any new app data)
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func load() -> QuitlyWidgetData? {
        guard let ud  = UserDefaults(suiteName: appGroupID),
              let raw = ud.data(forKey: userDefaultsKey)
        else { return nil }

        // If decode fails (e.g. stale format from old build), clear the stale data
        // and return nil so placeholder is shown instead of garbage values.
        guard let data = try? JSONDecoder().decode(QuitlyWidgetData.self, from: raw) else {
            ud.removeObject(forKey: userDefaultsKey)
            return nil
        }
        return data
    }

    private func loadLocked() -> Bool {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: lockedKey) ?? false
    }
}

// MARK: - View Helpers
extension View {
    func computedStreakDays(start: Date, current: Date) -> Int {
        let startDay = Calendar.current.startOfDay(for: start)
        let currentDay = Calendar.current.startOfDay(for: current)
        let days = Calendar.current.dateComponents([.day], from: startDay, to: currentDay).day ?? 0
        return max(0, days)
    }
    
    func computedMoneySaved(start: Date, current: Date, costPerDay: Double) -> Double {
        let days = max(0, current.timeIntervalSince(start)) / 86400
        return days * costPerDay
    }
}

// MARK: - Small Widget (streak only)
struct QuitlySmallView: View {
    let data: QuitlyWidgetData
    let currentDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Habit badge
            HStack(spacing: 5) {
                Image(systemName: data.habitEmoji)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(fireGrad)
                Text(data.habitName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Big number
            let currentStreak = computedStreakDays(start: data.streakStart, current: currentDate)
            Text("\(currentStreak)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text(data.textDaysClean)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(moneyGrad)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }
}

// MARK: - Medium Widget (streak + money)
struct QuitlyMediumView: View {
    let data: QuitlyWidgetData
    let currentDate: Date

    var body: some View {
        HStack(spacing: 0) {
            // LEFT – streak
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: data.habitEmoji)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(fireGrad)
                    Text(data.habitName)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(secondary)
                        .lineLimit(1)
                }
                Spacer()
                
                let currentStreak = computedStreakDays(start: data.streakStart, current: currentDate)
                Text("\(currentStreak)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Text(data.textDaysClean)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(moneyGrad)
            }
            .padding(14)
            .frame(maxHeight: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
                .padding(.vertical, 14)

            // RIGHT – money
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(green)
                    Text(data.textSaved)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(secondary)
                }
                Spacer()
                Text(formattedMoney)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                HStack(spacing: 3) {
                    Text(data.textKeepGoing)
                    Image(systemName: "figure.strengthtraining.traditional")
                }
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(green)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private var formattedMoney: String {
        let a = computedMoneySaved(start: data.streakStart, current: currentDate, costPerDay: data.dailyCostAmount)
        return a >= 1000
            ? String(format: "%.1fK%@", a / 1000, data.currencySymbol)
            : "\(Int(a))\(data.currencySymbol)"
    }
}

// MARK: - Locked Widget View
struct QuitlyLockedView: View {
    let data: QuitlyWidgetData
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(orange)
            Text(data.textGoPremium)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(data.textKeepWidget)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Entry View
struct QuitlyWidgetEntryView: View {
    var entry: QuitlyProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.isLocked {
            QuitlyLockedView(data: entry.data)
        } else {
            switch family {
            case .systemSmall:  QuitlySmallView(data: entry.data, currentDate: entry.date)
            case .systemMedium: QuitlyMediumView(data: entry.data, currentDate: entry.date)
            default:            QuitlySmallView(data: entry.data, currentDate: entry.date)
            }
        }
    }
}

// MARK: - Widget Declaration
struct QuitlyWidget: Widget {
    let kind = "QuitlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuitlyProvider()) { entry in
            QuitlyWidgetEntryView(entry: entry)
                // ✅ Gradient goes here — system applies proper corner-radius & no white border
                .containerBackground(fireBG, for: .widget)
        }
        .configurationDisplayName("Quitly")
        .description(String(localized: "widget_description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    QuitlyWidget()
} timeline: {
    QuitlyEntry(date: .now, data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    QuitlyWidget()
} timeline: {
    QuitlyEntry(date: .now, data: .placeholder)
}
