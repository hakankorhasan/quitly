//
//  HomeView.swift
//  quitly
//

import SwiftUI

struct HomeView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @State private var showingRewardsStore = false

    var body: some View {
        @Bindable var state = appState
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

            // Background glow blobs
            Circle()
                .fill(Color.fireOrange.opacity(0.09))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: 70, y: -130)

            Circle()
                .fill(Color.purpleAccent.opacity(0.07))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: -90, y: 420)

            Circle()
                .fill(Color.goldAccent.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 120, y: 320)

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
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // ── Hero: Streak circle + Timer + Money ───────────
                    StreakHeroView(habit: habit)
                        .padding(.top, 8)
                        .padding(.bottom, 28)

                    // ── Cards ─────────────────────────────────────────
                    VStack(spacing: 14) {
                        // Mood check-in (always visible)
                        MoodCheckInView(habit: habit)

                        // Daily motivation quote
                        DailyMotivationCardView()

                        // Next reward progress (only if rewards exist)
                        if !habit.rewards.isEmpty {
                            NextRewardProgressView(habit: habit, onTap: {
                                showingRewardsStore = true
                            })
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 28)

                    // ── Action Buttons ────────────────────────────────
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

                    Spacer().frame(height: 110) // Tab bar clearance
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
                        .padding(.bottom, 120)
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
        .sheet(isPresented: $showingRewardsStore) {
            RewardsStoreView(habit: habit)
                .presentationBackground(AppGradient.background)
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
