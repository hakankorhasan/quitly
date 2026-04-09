//
//  RelapseSheetView.swift
//  quitly
//

import SwiftUI

struct RelapseSheetView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @Environment(PremiumManager.self) private var premiumManager
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirm = false

    var body: some View {
        ZStack {
            // ── Uyarı ekranı ──────────────────────────────────────
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

                // Mevcut streak hatırlatıcısı
                HStack(spacing: 12) {
                    Image("burning_fire")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
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
                    // Devam et butonu
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

                    // Seriyi sıfırla → onay ekranına geç
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showConfirm = true
                        }
                    } label: {
                        Text(NSLocalizedString("relapse_confirm", comment: ""))
                            .foregroundStyle(Color.textSecondary.opacity(0.7))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                }

                Spacer().frame(height: 40)
            }
            .opacity(showConfirm ? 0 : 1)

            // ── Onay ekranı (confirmationDialog yerine inline) ────
            if showConfirm {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // Uyarı ikonu
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.red.opacity(0.9))
                    }

                    Spacer().frame(height: 24)

                    Text(NSLocalizedString("relapse_confirm_title", comment: ""))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer().frame(height: 10)

                    Text(NSLocalizedString("relapse_confirm_subtitle", comment: ""))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)

                    Spacer().frame(height: 40)

                    VStack(spacing: 14) {
                        // GERÇEK reset butonu
                        Button {
                            appState.confirmRelapse(habit: habit, premiumManager: premiumManager)
                            dismiss()
                        } label: {
                            Text(NSLocalizedString("relapse_confirm_action", comment: ""))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.red.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 24)

                        // Geri dön
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                showConfirm = false
                            }
                        } label: {
                            Text(NSLocalizedString("relapse_go_back", comment: ""))
                                .foregroundStyle(Color.textSecondary)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showConfirm)
    }
}
