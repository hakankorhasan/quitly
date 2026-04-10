//
//  MainTabView.swift
//  quitly
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case progress
    case settings

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var labelKey: String {
        switch self {
        case .home:     return "tab_home"
        case .progress: return "tab_progress"
        case .settings: return "tab_settings"
        }
    }

    var accentColor: Color {
        switch self {
        case .home:     return .fireOrange
        case .progress: return .purpleAccent
        case .settings: return .textSecondary
        }
    }
}

struct MainTabView: View {
    @Bindable var habit: Habit
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .home
    @State private var tabBounce: AppTab? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            AppGradient.background.ignoresSafeArea()

            // Page content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(habit: habit)
                case .progress:
                    InsightsView(habit: habit)
                case .settings:
                    SettingsView(habit: habit)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Premium Bottom Nav Bar ───────────────────────────
            bottomNavBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Bottom Nav Bar
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                        tabBounce = tab
                    }
                    // Reset bounce
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            tabBounce = nil
                        }
                    }
                } label: {
                    tabItem(tab: tab)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 30)
        .background(
            ZStack {
                // Frosted glass background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)

                // Subtle top border glow
                VStack {
                    LinearGradient(
                        colors: [
                            Color.fireOrange.opacity(0.15),
                            Color.purpleAccent.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 0.5)
                    Spacer()
                }

                // Dark overlay for depth
                Rectangle()
                    .fill(Color.black.opacity(0.2))
            }
            .ignoresSafeArea()
        )
    }

    // MARK: - Tab Item
    @ViewBuilder
    private func tabItem(tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        VStack(spacing: 6) {
            ZStack {
                // Selected indicator pill
                if isSelected {
                    Capsule()
                        .fill(tab.accentColor.opacity(0.15))
                        .frame(width: 52, height: 32)
                        .transition(.scale.combined(with: .opacity))
                }

                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 18 : 17, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? tab.accentColor : Color.textMuted
                    )
                    .scaleEffect(tabBounce == tab ? 1.2 : 1.0)
            }
            .frame(height: 32)

            Text(NSLocalizedString(tab.labelKey, comment: ""))
                .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(
                    isSelected ? tab.accentColor : Color.textMuted
                )
        }
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
