//
//  SettingsView.swift
//  quitly
//

import SwiftUI
import SwiftData
import WidgetKit

private let currencies = [("₺", "TRY"), ("$", "USD"), ("€", "EUR"), ("£", "GBP"), ("¥", "JPY"), ("₽", "RUB")]

struct SettingsView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager
    @AppStorage("setupComplete") private var setupComplete = false
    @AppStorage("notif_daily_enabled") private var dailyNotifEnabled = false
    @AppStorage("notif_weekend_enabled") private var weekendNotifEnabled = false

    @State private var habitName: String = ""
    @State private var dailyCost: String = ""
    @State private var showingResetAlert = false
    @State private var showingPaywall = false
    @State private var savedToast = false
    @State private var showingPrivacy = false
    @State private var showingTerms = false

    var body: some View {
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

            // ── Fixed Top Title ─────────────────────────────────────────
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text(NSLocalizedString("settings_title", comment: ""))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            .zIndex(10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 52) // Title bar clearance

                    // ── Header ─────────────────────────────────────────
                    profileHeader
                        .padding(.top, 4)

                    // ── Habit Name ─────────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("settings_habit_title", comment: "")
                    ) {
                        inlineTextField(
                            label: NSLocalizedString("settings_habit_name", comment: ""),
                            placeholder: habit.name,
                            text: $habitName,
                            onCommit: autoSave
                        )
                    }

                    // ── Cost ───────────────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("settings_cost_title", comment: "")
                    ) {
                        inlineTextField(
                            label: NSLocalizedString("settings_daily_cost", comment: ""),
                            placeholder: "\(Int(habit.dailyCostAmount))",
                            text: $dailyCost,
                            keyboardType: .decimalPad,
                            onCommit: autoSave
                        )
                        settingsDivider
                        HStack {
                            Text(NSLocalizedString("settings_currency", comment: ""))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            Picker("", selection: Binding(
                                get: { habit.currencySymbol },
                                set: { habit.currencySymbol = $0; autoSave() }
                            )) {
                                ForEach(currencies, id: \.0) { c in
                                    Text("\(c.0) \(c.1)").tag(c.0)
                                }
                            }
                            .tint(.soberBlue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }

                    // ── Quit Date ──────────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("settings_dates_title", comment: "")
                    ) {
                        HStack {
                            Text(NSLocalizedString("settings_quit_date", comment: ""))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            DatePicker("", selection: Binding(
                                get: { habit.streakStart },
                                set: { habit.streakStart = $0; autoSave() }
                            ), in: ...Date(), displayedComponents: .date)
                            .tint(.soberBlue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    // ── Goal Mode ──────────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("goal_mode_label", comment: "")
                    ) {
                        GoalModeSelectorView(selectedGoal: Binding(
                            get: { habit.goalMode },
                            set: { habit.goalMode = $0; autoSave() }
                        ))
                        .padding(16)
                    }

                    // ── Notifications ──────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("settings_notifications_title", comment: "")
                    ) {
                        notifRow(
                            icon: "sun.max.fill", iconColor: .amberGold,
                            label: NSLocalizedString("settings_notif_daily", comment: ""),
                            isOn: $dailyNotifEnabled
                        )
                        settingsDivider
                        notifRow(
                            icon: "moon.stars.fill", iconColor: .purpleAccent,
                            label: NSLocalizedString("settings_notif_weekend", comment: ""),
                            isOn: $weekendNotifEnabled
                        )
                    }

                    // ── Legal ──────────────────────────────────────────
                    SettingsSection(
                        title: NSLocalizedString("settings_legal", comment: "")
                    ) {
                        legalRow(icon: "lock.shield.fill", color: .purpleAccent,
                                 label: NSLocalizedString("settings_privacy", comment: "")) {
                            showingPrivacy = true
                        }
                        settingsDivider
                        legalRow(icon: "doc.text.fill", color: .soberBlue,
                                 label: NSLocalizedString("settings_terms", comment: "")) {
                            showingTerms = true
                        }
                    }

                    // ── Danger ─────────────────────────────────────────
                    Button {
                        showingResetAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text(NSLocalizedString("settings_reset_data", comment: ""))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.red.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.red.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 100)
                }
            }

            // ── Saved Toast ────────────────────────────────────────────
            if savedToast {
                savedToastView
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: savedToast)
        .alert(NSLocalizedString("settings_reset_alert_title", comment: ""), isPresented: $showingResetAlert) {
            Button(NSLocalizedString("settings_reset_confirm", comment: ""), role: .destructive) {
                resetAllData()
            }
            Button(NSLocalizedString("relapse_cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("settings_reset_alert_message", comment: ""))
        }
        .onChange(of: dailyNotifEnabled)  { scheduleNotifications() }
        .onChange(of: weekendNotifEnabled) { scheduleNotifications() }
        .onAppear {
            habitName = habit.name
            dailyCost = "\(Int(habit.dailyCostAmount))"
        }
        .fullScreenCover(isPresented: $showingPaywall)  { PaywallView() }
        .fullScreenCover(isPresented: $showingPrivacy)  {
            LegalWebView(title: NSLocalizedString("settings_privacy", comment: ""), urlString: LegalURL.privacyPolicy)
        }
        .fullScreenCover(isPresented: $showingTerms) {
            LegalWebView(title: NSLocalizedString("settings_terms", comment: ""), urlString: LegalURL.termsOfUse)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 14) {
            // Habit info row
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.name)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(goalLabel)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                if premiumManager.isPremium {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.goldAccent)
                        Text(NSLocalizedString("badge_pro", comment: ""))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.goldAccent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.goldAccent.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.goldAccent.opacity(0.3), lineWidth: 1))
                }
            }

            // Premium upgrade card — free users only
            if !premiumManager.isPremium {
                Button { showingPaywall = true } label: {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Image("splash-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("settings_go_premium", comment: ""))
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(NSLocalizedString("paywall_subtitle", comment: ""))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        // Feature pills
                        HStack(spacing: 8) {
                            premiumPill(icon: "shield.checkered", text: "Streak Shield")
                            premiumPill(icon: "brain.head.profile", text: "Insights")
                            premiumPill(icon: "bell.badge.fill", text: "Reminders")
                        }
                    }
                    .padding(16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.15, green: 0.08, blue: 0.35),
                                            Color(red: 0.08, green: 0.12, blue: 0.30)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.purpleAccent.opacity(0.5),
                                            Color.soberBlue.opacity(0.3),
                                            Color.purpleAccent.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    premiumManager.isPremium
                        ? Color.goldAccent.opacity(0.2)
                        : Color.soberBlue.opacity(0.15),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func premiumPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }

    // MARK: - Saved Toast
    private var savedToastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.greenClean)
            Text(NSLocalizedString("settings_saved", comment: ""))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(white: 0.12))
                .overlay(Capsule().strokeBorder(Color.greenClean.opacity(0.3), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
        .padding(.top, 60)
    }




    // MARK: - Helpers
    private var settingsDivider: some View {
        Divider().background(Color.white.opacity(0.07)).padding(.horizontal, 4)
    }

    private var goalLabel: String {
        switch habit.goalMode {
        case "less":     return NSLocalizedString("goal_subtitle_less", comment: "")
        case "weekends": return NSLocalizedString("goal_subtitle_weekends", comment: "")
        default:         return NSLocalizedString("goal_subtitle_quit", comment: "")
        }
    }

    @ViewBuilder
    private func inlineTextField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        onCommit: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: 160)
                .onSubmit(onCommit)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func notifRow(icon: String, iconColor: Color, label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(.soberBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func legalRow(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 24)
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Auto Save
    private func autoSave() {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { habit.name = name }
        if let cost = Double(dailyCost.replacingOccurrences(of: ",", with: ".")) {
            habit.dailyCostAmount = cost
        }
        try? modelContext.save()
        writeHabitToWidget(habit, premiumManager: premiumManager)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { savedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) { savedToast = false }
        }
    }

    private func resetAllData() {
        try? modelContext.delete(model: Habit.self)
        setupComplete = false
    }

    private func scheduleNotifications() {
        if dailyNotifEnabled || weekendNotifEnabled {
            NotificationManager.shared.requestPermission { granted in
                if granted {
                    NotificationManager.shared.scheduleAll(
                        streakDays: habit.streakDays,
                        dailyEnabled: dailyNotifEnabled,
                        weekendEnabled: weekendNotifEnabled
                    )
                }
            }
        } else {
            NotificationManager.shared.cancelAll()
        }
    }
}

// MARK: - Section Component
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.horizontal, 24)

            // Content card
            VStack(spacing: 0) { content }
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Text Field Component
private struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: 160)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
