//
//  UrgeModeView.swift
//  quitly
//
//  Full-screen breathing exercise: 10s wait → breathe cycle → motivational message.
//

import SwiftUI

struct UrgeModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: UrgePhase = .waiting
    @State private var countdown = 10
    @State private var breatheScale: CGFloat = 0.6
    @State private var breatheOpacity: Double = 0.4
    @State private var breatheLabel = ""
    @State private var motivationalQuote = ""
    @State private var appeared = false

    // After completing urge mode, trigger the trigger picker
    var onComplete: (() -> Void)? = nil

    private enum UrgePhase {
        case waiting, breathing, message
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.031, green: 0.067, blue: 0.157),
                    Color(red: 0.051, green: 0.051, blue: 0.102),
                    Color(red: 0.016, green: 0.039, blue: 0.098)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color.soberBlue.opacity(0.08))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -50)

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Phase content
                switch phase {
                case .waiting:
                    waitingView
                case .breathing:
                    breathingView
                case .message:
                    messageView
                }

                Spacer()

                // Bottom action
                if phase == .message {
                    Button {
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.success)
                        onComplete?()
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Text(NSLocalizedString("urge_stronger", comment: ""))
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .buttonStyle(FireButtonStyle())
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            startWaiting()
        }
    }

    // MARK: - Waiting Phase (10s)
    private var waitingView: some View {
        VStack(spacing: 24) {
            // Pulsing ring
            ZStack {
                Circle()
                    .strokeBorder(Color.soberBlue.opacity(0.15), lineWidth: 3)
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(Color.soberBlue.opacity(0.06))
                    .frame(width: 160, height: 160)
                    .scaleEffect(breatheScale)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: breatheScale)

                Text("\(countdown)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: countdown)
            }

            Text(NSLocalizedString("urge_wait_message", comment: ""))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Text(NSLocalizedString("urge_wait_subtitle", comment: ""))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
        .opacity(appeared ? 1 : 0)
        .transition(.opacity)
    }

    // MARK: - Breathing Phase
    private var breathingView: some View {
        VStack(spacing: 32) {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(Color.aquaTeal.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)

                // Breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aquaTeal.opacity(0.3), Color.soberBlue.opacity(0.08)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(breatheScale)
                    .opacity(breatheOpacity)

                // Inner glow
                Circle()
                    .fill(Color.aquaTeal.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .blur(radius: 15)
                    .scaleEffect(breatheScale * 0.8)
            }

            Text(breatheLabel)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.identity)
                .animation(.easeInOut(duration: 0.3), value: breatheLabel)
        }
        .transition(.opacity)
    }

    // MARK: - Message Phase
    private var messageView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.soberBlue, .aquaTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(NSLocalizedString("urge_conquered", comment: ""))
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(motivationalQuote)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    // MARK: - Flow Control

    private func startWaiting() {
        breatheScale = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            breatheScale = 1.1
        }

        // Countdown 10 → 1
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) { [self] in
                withAnimation { countdown = 10 - i }
                if i == 10 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        phase = .breathing
                    }
                    startBreathing()
                }
            }
        }
    }

    private func startBreathing() {
        // 4-7-8 breathing: Inhale 4s, Hold 7s, Exhale 8s = 19s total
        // Simplified: Inhale 4s, Hold 3s, Exhale 5s = 12s
        let steps: [(String, Double, CGFloat, Double)] = [
            (NSLocalizedString("urge_breathe_in", comment: ""),  4.0, 1.3, 0.9),
            (NSLocalizedString("urge_hold", comment: ""),        3.0, 1.3, 0.7),
            (NSLocalizedString("urge_breathe_out", comment: ""), 5.0, 0.6, 0.4),
        ]

        var delay = 0.0
        for step in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                breatheLabel = step.0
                withAnimation(.easeInOut(duration: step.1)) {
                    breatheScale = step.2
                    breatheOpacity = step.3
                }
            }
            delay += step.1
        }

        // After breathing, show message
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            motivationalQuote = MotivationEngine.shared.getRandomQuote()
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                phase = .message
            }
        }
    }
}
