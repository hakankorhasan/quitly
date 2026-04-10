//
//  quitlyApp.swift
//  quitly
//

import SwiftUI
import SwiftData
import RevenueCat
import FirebaseCore

@main
struct quitlyApp: App {
    @State private var appState      = AppState()
    @State private var premiumManager = PremiumManager()
    @State private var remoteConfig   = RemoteConfigManager()

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
        FirebaseApp.configure()
        Purchases.logLevel = .debug // Production'da .error yap
        Purchases.configure(withAPIKey: "appl_YryQlEiaGhnFelbkFestplYqJky")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(premiumManager)
                .environment(remoteConfig)
                .preferredColorScheme(.dark)
                .task {
                    await premiumManager.checkEntitlements()
                    await remoteConfig.checkForUpdate()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
