//
//  BreathingInterventionView.swift
//  quitly
//
//  4-4-6 Guided Breathing to return system to parasympathetic state.
//

import SwiftUI

struct BreathingInterventionView: View {
    var onComplete: () -> Void
    var requestDismiss: () -> Void

    @State private var breatheScale: CGFloat = 0.6
    @State private var breatheOpacity: Double = 0.4
    @State private var breatheLabel = NSLocalizedString("breathe_start", comment: "")
    
    @State private var cycleCount = 0
    private let targetCycles = 8 // approx 2 mins (8 * 14s = 112s)
    @State private var isFinished = false
    
    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()
            
            // Ambient glow
            Circle()
                .fill(Color.soberBlue.opacity(0.08))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -50)
            
            VStack {
                HStack {
                    Button {
                        if isFinished {
                            onComplete()
                        } else {
                            requestDismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
            .zIndex(10)

            if isFinished {
                // Done View
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.aquaTeal)

                    Text(NSLocalizedString("breathe_done_title", comment: ""))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(NSLocalizedString("breathe_done_desc", comment: ""))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 36)
                        
                    Button {
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.success)
                        onComplete()
                    } label: {
                        Text(NSLocalizedString("breathe_continue", comment: ""))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.aquaTeal))
                    }
                    .padding(.top, 20)
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else {
                // Breathing UI
                VStack(spacing: 40) {
                    ZStack {
                        // Outer ring guide
                        Circle()
                            .strokeBorder(Color.soberBlue.opacity(0.2), lineWidth: 2)
                            .frame(width: 260, height: 260)

                        // The lung
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.soberBlue.opacity(0.4), Color.aquaTeal.opacity(0.08)],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 130
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(breatheScale)
                            .opacity(breatheOpacity)

                        // Inner core
                        Circle()
                            .fill(Color.soberBlue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                            .scaleEffect(breatheScale * 0.7)
                    }

                    Text(breatheLabel)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.identity)
                        .animation(.easeInOut(duration: 0.3), value: breatheLabel)
                        
                    Text(String(format: NSLocalizedString("breathe_step_format", comment: ""), cycleCount + 1, targetCycles))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textMuted)
                }
                .transition(.opacity)
                .onAppear {
                    startBreathingCycle()
                }
            }
        }
    }
    
    // 4-4-6 Cycle
    private func startBreathingCycle() {
        guard !isFinished else { return }
        if cycleCount >= targetCycles {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                isFinished = true
            }
            return
        }
        
        let steps: [(String, Double, CGFloat, Double)] = [
            (NSLocalizedString("breathe_inhale", comment: ""), 4.0, 1.0, 0.9), // Inhale
            (NSLocalizedString("breathe_hold", comment: ""),      4.0, 1.0, 0.6), // Hold
            (NSLocalizedString("breathe_exhale", comment: ""), 6.0, 0.4, 0.3) // Exhale
        ]
        
        var delay = 0.0
        for step in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard !isFinished else { return }
                breatheLabel = step.0
                withAnimation(.easeInOut(duration: step.1)) {
                    breatheScale = step.2
                    breatheOpacity = step.3
                }
            }
            delay += step.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !isFinished else { return }
            cycleCount += 1
            startBreathingCycle()
        }
    }
}
