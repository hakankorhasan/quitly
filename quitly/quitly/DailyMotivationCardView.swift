//
//  DailyMotivationCardView.swift
//  quitly
//

import SwiftUI

struct DailyMotivationCardView: View {
    @State private var isExpanded = false

    // Günün ordinali ile deterministik söz seçimi (her gün değişir, app restart'ta sabit kalır)
    private var dailyQuote: String {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let index = dayIndex % 200
        return NSLocalizedString("mq_quote_\(index)", comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.purpleAccent)

                Text(NSLocalizedString("motivation_daily_title", comment: "Daily Motivation"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                // Gün badge
                Text(todayLabel)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.purpleAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.purpleAccent.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(dailyQuote)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut(duration: 0.25), value: isExpanded)

            if dailyQuote.count > 120 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded
                         ? NSLocalizedString("motivation_show_less", comment: "Show less")
                         : NSLocalizedString("motivation_show_more", comment: "Show more"))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.purpleAccent)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.purpleAccent.opacity(0.18), lineWidth: 1)
        )
    }

    private var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date())
    }
}
