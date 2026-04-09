//
//  InsightsView.swift
//  quitly
//

import SwiftUI

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var habit: Habit
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.051, green: 0.051, blue: 0.102).ignoresSafeArea()
            
            // Background glow blobs
            Circle()
                .fill(Color.purpleAccent.opacity(0.12))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -80, y: -120)
            
            Circle()
                .fill(Color.greenClean.opacity(0.10))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 100, y: 300)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(NSLocalizedString("insights_title", comment: ""))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textSecondary.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        SavingsChartView(habit: habit)
                        HealthMilestonesView(habit: habit)
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
