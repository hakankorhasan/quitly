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
    
    @Relationship(deleteRule: .cascade, inverse: \Reward.habit)
    var rewards: [Reward] = []

    init(
        name: String,
        emoji: String = "flame.fill",
        streakStart: Date = Date(),
        dailyCostAmount: Double = 0.0,
        currencySymbol: String = "₺"
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.streakStart = streakStart
        self.dailyCostAmount = dailyCostAmount
        self.currencySymbol = currencySymbol
        self.isActive = true
        self.createdAt = Date()
    }

    // MARK: - Computed

    var streakDays: Int {
        let days = Calendar.current.dateComponents([.day], from: streakStart.dayStart, to: Date().dayStart).day ?? 0
        return max(0, days)
    }

    var streakHoursTotal: Double {
        max(0, Date().timeIntervalSince(streakStart) / 3600)
    }

    var moneySaved: Double {
        return Double(streakDays) * dailyCostAmount
    }

    var formattedMoneySaved: String {
        let amount = moneySaved
        if amount >= 1000 {
            return String(format: "%.1fK%@", amount / 1000, currencySymbol)
        }
        return "\(Int(amount))\(currencySymbol)"
    }

    var nextMilestoneHours: Double {
        let elapsed = streakHoursTotal
        let thresholds: [Double] = [0.333, 8, 24, 48, 72, 168, 336, 720, 2160, 8760]
        return thresholds.first(where: { $0 > elapsed }) ?? 8760
    }

    var milestoneProgress: Double {
        let elapsed = streakHoursTotal
        let thresholds: [Double] = [0, 0.333, 8, 24, 48, 72, 168, 336, 720, 2160, 8760]
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
