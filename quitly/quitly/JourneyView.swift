//
//  JourneyView.swift
//  quitly
//

import SwiftUI

struct JourneyView: View {
    @Bindable var habit: Habit
    @State private var showingManageReplacements = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background glows
            Circle()
                .fill(Color.purpleAccent.opacity(0.07))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -60)
            
            Circle()
                .fill(Color.greenClean.opacity(0.07))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 100, y: 350)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(NSLocalizedString("journey_tab_title", comment: ""))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text(NSLocalizedString("journey_tab_subtitle", comment: ""))
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    VStack(spacing: 16) {
                        // Hours of freedom card
                        MoneySavedView(habit: habit)
                        
                        // My Alternatives quick card
                        replacementCard
                        
                        // Health Milestones
                        HealthMilestonesView(habit: habit)
                        
                        // Previous Attempts (Relapse history)
                        PreviousAttemptsView(habit: habit)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 110)
                }
            }
        }
        .fullScreenCover(isPresented: $showingManageReplacements) {
            ManageReplacementsView()
        }
    }
    
    private var replacementCard: some View {
        Button {
            showingManageReplacements = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.greenClean.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.greenClean)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("My Alternatives")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(ReplacementActivityStore.shared.enabled.count) activities ready when urge hits")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.greenClean.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
