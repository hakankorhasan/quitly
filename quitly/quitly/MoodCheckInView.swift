//
//  MoodCheckInView.swift
//  quitly
//

import SwiftUI

struct MoodCheckInView: View {
    let habit: Habit
    @State private var selectedMood: MoodEmoji?
    @State private var showConfirmation = false
    @State private var bounceIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.purpleAccent)

                Text(NSLocalizedString("mood_checkin_title", comment: ""))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                if selectedMood != nil {
                    Text(NSLocalizedString("mood_logged_today", comment: ""))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.greenClean)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.greenClean.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if showConfirmation, let mood = selectedMood {
                // Confirmation state
                HStack(spacing: 10) {
                    Image(mood.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.label)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(NSLocalizedString("mood_saved_message", comment: ""))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.greenClean)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                // Question + emoji picker
                Text(NSLocalizedString("mood_checkin_question", comment: ""))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 0) {
                    ForEach(Array(MoodEmoji.allCases.enumerated()), id: \.offset) { index, mood in
                        Button {
                            tapped(mood: mood, index: index)
                        } label: {
                            VStack(spacing: 5) {
                                Image(mood.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .scaleEffect(bounceIndex == index ? 1.35 : (selectedMood == mood ? 1.15 : 1.0))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bounceIndex)

                                Text(mood.label)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(selectedMood == mood ? Color.white : Color.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMood == mood
                                          ? Color.purpleAccent.opacity(0.2)
                                          : Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                selectedMood == mood
                                                    ? Color.purpleAccent.opacity(0.5)
                                                    : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .padding(.horizontal, 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.purpleAccent.opacity(0.18), lineWidth: 1)
        )
        .onAppear {
            selectedMood = MoodStore.shared.todayMood(for: habit.id)
            if selectedMood != nil {
                showConfirmation = true
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showConfirmation)
    }

    private func tapped(mood: MoodEmoji, index: Int) {
        guard selectedMood == nil else { return } // Günde bir kez
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        bounceIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { bounceIndex = nil }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedMood = mood
        }

        MoodStore.shared.saveMood(mood, for: habit.id)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showConfirmation = true
            }
        }
    }
}
