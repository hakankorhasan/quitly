//
//  RewardsStoreView.swift
//  quitly
//

import SwiftUI
import SwiftData

struct RewardsStoreView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddReward = false
    
    // Sort rewards: available first, then locked (by price), then purchased
    var sortedRewards: [Reward] {
        let money = habit.moneySaved
        return habit.rewards.sorted { r1, r2 in
            if r1.isPurchased != r2.isPurchased {
                return !r1.isPurchased && r2.isPurchased // Not purchased first
            }
            let r1Afford = money >= r1.price
            let r2Afford = money >= r2.price
            if r1Afford != r2Afford {
                return r1Afford && !r2Afford // Afford first
            }
            return r1.price < r2.price
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppGradient.background.ignoresSafeArea()
                
                // Glow effects
                Circle()
                    .fill(Color.greenClean.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -80, y: -50)
                
                Circle()
                    .fill(Color.purpleAccent.opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: 100, y: 300)
                
                VStack(spacing: 0) {
                    // Header Header
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("rewards_saved_total", comment: ""))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                        
                        Text(habit.formattedMoneySaved)
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.greenClean, .white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .greenClean.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if habit.rewards.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(sortedRewards) { reward in
                                    RewardCardView(reward: reward, habit: habit)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                modelContext.delete(reward)
                                                try? modelContext.save()
                                            } label: {
                                                Label(NSLocalizedString("settings_reset_data", comment: "Delete"), systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 100) // Scroll padding
                    }
                }
            }
            .navigationTitle(NSLocalizedString("rewards_store_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textSecondary)
                            .font(.system(size: 20))
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddReward = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.greenClean)
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingAddReward) {
                AddRewardSheet(habit: habit)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.cardBG)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(Color.textMuted)
            Text("No rewards yet!")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            Text("Add things you want to buy using your saved money.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Add Custom Reward") {
                showingAddReward = true
            }
            .buttonStyle(GhostButtonStyle())
            .padding(.top, 10)
        }
        .padding(.top, 60)
    }
}

// MARK: - Reward Card
struct RewardCardView: View {
    @Bindable var reward: Reward
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @State private var justClaimed = false
    
    var affordable: Bool {
        habit.moneySaved >= reward.price
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        reward.isPurchased ? Color.greenClean.opacity(0.2) :
                        (affordable ? Color.greenClean.opacity(0.15) : Color.textMuted.opacity(0.2))
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: reward.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        reward.isPurchased ? Color.greenClean :
                            (affordable ? Color.white : Color.textMuted)
                    )
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(reward.isPurchased ? Color.textSecondary : .white)
                    .strikethrough(reward.isPurchased, color: .textSecondary)
                
                if reward.isPurchased {
                    Text(NSLocalizedString("reward_purchased", comment: ""))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.greenClean)
                } else if affordable {
                    Text("\(Int(reward.price))\(habit.currencySymbol) • \(NSLocalizedString("reward_available", comment: ""))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.greenClean)
                } else {
                    Text("\(Int(reward.price))\(habit.currencySymbol) • \(NSLocalizedString("reward_locked", comment: ""))")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            
            Spacer()
            
            // Action Button
            if reward.isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.greenClean)
                    .scaleEffect(justClaimed ? 1.3 : 1.0)
            } else if affordable {
                Button {
                    claimReward()
                } label: {
                    Text(NSLocalizedString("reward_claim_action", comment: ""))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.greenClean)
                        .clipShape(Capsule())
                        .shadow(color: .greenClean.opacity(0.4), radius: 5, x: 0, y: 3)
                }
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardSurface.opacity(reward.isPurchased ? 0.3 : (affordable ? 0.8 : 0.4)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(affordable && !reward.isPurchased ? Color.greenClean.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
        )
        // Glow effect for affordable items
        .shadow(color: affordable && !reward.isPurchased ? Color.greenClean.opacity(0.15) : .clear, radius: 10, x: 0, y: 0)
    }
    
    private func claimReward() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            reward.isPurchased = true
            justClaimed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                justClaimed = false
            }
        }
        try? modelContext.save()
    }
}

// MARK: - Add Reward Sheet
struct AddRewardSheet: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var priceStr = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cardBG.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("reward_add_name", comment: ""))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                        
                        TextField("New Phone, Sneakers...", text: $title)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .padding(16)
                            .background(Color.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("reward_add_price", comment: ""))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                        
                        HStack {
                            Text(habit.currencySymbol)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                            TextField("0.00", text: $priceStr)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .padding(16)
                        .background(Color.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Spacer()
                    
                    Button {
                        saveReward()
                    } label: {
                        Text(NSLocalizedString("reward_add_save", comment: ""))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(title.isEmpty || priceStr.isEmpty ? Color.textMuted : Color.greenClean)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(title.isEmpty || priceStr.isEmpty)
                    .padding(.bottom, 16)
                }
                .padding(24)
            }
            .navigationTitle(NSLocalizedString("reward_add_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
    
    private func saveReward() {
        if let price = Double(priceStr.replacingOccurrences(of: ",", with: ".")) {
            let r = Reward(title: title, price: price)
            modelContext.insert(r)
            r.habit = habit
            try? modelContext.save()
            dismiss()
        }
    }
}
