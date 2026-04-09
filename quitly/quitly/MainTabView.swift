//
//  MainTabView.swift
//  quitly
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case journey

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .journey: return "chart.line.uptrend.xyaxis"
        }
    }

    var labelKey: String {
        switch self {
        case .home:    return "tab_home"
        case .journey: return "tab_journey"
        }
    }
}

struct MainTabView: View {
    @Bindable var habit: Habit
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AppGradient.background.ignoresSafeArea()

            // Page content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(habit: habit)
                case .journey:
                    JourneyView(habit: habit)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    tabItem(tab: tab, isSelected: selectedTab == tab)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28) // safe area için
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                )
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private func tabItem(tab: AppTab, isSelected: Bool) -> some View {
        VStack(spacing: 5) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(tab == .home ? Color.fireOrange.opacity(0.18) : Color.purpleAccent.opacity(0.18))
                        .frame(width: 48, height: 32)
                }

                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? (tab == .home ? Color.fireOrange : Color.purpleAccent)
                            : Color.textMuted
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            Text(NSLocalizedString(tab.labelKey, comment: ""))
                .font(.system(size: 10, weight: isSelected ? .bold : .regular, design: .rounded))
                .foregroundStyle(
                    isSelected
                        ? (tab == .home ? Color.fireOrange : Color.purpleAccent)
                        : Color.textMuted
                )
        }
        .contentShape(Rectangle())
    }
}
