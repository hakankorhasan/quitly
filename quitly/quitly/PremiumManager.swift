//
//  PremiumManager.swift
//  quitly
//
//  Central source of truth for premium state, paywall trigger, and streak protection.
//

import Foundation
import SwiftUI

@Observable
final class PremiumManager {

    // MARK: - Persisted State
    var isPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "premium_unlocked") }
        set { UserDefaults.standard.set(newValue, forKey: "premium_unlocked") }
    }

    /// Whether the paywall was already shown once (so we don't show it again)
    var paywallShownOnce: Bool {
        get { UserDefaults.standard.bool(forKey: "paywall_shown_once") }
        set { UserDefaults.standard.set(newValue, forKey: "paywall_shown_once") }
    }

    /// Grace period start date — set when user sees paywall but doesn't buy
    var gracePeriodStart: Date? {
        get { UserDefaults.standard.object(forKey: "grace_period_start") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "grace_period_start") }
    }

    // MARK: - Constants
    private let streakTriggerDays = 3        // Show paywall after this many streak days
    private let gracePeriodDays   = 4        // Free extension after skipping paywall

    // MARK: - Computed

    /// Is widget accessible? Free for first 3 streak days, then premium-only.
    func isWidgetEnabled(streakDays: Int) -> Bool {
        if isPremium { return true }
        return streakDays < streakTriggerDays   // 0,1,2 = free trial; 3+ = locked
    }

    /// Should we show the paywall RIGHT NOW?
    func shouldTriggerPaywall(streakDays: Int) -> Bool {
        guard !isPremium else { return false }          // Already premium
        guard !paywallShownOnce else { return false }   // Already shown once
        return streakDays >= streakTriggerDays
    }

    /// Is user in grace period (skipped paywall, still getting free streak)?
    var isInGracePeriod: Bool {
        guard !isPremium, let start = gracePeriodStart else { return false }
        let daysSinceSkip = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return daysSinceSkip < gracePeriodDays
    }

    /// Days remaining in grace period
    var graceDaysRemaining: Int {
        guard let start = gracePeriodStart else { return 0 }
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, gracePeriodDays - elapsed)
    }

    /// Should we show the subtle reminder banner?
    var shouldShowReminderBanner: Bool {
        guard !isPremium else { return false }
        return isInGracePeriod
    }

    // MARK: - Actions

    /// Called when user sees the paywall and dismisses without buying
    func onPaywallSkipped() {
        paywallShownOnce = true
        if gracePeriodStart == nil {
            gracePeriodStart = Date()
        }
    }

    /// Called when user successfully purchases premium
    func onPremiumPurchased() {
        isPremium = true
        paywallShownOnce = true
        gracePeriodStart = nil
    }

    /// Called when user taps "Restore Purchases"
    func onRestorePurchases() {
        // TODO: Wire RevenueCat restore here
        // For now, simulate success
        onPremiumPurchased()
    }

    /// Mark paywall as shown (so we record the trigger happened)
    func markPaywallShown() {
        paywallShownOnce = true
        if gracePeriodStart == nil {
            gracePeriodStart = Date()
        }
    }

    // MARK: - Debug

    func resetForDebug() {
        UserDefaults.standard.removeObject(forKey: "premium_unlocked")
        UserDefaults.standard.removeObject(forKey: "paywall_shown_once")
        UserDefaults.standard.removeObject(forKey: "grace_period_start")
    }
}
