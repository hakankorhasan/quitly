//
//  MoneySavedView.swift
//  quitly
//
//  Repurposed as "Time Reclaimed" — hours of freedom since streak started
//

import SwiftUI

struct MoneySavedView: View {
    let habit: Habit

    private var hours: Int { Int(habit.hoursReclaimed) }
    private var days: Int { habit.streakDays }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.goldAccent.opacity(0.3), Color.amberGold.opacity(0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.goldAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("home_money_saved_title", comment: ""))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(habit.formattedHoursReclaimed)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(Color.goldAccent)
                        .contentTransition(.numericText(countsDown: false))
                    Text(NSLocalizedString("time_reclaimed_unit", comment: ""))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.goldAccent.opacity(0.7))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(NSLocalizedString("time_reclaimed_since", comment: ""))
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                Text("\(days) \(NSLocalizedString("home_day_unit", comment: ""))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(20)
        .glassCard()
    }
}
