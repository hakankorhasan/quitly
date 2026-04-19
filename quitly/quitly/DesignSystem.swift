//
//  DesignSystem.swift
//  quitly
//
//  Soberli – Alcohol Recovery Design System
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    static let appBG        = Color(red: 0.035, green: 0.035, blue: 0.043) // #09090B
    static let cardBG       = Color(red: 0.094, green: 0.094, blue: 0.106) // #18181B
    static let cardSurface  = Color(red: 0.153, green: 0.153, blue: 0.165) // #27272A

    // Primary accent — electric violet (replaces soberBlue/fireOrange)
    static let soberBlue    = Color(red: 0.486, green: 0.227, blue: 0.929) // #7C3AED
    // Secondary accent — neon pink (replaces aquaTeal/purpleAccent)
    static let aquaTeal     = Color(red: 0.925, green: 0.282, blue: 0.596) // #EC4899
    // Success green - bright spring green
    static let greenClean   = Color(red: 0.204, green: 0.827, blue: 0.600) // #34D399
    // Warm amber for achievements
    static let amberGold    = Color(red: 0.984, green: 0.827, blue: 0.302) // #FCD34D
    // Gold for premium
    static let goldAccent   = Color(red: 0.984, green: 0.827, blue: 0.302) // #FCD34D

    // Legacy aliases (so existing code doesn't break)
    static let fireOrange   = soberBlue
    static let purpleAccent = aquaTeal

    // Text
    static let textPrimary  = Color(red: 0.976, green: 0.980, blue: 0.984) // #F9FAFB
    static let textSecondary = Color(red: 0.612, green: 0.639, blue: 0.686) // #9CA3AF
    static let textMuted    = Color(red: 0.294, green: 0.337, blue: 0.396) // #4B5563
}

// MARK: - Gradients
enum AppGradient {
    static let background = LinearGradient(
        colors: [Color.appBG, Color.cardBG],
        startPoint: .top, endPoint: .bottom
    )
    static let fire = LinearGradient(
        colors: [.soberBlue, Color(red: 0.349, green: 0.149, blue: 0.800)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let purple = LinearGradient(
        colors: [.aquaTeal, Color(red: 0.749, green: 0.094, blue: 0.404)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let green = LinearGradient(
        colors: [.greenClean, Color(red: 0.020, green: 0.588, blue: 0.412)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gold = LinearGradient(
        colors: [.amberGold, Color(red: 0.871, green: 0.569, blue: 0.020)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.cardBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Button Styles
struct FireButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppGradient.fire)
                    .shadow(color: Color.soberBlue.opacity(configuration.isPressed ? 0.2 : 0.5),
                            radius: 16, x: 0, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(Color.textSecondary)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    var color: Color = .aquaTeal
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(color.opacity(0.6), lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 14).fill(color.opacity(0.08)))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
