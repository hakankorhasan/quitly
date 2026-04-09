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

    private var lastQuoteIndex = -1

    func stayStrong() {
        motivationalQuote = MotivationEngine.shared.getRandomQuote()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showingMotivation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) { self?.showingMotivation = false }
        }
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

        // Streak'i sıfırla
        habit.streakStart = Date()
        
        // Widget'ı DA güncelle ki anında eski streak'i yerine 0 göstersin
        writeHabitToWidget(habit, premiumManager: premiumManager)
        
        showingRelapse = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showingRelapseSupport = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            withAnimation(.easeOut) { self?.showingRelapseSupport = false }
        }
    }
}
