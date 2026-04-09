//
//  PaywallView.swift
//  quitly
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var flamePulse = false

    private let features: [(icon: String, color: Color, title: String, subtitle: String)] = [
        ("crown.fill",           .goldAccent,   "paywall_feature_habits",   "paywall_feature_habits_desc"),
        ("shield.checkered",     .purpleAccent, "paywall_feature_streak",   "paywall_feature_streak_desc"),
        ("chart.bar.fill",       .greenClean,   "paywall_feature_insights", "paywall_feature_insights_desc"),
        ("paintbrush.fill",      .fireOrange,   "paywall_feature_themes",   "paywall_feature_themes_desc"),
        ("rectangle.grid.2x2.fill", .purpleAccent, "paywall_feature_widgets", "paywall_feature_widgets_desc"),
    ]

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

                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.textSecondary.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer().frame(height: 20)

                    // Hero Flame
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(Color.fireOrange.opacity(0.15))
                            .frame(width: 140, height: 140)
                            .blur(radius: 30)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.fireOrange, Color(red: 1.0, green: 0.239, blue: 0.0), .purpleAccent],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .scaleEffect(flamePulse ? 1.06 : 1.0)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: flamePulse)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    Spacer().frame(height: 24)

                    // Headline
                    Text(NSLocalizedString("paywall_headline", comment: ""))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)

                    Spacer().frame(height: 8)

                    // Subtitle
                    Text(NSLocalizedString("paywall_subtitle", comment: ""))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                    Spacer().frame(height: 32)

                    // Feature List
                    VStack(spacing: 12) {
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

                    Spacer().frame(height: 36)

                    // Price info
                    VStack(spacing: 4) {
                        Text(NSLocalizedString("paywall_price", comment: ""))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(NSLocalizedString("paywall_price_period", comment: ""))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 20)

                    // CTA Button
                    Button {
                        // TODO: RevenueCat purchase
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(NSLocalizedString("paywall_cta", comment: ""))
                        }
                    }
                    .buttonStyle(FireButtonStyle())
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                    Spacer().frame(height: 14)

                    // Skip
                    Button {
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
                            // TODO: RevenueCat restore
                        }
                        Text("•")
                        Button(NSLocalizedString("paywall_terms", comment: "")) {}
                        Text("•")
                        Button(NSLocalizedString("paywall_privacy", comment: "")) {}
                    }
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, 16)

                    Spacer().frame(height: 40)
                }
            }
        }
        .onAppear {
            flamePulse = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
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
