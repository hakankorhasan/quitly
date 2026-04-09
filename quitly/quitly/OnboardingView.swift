//
//  OnboardingView.swift
//  quitly
//
//  Simplified: Smoking-only app. Welcome → Setup (2 pages).
//

import SwiftUI

struct OnboardingView: View {
    @State private var page = 0

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

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
                HabitSetupView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: page)

            // Page dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { i in
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
            ZStack {
                Circle()
                    .fill(Color.fireOrange.opacity(0.18))
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)
                Image("burning_fire")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .scaleEffect(flamePulse ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: flamePulse)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            .onAppear { flamePulse = true }

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
