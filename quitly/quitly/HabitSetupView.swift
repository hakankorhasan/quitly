//
//  HabitSetupView.swift
//  quitly
//

import SwiftUI
import SwiftData

private let currencies = [
    ("₺", "TRY – Turkish Lira"),
    ("$", "USD – US Dollar"),
    ("€", "EUR – Euro"),
    ("£", "GBP – British Pound"),
    ("¥", "JPY – Japanese Yen"),
    ("₽", "RUB – Russian Ruble"),
]

struct HabitSetupView: View {
    // Alcohol recovery app: hardcoded
    private let habitEmoji = "cocktail"
    private let habitName_  = "Drinking"

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("setupComplete") private var setupComplete = false

    @State private var habitName: String = ""
    @State private var dailyCost: String = ""
    @State private var selectedCurrency = "₺"
    @State private var quitDate = Date()
    @State private var goalMode = "quit"
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Spacer().frame(height: 60)

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: habitEmoji)
                        .font(.system(size: 42))
                        .foregroundStyle(AppGradient.fire)
                    Text(NSLocalizedString("onboarding_setup_title", comment: ""))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .padding(.horizontal, 28)

                // Fields
                VStack(spacing: 16) {
                    // Goal Mode
                    VStack(alignment: .leading, spacing: 8) {
                        label(NSLocalizedString("goal_mode_label", comment: ""))
                        GoalModeSelectorView(selectedGoal: $goalMode)
                    }

                    // Habit Name
                    VStack(alignment: .leading, spacing: 8) {
                        label(NSLocalizedString("onboarding_habit_name_label", comment: ""))
                        TextField(NSLocalizedString("onboarding_habit_name_placeholder", comment: ""), text: $habitName)
                            .fieldStyle()
                    }

                    // Daily Cost
                    VStack(alignment: .leading, spacing: 8) {
                        label(NSLocalizedString("onboarding_daily_cost_label", comment: ""))
                        HStack(spacing: 8) {
                            TextField("0", text: $dailyCost)
                                .keyboardType(.decimalPad)
                                .fieldStyle()
                            Picker("", selection: $selectedCurrency) {
                                ForEach(currencies, id: \.0) { c in
                                    Text(c.0).tag(c.0)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.fireOrange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.cardBG)
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.08)))
                            )
                        }
                    }

                    // Quit Date
                    VStack(alignment: .leading, spacing: 8) {
                        label(NSLocalizedString("onboarding_quit_date_label", comment: ""))
                        DatePicker("", selection: $quitDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(.fireOrange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.cardBG)
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.08)))
                            )
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                // CTA
                Button(action: saveAndLaunch) {
                    HStack(spacing: 8) {
                        Text(NSLocalizedString("onboarding_finish", comment: ""))
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .buttonStyle(FireButtonStyle())
                .padding(.horizontal, 24)
                .disabled(resolvedName.isEmpty)
                .opacity(resolvedName.isEmpty ? 0.5 : 1.0)
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 80)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            habitName = habitName_
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appeared = true }
        }
    }

    private var resolvedName: String {
        habitName.trimmingCharacters(in: .whitespaces).isEmpty ? habitName_ : habitName
    }

    private func saveAndLaunch() {
        let cost = Double(dailyCost.replacingOccurrences(of: ",", with: ".")) ?? 0
        let new = Habit(name: resolvedName, emoji: habitEmoji, streakStart: quitDate,
                        dailyCostAmount: cost, currencySymbol: selectedCurrency,
                        goalMode: goalMode)
        modelContext.insert(new)
        try? modelContext.save()
        withAnimation { setupComplete = true }
        dismiss()
    }

    @ViewBuilder
    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

private extension View {
    func fieldStyle() -> some View {
        self
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBG)
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.08)))
            )
    }
}
