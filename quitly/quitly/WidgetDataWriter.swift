//
//  WidgetDataWriter.swift
//  quitly
//
//  Writes the active habit's data to the shared App Group UserDefaults
//  so the QuitlyWidget can read it. Also writes a `widgetLocked` flag
//  so the widget can show a "Premium required" screen when appropriate.
//

import Foundation
import WidgetKit

private let appGroupID      = "group.com.hakankorhasan.quitalcohol.QuitlyWidget"
private let userDefaultsKey = "quitly_widget_data"
private let lockedKey       = "quitly_widget_locked"

struct WidgetHabitData: Codable {
    var habitName: String
    var habitEmoji: String
    var streakStart: Date
    var dailyCostAmount: Double
    var currencySymbol: String
    
    // Pre-localized strings from main app
    var textDaysClean: String
    var textSaved: String
    var textKeepGoing: String
    var textGoPremium: String
    var textKeepWidget: String
}

func writeHabitToWidget(_ habit: Habit, premiumManager: PremiumManager) {
    guard let defaults = UserDefaults(suiteName: appGroupID) else {
        print("[Widget] ❌ App Group UserDefaults FAILED — check App Group entitlement: \(appGroupID)")
        return
    }

    // 1. Write habit data (with pre-localized strings)
    let daysString = habit.streakDays == 1 ? "widget_day_clean" : "widget_days_clean"
    
    let data = WidgetHabitData(
        habitName:      habit.name,
        habitEmoji:     habit.emoji,
        streakStart:    habit.streakStart,
        dailyCostAmount: habit.dailyCostAmount,
        currencySymbol: habit.currencySymbol,
        textDaysClean:  NSLocalizedString(daysString, comment: ""),
        textSaved:      NSLocalizedString("widget_saved", comment: ""),
        textKeepGoing:  NSLocalizedString("widget_keep_going", comment: ""),
        textGoPremium:  NSLocalizedString("widget_go_premium", comment: ""),
        textKeepWidget: NSLocalizedString("widget_keep_widget", comment: "")
    )
    if let encoded = try? JSONEncoder().encode(data) {
        defaults.set(encoded, forKey: userDefaultsKey)
        defaults.synchronize()  // Force flush to disk immediately
        print("[Widget] ✅ Wrote to App Group | currency: \(habit.currencySymbol) | streak: \(habit.streakDays)d | cost: \(habit.dailyCostAmount)")
    } else {
        print("[Widget] ❌ JSON encode FAILED")
    }

    // 2. Write lock flag
    let locked = !premiumManager.isWidgetEnabled
    defaults.set(locked, forKey: lockedKey)
    print("[Widget] locked: \(locked)")

    // 3. Reload widget timeline
    DispatchQueue.main.async {
        WidgetCenter.shared.reloadTimelines(ofKind: "QuitlyWidget")
        print("[Widget] Requested targeted timeline reload for QuitlyWidget")
    }
}
