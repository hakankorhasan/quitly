//
//  TriggerInsightCardView.swift
//  quitly
//
//  Summary card for Insights tab: shows user's trigger overview. Tappable → TriggerDetailView.
//

import SwiftUI

struct TriggerInsightCardView: View {
    let habit: Habit
    @State private var topTrigger: TriggerReason? = nil
    @State private var counts: [(TriggerReason, Int)] = []
    @State private var totalLogs = 0
    @State private var showingDetail = false

    var body: some View {
        Group {
            if totalLogs > 0 {
                // Has data — show insight card
                Button {
                    showingDetail = true
                } label: {
                    insightContent
                }
                .buttonStyle(.plain)
            } else {
                // No data yet — show subtle prompt
                Button {
                    showingDetail = true
                } label: {
                    emptyPrompt
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear { loadData() }
        .onReceive(NotificationCenter.default.publisher(for: .relapseConfirmed)) { _ in
            loadData()
        }
        .sheet(isPresented: $showingDetail) {
            TriggerDetailView(habit: habit)
                .presentationBackground(Color.appBG)
        }
    }

    // MARK: - Insight Content (has data)
    private var insightContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.soberBlue)

                Text(NSLocalizedString("trigger_insight_title", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                HStack(spacing: 4) {
                    Text(String(format: NSLocalizedString("trigger_detail_total", comment: ""), totalLogs))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.soberBlue)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.soberBlue.opacity(0.6))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.soberBlue.opacity(0.12))
                .clipShape(Capsule())
            }

            // Main insight or mini breakdown
            if let top = topTrigger {
                HStack(spacing: 12) {
                    Image(top.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: NSLocalizedString("trigger_insight_main", comment: ""),
                                    top.label.lowercased()))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineSpacing(3)
                    }
                }
            }

            // Mini bar breakdown (top 3)
            if counts.count > 0 {
                let maxCount = counts.first?.1 ?? 1
                VStack(spacing: 6) {
                    ForEach(counts.prefix(3), id: \.0) { reason, count in
                        HStack(spacing: 10) {
                            Image(reason.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .frame(width: 22)

                            Text(reason.label)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 80, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.04))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(reason.color.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount))
                                }
                            }
                            .frame(height: 8)

                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.textMuted)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
                .padding(.top, 4)
            }

            // Tap hint
            HStack {
                Spacer()
                Text(NSLocalizedString("trigger_detail_tap_more", comment: ""))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.soberBlue.opacity(0.7))
                Image(systemName: "arrow.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.soberBlue.opacity(0.5))
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.soberBlue.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Empty Prompt (no data)
    private var emptyPrompt: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.soberBlue.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.soberBlue.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(NSLocalizedString("trigger_insight_title", comment: ""))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(NSLocalizedString("trigger_detail_empty_card", comment: ""))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textMuted)
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.soberBlue.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Load
    private func loadData() {
        topTrigger = TriggerStore.shared.topTrigger(for: habit.id)
        counts = TriggerStore.shared.triggerCounts(for: habit.id)
        totalLogs = TriggerStore.shared.logs(for: habit.id).count
    }
}
