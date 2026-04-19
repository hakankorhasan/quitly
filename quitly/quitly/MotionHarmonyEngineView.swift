//
//  MotionHarmonyEngineView.swift
//  quitly
//
//  Cognitive Reset Engine: Motion Harmony Trace
//  Synchronizes user movement with continuous evolving visual motion fields.
//

import SwiftUI

struct MotionHarmonyEngineView: View {
    var onComplete: (Int) -> Void
    var requestDismiss: () -> Void
    
    @State private var phase: MotionPhase = .observation
    @State private var loopTimer: Timer?
    @State private var totalTimeElapsed: Double = 0.0
    
    // Physics & Motion
    @State private var dragVelocity: Double = 0.0
    @State private var targetVelocity: Double = 0.0
    @State private var fieldRotation: Double = 0.0
    @State private var baseTime: Double = 0.0
    
    // Smooth trailing value for physics
    @State private var smoothedVelocity: Double = 0.0
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    @State private var lastHapticTime: Double = 0.0
    
    enum MotionPhase {
        case observation    // 0-20s: System autos
        case sync           // 20-90s: User interaction
        case dissolution    // 90s+: Fade
    }
    
    var body: some View {
        ZStack {
            Color.appBG.ignoresSafeArea()
            
            // Motion Field
            if phase != .dissolution {
                MotionFieldView(rotation: fieldRotation, stressLevel: smoothedVelocity)
            }
            
            // Touch Area Handler
            if phase == .sync {
                Color.white.opacity(0.001)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let speed = calculateDragSpeed(translation: value.translation)
                                targetVelocity = min(speed / 50.0, 1.0) // Normalize 0...1
                            }
                            .onEnded { _ in
                                // When lifting finger, velocity naturally zeroes but we don't punish immediately
                                targetVelocity = 0.1
                            }
                    )
            }
            
            VStack {
                // Top Bar
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
            
            // Overlays
            if phase == .observation && totalTimeElapsed < 5 {
                engineMessage("Akışı izle. Fiziksel olarak yavaşla.")
            } else if phase == .sync && totalTimeElapsed > 20 && totalTimeElapsed < 26 {
                engineMessage("Ekranda sürekli ve yavaş bir iz bırak...")
            } else if phase == .dissolution {
                exitMessage
            }
        }
        .onAppear {
            impactLight.prepare()
            impactSoft.prepare()
            startEngine()
        }
        .onDisappear {
            cleanUp()
        }
    }
    
    private func engineMessage(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .transition(.opacity)
    }
    
    private var exitMessage: some View {
        VStack(spacing: 24) {
            Image(systemName: "circle.dashes")
                .font(.system(size: 48))
                .foregroundStyle(Color.aquaTeal)
            
            Text("Hareket Uyumu Sağlandı")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Fiziksel hızın dengelendi.\nDürtüsel enerjin tamamen sönümlendi.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
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
    
    // MARK: - Handlers
    
    @State private var lastDragPos: CGSize = .zero
    private func calculateDragSpeed(translation: CGSize) -> Double {
        let dx = translation.width - lastDragPos.width
        let dy = translation.height - lastDragPos.height
        let dist = sqrt(dx*dx + dy*dy)
        lastDragPos = translation
        return Double(dist)
    }
    
    // MARK: - Engine Loop
    
    private func startEngine() {
        totalTimeElapsed = 0.0
        smoothedVelocity = 0.5 // Start with some chaos
        
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            tick()
        }
    }
    
    private func cleanUp() {
        loopTimer?.invalidate()
    }
    
    private func tick() {
        let dt = 0.016
        totalTimeElapsed += dt
        
        // Physics logic: Interpolate smoothedVelocity towards target
        if phase == .observation {
            // Auto calming down
            smoothedVelocity += (0.2 - smoothedVelocity) * 0.02
        } else if phase == .sync {
            // Decelerate naturally to reward slowness
            smoothedVelocity += (targetVelocity - smoothedVelocity) * 0.05
            targetVelocity *= 0.95 // Drain speed instantly if dragging stops
        }
        
        // Apply rotation
        let speedMultiplier = 1.0 + (smoothedVelocity * 15.0) // If velocity goes up, rotation spins wildly
        fieldRotation += (dt * 15.0 * speedMultiplier)
        
        // Haptic feedback locking when harmonic (velocity very low)
        if phase == .sync && smoothedVelocity < 0.15 {
            if totalTimeElapsed - lastHapticTime > (1.2 - smoothedVelocity) {
                impactSoft.impactOccurred()
                lastHapticTime = totalTimeElapsed
            }
        }
        
        // Phases Controller
        DispatchQueue.main.async {
            switch totalTimeElapsed {
            case 20.0...20.1 where phase == .observation:
                withAnimation(.easeInOut(duration: 2.0)) {
                    phase = .sync
                }
            case 90.0...90.1 where phase == .sync:
                withAnimation(.easeInOut(duration: 3.0)) {
                    phase = .dissolution
                }
            default:
                break
            }
        }
    }
}

struct MotionFieldView: View {
    var rotation: Double
    var stressLevel: Double // 0.0 (calm) to 1.0 (chaos)
    
    var body: some View {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        // 0.0 -> aquaTeal. 1.0 -> amber/red
        let calmnessFactor = 1.0 - stressLevel
        let color1 = Color.soberBlue.opacity(0.3 + (stressLevel * 0.3))
        let color2 = Color.aquaTeal.opacity(calmnessFactor * 0.5)
        let color3 = Color.amberGold.opacity(stressLevel * 0.6)
        
        ZStack {
            // Blob 1
            Circle()
                .fill(color1)
                .frame(width: w * 0.8)
                .offset(x: -w * 0.2, y: -h * 0.15)
                .blur(radius: 60)
            
            // Blob 2
            Circle()
                .fill(color2)
                .frame(width: w * 0.6)
                .offset(x: w * 0.25, y: h * 0.1)
                .blur(radius: 80)
            
            // Blob 3
            Circle()
                .fill(color3)
                .frame(width: w * 0.9)
                .offset(x: 0, y: -h * 0.05)
                .blur(radius: 50 + (calmnessFactor * 50)) // Blurs out when calm, becomes defined when chaotic
                .scaleEffect(1.0 + stressLevel * 0.3)
        }
        .rotationEffect(Angle(degrees: rotation))
        .animation(.linear(duration: 0.1), value: rotation)
        .animation(.easeInOut(duration: 0.5), value: stressLevel)
    }
}
