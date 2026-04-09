//
//  HomeView.swift
//  quitly
//

import SwiftUI

struct HomeView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @State private var flamePulse = false
    @AppStorage("hasSeenWelcomeScreen") private var welcomeShown = false

    var body: some View {
        @Bindable var state = appState
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

            // Background glow blobs
            Circle()
                .fill(Color.fireOrange.opacity(0.08))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: 60, y: -120)

            Circle()
                .fill(Color.purpleAccent.opacity(0.07))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: -80, y: 400)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Image(systemName: habit.emoji)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(habit.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            Text(NSLocalizedString("home_your_journey", comment: ""))
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                        Button {
                            appState.showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 16)

                    // Streak Counter
                    StreakCounterView(habit: habit)
                        .padding(.top, 8)
                        .padding(.bottom, 32)

                    // Cards
                    VStack(spacing: 16) {
                        MoneySavedView(habit: habit)
                        SavingsChartView(habit: habit)
                        HealthMilestonesView(habit: habit)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 36)

                    // Action Buttons
                    VStack(spacing: 14) {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            appState.stayStrong()
                        } label: {
                            HStack(spacing: 8) {
                                Text(NSLocalizedString("home_stay_strong", comment: ""))
                                Image(systemName: "figure.strengthtraining.traditional")
                            }
                        }
                        .buttonStyle(FireButtonStyle())
                        .padding(.horizontal, 24)

                        Button(NSLocalizedString("home_i_slipped", comment: "")) {
                            appState.showingRelapse = true
                        }
                        .buttonStyle(GhostButtonStyle())
                    }

                    Spacer().frame(height: 56)
                }
            }

            // Motivation Banner
            if appState.showingMotivation {
                MotivationBannerView(quote: appState.motivationalQuote)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }

            // Relapse Support Banner
            if appState.showingRelapseSupport {
                VStack {
                    Spacer()
                    RelapseSuportBanner()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }

            // Welcome overlay — shown briefly on first open
            if !welcomeShown {
                WelcomeOverlay(habitName: habit.name, onDone: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        welcomeShown = true
                    }
                })
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.showingRelapseSupport)
        .sheet(isPresented: $state.showingRelapse) {
            RelapseSheetView(habit: habit)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.cardBG)
        }
        .sheet(isPresented: $state.showingSettings) {
            SettingsView(habit: habit)
                .presentationBackground(Color(red: 0.08, green: 0.08, blue: 0.13))
        }
    }
}

// MARK: - Welcome Overlay
private struct WelcomeOverlay: View {
    let habitName: String
    let onDone: () -> Void
    @State private var appeared = false
    @State private var flamePulse = false

    var body: some View {
        ZStack {
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()

            // Glow
            Circle()
                .fill(Color.fireOrange.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 80)

            VStack(spacing: 0) {
                Spacer()

                // Flame
                ZStack {
                    Circle()
                        .fill(Color.fireOrange.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppGradient.fire)
                        .scaleEffect(flamePulse ? 1.07 : 1.0)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: flamePulse)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.7)

                Spacer().frame(height: 32)

                Text(NSLocalizedString("home_welcome_title", comment: ""))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 12)

                Text(NSLocalizedString("home_welcome_subtitle", comment: ""))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                Spacer()

                Button(NSLocalizedString("home_welcome_cta", comment: ""), action: onDone)
                    .buttonStyle(FireButtonStyle())
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            flamePulse = true
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.3)) {
                appeared = true
            }
        }
    }
}

// MARK: - Relapse Support Banner
private struct RelapseSuportBanner: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "heart.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.purpleAccent)
            Text(NSLocalizedString("relapse_support_message", comment: ""))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}
