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
    @State private var showSplash = true

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
                            MainTabView(habit: habit)
                                .tag(habit.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                }
            } else {
                OnboardingView()
            }

            // Splash screen overlay — uygulama ilk açılışında gösterilir
            if showSplash {
                SplashView(isVisible: $showSplash)
                    .transition(.opacity)
                    .zIndex(10)
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

