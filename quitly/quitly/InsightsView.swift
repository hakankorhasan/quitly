//
//  InsightsView.swift
//  quitly
//

import SwiftUI

struct InsightsView: View {
    @Bindable var habit: Habit
    @Environment(PremiumManager.self) private var premiumManager
    @State private var showingRewardsStore = false
    @State private var showingPaywall = false
    
    var body: some View {
        GeometryReader { geo in
            let isSmall = geo.size.width < 380
            let hPad: CGFloat = isSmall ? 14 : 20

            ZStack(alignment: .top) {
                AppGradient.background.ignoresSafeArea()
                
                // Background glow blobs
                Circle()
                    .fill(Color.purpleAccent.opacity(0.12))
                    .frame(width: 340, height: 340)
                    .blur(radius: 90)
                    .offset(x: -80, y: -120)
                
                Circle()
                    .fill(Color.greenClean.opacity(0.10))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: 100, y: 300)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack(spacing: isSmall ? 10 : 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("insights_title", comment: ""))
                                    .font(.system(size: isSmall ? 18 : 20, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(NSLocalizedString("insights_subtitle", comment: ""))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, hPad)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            // FREE — Money saved + chart
                            MoneySavedView(habit: habit)
                            SavingsChartView(habit: habit)

                            if premiumManager.hasFullAccess {
                                // PREMIUM — all features
                                MiniCalendarView(habit: habit)
                                TriggerInsightCardView(habit: habit)
                                HealthMilestonesView(habit: habit)
                                NextRewardProgressView(habit: habit, onTap: {
                                    showingRewardsStore = true
                                })
                                if !habit.rewards.isEmpty {
                                    rewardsStoreButton
                                }
                                PreviousAttemptsView(habit: habit)
                            } else {
                                // LOCKED — unlock CTA
                                premiumUnlockCard
                            }
                        }
                        .padding(.horizontal, hPad)

                        Spacer().frame(height: 110)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRewardsStore) {
            RewardsStoreView(habit: habit)
                .presentationBackground(AppGradient.background)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Premium Unlock Card
    private var premiumUnlockCard: some View {
        Button { showingPaywall = true } label: {
            VStack(spacing: 16) {
                // Lock icon
                ZStack {
                    Circle()
                        .fill(Color.purpleAccent.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.purpleAccent)
                }

                VStack(spacing: 6) {
                    Text(NSLocalizedString("settings_go_premium", comment: ""))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(NSLocalizedString("insights_unlock_desc", comment: ""))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                // Feature list
                VStack(spacing: 8) {
                    lockedFeature(icon: "calendar", text: NSLocalizedString("insights_locked_calendar", comment: ""))
                    lockedFeature(icon: "brain.head.profile", text: NSLocalizedString("insights_locked_triggers", comment: ""))
                    lockedFeature(icon: "heart.text.square", text: NSLocalizedString("insights_locked_health", comment: ""))
                }

                // CTA button
                Text(NSLocalizedString("paywall_cta", comment: ""))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppGradient.fire)
                    )
            }
            .padding(20)
            .glassCard(cornerRadius: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.purpleAccent.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func lockedFeature(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.purpleAccent)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.textMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Rewards Store Button
    private var rewardsStoreButton: some View {
        Button {
            showingRewardsStore = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.greenClean.opacity(0.15)).frame(width: 40, height: 40)
                    Image("gift-box")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("rewards_store_title", comment: ""))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    let affordable = habit.rewards.filter { !$0.isPurchased && habit.moneySaved >= $0.price }.count
                    if affordable > 0 {
                        Text(String(format: NSLocalizedString("rewards_affordable_count", comment: ""), affordable))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.greenClean)
                    } else {
                        Text(NSLocalizedString("rewards_store_subtitle", comment: ""))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(16)
            .glassCard(cornerRadius: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.greenClean.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
