//
//  NextRewardProgressView.swift
//  quitly
//

import SwiftUI

struct NextRewardProgressView: View {
    let habit: Habit
    var onTap: (() -> Void)? = nil
    @State private var showingRewardsStore = false
    @State private var animateBar = false

    // Satın alınmamış, en ucuz ödül
    private var nextReward: Reward? {
        habit.rewards
            .filter { !$0.isPurchased }
            .sorted { $0.price < $1.price }
            .first
    }

    private var progress: Double {
        guard let reward = nextReward, reward.price > 0 else { return 0 }
        return min(1.0, habit.moneySaved / reward.price)
    }

    private var remaining: Double {
        guard let reward = nextReward else { return 0 }
        return max(0, reward.price - habit.moneySaved)
    }

    var body: some View {
        Button {
            if let onTap {
                onTap()
            } else {
                showingRewardsStore = true
            }
        } label: {
            VStack(spacing: 14) {
                if let reward = nextReward {
                    // Header
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.greenClean.opacity(0.15))
                                .frame(width: 38, height: 38)
                            Image("gift-box")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("next_reward_heading", comment: ""))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Text(reward.title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }

                        Spacer()

                        // Yüzde
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(progress >= 1.0 ? Color.greenClean : Color.goldAccent)
                    }

                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.07))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    progress >= 1.0
                                        ? LinearGradient(colors: [Color.greenClean, Color.greenClean.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.goldAccent, Color.fireOrange], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: animateBar ? geo.size.width * min(1.0, progress) : 0, height: 8)
                                .shadow(color: progress >= 1.0 ? Color.greenClean.opacity(0.5) : Color.goldAccent.opacity(0.4), radius: 4)
                        }
                    }
                    .frame(height: 8)

                    // Alt bilgi
                    HStack {
                        if progress >= 1.0 {
                            Label(NSLocalizedString("reward_available", comment: ""), systemImage: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.greenClean)
                        } else {
                            Text(String(format: NSLocalizedString("next_reward_remaining", comment: ""), Int(remaining), habit.currencySymbol))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        Text("\(Int(habit.moneySaved))\(habit.currencySymbol) / \(Int(reward.price))\(habit.currencySymbol)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                    }

                } else {
                    // Empty state
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.purpleAccent.opacity(0.12))
                                .frame(width: 38, height: 38)
                            Image("gift-box")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("rewards_store_title", comment: ""))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(NSLocalizedString("next_reward_empty", comment: ""))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
            .padding(18)
            .glassCard(cornerRadius: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        nextReward != nil
                            ? (progress >= 1.0 ? Color.greenClean.opacity(0.4) : Color.goldAccent.opacity(0.25))
                            : Color.purpleAccent.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeOut(duration: 1.1).delay(0.2)) {
                animateBar = true
            }
        }
        .sheet(isPresented: $showingRewardsStore) {
            RewardsStoreView(habit: habit)
                .presentationBackground(AppGradient.background)
        }
    }
}
