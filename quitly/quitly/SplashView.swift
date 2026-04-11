//
//  SplashView.swift
//  quitly
//
//  Soberli – Alcohol Recovery Splash Screen
//

import SwiftUI
internal import Combine

// MARK: - Bubble Particle (replaces smoke for alcohol theme)
private struct BubbleParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var drift: CGFloat
}

// MARK: - Bubble Effect View
private struct BubbleEffectView: View {
    @State private var particles: [BubbleParticle] = []
    let timer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.soberBlue.opacity(p.opacity * 0.6),
                                Color.aquaTeal.opacity(p.opacity * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: p.size / 2
                        )
                    )
                    .frame(width: p.size, height: p.size)
                    .blur(radius: p.size * 0.15)
                    .position(x: p.x, y: p.y)
            }
        }
        .frame(width: 200, height: 300)
        .onReceive(timer) { _ in
            spawnParticle()
            updateParticles()
        }
    }

    private func spawnParticle() {
        let newP = BubbleParticle(
            x: 100 + CGFloat.random(in: -30...30),
            y: 280,
            size: CGFloat.random(in: 8...22),
            opacity: Double.random(in: 0.3...0.6),
            drift: CGFloat.random(in: -0.8...0.8)
        )
        particles.append(newP)
    }

    private func updateParticles() {
        withAnimation(.easeOut(duration: 0.12)) {
            for i in particles.indices {
                particles[i].y -= CGFloat.random(in: 2.0...4.0)
                particles[i].x += particles[i].drift
                particles[i].size += CGFloat.random(in: 0.3...0.8)
                particles[i].opacity -= 0.012
            }
            particles.removeAll { $0.opacity <= 0 || $0.y < -30 }
        }
    }
}

// MARK: - Splash View
struct SplashView: View {
    @Binding var isVisible: Bool

    @State private var iconScale: CGFloat = 0.7
    @State private var iconOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var bubblesVisible: Bool = false

    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            // Ambient glow — blue tones
            Circle()
                .fill(Color.soberBlue.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: -60, y: -200)

            Circle()
                .fill(Color.aquaTeal.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 90)
                .offset(x: 80, y: 260)

            ZStack {
                // Soft glow
                Circle()
                    .fill(Color.soberBlue.opacity(0.18))
                    .frame(width: 380, height: 380)
                    .blur(radius: 70)
                    .opacity(glowOpacity)

                // App icon
                Image("splash_page")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                // Bubble effect
                if bubblesVisible {
                    BubbleEffectView()
                        .offset(x: 0, y: -60)
                        .opacity(iconOpacity * 0.7)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.1)) {
                glowOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bubblesVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    isVisible = false
                }
            }
        }
    }
}
