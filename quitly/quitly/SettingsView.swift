//
//  SettingsView.swift
//  quitly
//

import SwiftUI
import SwiftData

private let currencies = [("₺", "TRY"), ("$", "USD"), ("€", "EUR"), ("£", "GBP"), ("¥", "JPY"), ("₽", "RUB")]

struct SettingsView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("setupComplete") private var setupComplete = false

    @State private var habitName: String = ""
    @State private var dailyCost: String = ""
    @State private var showingResetAlert = false
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.13).ignoresSafeArea()

                ScrollView {
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

                        // Go Premium
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle().fill(AppGradient.fire).frame(width: 40, height: 40)
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 18))
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

                        // Danger Zone
                        Button(NSLocalizedString("settings_reset_data", comment: "")) {
                            showingResetAlert = true
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.top, 8)

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("settings_save", comment: "")) {
                        saveChanges()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.fireOrange)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("settings_cancel", comment: "")) { dismiss() }
                        .foregroundStyle(Color.textSecondary)
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
        }
        .onAppear {
            habitName = habit.name
            dailyCost = "\(Int(habit.dailyCostAmount))"
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private func saveChanges() {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { habit.name = name }
        if let cost = Double(dailyCost.replacingOccurrences(of: ",", with: ".")) {
            habit.dailyCostAmount = cost
        }
        try? modelContext.save()
    }

    private func resetAllData() {
        try? modelContext.delete(model: Habit.self)
        setupComplete = false
        dismiss()
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
