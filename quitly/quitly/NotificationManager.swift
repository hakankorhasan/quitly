//
//  NotificationManager.swift
//  quitly
//
//  Local notification scheduling — no backend needed.
//  Uses UNUserNotificationCenter calendar triggers.
//  Reschedule on every app open so streak count stays fresh.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
    }

    // MARK: - Schedule All
    // Call this every time the app becomes active so streak count is fresh.

    func scheduleAll(streakDays: Int, dailyEnabled: Bool, weekendEnabled: Bool) {
        let center = UNUserNotificationCenter.current()

        // Cancel old ones first, then re-add fresh
        center.removeAllPendingNotificationRequests()

        guard dailyEnabled || weekendEnabled else { return }

        // Check permission before scheduling
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else { return }

            if dailyEnabled {
                self?.scheduleDailyMorning(streakDays: streakDays)
            }
            if weekendEnabled {
                self?.scheduleFridayEvening()
                self?.scheduleSaturdayNight(streakDays: streakDays)
            }
        }
    }

    // MARK: - Cancel All

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Private Triggers

    /// Her gün sabah 09:00 — "X days clean, keep going!"
    private func scheduleDailyMorning(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_morning_title", comment: "")
        content.body  = String(format: NSLocalizedString("notif_morning_body", comment: ""), streakDays)
        content.sound = .default

        var dc = DateComponents()
        dc.hour   = 9
        dc.minute = 0

        add(content: content, trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true),
            id: "notif_daily_morning")
    }

    /// Her Cuma 18:00 — hafta sonu uyarısı
    private func scheduleFridayEvening() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_friday_title", comment: "")
        content.body  = NSLocalizedString("notif_friday_body", comment: "")
        content.sound = .default

        var dc = DateComponents()
        dc.weekday = 6   // 1=Sun, 6=Fri
        dc.hour    = 18
        dc.minute  = 0

        add(content: content, trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true),
            id: "notif_friday_evening")
    }

    /// Her Cumartesi 20:00 — "don't break the chain tonight"
    private func scheduleSaturdayNight(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_saturday_title", comment: "")
        content.body  = String(format: NSLocalizedString("notif_saturday_body", comment: ""), streakDays)
        content.sound = .default

        var dc = DateComponents()
        dc.weekday = 7   // 1=Sun, 7=Sat
        dc.hour    = 20
        dc.minute  = 0

        add(content: content, trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true),
            id: "notif_saturday_night")
    }

    // MARK: - Helper

    private func add(content: UNMutableNotificationContent,
                     trigger: UNNotificationTrigger,
                     id: String) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("⚠️ Notification error [\(id)]: \(error)") }
        }
    // MARK: - DEV TEST — Remove before release
    func sendTestNotification(streakDays: Int = 7) {
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Notification"
        content.body  = "Good Morning ☀️ — You're \(streakDays) days clean. Keep going!"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "dev_test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("⚠️ Test notif error: \(error)") }
            else { print("✅ Scheduled — go to background now!") }
        }
    }
}
