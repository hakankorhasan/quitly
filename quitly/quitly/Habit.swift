//
//  Habit.swift
//  quitly
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var emoji: String
    var streakStart: Date
    var dailyCostAmount: Double
    var currencySymbol: String
    var isActive: Bool
    var createdAt: Date
    var goalMode: String = "quit"  // "quit", "less", "weekends"
    

    init(
        name: String,
        emoji: String = "flame.fill",
        streakStart: Date = Date(),
        dailyCostAmount: Double = 0.0,
        currencySymbol: String = "₺",
        goalMode: String = "quit"
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.streakStart = streakStart
        self.dailyCostAmount = dailyCostAmount
        self.currencySymbol = currencySymbol
        self.isActive = true
        self.createdAt = Date()
        self.goalMode = goalMode
    }

    // MARK: - Computed

    var streakDays: Int {
        let days = Calendar.current.dateComponents([.day], from: streakStart.dayStart, to: Date().dayStart).day ?? 0
        return max(0, days)
    }

    var streakHoursTotal: Double {
        max(0, Date().timeIntervalSince(streakStart) / 3600)
    }

    // MARK: - Hours Reclaimed (replaces money concept)
    /// Total hours of freedom since streak started
    var hoursReclaimed: Double {
        return streakHoursTotal
    }

    var formattedHoursReclaimed: String {
        let h = Int(hoursReclaimed)
        if h >= 1000 {
            return String(format: "%.1fK", Double(h) / 1000)
        }
        return "\(h)h"
    }

    // Legacy — kept for SwiftData schema compatibility, not shown in UI
    var moneySaved: Double { 0 }
    var formattedMoneySaved: String { formattedHoursReclaimed }

    var nextMilestoneHours: Double {
        let elapsed = streakHoursTotal
        let thresholds = HealthMilestone.all.map { $0.hours }
        return thresholds.first(where: { $0 > elapsed }) ?? thresholds.last!
    }

    var milestoneProgress: Double {
        let elapsed = streakHoursTotal
        let thresholds = [0.0] + HealthMilestone.all.map { $0.hours }
        guard let nextIdx = thresholds.firstIndex(where: { $0 > elapsed }), nextIdx > 0 else {
            return 1.0
        }
        let prev = thresholds[nextIdx - 1]
        let next = thresholds[nextIdx]
        return min(1.0, (elapsed - prev) / (next - prev))
    }
}

extension Date {
    var dayStart: Date { Calendar.current.startOfDay(for: self) }
}
