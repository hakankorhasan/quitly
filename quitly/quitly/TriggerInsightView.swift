//
//  TriggerInsightView.swift
//  quitly
//
//  Bottom sheet that asks "Why did you feel like drinking?" after Stay Strong or Relapse.
//

import SwiftUI

struct TriggerInsightView: View {
    let habitId: UUID
    let context: String  // "stayStrong" or "relapse"
    @Environment(\.dismiss) private var dismiss
    @State private var selected: TriggerReason? = nil
    @State private var saved = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            Spacer().frame(height: 28)

            // Header
            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.soberBlue, .aquaTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(NSLocalizedString("trigger_question", comment: ""))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(NSLocalizedString("trigger_subtitle", comment: ""))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)

            Spacer().frame(height: 16)

            if saved, let reason = selected {
                // Saved state
                Spacer()
                VStack(spacing: 14) {
                    Image(reason.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    Text(NSLocalizedString("trigger_saved", comment: ""))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.greenClean)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.greenClean)
                }
                .transition(.scale.combined(with: .opacity))
                Spacer()
            } else {
                Spacer().frame(height: 8)
                // Option grid
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(TriggerReason.allCases, id: \.self) { reason in
                            let isSelected = selected == reason
                            Button {
                                let gen = UIImpactFeedbackGenerator(style: .medium)
                                gen.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selected = reason
                                }
                                // Save after brief delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    let log = TriggerLog(reason: reason, habitId: habitId, context: context)
                                    TriggerStore.shared.save(log: log)
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        saved = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(reason.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .frame(width: 40)

                                    Text(reason.label)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(reason.color)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isSelected ? reason.color.opacity(0.12) : Color.cardBG)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(
                                                    isSelected ? reason.color.opacity(0.5) : Color.white.opacity(0.08),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(selected != nil)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }

            // Skip button
            if !saved {
                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("trigger_skip", comment: ""))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.bottom, 36)
                .padding(.top, 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: saved)
    }
}
