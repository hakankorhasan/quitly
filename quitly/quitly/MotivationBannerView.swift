//
//  MotivationBannerView.swift
//  quitly
//

import SwiftUI

struct MotivationBannerView: View {
    let quote: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundStyle(.white)
            Text(quote)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(3)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [Color.fireOrange.opacity(0.95), Color.purpleAccent.opacity(0.9)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .shadow(color: Color.fireOrange.opacity(0.4), radius: 12, x: 0, y: 4)
        )
        .padding(.top, 44) // below status bar
    }
}
