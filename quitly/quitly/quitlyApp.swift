//
//  quitlyApp.swift
//  quitly
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct quitlyApp: App {
    @State private var appState      = AppState()
    @State private var premiumManager = PremiumManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Habit.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        Purchases.logLevel = .debug // Production'da .error yap
        Purchases.configure(withAPIKey: "appl_YryQlEiaGhnFelbkFestplYqJky")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(premiumManager)
                .preferredColorScheme(.dark)
                .task {
                    await premiumManager.checkEntitlements()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
