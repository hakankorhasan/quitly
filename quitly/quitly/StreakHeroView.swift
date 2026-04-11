//
//  StreakHeroView.swift
//  quitly
//
//  Ana streak gösterimi: ortada gün circle'ı, solunda zaman sayacı, sağında tasarruf mini circle.
//

import SwiftUI
internal import Combine

struct StreakHeroView: View {
    let habit: Habit

    @State private var flamePulse  = false
    @State private var ringAppear  = false
    @State private var appeared    = false
    @State private var glowPulse   = false
    @State private var countedDays = 0
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let lineWidth: CGFloat = 9

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let safeW = w - 40 // Leave 20pt padding on both sides internally
            let ringSize: CGFloat = min(156, safeW * 0.42)
            let miniSize: CGFloat = min(90, safeW * 0.25)
            let hSpacing: CGFloat = max(8, safeW * 0.04)

            bodyContent(ringSize: ringSize, miniSize: miniSize, hSpacing: hSpacing)
                .frame(width: w)
        }
        .frame(height: 220)
    }

    private func bodyContent(ringSize: CGFloat, miniSize: CGFloat, hSpacing: CGFloat) -> some View {
        VStack(spacing: 8) {
            // ── Hero Row ─────────────────────────────────────────
            HStack(alignment: .bottom, spacing: hSpacing) {

                // ── Left mini: Time counter ───────────────────────
                miniCircle(
                    topLabel: timeTopLabel,
                    bigValue: timeBigValue,
                    bottomLabel: timeBottomLabel,
                    color: Color.purpleAccent,
                    systemImage: "timer",
                    miniSize: miniSize
                )

                // ── Center: Main streak ring ──────────────────────
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: lineWidth)
                        .frame(width: ringSize, height: ringSize)

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

                    // Glow dot
                    if ringAppear && habit.milestoneProgress > 0.01 {
                        let angle = (habit.milestoneProgress * 360 - 90) * .pi / 180
                        let radius = ringSize / 2
                        Circle()
                            .fill(Color.fireOrange)
                            .frame(width: lineWidth + 3, height: lineWidth + 3)
                            .shadow(color: Color.fireOrange.opacity(0.9), radius: 6)
                            .offset(
                                x: CGFloat(cos(angle)) * radius,
                                y: CGFloat(sin(angle)) * radius
                            )
                            .opacity(appeared ? 1 : 0)
                    }

                    // Radial inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.fireOrange.opacity(glowPulse ? 0.18 : 0.08),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 72
                            )
                        )
                        .frame(width: ringSize, height: ringSize)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

                    // Center content
                    VStack(spacing: 4) {
                        Image("cocktail")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .scaleEffect(flamePulse ? 1.08 : 1.0)
                            .shadow(color: Color.soberBlue.opacity(0.4), radius: 6)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: flamePulse
                            )

                        Text("\(countedDays)")
                            .font(.system(size: 54, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: Color.fireOrange.opacity(0.2), radius: 10)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: countedDays)

                        Text(habit.streakDays == 1
                             ? NSLocalizedString("home_day_clean", comment: "")
                             : NSLocalizedString("home_days_clean", comment: ""))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                            .opacity(appeared ? 1 : 0)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.80)
                .animation(.spring(response: 0.8, dampingFraction: 0.72), value: appeared)

                // ── Right mini: Money saved ───────────────────────
                miniCircle(
                    topLabel: NSLocalizedString("mini_money_label", comment: ""),
                    bigValue: habit.formattedMoneySaved,
                    bottomLabel: "\(Int(habit.dailyCostAmount))\(habit.currencySymbol)/\(NSLocalizedString("home_day_unit", comment: ""))",
                    color: Color.goldAccent,
                    imageName: "wallet",
                    miniSize: miniSize
                )
            }
            .padding(.horizontal, 10)

            // Hours sub-label (Day 0 durumu)
            if habit.streakDays == 0 {
                let h = Int(habit.streakHoursTotal)
                Text(String(format: NSLocalizedString("home_hours_in", comment: ""), h))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .opacity(appeared ? 1 : 0)
            }

            // Identity Line
            Text(identityLine)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .italic()
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.textSecondary.opacity(0.9), Color.textMuted],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .animation(.easeInOut(duration: 1.0).delay(0.8), value: appeared)
        }
        .onAppear {
            flamePulse = true
            glowPulse  = true
            currentTime = Date()

            withAnimation(.spring(response: 0.8, dampingFraction: 0.72).delay(0.1)) {
                appeared = true
            }
            withAnimation(.spring(response: 1.4, dampingFraction: 0.7).delay(0.4)) {
                ringAppear = true
            }
            animateCountUp()
        }
        .onReceive(timer) { t in
            currentTime = t
        }
    }

    // MARK: - Mini Circle
    @ViewBuilder
    private func miniCircle(
        topLabel: String,
        bigValue: String,
        bottomLabel: String,
        color: Color,
        systemImage: String? = nil,
        imageName: String? = nil,
        miniSize: CGFloat = 100
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.10))

                    .frame(width: miniSize, height: miniSize)
                    .overlay(
                        Circle()
                            .strokeBorder(color.opacity(0.25), lineWidth: 1.5)
                    )

                VStack(spacing: 2) {
                    if let sys = systemImage {
                        Image(systemName: sys)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(color.opacity(0.8))
                    } else if let img = imageName {
                        Image(img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .opacity(0.9)
                    }

                    Text(bigValue)
                        .font(.system(size: bigValue.count > 4 ? 13 : 17, weight: .black, design: .rounded))
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 6)

                    Text(topLabel)
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(color.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(0.3)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 4)
                }
            }

            Text(bottomLabel)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: miniSize)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.7)
        .animation(.spring(response: 0.8, dampingFraction: 0.72).delay(0.2), value: appeared)
    }

    // MARK: - Time labels
    private var elapsed: TimeInterval {
        max(0, currentTime.timeIntervalSince(habit.streakStart))
    }

    private var timeTopLabel: String {
        let d = Int(elapsed) / 86400
        let h = (Int(elapsed) % 86400) / 3600
        let m = (Int(elapsed) % 3600) / 60
        if d > 0 { return NSLocalizedString("mini_time_days", comment: "") }
        if h > 0 { return NSLocalizedString("mini_time_hours", comment: "") }
        return NSLocalizedString("mini_time_mins", comment: "")
    }

    private var timeBigValue: String {
        let d = Int(elapsed) / 86400
        let h = (Int(elapsed) % 86400) / 3600
        let m = (Int(elapsed) % 3600) / 60
        if d > 0 { return "\(d)" }
        if h > 0 { return "\(h)" }
        return "\(m)"
    }

    private var timeBottomLabel: String {
        let d = Int(elapsed) / 86400
        let h = (Int(elapsed) % 86400) / 3600
        let m = (Int(elapsed) % 3600) / 60
        let s = Int(elapsed) % 60

        if d > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        if h > 0 {
            return String(format: "%02d:%02d", m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Count-up animation
    private func animateCountUp() {
        let target = habit.streakDays
        guard target > 0 else { countedDays = 0; return }
        let total = min(max(Double(target) * 0.06, 0.3), 1.4)
        let steps = min(target, 25)
        let interval = total / Double(steps)
        var current = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            current += max(1, target / steps)
            if current >= target {
                countedDays = target
                t.invalidate()
            } else {
                countedDays = current
            }
        }
    }

    // MARK: - Identity Line
    private var identityLine: String {
        let days = habit.streakDays
        switch days {
        case 0:      return NSLocalizedString("identity_day0", comment: "")
        case 1...3:  return NSLocalizedString("identity_day1_3", comment: "")
        case 4...7:  return NSLocalizedString("identity_day4_7", comment: "")
        case 8...14: return NSLocalizedString("identity_day8_14", comment: "")
        case 15...30: return NSLocalizedString("identity_day15_30", comment: "")
        default:     return NSLocalizedString("identity_day30plus", comment: "")
        }
    }
}
