//
//  GoalModeSelectorView.swift
//  quitly
//
//  3-option goal picker: Quit completely / Drink less / Only weekends
//

import SwiftUI

struct GoalModeSelectorView: View {
    @Binding var selectedGoal: String

    private let goals: [(id: String, icon: String, titleKey: String, descKey: String, color: Color)] = [
        ("quit",     "nosign",          "goal_quit_title",     "goal_quit_desc",     .soberBlue),
        ("less",     "arrow.down.right", "goal_less_title",     "goal_less_desc",     .aquaTeal),
        ("weekends", "calendar",         "goal_weekends_title", "goal_weekends_desc", .amberGold),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(goals, id: \.id) { goal in
                let isSelected = selectedGoal == goal.id
                Button {
                    let gen = UIImpactFeedbackGenerator(style: .light)
                    gen.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedGoal = goal.id
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(goal.color.opacity(isSelected ? 0.25 : 0.10))
                                .frame(width: 42, height: 42)
                            Image(systemName: goal.icon)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(goal.color)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(NSLocalizedString(goal.titleKey, comment: ""))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(NSLocalizedString(goal.descKey, comment: ""))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .strokeBorder(isSelected ? goal.color : Color.white.opacity(0.15), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            if isSelected {
                                Circle()
                                    .fill(goal.color)
                                    .frame(width: 14, height: 14)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBG)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        isSelected ? goal.color.opacity(0.5) : Color.white.opacity(0.08),
                                        lineWidth: isSelected ? 1.5 : 1
                                    )
                            )
                            .shadow(color: isSelected ? goal.color.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
        }
    }
}
