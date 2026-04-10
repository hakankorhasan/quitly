//
//  PremiumManager.swift
//  quitly
//
//  Central source of truth for premium state, paywall trigger, and streak protection.
//  Wired to RevenueCat for real purchase/restore flow.
//

import Foundation
import SwiftUI
import RevenueCat

// MARK: - Constants
private let kEntitlement = "Quit Smoking Pro"
private let kOffering    = "Premium"
private let kPackage     = "$rc_monthly"

@Observable
final class PremiumManager {

    // MARK: - State
    var isPremium: Bool = false
    var isLoading: Bool = false
    var currentOffering: Offering? = nil
    var errorMessage: String? = nil

    /// Grace period start date — set when user sees paywall but doesn't buy
    var gracePeriodStart: Date? {
        get { UserDefaults.standard.object(forKey: "grace_period_start") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "grace_period_start") }
    }

    /// App installation/first-launch date
    var installDate: Date {
        if let exp = UserDefaults.standard.object(forKey: "install_date") as? Date {
            return exp
        } else {
            let now = Date()
            UserDefaults.standard.set(now, forKey: "install_date")
            return now
        }
    }

    // MARK: - Constants
    private let streakTriggerDays = 3
    private let gracePeriodDays   = 4

    // MARK: - Computed

    var isWidgetEnabled: Bool {
        if isPremium { return true }
        let daysPassed = Calendar.current.dateComponents([.day],
            from: Calendar.current.startOfDay(for: installDate),
            to:   Calendar.current.startOfDay(for: Date())).day ?? 0
        return daysPassed < 3
    }

    func shouldTriggerPaywall(streakDays: Int) -> Bool {
        guard !isPremium else { return false }
        return streakDays >= streakTriggerDays
    }

    var isInGracePeriod: Bool {
        guard !isPremium, let start = gracePeriodStart else { return false }
        let daysSinceSkip = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return daysSinceSkip < gracePeriodDays
    }

    var graceDaysRemaining: Int {
        guard let start = gracePeriodStart else { return 0 }
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, gracePeriodDays - elapsed)
    }

    var shouldShowReminderBanner: Bool {
        guard !isPremium else { return false }
        return isInGracePeriod
    }

    // MARK: - RevenueCat Actions

    /// Uygulama açıldığında ve paywallden önce çağır
    @MainActor
    func checkEntitlements() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements[kEntitlement]?.isActive == true
        } catch {
            print("[PremiumManager] checkEntitlements error: \(error)")
        }
    }

    /// Paywall için güncel offering'i yükle
    @MainActor
    func fetchOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.offering(identifier: kOffering) ?? offerings.current
        } catch {
            print("[PremiumManager] fetchOffering error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    /// Satın alma — paketi bul ve purchase et
    @MainActor
    func purchase() async -> Bool {
        guard let offering = currentOffering,
              let package = offering.package(identifier: kPackage) ?? offering.availablePackages.first
        else {
            errorMessage = "Product not found"
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            let active = result.customerInfo.entitlements[kEntitlement]?.isActive == true
            if active {
                isPremium = true
                gracePeriodStart = nil
            }
            return active
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Restore purchases
    @MainActor
    func restorePurchases() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            let active = info.entitlements[kEntitlement]?.isActive == true
            isPremium = active
            return active
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Paywall lifecycle

    func onPaywallSkipped() {
        if gracePeriodStart == nil {
            gracePeriodStart = Date()
        }
    }

    // MARK: - Debug

    func resetForDebug() {
        isPremium = false
        gracePeriodStart = nil
        UserDefaults.standard.removeObject(forKey: "grace_period_start")
    }
}
