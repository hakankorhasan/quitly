//
//  UrgeModeView.swift
//  quitly
//
//  Full-screen breathing exercise: 10s wait → breathe cycle → motivational message.
//

import SwiftUI

struct UrgeModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state: UrgeState = .hub
    @State private var showingReplacements = false
    @State private var appeared = false
    
    var onComplete: (() -> Void)? = nil

    private enum UrgeState {
        case hub, breathing, game, journal, calmReturn
    }

    private enum EngineType: CaseIterable {
        case flowTrace, motionHarmony, sequenceMemory
    }
    
    @State private var selectedEngine: EngineType = .flowTrace

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

            // Ambient background for hub
            if state == .hub {
                Circle()
                    .fill(Color.soberBlue.opacity(0.08))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(y: -50)
            }

            switch state {
            case .hub:
                hubView
            case .breathing:
                BreathingInterventionView(
                    onComplete: { transitionToCalm() },
                    requestDismiss: { state = .hub }
                )
                .transition(.opacity)
            case .game:
                if selectedEngine == .flowTrace {
                    FlowTraceEngineView(
                        onComplete: { _ in transitionToCalm() },
                        requestDismiss: { state = .hub }
                    )
                    .transition(.opacity)
                } else if selectedEngine == .motionHarmony {
                    MotionHarmonyEngineView(
                        onComplete: { _ in transitionToCalm() },
                        requestDismiss: { state = .hub }
                    )
                    .transition(.opacity)
                } else {
                    SequenceMemoryEngineView(
                        onComplete: { _ in transitionToCalm() },
                        requestDismiss: { state = .hub }
                    )
                    .transition(.opacity)
                }
            case .journal:
                JournalInterventionView(
                    onComplete: { transitionToCalm() },
                    requestDismiss: { state = .hub }
                )
                .transition(.opacity)
            case .calmReturn:
                CalmReturnView(
                    onDismiss: {
                        onComplete?()
                        dismiss()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: state)
        .sheet(isPresented: $showingReplacements) {
            ReplacementBehaviorView()
                .presentationBackground(AppGradient.background)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var hubView: some View {
        VStack(spacing: 0) {
            // Header
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
            
            // Title
            VStack(spacing: 12) {
                Text(NSLocalizedString("urge_title", comment: ""))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(NSLocalizedString("urge_subtitle", comment: ""))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer().frame(height: 50)
            
            // 3 Intervention Options
            VStack(spacing: 16) {
                interventionCard(
                    title: NSLocalizedString("urge_breathe_title", comment: ""),
                    subtitle: NSLocalizedString("urge_breathe_desc", comment: ""),
                    icon: "wind",
                    color: .aquaTeal,
                    delay: 0.1
                ) {
                    state = .breathing
                }
                
                interventionCard(
                    title: NSLocalizedString("urge_game_title", comment: ""),
                    subtitle: NSLocalizedString("urge_game_desc", comment: ""),
                    icon: "gamecontroller.fill",
                    color: .soberBlue,
                    delay: 0.2
                ) {
                    selectedEngine = EngineType.allCases.randomElement() ?? .flowTrace
                    state = .game
                }
                
                interventionCard(
                    title: NSLocalizedString("urge_journal_title", comment: ""),
                    subtitle: NSLocalizedString("urge_journal_desc", comment: ""),
                    icon: "pencil.line",
                    color: .amberGold,
                    delay: 0.3
                ) {
                    state = .journal
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Alternatives Shortcut
            Button {
                showingReplacements = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 14, weight: .bold))
                    Text(NSLocalizedString("urge_alternatives", comment: ""))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.greenClean)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.greenClean.opacity(0.1))
                        .overlay(Capsule().strokeBorder(Color.greenClean.opacity(0.3), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 50)
            .opacity(appeared ? 1 : 0)
        }
    }
    
    private func interventionCard(title: String, subtitle: String, icon: String, color: Color, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.2))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }

    private func transitionToCalm() {
        withAnimation {
            state = .calmReturn
        }
    }
}
