//
//  PreviousAttemptsView.swift
//  quitly
//
//  Journey sekmesinde gösterilen "Önceki Denemeler" kartı.
//

import SwiftUI

struct PreviousAttemptsView: View {
    let habit: Habit
    @State private var records: [RelapseRecord] = []
    @State private var isExpanded = false

    private var displayedRecords: [RelapseRecord] {
        isExpanded ? records : Array(records.prefix(3))
    }

    var body: some View {
        Group {
            if records.isEmpty {
                // Boş durum — kart yine de görünür
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.purpleAccent.opacity(0.10))
                            .frame(width: 44, height: 44)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.purpleAccent.opacity(0.7))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(NSLocalizedString("attempts_title", comment: ""))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(NSLocalizedString("attempts_empty", comment: ""))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                }
                .padding(18)
                .glassCard(cornerRadius: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.purpleAccent.opacity(0.15), lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    // Header
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.purpleAccent)

                        Text(NSLocalizedString("attempts_title", comment: ""))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        Spacer()

                        Text(String(format: NSLocalizedString("attempts_count", comment: ""), records.count))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.purpleAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.purpleAccent.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    // Best streak badge (en uzun deneme)
                    if let best = records.max(by: { $0.streakDays < $1.streakDays }), best.streakDays > 0 {
                        HStack(spacing: 10) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.goldAccent)
                            Text(String(format: NSLocalizedString("attempts_best", comment: ""),
                                        best.streakDays, best.durationLabel))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.goldAccent)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.goldAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // Rows
                    VStack(spacing: 10) {
                        ForEach(Array(displayedRecords.enumerated()), id: \.element.id) { idx, record in
                            AttemptRow(index: records.count - (records.firstIndex(where: { $0.id == record.id }) ?? 0),
                                       record: record)
                        }
                    }

                    // Show more / less
                    if records.count > 3 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(isExpanded
                                     ? NSLocalizedString("attempts_show_less", comment: "")
                                     : String(format: NSLocalizedString("attempts_show_more", comment: ""), records.count - 3))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.purpleAccent)
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.purpleAccent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.purpleAccent.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .glassCard(cornerRadius: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.purpleAccent.opacity(0.18), lineWidth: 1)
                )
            }
        }
        .onAppear {
            loadRecords()
        }
        .onReceive(NotificationCenter.default.publisher(for: .relapseConfirmed)) { _ in
            // Relapse kaydedildi → hemen yenile
            loadRecords()
        }
    }

    private func loadRecords() {
        records = RelapseStore.shared.records(for: habit.id)
    }
}

// MARK: - Attempt Row
private struct AttemptRow: View {
    let index: Int
    let record: RelapseRecord

    var body: some View {
        HStack(spacing: 14) {
            // Index badge
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 34, height: 34)
                Text("#\(index)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }

            // Duration info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image("burning_fire")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text(String(format: NSLocalizedString("attempts_row_days", comment: ""), record.streakDays))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Text(record.durationLabel)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            // Date
            Text(record.relapseDateLabel)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textMuted)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.025))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
