//
//  SplashView.swift
//  quitly
//
//  Soberli – Alcohol Recovery Splash Screen
//

import SwiftUI
internal import Combine

// MARK: - Splash View
struct SplashView: View {
    @Binding var isVisible: Bool

    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0

    var body: some View {
        ZStack {
            // Solid background
            Color(red: 0.051, green: 0.051, blue: 0.102) // #0D0D1A
                .ignoresSafeArea()

            // Center icon
            Image("splash-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

            // Bottom label
            VStack {
                Spacer()
                Text("Quit Alcohol")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(white: 1).opacity(0.35))
                    .padding(.bottom, 52)
                    .opacity(iconOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    isVisible = false
                }
            }
        }
    }
}
