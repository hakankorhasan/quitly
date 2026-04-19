//
//  FocusTapGameView.swift
//  quitly
//
//  Mini-game: Dopamine reset / pattern break. 
//  Flow Trace Engine: Align with the moving path to reset focus.
//

import SwiftUI

struct FlowTraceEngineView: View {
    var onComplete: (Int) -> Void // Yields arbitrary completion marker (100)
    var requestDismiss: () -> Void

    // MARK: - Engine State
    @State private var phase: FlowPhase = .intro
    @State private var sessionTimer: Timer?
    @State private var loopTimer: Timer?
    @State private var totalTimeElapsed: Double = 0.0
    
    // MARK: - Motion & Kinematics
    @State private var pathOffset: CGFloat = 0.0
    @State private var userX: CGFloat = UIScreen.main.bounds.width / 2
    @State private var isAligned: Bool = false
    
    // Physics / Path generation variables
    @State private var baseTime: Double = 0.0
    private let screenWidth = UIScreen.main.bounds.width
    private let centerY = UIScreen.main.bounds.height * 0.6
    
    // Feedback
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    @State private var lastHapticTime: Double = 0.0

    enum FlowPhase {
        case intro             // Just looking, getting ready
        case stabilization     // 0-15s: Auto-path breathing
        case alignment         // 15-60s: User tracing, simple path
        case deepFlow          // 60-90s: Dual layer, focus lock
        case exit              // 90s+: Fade out and calm
    }
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.appBG.ignoresSafeArea()
            
            if phase == .deepFlow || phase == .exit {
                // Background wave field for Deep Flow
                Circle()
                    .fill(Color.soberBlue.opacity(0.1))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .scaleEffect(isAligned ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAligned)
            }
            
