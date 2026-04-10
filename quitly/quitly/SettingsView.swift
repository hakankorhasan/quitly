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

    @State private var habitName: String = ""
    @State private var dailyCost: String = ""
    @State private var showingResetAlert = false
    @State private var showingPaywall = false
    @State private var savedFeedback = false
    @State private var showingPrivacy = false
    @State private var showingTerms = false

    var body: some View {
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // ── Premium Header ─────────────────────────────
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.textSecondary.opacity(0.25), Color.textSecondary.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 42)

                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("settings_title", comment: ""))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(NSLocalizedString("settings_subtitle", comment: ""))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    VStack(spacing: 20) {
                        // Habit Section
                        SettingsSection(title: NSLocalizedString("settings_habit_title", comment: "")) {
                            LabeledTextField(
                                label: NSLocalizedString("settings_habit_name", comment: ""),
                                placeholder: habit.name,
                                text: $habitName
                            )
                        }

                        // Cost Section
                        SettingsSection(title: NSLocalizedString("settings_cost_title", comment: "")) {
                            LabeledTextField(
                                label: NSLocalizedString("settings_daily_cost", comment: ""),
                                placeholder: "\(Int(habit.dailyCostAmount))",
                                text: $dailyCost,
                                keyboardType: .decimalPad
                            )
                            Divider().background(Color.white.opacity(0.07))
                            HStack {
                                Text(NSLocalizedString("settings_currency", comment: ""))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                Picker("", selection: $habit.currencySymbol) {
                                    ForEach(currencies, id: \.0) { c in
                                        Text("\(c.0) \(c.1)").tag(c.0)
                                    }
                                }
                                .tint(.fireOrange)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }

                        // Quit Date
                        SettingsSection(title: NSLocalizedString("settings_dates_title", comment: "")) {
                            HStack {
                                Text(NSLocalizedString("settings_quit_date", comment: ""))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                DatePicker("", selection: $habit.streakStart, in: ...Date(), displayedComponents: .date)
                                    .tint(.fireOrange)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }

                        // Go Premium / Pro Badge
                        if premiumManager.isPremium {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle().fill(Color.goldAccent.opacity(0.2)).frame(width: 40, height: 40)
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.goldAccent)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(NSLocalizedString("badge_pro", comment: ""))
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.goldAccent)
                                    Text(NSLocalizedString("paywall_feature_streak_desc", comment: ""))
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundStyle(Color.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.goldAccent)
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.goldAccent.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(AppGradient.fire).frame(width: 40, height: 40)
                                        Image("burning_fire")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(NSLocalizedString("settings_go_premium", comment: ""))
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text(NSLocalizedString("paywall_subtitle", comment: ""))
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.fireOrange)
                                }
                                .padding(16)
                                .glassCard(cornerRadius: 16)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }

                        // Save Button
                        Button {
                            saveChanges()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: savedFeedback ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                                    .font(.system(size: 15, weight: .bold))
                                Text(savedFeedback
                                     ? NSLocalizedString("settings_saved", comment: "")
                                     : NSLocalizedString("settings_save", comment: ""))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(savedFeedback
                                          ? AnyShapeStyle(Color.greenClean.opacity(0.8))
                                          : AnyShapeStyle(AppGradient.fire))
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: savedFeedback)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        // Legal Section
                        SettingsSection(title: NSLocalizedString("settings_legal", comment: "")) {
                            // Privacy Policy
                            Button {
                                showingPrivacy = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.purpleAccent)
                                        .frame(width: 24)
                                    Text(NSLocalizedString("settings_privacy", comment: ""))
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

                            Divider().background(Color.white.opacity(0.07))

                            // Terms of Use
                            Button {
                                showingTerms = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.fireOrange)
                                        .frame(width: 24)
                                    Text(NSLocalizedString("settings_terms", comment: ""))
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

                        // Danger Zone
                        Button(NSLocalizedString("settings_reset_data", comment: "")) {
                            showingResetAlert = true
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.top, 8)

                        Spacer().frame(height: 110) // Tab bar clearance
                    }
                    }
                }
            }
            .alert(NSLocalizedString("settings_reset_alert_title", comment: ""), isPresented: $showingResetAlert) {
                Button(NSLocalizedString("settings_reset_confirm", comment: ""), role: .destructive) {
                    resetAllData()
                }
                Button(NSLocalizedString("relapse_cancel", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("settings_reset_alert_message", comment: ""))
            }
        .onAppear {
            habitName = habit.name
            dailyCost = "\(Int(habit.dailyCostAmount))"
        }

        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showingPrivacy) {
            LegalWebView(
                title: NSLocalizedString("settings_privacy", comment: ""),
                urlString: LegalURL.privacyPolicy
            )
        }
        .fullScreenCover(isPresented: $showingTerms) {
            LegalWebView(
                title: NSLocalizedString("settings_terms", comment: ""),
                urlString: LegalURL.termsOfUse
            )
        }
    }

    private func saveChanges() {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { habit.name = name }
        if let cost = Double(dailyCost.replacingOccurrences(of: ",", with: ".")) {
            habit.dailyCostAmount = cost
        }
        try? modelContext.save()
        // Push updated data to widget & sync
        writeHabitToWidget(habit, premiumManager: premiumManager)
        // Show saved feedback
        withAnimation { savedFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { savedFeedback = false }
        }
    }

    private func resetAllData() {
        try? modelContext.delete(model: Habit.self)
        setupComplete = false
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            VStack(spacing: 0) { content }
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 20)
        }
    }
}

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
