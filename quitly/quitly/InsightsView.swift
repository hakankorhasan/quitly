//
//  InsightsView.swift
//  quitly
//

import SwiftUI

struct InsightsView: View {
    @Bindable var habit: Habit
    @State private var showingRewardsStore = false
    
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
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purpleAccent.opacity(0.25), Color.purpleAccent.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 42)

                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.purpleAccent)
                            }

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
                            // Para tasarrufu özet kartı
                            MoneySavedView(habit: habit)

                            // Savings Chart
                            SavingsChartView(habit: habit)

                            // Mini Calendar
                            MiniCalendarView(habit: habit)

                            // Trigger Insights
                            TriggerInsightCardView(habit: habit)

                            // Sağlık Dönüm Noktaları
                            HealthMilestonesView(habit: habit)

                            // Ödül İlerleme Kartı
                            NextRewardProgressView(habit: habit, onTap: {
                                showingRewardsStore = true
                            })

                            // Ödül Mağazası Butonu
                            if !habit.rewards.isEmpty {
                                rewardsStoreButton
                            }

                            // Önceki Denemeler (Relapse geçmişi)
                            PreviousAttemptsView(habit: habit)
                        }
                        .padding(.horizontal, hPad)

                        Spacer().frame(height: 110) // Tab bar clearance
                    }
                }
            }
        }
        .sheet(isPresented: $showingRewardsStore) {
            RewardsStoreView(habit: habit)
                .presentationBackground(AppGradient.background)
        }
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
