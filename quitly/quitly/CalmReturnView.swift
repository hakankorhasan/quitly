//
//  CalmReturnView.swift
//  quitly
//
//  The success / completion screen after any Urge Intervention.
//

import SwiftUI

struct CalmReturnView: View {
    var onDismiss: () -> Void

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            // Very soft, dark background
            LinearGradient(
                colors: [Color.appBG, Color.cardBG],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Soft glow
            Circle()
                .fill(Color.aquaTeal.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -50)

            VStack(spacing: 32) {
                // Calm Icon
                ZStack {
                    Circle()
                        .strokeBorder(Color.aquaTeal.opacity(0.2), lineWidth: 1)
                        .frame(width: 120, height: 120)
                        
                    Circle()
                        .fill(Color.aquaTeal.opacity(0.08))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.aquaTeal)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                // Message
                VStack(spacing: 12) {
                    Text(NSLocalizedString("calm_return_title", comment: ""))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(NSLocalizedString("calm_return_desc", comment: ""))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                .offset(y: textOffset)
                .opacity(contentOpacity)

                Spacer().frame(height: 40)

                // Continue Button
                Button {
                    let gen = UINotificationFeedbackGenerator()
                    gen.notificationOccurred(.success)
                    onDismiss()
                } label: {
                    Text(NSLocalizedString("calm_return_continue", comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.aquaTeal)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.aquaTeal.opacity(0.1))
                                .overlay(Capsule().strokeBorder(Color.aquaTeal.opacity(0.3), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
                .offset(y: textOffset)
                .opacity(contentOpacity)
            }
        }
        .onAppear {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                textOffset = 0
                contentOpacity = 1.0
            }
        }
    }
}
