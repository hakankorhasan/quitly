//
//  RelapseSheetView.swift
//  quitly
//

import SwiftUI

struct RelapseSheetView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.red.opacity(0.8))

            Spacer().frame(height: 20)

            Text(NSLocalizedString("relapse_title", comment: ""))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer().frame(height: 12)

            Text(NSLocalizedString("relapse_warning", comment: ""))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .lineSpacing(4)

            Spacer().frame(height: 36)

            // Current streak reminder
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppGradient.fire)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(habit.streakDays) \(NSLocalizedString("home_days_clean", comment: ""))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(NSLocalizedString("relapse_streak_reminder", comment: ""))
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
            }
            .padding(18)
            .glassCard()
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            VStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text(NSLocalizedString("relapse_cancel", comment: "").replacingOccurrences(of: " 💚", with: ""))
                        Image(systemName: "heart.fill")
                    }
                }
                .buttonStyle(OutlineButtonStyle(color: .greenClean))
                .padding(.horizontal, 24)

                Button(action: {
                    withAnimation { showConfirm = true }
                }) {
                    Text(NSLocalizedString("relapse_confirm", comment: ""))
                        .foregroundStyle(Color.textSecondary.opacity(0.7))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
            }

            Spacer().frame(height: 40)
        }
        .confirmationDialog(
            NSLocalizedString("relapse_confirm_title", comment: ""),
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("relapse_confirm_action", comment: ""), role: .destructive) {
                appState.confirmRelapse(habit: habit)
                dismiss()
            }
        } message: {
            Text(NSLocalizedString("relapse_confirm_subtitle", comment: ""))
        }
    }
}
