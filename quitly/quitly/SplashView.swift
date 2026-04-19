//
//  SplashView.swift
//  quitly
//
//  PMO Recovery — Launch splash screen
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
            Color.appBG
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
                Text(NSLocalizedString("app_name", comment: ""))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 32)
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
