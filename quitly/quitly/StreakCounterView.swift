//
//  StreakCounterView.swift
//  quitly
//

import SwiftUI

struct StreakCounterView: View {
    let habit: Habit
    @State private var flamePulse = false
    @State private var ringAppear = false
    @State private var appeared = false

    private let ringSize: CGFloat = 220
    private let lineWidth: CGFloat = 10

    var body: some View {
        VStack(spacing: 24) {
            // Ring + Counter
            ZStack {
                // Track ring
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: lineWidth)
                    .frame(width: ringSize, height: ringSize)

                // Progress ring
                Circle()
                    .trim(from: 0, to: ringAppear ? habit.milestoneProgress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [Color.fireOrange, Color.purpleAccent, Color.fireOrange],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.75), value: ringAppear)

                // Glow behind ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.fireOrange.opacity(0.15), .clear],
                            center: .center, startRadius: 60, endRadius: 110
                        )
                    )
                    .frame(width: ringSize, height: ringSize)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(AppGradient.fire)
                        .scaleEffect(flamePulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: flamePulse)

                    Text("\(habit.streakDays)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(countsDown: false))
                        .shadow(color: Color.fireOrange.opacity(0.3), radius: 10)

                    Text(habit.streakDays == 1
                         ? NSLocalizedString("home_day_clean", comment: "")
                         : NSLocalizedString("home_days_clean", comment: ""))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.85)

            // Hours label
            if habit.streakDays == 0 {
                let h = Int(habit.streakHoursTotal)
                Text(String(format: NSLocalizedString("home_hours_in", comment: ""), h))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .onAppear {
            flamePulse = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                appeared = true
                ringAppear = true
            }
        }
    }
}
