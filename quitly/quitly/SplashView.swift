//
//  SplashView.swift
//  quitly
//

import SwiftUI
internal import Combine

// MARK: - Smoke Particle
private struct SmokeParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var drift: CGFloat  // yatay kayma yönü
}

// MARK: - Smoke Effect View
private struct SmokeEffectView: View {
    @State private var particles: [SmokeParticle] = []
    let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(p.opacity * 0.9),
                                Color(white: 0.8).opacity(p.opacity * 0.6),
                                Color.gray.opacity(p.opacity * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: p.size / 2
                        )
                    )
                    .frame(width: p.size, height: p.size)
                    .blur(radius: p.size * 0.22)
                    .position(x: p.x, y: p.y)
            }
        }
        .frame(width: 160, height: 280)
        .onReceive(timer) { _ in
            spawnParticle()
            updateParticles()
        }
    }

    private func spawnParticle() {
        let newP = SmokeParticle(
            x: 80 + CGFloat.random(in: -16...16),
            y: 250,
            size: CGFloat.random(in: 24...44),
            opacity: Double.random(in: 0.38...0.65),
            drift: CGFloat.random(in: -1.0...1.5)
        )
        particles.append(newP)
    }

    private func updateParticles() {
        withAnimation(.easeOut(duration: 0.08)) {
            for i in particles.indices {
                particles[i].y -= CGFloat.random(in: 3.0...5.5)
                particles[i].x += particles[i].drift
                particles[i].size += CGFloat.random(in: 1.0...2.2)
                particles[i].opacity -= 0.018
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
    @State private var smokeVisible: Bool = false

    var body: some View {
        ZStack {
            // Arka plan — uygulamanın gradient'ıyla birebir aynı
            AppGradient.background
                .ignoresSafeArea()

            // Ambient glow blob'ları (HomeView ile aynı his)
            Circle()
                .fill(Color.fireOrange.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: -60, y: -200)

            Circle()
                .fill(Color.purpleAccent.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 90)
                .offset(x: 80, y: 260)

            // App icon — tam ortada, glow ile
            ZStack {
                // Soft glow halkası
                Circle()
                    .fill(Color.fireOrange.opacity(0.18))
                    .frame(width: 380, height: 380)
                    .blur(radius: 70)
                    .opacity(glowOpacity)

                // App icon — yuvarlatılmış köşeler
                Image("splash_page")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                // Duman efekti — sağ tarafta küllerin olduğu kısım
                if smokeVisible {
                    SmokeEffectView()
                        .offset(x: 80, y: -90)
                        .opacity(iconOpacity)
                }
            }
        }
        .onAppear {
            // Icon fade-in + pop-in
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.1)) {
                glowOpacity = 1.0
            }
            // Duman biraz gecikmeli başlasın
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                smokeVisible = true
            }
            // HARDCODED LOCK — splash geçmez
        }
    }
}
