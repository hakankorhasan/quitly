//
//  ReplacementActivity.swift
//  quitly
//
//  Model + store for replacement behaviors.
//  Stores user's custom list in UserDefaults (JSON), no SwiftData migration needed.
//

import Foundation
import SwiftUI

// MARK: - Model

struct ReplacementActivity: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var icon: String        // SF Symbol name
    var color: String       // hex or named color key
    var isCustom: Bool      // false = built-in default
    var isEnabled: Bool     // user can disable defaults

    // MARK: Built-in defaults
    static let defaults: [ReplacementActivity] = [
        ReplacementActivity(title: "Push-ups",          icon: "figure.strengthtraining.traditional", color: "fireOrange",    isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Cold Shower",        icon: "shower.fill",                          color: "aquaTeal",     isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Go for a Walk",     icon: "figure.walk",                           color: "greenClean",   isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Read a Book",        icon: "book.fill",                             color: "purpleAccent", isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Listen to Music",   icon: "music.note",                            color: "soberBlue",    isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Meditate",           icon: "brain.fill",                            color: "aquaTeal",     isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Deep Breathing",    icon: "wind",                                  color: "soberBlue",    isCustom: false, isEnabled: true),
        ReplacementActivity(title: "Call a Friend",     icon: "phone.fill",                            color: "greenClean",   isCustom: false, isEnabled: true),
    ]
}

// MARK: - Color helper

extension ReplacementActivity {
    var swiftUIColor: Color {
        switch color {
        case "fireOrange":   return .fireOrange
        case "aquaTeal":     return .aquaTeal
        case "greenClean":   return .greenClean
        case "purpleAccent": return .purpleAccent
        case "soberBlue":    return .soberBlue
        case "goldAccent":   return .goldAccent
        case "amberGold":    return .amberGold
        default:             return .purpleAccent
        }
    }

    static let colorOptions: [(name: String, color: Color, key: String)] = [
        ("Orange", .fireOrange,   "fireOrange"),
        ("Teal",   .aquaTeal,     "aquaTeal"),
        ("Green",  .greenClean,   "greenClean"),
        ("Purple", .purpleAccent, "purpleAccent"),
        ("Blue",   .soberBlue,    "soberBlue"),
        ("Gold",   .goldAccent,   "goldAccent"),
    ]
}

// MARK: - Store (Observable)

@Observable
final class ReplacementActivityStore {
    static let shared = ReplacementActivityStore()
    private let key = "replacement_activities_v1"

    private(set) var activities: [ReplacementActivity] = []

    private init() {
        load()
    }

    // MARK: - Computed

    var enabled: [ReplacementActivity] {
        activities.filter { $0.isEnabled }
    }

    // MARK: - Mutations

    func add(_ activity: ReplacementActivity) {
        activities.append(activity)
        save()
    }

    func remove(id: UUID) {
        activities.removeAll { $0.id == id && $0.isCustom }
        save()
    }

    func toggle(id: UUID) {
        guard let idx = activities.firstIndex(where: { $0.id == id }) else { return }
        activities[idx].isEnabled.toggle()
        save()
    }

    func moveUp(id: UUID) {
        guard let idx = activities.firstIndex(where: { $0.id == id }), idx > 0 else { return }
        activities.swapAt(idx, idx - 1)
        save()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ReplacementActivity].self, from: data) {
            activities = decoded
        } else {
            // First launch — seed defaults
            activities = ReplacementActivity.defaults
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
