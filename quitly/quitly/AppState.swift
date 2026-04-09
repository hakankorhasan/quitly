//
//  AppState.swift
//  quitly
//

import SwiftUI

@Observable
final class AppState {
    var showingRelapse = false
    var showingSettings = false
    var showingMotivation = false
    var motivationalQuote = ""
    var showingRelapseSupport = false

    private let quoteKeys = (1...10).map { "motivation_\($0)" }
    private var lastQuoteIndex = -1

    func stayStrong() {
        var idx: Int
        repeat { idx = Int.random(in: 0..<quoteKeys.count) } while idx == lastQuoteIndex
        lastQuoteIndex = idx
        motivationalQuote = NSLocalizedString(quoteKeys[idx], comment: "Motivational quote")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showingMotivation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) { self?.showingMotivation = false }
        }
    }

    func confirmRelapse(habit: Habit) {
        habit.streakStart = Date()
        showingRelapse = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showingRelapseSupport = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            withAnimation(.easeOut) { self?.showingRelapseSupport = false }
        }
    }
}
