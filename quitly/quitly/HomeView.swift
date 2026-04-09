//
//  HomeView.swift
//  quitly
//

import SwiftUI

struct HomeView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @State private var flamePulse = false

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
