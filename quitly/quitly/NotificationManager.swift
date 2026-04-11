//
//  NotificationManager.swift
//  quitly
//
//  Smart time-based notifications for alcohol recovery.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Permission
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Schedule All
    func scheduleAll(streakDays: Int, dailyEnabled: Bool, weekendEnabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        if dailyEnabled {
            scheduleDailyMorning(streakDays: streakDays)
        }
        if weekendEnabled {
            scheduleFridayEvening(streakDays: streakDays)
            scheduleSaturdayNight(streakDays: streakDays)
        }
    }

    // MARK: - Daily Morning (09:00)
    private func scheduleDailyMorning(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_morning_title", comment: "")
        content.body = String(format: NSLocalizedString("notif_morning_body", comment: ""), streakDays)
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_morning", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Friday Evening (18:00)
    private func scheduleFridayEvening(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_friday_title", comment: "")
        content.body = NSLocalizedString("notif_friday_body", comment: "")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 6  // Friday
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "friday_evening", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Saturday Night (20:00)
    private func scheduleSaturdayNight(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_saturday_title", comment: "")
        content.body = String(format: NSLocalizedString("notif_saturday_body", comment: ""), streakDays)
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 7  // Saturday
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "saturday_night", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel All
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
