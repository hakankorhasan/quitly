//
//  AppState.swift
//  quitly
//

import SwiftUI

extension Notification.Name {
    static let relapseConfirmed = Notification.Name("quitly.relapseConfirmed")
}

@Observable
final class AppState {
    var showingRelapse = false
    var showingSettings = false
    var showingMotivation = false
    var motivationalQuote = ""
    var showingRelapseSupport = false
    var showingPaywall = false
    var showingUrgeMode = false
    var showingTriggerPicker = false
    var triggerContext = "stayStrong" // "stayStrong" or "relapse"
    var streakProtectedFeedback = false

    private var lastQuoteIndex = -1

    func stayStrong() {
        // Open Urge Mode instead of just showing a banner
        showingUrgeMode = true
    }

    /// Called after Urge Mode completes — shows the trigger picker
    func onUrgeModeComplete() {
        triggerContext = "stayStrong"
        showingTriggerPicker = true
    }

    func confirmRelapse(habit: Habit, premiumManager: PremiumManager) {
        // Mevcut streak'i kaydet
        let record = RelapseRecord(
            id: UUID(),
            habitId: habit.id,
            streakStart: habit.streakStart,
            relapseDate: Date(),
            streakDays: habit.streakDays
        )
        RelapseStore.shared.save(record: record)

        // Journey tab'ını haberdar et
        NotificationCenter.default.post(name: .relapseConfirmed, object: nil)

        // Streak Protection: Premium → -1 gün ceza, Free → tam sıfırlama
        if premiumManager.isPremium && habit.streakDays > 1 {
            // Streak -1 gün ceza: streakStart'ı 1 gün ileri al
            if let newStart = Calendar.current.date(byAdding: .day, value: 1, to: habit.streakStart) {
                habit.streakStart = newStart
            }
            streakProtectedFeedback = true
        } else {
            habit.streakStart = Date()
        }
        
        // Widget'ı DA güncelle ki anında eski streak'i yerine günceli göstersin
        writeHabitToWidget(habit, premiumManager: premiumManager)
        
        showingRelapse = false

        // Trigger picker for relapse
        triggerContext = "relapse"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.showingTriggerPicker = true
        }

        // Support banners
        if streakProtectedFeedback {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showingRelapseSupport = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                withAnimation(.easeOut) {
                    self?.showingRelapseSupport = false
                    self?.streakProtectedFeedback = false
                }
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showingRelapseSupport = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                withAnimation(.easeOut) { self?.showingRelapseSupport = false }
            }
        }
    }
}