            // Top Bar
            VStack {
                HStack {
                    Button {
                        cleanUp()
                        requestDismiss()
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
            
            // Central Flow Elements
            ZStack {
                // The Path (Invisible rhythm line shown as glowing trace)
                if phase != .intro && phase != .exit {
                    PathLine(xOffset: pathOffset, phase: phase, isAligned: isAligned)
                }
                
                // The User Node
                if phase == .alignment || phase == .deepFlow {
                    UserNode(x: userX, isAligned: isAligned)
                        .position(x: userX, y: centerY)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // Limit drag bounds
                                    userX = max(40, min(screenWidth - 40, value.location.x))
                                }
                        )
                }
                
                // Auto Node (Phase 1)
                if phase == .stabilization {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .blur(radius: 2)
                        .position(x: screenWidth / 2 + pathOffset, y: centerY)
                }
                
                // Overlay Text Directives
                if phase == .intro {
                    introMessage
                } else if phase == .stabilization && totalTimeElapsed < 5 {
                    engineMessage("Sadece izle ve nefes al...")
                } else if phase == .alignment && totalTimeElapsed > 15 && totalTimeElapsed < 22 {
                    engineMessage("Dokun ve akışı takip et...")
                } else if phase == .deepFlow && totalTimeElapsed > 60 && totalTimeElapsed < 65 {
                    engineMessage("Pürüzsüz ritmi koru...")
                } else if phase == .exit {
                    exitMessage
                }
            }
        }
        .onAppear {
            impactLight.prepare()
            impactSoft.prepare()
        }
        .onDisappear {
            cleanUp()
        }
    }
    
    // MARK: - Views
    
    private var introMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "aqi.medium")
                .font(.system(size: 40))
                .foregroundStyle(Color.soberBlue)
            
            Text("Flow Trace")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Tıklama yok. Hedef yok. \nSadece merkezi akışla hizalan.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                startEngine()
            } label: {
                Text("Hizalan")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.soberBlue))
            }
            .padding(.top, 24)
        }
        .transition(.opacity)
    }
    
    private func engineMessage(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Color.textSecondary)
            .position(x: screenWidth / 2, y: centerY - 120)
            .transition(.opacity)
    }
    
    private var exitMessage: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.aquaTeal)
            
            Text("Kontrol Sende")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Dürtü dalgası kırıldı.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textSecondary)
            
            Button {
                cleanUp()
                onComplete(100)
            } label: {
                Text("Devreye Dön")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.aquaTeal))
            }
            .padding(.top, 20)
        }
        .transition(.opacity)
    }
    
    // MARK: - Engine Logic
    
    private func startEngine() {
        impactLight.impactOccurred()
        
        withAnimation(.easeOut(duration: 1.0)) {
            phase = .stabilization
        }
        
        totalTimeElapsed = 0.0
        baseTime = 0.0
        
        // Master Loop ~60fps logic clock
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            tick()
        }
    }
    
    private func cleanUp() {
        sessionTimer?.invalidate()
        loopTimer?.invalidate()
    }
    
    private func tick() {
        let dt = 0.016
        totalTimeElapsed += dt
        baseTime += dt
        
        // 1. Calculate Path Physics
        let targetSpeed = phase == .deepFlow ? 0.8 : 0.5 // Radians per sec multiplier
        var currentAmplitude: CGFloat = 80.0
        
        if phase == .deepFlow {
            // Complex path
            let wave1 = sin(baseTime * targetSpeed) * currentAmplitude
            let wave2 = cos(baseTime * 1.3) * (currentAmplitude * 0.4)
            pathOffset = wave1 + wave2
        } else {
            // Simple path
            pathOffset = sin(baseTime * targetSpeed) * currentAmplitude
        }
        
        // 2. Alignment Logic
        let pathCenter = screenWidth / 2 + pathOffset
        
        if phase == .alignment || phase == .deepFlow {
            let distance = abs(userX - pathCenter)
            let wasAligned = isAligned
            isAligned = distance < 35.0 // Margin of alignment
            
            if isAligned && !wasAligned {
                // Gentle pulse on entry
                if totalTimeElapsed - lastHapticTime > 0.5 {
                    impactSoft.impactOccurred()
                    lastHapticTime = totalTimeElapsed
                }
            }
        }
        
        // 3. Phase Controller
        DispatchQueue.main.async {
            switch totalTimeElapsed {
            case 15.0...15.1 where phase == .stabilization:
                withAnimation(.easeInOut(duration: 2.0)) {
                    phase = .alignment
                    userX = screenWidth / 2
                }
            case 60.0...60.1 where phase == .alignment:
                withAnimation(.easeInOut(duration: 2.0)) {
                    phase = .deepFlow
                }
            case 90.0...90.1 where phase == .deepFlow:
                withAnimation(.easeInOut(duration: 3.0)) {
                    phase = .exit
                }
            default:
                break
            }
        }
    }
}

// MARK: - Subcomponents

struct PathLine: View {
    var xOffset: CGFloat
    var phase: FlowTraceEngineView.FlowPhase
    var isAligned: Bool
    
    var body: some View {
        let pathColor = isAligned ? Color.soberBlue : Color.white.opacity(0.3)
        let strokeWidth = isAligned ? 6.0 : 4.0
        
        GeometryReader { geo in
            Path { path in
                let mx = geo.size.width / 2 + xOffset
                let startY: CGFloat = 0
                let endY = geo.size.height
                
                path.move(to: CGPoint(x: mx, y: startY))
                path.addLine(to: CGPoint(x: mx, y: endY))
            }
            .stroke(pathColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .blur(radius: isAligned ? 4.0 : 0.0)
            .animation(.interactiveSpring(), value: xOffset)
            .animation(.easeInOut, value: isAligned)
        }
        .opacity(phase == .deepFlow ? 0.6 : 1.0)
    }
}

struct UserNode: View {
    var x: CGFloat
    var isAligned: Bool
    
    var body: some View {
        ZStack {
            // Halo
            Circle()
                .fill(isAligned ? Color.soberBlue.opacity(0.2) : Color.clear)
                .frame(width: 80, height: 80)
            
            // Core core
            Circle()
                .strokeBorder(isAligned ? Color.soberBlue : Color.white.opacity(0.5), lineWidth: 3)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.appBG))
            
            if isAligned {
                Circle()
                    .fill(Color.soberBlue)
                    .frame(width: 16, height: 16)
            }
        }
        .animation(.interactiveSpring(response: 0.1, dampingFraction: 0.8), value: x)
        .animation(.easeInOut(duration: 0.2), value: isAligned)
    }
}
