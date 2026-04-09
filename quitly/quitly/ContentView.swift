//
//  ContentView.swift (AppRoot)
//  quitly
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(PremiumManager.self) private var premiumManager
    @Query private var habits: [Habit]
    @AppStorage("setupComplete") private var setupComplete = false

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

            if setupComplete {
                let activeHabits = habits.filter { $0.isActive }
                if activeHabits.isEmpty {
                    OnboardingView()
                } else {
                    TabView {
                        ForEach(activeHabits) { habit in
                            HomeView(habit: habit)
                                .tag(habit.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .ignoresSafeArea()
                }
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: setupComplete)
        .onAppear {
            if let first = habits.first(where: { $0.isActive }) {
                writeHabitToWidget(first, premiumManager: premiumManager)
            }
        }
        .onChange(of: habits) {
            if let first = habits.first(where: { $0.isActive }) {
                writeHabitToWidget(first, premiumManager: premiumManager)
            }
        }
    }
}

