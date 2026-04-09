//
//  SavingsChartView.swift
//  quitly
//

import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let amount: Double
}

struct SavingsChartView: View {
    let habit: Habit
    @State private var animateChart = false

    var chartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        let cost = habit.dailyCostAmount
        // Generate projected savings for 30 days
        for day in 1...30 {
            data.append(ChartDataPoint(day: day, amount: Double(day) * cost))
        }
        return data
    }
    
    // Pre-calculate complex styles to reduce compiler type-check load
    private let chartGradient = LinearGradient(
        colors: [Color.greenClean.opacity(0.4), Color.greenClean.opacity(0.0)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    private let chartStroke = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
    
    @ViewBuilder
    private func currentDayAnnotation(day: Int) -> some View {
        Text("Day \(day)")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Color.greenClean)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle().fill(AppGradient.green).frame(width: 32, height: 32)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Text(NSLocalizedString("home_savings_chart_title", comment: ""))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            Chart {
                ForEach(chartData) { point in
                    let actualAmount = animateChart ? point.amount : 0.0
                    
                    AreaMark(
                        x: .value("Day", point.day),
                        y: .value("Amount", actualAmount)
                    )
                    .foregroundStyle(chartGradient)
                    
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Amount", actualAmount)
                    )
                    .foregroundStyle(AppGradient.green)
                    .lineStyle(chartStroke)
                }
                
                // Moved OUTSIDE the ForEach loop so compiler doesn't choke on inline logic
                if let currentPoint = chartData.first(where: { $0.day == habit.streakDays }) {
                    let actualAmount = animateChart ? currentPoint.amount : 0.0
                    PointMark(
                        x: .value("Day", currentPoint.day),
                        y: .value("Amount", actualAmount)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(100)
                    .annotation(position: .top) {
                        currentDayAnnotation(day: currentPoint.day)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: [1, 10, 20, 30]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 140)
            .chartYScale(domain: [0.0, (habit.dailyCostAmount * 30.0) * 1.1])
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).delay(0.2)) {
                    animateChart = true
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 24)
    }
}
