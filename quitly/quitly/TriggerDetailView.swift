//
//  TriggerDetailView.swift
//  quitly
//
//  Full trigger analysis screen — shows breakdown, history timeline, and patterns.
//

import SwiftUI

struct TriggerDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [TriggerLog] = []
    @State private var counts: [(TriggerReason, Int)] = []
    @State private var appeared = false

    private var totalLogs: Int { logs.count }

    var body: some View {
        ZStack {
            Color.appBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    header
                        .padding(.top, 16)

                    if logs.isEmpty {
                        emptyState
                    } else {
                        // Donut breakdown
                        triggerBreakdown
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)

                        // Top insight callout
                        if let top = counts.first {
                            topInsightBanner(reason: top.0, count: top.1)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)
                        }

                        // Context breakdown (Stay Strong vs Relapse)
                        contextBreakdown
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)

                        // Recent history timeline
                        recentTimeline
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            loadData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) {
                appeared = true
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("trigger_detail_title", comment: ""))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(NSLocalizedString("trigger_detail_subtitle", comment: ""))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.textSecondary.opacity(0.6))
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(Color.soberBlue.opacity(0.4))
            Text(NSLocalizedString("trigger_detail_empty", comment: ""))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            Text(NSLocalizedString("trigger_detail_empty_hint", comment: ""))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Trigger Breakdown (Visual Bars)
    private var triggerBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.soberBlue)
                Text(NSLocalizedString("trigger_detail_breakdown", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                Text(String(format: NSLocalizedString("trigger_detail_total", comment: ""), totalLogs))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.soberBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.soberBlue.opacity(0.12))
                    .clipShape(Capsule())
            }

            let maxCount = counts.first?.1 ?? 1
            ForEach(counts, id: \.0) { reason, count in
                HStack(spacing: 12) {
                    Image(reason.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(reason.label)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(count)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(reason.color)
                            Text("(\(percentage(count))%)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textMuted)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(reason.color)
                                    .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(.vertical, 4)
            }

            // Show all 5 reasons, including zeros
            let logged = Set(counts.map { $0.0 })
            let unused = TriggerReason.allCases.filter { !logged.contains($0) }
            if !unused.isEmpty {
                ForEach(unused, id: \.self) { reason in
                    HStack(spacing: 12) {
                        Image(reason.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .opacity(0.4)
                        Text(reason.label)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                        Spacer()
                        Text("0")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.soberBlue.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Top Insight Banner
    private func topInsightBanner(reason: TriggerReason, count: Int) -> some View {
        HStack(spacing: 14) {
            Image(reason.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(NSLocalizedString("trigger_detail_top_label", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .textCase(.uppercase)
                Text(String(format: NSLocalizedString("trigger_insight_main", comment: ""),
                            reason.label.lowercased()))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(reason.color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(reason.color.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Context Breakdown (Stay Strong vs Relapse)
    private var contextBreakdown: some View {
        let stayStrongCount = logs.filter { $0.context == "stayStrong" }.count
        let relapseCount = logs.filter { $0.context == "relapse" }.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.aquaTeal)
                Text(NSLocalizedString("trigger_detail_context", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            HStack(spacing: 12) {
                // Stay Strong
                contextCard(
                    icon: "shield.checkered",
                    color: .greenClean,
                    title: NSLocalizedString("trigger_detail_resisted", comment: ""),
                    count: stayStrongCount
                )

                // Relapse
                contextCard(
                    icon: "exclamationmark.triangle.fill",
                    color: .red.opacity(0.8),
                    title: NSLocalizedString("trigger_detail_slipped", comment: ""),
                    count: relapseCount
                )
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.aquaTeal.opacity(0.15), lineWidth: 1)
        )
    }

    private func contextCard(icon: String, color: Color, title: String, count: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(color)
            }
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Recent Timeline
    private var recentTimeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.purpleAccent)
                Text(NSLocalizedString("trigger_detail_recent", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            ForEach(Array(logs.prefix(15).enumerated()), id: \.element.id) { index, log in
                HStack(spacing: 14) {
                    // Timeline dot + line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(log.reason.color)
                            .frame(width: 10, height: 10)
                        if index < min(logs.count, 15) - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 1.5)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 10)

                    // Content
                    HStack(spacing: 10) {
                        Image(log.reason.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.reason.label)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(log.context == "stayStrong"
                                 ? NSLocalizedString("trigger_detail_resisted_label", comment: "")
                                 : NSLocalizedString("trigger_detail_slipped_label", comment: ""))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(log.context == "stayStrong" ? Color.greenClean : Color.red.opacity(0.8))
                        }

                        Spacer()

                        Text(timeAgo(log.date))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.025))
                    )
                }
                .frame(minHeight: 52)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.purpleAccent.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private func loadData() {
        logs = TriggerStore.shared.logs(for: habit.id)
        counts = TriggerStore.shared.triggerCounts(for: habit.id)
    }

    private func percentage(_ count: Int) -> Int {
        guard totalLogs > 0 else { return 0 }
        return Int(round(Double(count) / Double(totalLogs) * 100))
    }

    private func timeAgo(_ date: Date) -> String {
        let cal = Calendar.current
        let now = Date()
        let components = cal.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return String(format: NSLocalizedString("trigger_detail_days_ago", comment: ""), days)
        } else if let hours = components.hour, hours > 0 {
            return String(format: NSLocalizedString("trigger_detail_hours_ago", comment: ""), hours)
        } else if let mins = components.minute, mins > 0 {
            return String(format: NSLocalizedString("trigger_detail_mins_ago", comment: ""), mins)
        }
        return NSLocalizedString("trigger_detail_just_now", comment: "")
    }
}
