//
//  PaywallView.swift
//  quitly
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PremiumManager.self) private var premiumManager
    @State private var appeared = false
    @State private var showRestoreSuccess = false
    @State private var showRestoreFail = false

    private let features: [(icon: String, color: Color, title: String, subtitle: String)] = [
        ("crown.fill",              .goldAccent,   "paywall_feature_habits",   "paywall_feature_habits_desc"),
        ("shield.checkered",        .purpleAccent, "paywall_feature_streak",   "paywall_feature_streak_desc"),
        ("chart.bar.fill",          .greenClean,   "paywall_feature_insights", "paywall_feature_insights_desc"),
        ("rectangle.grid.2x2.fill", .purpleAccent, "paywall_feature_widgets",  "paywall_feature_widgets_desc"),
        ("shield.lefthalf.filled",  .goldAccent,   "paywall_feature_protection", "paywall_feature_protection_desc"),
    ]

    // Dinamik fiyat RevenueCat'ten, yoksa fallback
    private var localizedPrice: String {
        if let pkg = premiumManager.currentOffering?.availablePackages.first {
            return pkg.storeProduct.localizedPriceString
        }
        return NSLocalizedString("paywall_price", comment: "")
    }

    // Subscription duration derived from RevenueCat package type
    private var subscriptionDuration: String {
        guard let pkg = premiumManager.currentOffering?.availablePackages.first else {
            return NSLocalizedString("paywall_subscription_duration", comment: "")
        }
        switch pkg.packageType {
        case .monthly:  return NSLocalizedString("paywall_subscription_monthly", comment: "")
        case .annual:   return NSLocalizedString("paywall_subscription_annual", comment: "")
        case .weekly:   return NSLocalizedString("paywall_subscription_weekly", comment: "")
        default:        return NSLocalizedString("paywall_subscription_duration", comment: "")
        }
    }

    private let privacyURL = URL(string: "https://quitsmoking-2f3c7.web.app/privacy")!
    private let termsURL   = URL(string: "https://quitsmoking-2f3c7.web.app/terms")!

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.051, green: 0.051, blue: 0.102).ignoresSafeArea()

            // Glow blobs
            Circle()
                .fill(Color.fireOrange.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(y: -250)

            Circle()
                .fill(Color.purpleAccent.opacity(0.10))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 60, y: 200)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header: title left, close button right
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("paywall_headline", comment: ""))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)

                            Text(NSLocalizedString("paywall_subtitle", comment: ""))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                        }

                        Spacer()

                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.textSecondary.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer().frame(height: 32)


                    // Feature List
                    VStack(spacing: 16) {
                        ForEach(features.indices, id: \.self) { index in
                            let feature = features[index]
                            FeatureRow(
                                icon: feature.icon,
                                color: feature.color,
                                title: NSLocalizedString(feature.title, comment: ""),
                                subtitle: NSLocalizedString(feature.subtitle, comment: "")
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.08 + 0.3),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 44)

                    // Price info (RevenueCat'ten dinamik)
                    VStack(spacing: 6) {
                        // Subscription name + duration — required by App Store Guideline 3.1.2(c)
                        Text(subscriptionDuration)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.07))
                            .clipShape(Capsule())
                        Text(localizedPrice)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(NSLocalizedString("paywall_price_period", comment: ""))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 28)

                    // CTA Button
                    Button {
                        Task {
                            let success = await premiumManager.purchase()
                            if success { dismiss() }
                        }
                    } label: {
                        if premiumManager.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(height: 24)
                        } else {
                            HStack(spacing: 8) {
                                Image("splash-icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text(NSLocalizedString("paywall_cta", comment: ""))
                            }
                        }
                    }
                    .buttonStyle(FireButtonStyle())
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .disabled(premiumManager.isLoading)

                    // Error message
                    if let error = premiumManager.errorMessage {
                        Text(error)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 14)

                    // Skip
                    Button {
                        premiumManager.onPaywallSkipped()
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("paywall_skip", comment: ""))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                    }
                    .opacity(appeared ? 1 : 0)

                    // Restore + Terms
                    HStack(spacing: 16) {
                        Button(NSLocalizedString("paywall_restore", comment: "")) {
                            Task {
                                let success = await premiumManager.restorePurchases()
                                if success {
                                    showRestoreSuccess = true
                                } else {
                                    showRestoreFail = true
                                }
                            }
                        }
                        Text("•")
                        Button(NSLocalizedString("paywall_terms", comment: "")) {
                            UIApplication.shared.open(termsURL)
                        }
                        Text("•")
                        Button(NSLocalizedString("paywall_privacy", comment: "")) {
                            UIApplication.shared.open(privacyURL)
                        }
                    }
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, 16)

                    Spacer().frame(height: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
            Task {
                await premiumManager.fetchOffering()
            }
        }
        .alert("✅ Restore Successful", isPresented: $showRestoreSuccess) {
            Button("OK") { if premiumManager.isPremium { dismiss() } }
        } message: {
            Text("Your purchases have been restored.")
        }
        .alert("Nothing to Restore", isPresented: $showRestoreFail) {
            Button("OK") {}
        } message: {
            Text("No previous purchases found for this account.")
        }
    }
}

// MARK: - Feature Row
private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(color.opacity(0.7))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
