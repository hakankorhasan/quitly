//
//  ContentView.swift (AppRoot)
//  quitly
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Query private var habits: [Habit]
    @AppStorage("setupComplete") private var setupComplete = false

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

            if setupComplete, let habit = habits.first(where: { $0.isActive }) {
                HomeView(habit: habit)
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: setupComplete)
    }
}
