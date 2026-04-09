//
//  MoodLog.swift
//  quitly
//
//  Local storage için Codable mood log modeli (UserDefaults)
//

import Foundation

enum MoodEmoji: String, Codable, CaseIterable {
    case excellent = "great"
    case good      = "good"
    case neutral   = "confused"
    case struggling = "hard"
    case rough     = "bad"

    var label: String {
        switch self {
        case .excellent:  return NSLocalizedString("mood_excellent", comment: "")
        case .good:       return NSLocalizedString("mood_good", comment: "")
        case .neutral:    return NSLocalizedString("mood_neutral", comment: "")
        case .struggling: return NSLocalizedString("mood_struggling", comment: "")
        case .rough:      return NSLocalizedString("mood_rough", comment: "")
        }
    }

    var color: String {
        switch self {
        case .excellent:  return "greenClean"
        case .good:       return "greenClean"
        case .neutral:    return "goldAccent"
        case .struggling: return "fireOrange"
        case .rough:      return "purpleAccent"
        }
    }
}

struct MoodLog: Codable, Identifiable {
    var id: UUID
    var date: Date
    var mood: MoodEmoji
    var habitId: UUID

    init(mood: MoodEmoji, habitId: UUID) {
        self.id = UUID()
        self.date = Date()
        self.mood = mood
        self.habitId = habitId
    }
}

// MARK: - MoodStore
final class MoodStore {
    static let shared = MoodStore()
    private let key = "quitly_mood_logs"

    func saveMood(_ mood: MoodEmoji, for habitId: UUID) {
        var logs = allLogs()
        let entry = MoodLog(mood: mood, habitId: habitId)
        logs.append(entry)
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func allLogs() -> [MoodLog] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let logs = try? JSONDecoder().decode([MoodLog].self, from: data)
        else { return [] }
        return logs
    }

    func todayMood(for habitId: UUID) -> MoodEmoji? {
        let today = Calendar.current.startOfDay(for: Date())
        return allLogs()
            .filter { $0.habitId == habitId && Calendar.current.startOfDay(for: $0.date) == today }
            .last?.mood
    }
}
