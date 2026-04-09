//
//  OnboardingView.swift
//  quitly
//

import SwiftUI

private let presetHabits: [(emoji: String, name: String, key: String)] = [
    ("wind", "Smoking",      "onboarding_smoking"),
    ("wineglass.fill", "Alcohol",      "onboarding_alcohol"),
    ("birthday.cake.fill", "Sugar",        "onboarding_sugar"),
    ("cup.and.saucer.fill", "Caffeine",    "onboarding_caffeine"),
    ("iphone", "Social Media", "onboarding_social_media"),
    ("pencil", "Custom",      "onboarding_custom"),
]

struct OnboardingView: View {
    var isAddingHabit: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var selectedHabit: (emoji: String, name: String, key: String)? = nil
    @State private var animateIn = false

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()
            
            if isAddingHabit {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding()
                    }
                    Spacer()
                }
                .zIndex(20)
            }
            
            // Glow blobs
            Circle()
                .fill(Color.fireOrange.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -60, y: -200)
            Circle()
                .fill(Color.purpleAccent.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 80, y: 300)

            TabView(selection: $page) {
                WelcomePageView(onNext: { withAnimation(.spring()) { page = 1 } })
                    .tag(0)
                HabitPickerPageView(
                    presets: presetHabits,
                    selected: $selectedHabit,
                    onNext: { withAnimation(.spring()) { page = 2 } }
                )
                .tag(1)
                HabitSetupView(
                    habit: selectedHabit ?? presetHabits[0]
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: page)

            // Page dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(page == i ? Color.fireOrange : Color.white.opacity(0.25))
                            .frame(width: page == i ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.bottom, 54)
            }
        }
    }
}

// MARK: - Page 1: Welcome
private struct WelcomePageView: View {
    let onNext: () -> Void
    @State private var flamePulse = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Flame
            Image(systemName: "flame.fill")
                .font(.system(size: 90))
                .foregroundStyle(AppGradient.fire)
                .scaleEffect(flamePulse ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: flamePulse)
                .onAppear { flamePulse = true }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)

            Spacer().frame(height: 32)

            Text(NSLocalizedString("app_name", comment: ""))
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 12)

            Text(NSLocalizedString("onboarding_tagline", comment: ""))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)

            Spacer()

            Button(NSLocalizedString("onboarding_get_started", comment: ""), action: onNext)
                .buttonStyle(FireButtonStyle())
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 100)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.2)) {
                appeared = true
            }
        }
    }
}

// MARK: - Page 2: Habit Picker
private struct HabitPickerPageView: View {
    let presets: [(emoji: String, name: String, key: String)]
    @Binding var selected: (emoji: String, name: String, key: String)?
    let onNext: () -> Void
    @State private var appeared = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)

            Text(NSLocalizedString("onboarding_pick_habit", comment: ""))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 32)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(presets.indices, id: \.self) { i in
                    let preset = presets[i]
                    let isSelected = selected?.name == preset.name
                    Button {
                        withAnimation(.spring(response: 0.3)) { selected = preset }
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: preset.emoji)
                                .font(.system(size: 32))
                                .foregroundStyle(isSelected ? AppGradient.fire : AppGradient.gold)
                            Text(NSLocalizedString(preset.key, comment: ""))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .white : Color.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isSelected ? Color.fireOrange.opacity(0.2) : Color.cardBG)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(
                                            isSelected ? Color.fireOrange : Color.white.opacity(0.07),
                                            lineWidth: isSelected ? 1.5 : 1
                                        )
                                )
                        )
                        .scaleEffect(isSelected ? 1.04 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(i) * 0.05 + 0.15), value: appeared)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                if selected == nil { selected = presets[0] }
                onNext()
            }) {
                Text("Continue →")
                    .padding(.trailing, 4)
            }
            .buttonStyle(FireButtonStyle())
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 100)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}
