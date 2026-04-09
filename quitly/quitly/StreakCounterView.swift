//
//  StreakCounterView.swift
//  quitly
//

import SwiftUI

struct StreakCounterView: View {
    let habit: Habit
    @State private var flamePulse   = false
    @State private var ringAppear   = false
    @State private var appeared     = false
    @State private var glowPulse    = false
    @State private var countedDays  = 0

    private let ringSize:  CGFloat = 230
    private let lineWidth: CGFloat = 11

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer subtle track
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: lineWidth)
                    .frame(width: ringSize, height: ringSize)

                // Animated progress ring
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
                    .animation(
                        .spring(response: 1.4, dampingFraction: 0.7).delay(0.4),
                        value: ringAppear
                    )

                // Glow dot at ring head
                if ringAppear && habit.milestoneProgress > 0.01 {
                    let angle = (habit.milestoneProgress * 360 - 90) * .pi / 180
                    let radius = ringSize / 2
                    Circle()
                        .fill(Color.fireOrange)
                        .frame(width: lineWidth + 4, height: lineWidth + 4)
                        .shadow(color: Color.fireOrange.opacity(0.9), radius: 8)
                        .offset(
                            x: CGFloat(cos(angle)) * radius,
                            y: CGFloat(sin(angle)) * radius
                        )
                        .opacity(appeared ? 1 : 0)
                }

                // Radial glow inside ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.fireOrange.opacity(glowPulse ? 0.20 : 0.10),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 105
                        )
                    )
                    .frame(width: ringSize, height: ringSize)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

                // Center content
                VStack(spacing: 6) {
                    // Flame
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppGradient.fire)
                        .scaleEffect(flamePulse ? 1.12 : 1.0)
                        .shadow(color: Color.fireOrange.opacity(0.5), radius: 8)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: flamePulse
                        )

                    // Day count — counting-up animation
                    Text("\(countedDays)")
                        .font(.system(size: 76, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: Color.fireOrange.opacity(0.25), radius: 12)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: countedDays)

                    Text(habit.streakDays == 1
                         ? NSLocalizedString("home_day_clean", comment: "")
                         : NSLocalizedString("home_days_clean", comment: ""))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .opacity(appeared ? 1 : 0)
                }
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.80)
            .animation(.spring(response: 0.8, dampingFraction: 0.72), value: appeared)

            // Hours sub-label
            if habit.streakDays == 0 {
                let h = Int(habit.streakHoursTotal)
                Text(String(format: NSLocalizedString("home_hours_in", comment: ""), h))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            flamePulse = true
            glowPulse  = true

            // Staggered entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.72).delay(0.1)) {
                appeared = true
            }
            withAnimation(.spring(response: 1.4, dampingFraction: 0.7).delay(0.4)) {
                ringAppear = true
            }

            // Count-up from 0 to actual days
            animateCountUp()
        }
    }

    private func animateCountUp() {
        let target = habit.streakDays
        guard target > 0 else { countedDays = 0; return }

        // Duration for count-up: max 1.6s, min 0.3s
        let total = min(max(Double(target) * 0.06, 0.3), 1.6)
        let steps = min(target, 30)
        let interval = total / Double(steps)

        var current = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            current += max(1, target / steps)
            if current >= target {
                countedDays = target
                timer.invalidate()
            } else {
                countedDays = current
            }
        }
    }
}
