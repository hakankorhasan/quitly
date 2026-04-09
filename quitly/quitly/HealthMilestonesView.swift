//
//  HealthMilestonesView.swift
//  quitly
//

import SwiftUI

struct HealthMilestonesView: View {
    let habit: Habit

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(NSLocalizedString("home_health_journey", comment: ""))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                let unlocked = HealthMilestone.all.filter { habit.streakHoursTotal >= $0.hours }.count
                Text("\(unlocked)/\(HealthMilestone.all.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.greenClean)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(HealthMilestone.all) { milestone in
                        MilestoneCard(milestone: milestone, hoursElapsed: habit.streakHoursTotal)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
        .padding(20)
        .glassCard()
    }
}

private struct MilestoneCard: View {
    let milestone: HealthMilestone
    let hoursElapsed: Double

    private var isUnlocked: Bool { hoursElapsed >= milestone.hours }
    private var isNext: Bool {
        !isUnlocked &&
        HealthMilestone.all.first(where: { hoursElapsed < $0.hours })?.id == milestone.id
    }

    var body: some View {
        VStack(spacing: 10) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(isUnlocked
                          ? AnyShapeStyle(milestone.color.opacity(0.22))
                          : AnyShapeStyle(Color.white.opacity(0.04)))
                    .frame(width: 52, height: 52)

                if isUnlocked {
                    Circle()
                        .strokeBorder(milestone.color.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 52, height: 52)
                } else if isNext {
                    Circle()
                        .strokeBorder(Color.fireOrange.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 52, height: 52)
                }

                Image(systemName: milestone.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isUnlocked ? milestone.color : Color.textMuted)
                    .opacity(isUnlocked ? 1.0 : 0.6)
            }

            // Time label
            Text(milestone.timeLabel)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(isUnlocked ? milestone.color : (isNext ? .fireOrange : .textMuted))

            // Title
            Text(NSLocalizedString(milestone.titleKey, comment: ""))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(isUnlocked ? Color.textPrimary : Color.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 68)

            // Check or lock
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : (isNext ? "clock.fill" : "lock.fill"))
                .font(.system(size: 12))
                .foregroundStyle(isUnlocked ? milestone.color : (isNext ? .fireOrange : .textMuted))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(width: 84)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked
                      ? milestone.color.opacity(0.08)
                      : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isUnlocked ? milestone.color.opacity(0.2) : (isNext ? Color.fireOrange.opacity(0.3) : Color.clear),
                            lineWidth: 1
                        )
                )
        )
    }
}
