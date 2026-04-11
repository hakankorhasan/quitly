//
//  TriggerLog.swift
//  quitly
//
//  Tracks why the user felt like drinking — used by Trigger Insight system.
//

import Foundation
import SwiftUI

// MARK: - Trigger Reason
enum TriggerReason: String, Codable, CaseIterable {
    case stress
    case social
    case bored
    case habit
    case celebration

    var label: String {
        switch self {
        case .stress:       return NSLocalizedString("trigger_stress", comment: "")
        case .social:       return NSLocalizedString("trigger_social", comment: "")
        case .bored:        return NSLocalizedString("trigger_bored", comment: "")
        case .habit:        return NSLocalizedString("trigger_habit", comment: "")
        case .celebration:  return NSLocalizedString("trigger_celebration", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .stress:       return "stress"
        case .social:       return "social-cheers"
        case .bored:        return "bored"
        case .habit:        return "routine"
        case .celebration:  return "party"
        }
    }

    var color: Color {
        switch self {
        case .stress:       return .red.opacity(0.8)
        case .social:       return .soberBlue
        case .bored:        return .textSecondary
        case .habit:        return .amberGold
        case .celebration:  return .greenClean
        }
    }
}

// MARK: - Trigger Log Entry
struct TriggerLog: Codable, Identifiable {
    var id: UUID
    var date: Date
    var reason: TriggerReason
    var habitId: UUID
    var context: String  // "stayStrong" or "relapse"

    init(reason: TriggerReason, habitId: UUID, context: String) {
        self.id = UUID()
        self.date = Date()
        self.reason = reason
        self.habitId = habitId
        self.context = context
    }
}

// MARK: - Trigger Store
final class TriggerStore {
    static let shared = TriggerStore()
    private let key = "quitly_trigger_logs"

    func save(log: TriggerLog) {
        var all = allLogs()
        all.append(log)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func allLogs() -> [TriggerLog] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let logs = try? JSONDecoder().decode([TriggerLog].self, from: data)
        else { return [] }
        return logs
    }

    func logs(for habitId: UUID) -> [TriggerLog] {
        allLogs()
            .filter { $0.habitId == habitId }
            .sorted { $0.date > $1.date }
    }

    func topTrigger(for habitId: UUID) -> TriggerReason? {
        let habitLogs = logs(for: habitId)
        guard habitLogs.count >= 3 else { return nil }
        let counts = Dictionary(grouping: habitLogs, by: { $0.reason })
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    func triggerCounts(for habitId: UUID) -> [(TriggerReason, Int)] {
        let habitLogs = logs(for: habitId)
        let counts = Dictionary(grouping: habitLogs, by: { $0.reason })
            .mapValues { $0.count }
        return TriggerReason.allCases
            .map { ($0, counts[$0] ?? 0) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }
}
