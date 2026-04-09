//
//  MoneySavedView.swift
//  quitly
//

import SwiftUI

struct MoneySavedView: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppGradient.gold)
                    .frame(width: 48, height: 48)
                Image(systemName: "banknote.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("home_money_saved_title", comment: ""))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(habit.formattedMoneySaved)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Color.goldAccent)
                    .contentTransition(.numericText(countsDown: false))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(NSLocalizedString("home_daily_cost", comment: ""))
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                Text("\(Int(habit.dailyCostAmount))\(habit.currencySymbol)/\(NSLocalizedString("home_day_unit", comment: ""))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(20)
        .glassCard()
    }
}
