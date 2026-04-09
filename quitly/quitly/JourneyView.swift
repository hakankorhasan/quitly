//
//  JourneyView.swift
//  quitly
//

import SwiftUI

struct JourneyView: View {
    @Bindable var habit: Habit
    @State private var showingRewardsStore = false

    var body: some View {
        ZStack(alignment: .top) {
            // Background glows
            Circle()
                .fill(Color.purpleAccent.opacity(0.07))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -60)

            Circle()
                .fill(Color.greenClean.opacity(0.07))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 100, y: 350)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("journey_tab_title", comment: ""))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text(NSLocalizedString("journey_tab_subtitle", comment: ""))
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        // Para tasarrufu özet kartı
                        MoneySavedView(habit: habit)

                        // Savings Chart
                        SavingsChartView(habit: habit)

                        // Sağlık Dönüm Noktaları
                        HealthMilestonesView(habit: habit)

                        // Ödül İlerleme Kartı
                        NextRewardProgressView(habit: habit)

                        // Ödül Mağazası Butonu (Ödül varsa göster)
                        if !habit.rewards.isEmpty {
                            rewardsStoreButton
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 56)
                }
            }
        }
        .sheet(isPresented: $showingRewardsStore) {
            RewardsStoreView(habit: habit)
        }
    }

    private var rewardsStoreButton: some View {
        Button {
            showingRewardsStore = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.greenClean.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: "gift.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.greenClean)
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
