//
//  SequenceMemoryEngineView.swift
//  quitly
//
//  Cognitive Reset Engine: Sequence Memory
//  9 balls light up in a sequence; user repeats it. Heavy working memory load.
//

import SwiftUI

struct SequenceMemoryEngineView: View {
    var onComplete: (Int) -> Void
    var requestDismiss: () -> Void
    
    // Game State
    @State private var level: Int = 1
    @State private var sequence: [Int] = []
    @State private var userStepIndex: Int = 0
    
    @State private var activeBall: Int? = nil
    @State private var phase: GamePhase = .intro
    @State private var hasLost: Bool = false
    @State private var shakeTrigger: Bool = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notifFeedback = UINotificationFeedbackGenerator()
    
    enum GamePhase {
        case intro
        case observing // Showing the sequence
        case playing   // User's turn to repeat
        case finished
    }
    
    var body: some View {
        ZStack {
            Color.appBG.ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    Button {
                        requestDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }
                    
                    Spacer()
                    
                    if phase == .observing || phase == .playing {
                        Text(String(format: NSLocalizedString("engine_seq_level", comment: ""), level))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color.amberGold)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
            .zIndex(10)
            
            switch phase {
            case .intro:
                introView
            case .observing, .playing:
                playingView
            case .finished:
                finishedView
            }
        }
        .onAppear {
            impactLight.prepare()
            impactHeavy.prepare()
        }
    }
    
    // MARK: - Intro
    private var introView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(Color.amberGold.opacity(0.15)).frame(width: 80, height: 80)
                Image(systemName: "circle.grid.3x3.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.amberGold)
            }
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("engine_seq_title", comment: ""))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(NSLocalizedString("engine_seq_desc", comment: ""))
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Button {
                startGame()
            } label: {
                Text(NSLocalizedString("engine_seq_start", comment: ""))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.soberBlue))
            }
            .padding(.top, 20)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }
    
    // MARK: - Playing
    private var playingView: some View {
        VStack(spacing: 60) {
            VStack(spacing: 8) {
                Text(phase == .observing ? NSLocalizedString("engine_seq_watch", comment: "") : NSLocalizedString("engine_seq_turn", comment: ""))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(phase == .observing ? Color.amberGold : Color.greenClean)
                    .animation(.easeInOut, value: phase)
            }
            
            // 3x3 Grid
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<9, id: \.self) { index in
                    let isGlowing = activeBall == index
                    
                    Button {
                        if phase == .playing {
                            handleTap(index)
                        }
                    } label: {
                        Circle()
                            .fill(isGlowing ? (phase == .observing ? Color.amberGold : Color.greenClean) : Color.white.opacity(0.05))
                            .aspectRatio(1, contentMode: .fit)
                            .shadow(color: isGlowing ? (phase == .observing ? Color.amberGold : Color.greenClean).opacity(0.8) : .clear, radius: 15)
                            .overlay(
                                Circle().strokeBorder(Color.white.opacity(isGlowing ? 0 : 0.1), lineWidth: 1)
                            )
                            .scaleEffect(isGlowing ? 1.05 : 1.0)
                            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5), value: isGlowing)
                    }
                    .buttonStyle(.plain)
                    .disabled(phase == .observing)
                }
            }
            .padding(.horizontal, 40)
            .modifier(ShakeEffect(animatableData: CGFloat(shakeTrigger ? 1 : 0)))
        }
        .transition(.opacity)
    }
    
    // MARK: - Finished
    private var finishedView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(hasLost ? Color.red.opacity(0.15) : Color.greenClean.opacity(0.15)).frame(width: 100, height: 100)
                Text("Lv.\(level)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(hasLost ? Color.red : Color.greenClean)
            }
            
            VStack(spacing: 8) {
                Text(hasLost ? NSLocalizedString("engine_seq_lost_title", comment: "") : NSLocalizedString("engine_seq_won_title", comment: ""))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(hasLost ? NSLocalizedString("engine_seq_lost_desc", comment: "") : NSLocalizedString("engine_seq_won_desc", comment: ""))
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Button {
                    if hasLost {
                        startGame() // Play again
                    } else {
                        onComplete(level)
                    }
                } label: {
                    Text(hasLost ? NSLocalizedString("engine_seq_retry", comment: "") : NSLocalizedString("engine_return", comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(hasLost ? Color.amberGold : Color.aquaTeal))
                }
                
                if hasLost {
                    Button {
                        onComplete(level)
                    } label: {
                        Text(NSLocalizedString("engine_seq_exit", comment: ""))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.vertical, 14)
                    }
                }
            }
            .padding(.top, 10)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }
    
    // MARK: - Logic
    
    private func startGame() {
        level = 1
        sequence.removeAll()
        hasLost = false
        
        // Start sequence level 1 with 3 balls
        for _ in 0..<3 {
            sequence.append(Int.random(in: 0..<9))
        }
        
        playSequence()
    }
    
    private func playSequence() {
        userStepIndex = 0
        activeBall = nil
        
        withAnimation {
            phase = .observing
        }
        
        var delay = 0.5
        for (index, ballIndex) in sequence.enumerated() {
            // Turn on
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.activeBall = ballIndex
                self.impactLight.impactOccurred()
            }
            
            // Turn off
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.4) {
                self.activeBall = nil
                
                // If it was the last ball, switch to playing phase
                if index == sequence.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            self.phase = .playing
                        }
                    }
                }
            }
            delay += 0.6 // Space between flashes
        }
    }
    
    private func handleTap(_ index: Int) {
        guard phase == .playing else { return }
        
        let expected = sequence[userStepIndex]
        
        activeBall = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.activeBall == index {
                self.activeBall = nil
            }
        }
        
        if index == expected {
            // Correct
            impactLight.impactOccurred()
            userStepIndex += 1
            
            if userStepIndex == sequence.count {
                // Passed Level
                phase = .observing // freeze touches
                notifFeedback.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    level += 1
                    sequence.append(Int.random(in: 0..<9))
                    playSequence()
                }
            }
        } else {
            // Wrong
            notifFeedback.notificationOccurred(.error)
            withAnimation(.default) {
                shakeTrigger.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasLost = true
                withAnimation {
                    phase = .finished
                }
            }
        }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
