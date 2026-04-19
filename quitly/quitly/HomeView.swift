//
//  HomeView.swift
//  quitly
//

import SwiftUI

struct HomeView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @Environment(PremiumManager.self) private var premiumManager
    @Environment(RemoteConfigManager.self) private var remoteConfig
    @State private var showingPaywall = false
    @State private var showingManageReplacements = false

    var body: some View {
        @Bindable var state = appState
        GeometryReader { geo in
            let isSmall = geo.size.width < 380 // iPhone SE/13 mini
            let hPad: CGFloat = isSmall ? 16 : 24

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
                        // ── Top Bar ───────────────────────────────────────
                        HStack(spacing: isSmall ? 10 : 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.name)
                                    .font(.system(size: isSmall ? 18 : 20, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(goalSubtitle)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()

                            // Free / Pro Badge
                            premiumBadge
                        }
                        .padding(.horizontal, hPad)
                        .padding(.top, 12)
                        .padding(.bottom, 12)

                        // ── Hero: Streak circle + Timer + Money ───────────
                        StreakHeroView(habit: habit)
                            .padding(.top, 8)
                            .padding(.bottom, isSmall ? 8 : 12)

                        // ── Cards ─────────────────────────────────────────
                        VStack(spacing: isSmall ? 10 : 14) {
                            // Mood check-in (always visible)
                            MoodCheckInView(habit: habit)

                            // Daily motivation quote
                            DailyMotivationCardView()

                            // My Alternatives card shortcut
                            replacementCard
                        }
                        .padding(.horizontal, hPad)

                        Spacer().frame(height: isSmall ? 20 : 28)

                        // ── Action Buttons ────────────────────────────────
                        VStack(spacing: isSmall ? 10 : 14) {
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
                            .padding(.horizontal, hPad + 4)

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
                        RelapseSuportBanner(isProtected: appState.streakProtectedFeedback)
                            .padding(.horizontal, hPad)
                            .padding(.bottom, 120)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(10)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.showingRelapseSupport)
        .sheet(isPresented: $state.showingRelapse) {
            RelapseSheetView(habit: habit)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.cardBG)
        }
        .fullScreenCover(isPresented: $showingManageReplacements) {
            ManageReplacementsView()
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $state.showingUrgeMode) {
            UrgeModeView {
                appState.onUrgeModeComplete()
            }
        }
        .sheet(isPresented: $state.showingTriggerPicker) {
            TriggerInsightView(habitId: habit.id, context: appState.triggerContext)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.cardBG)
        }
        .overlay {
            if remoteConfig.shouldShowUpdate {
                UpdatePopupView(
                    latestVersion: remoteConfig.latestVersion,
                    appStoreURL: remoteConfig.appStoreURL,
                    onDismiss: {
                        remoteConfig.dismissUpdate()
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            // Sync widget data every time home appears
            writeHabitToWidget(habit, premiumManager: premiumManager)

            // Reschedule with fresh streak count every time home appears
            let dailyEnabled   = UserDefaults.standard.bool(forKey: "notif_daily_enabled")
            let weekendEnabled = UserDefaults.standard.bool(forKey: "notif_weekend_enabled")
            if dailyEnabled || weekendEnabled {
                NotificationManager.shared.scheduleAll(
                    streakDays: habit.streakDays,
                    dailyEnabled: dailyEnabled,
                    weekendEnabled: weekendEnabled
                )
            }
        }
    }

    // MARK: - Goal Subtitle
    private var goalSubtitle: String {
        switch habit.goalMode {
        case "less":   return NSLocalizedString("goal_subtitle_less", comment: "")
        case "90days": return NSLocalizedString("goal_subtitle_90days", comment: "")
        default:       return NSLocalizedString("goal_subtitle_quit", comment: "")
        }
    }

    // MARK: - Free / Pro Badge
    private var premiumBadge: some View {
        Button {
            if !premiumManager.isPremium {
                showingPaywall = true
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: premiumManager.isPremium ? "crown.fill" : "sparkle")
                    .font(.system(size: 10, weight: .bold))

                Text(NSLocalizedString(
                    premiumManager.isPremium ? "badge_pro" : "badge_free",
                    comment: ""
                ))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(premiumManager.isPremium ? Color.goldAccent : Color.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        premiumManager.isPremium
                            ? Color.goldAccent.opacity(0.15)
                            : Color.white.opacity(0.08)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                premiumManager.isPremium
                                    ? Color.goldAccent.opacity(0.3)
                                    : Color.white.opacity(0.12),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - My Alternatives Card
    private var replacementCard: some View {
        Button {
            showingManageReplacements = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.greenClean.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.greenClean)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("My Alternatives")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(ReplacementActivityStore.shared.enabled.count) activities ready when urge hits")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.greenClean.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Relapse Support Banner
private struct RelapseSuportBanner: View {
    var isProtected: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isProtected ? "shield.checkered" : "heart.fill")
                .font(.system(size: 24))
                .foregroundStyle(isProtected ? Color.goldAccent : Color.purpleAccent)
            Text(isProtected
                 ? NSLocalizedString("streak_protected_message", comment: "")
                 : NSLocalizedString("relapse_support_message", comment: ""))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isProtected ? Color.goldAccent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
