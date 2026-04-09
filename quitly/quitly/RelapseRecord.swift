//
//  RelapseRecord.swift
//  quitly
//
//  Her "Bozdum" sonrası kaydedilen deneme verisi — UserDefaults
//

import Foundation

struct RelapseRecord: Codable, Identifiable {
    var id: UUID
    var habitId: UUID
    var streakStart: Date   // Streak'in başladığı an
    var relapseDate: Date   // Bozulduğu an
    var streakDays: Int

    var totalSeconds: TimeInterval {
        relapseDate.timeIntervalSince(streakStart)
    }

    var durationLabel: String {
        let total = Int(totalSeconds)
        let days  = total / 86400
        let hours = (total % 86400) / 3600
        let mins  = (total % 3600) / 60

        if days > 0 {
            return "\(days)g \(hours)s \(mins)d"
        } else if hours > 0 {
            return "\(hours)s \(mins)d"
        } else {
            return "\(mins)d"
        }
    }

    var relapseDateLabel: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        fmt.locale = Locale.current
        return fmt.string(from: relapseDate)
    }
}

// MARK: - RelapseStore
final class RelapseStore {
    static let shared = RelapseStore()
    private let key = "quitly_relapse_records"

    func save(record: RelapseRecord) {
        var all = allRecords()
        all.append(record)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func allRecords() -> [RelapseRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([RelapseRecord].self, from: data)
        else { return [] }
        return records
    }

    func records(for habitId: UUID) -> [RelapseRecord] {
        allRecords()
            .filter { $0.habitId == habitId }
            .sorted { $0.relapseDate > $1.relapseDate } // En yeni önce
    }
}
