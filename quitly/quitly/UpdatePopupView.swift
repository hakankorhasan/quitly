//
//  UpdatePopupView.swift
//  quitly
//
//  Yeni güncelleme mevcut olduğunda gösterilen premium görünümlü popup.
//

import SwiftUI

struct UpdatePopupView: View {
    let latestVersion: String
    let appStoreURL: String
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var iconPulse = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(appeared ? 0.65 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Popup card
            VStack(spacing: 0) {
                // ── Glow circle + icon ──────────────────────────
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color.fireOrange.opacity(0.20))
                        .frame(width: 120, height: 120)
                        .blur(radius: 30)

                    // Icon circle
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.fireOrange, Color.purpleAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)

                        Image(systemName: "arrow.down.app.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(iconPulse ? 1.08 : 1.0)
                    }
                    .shadow(color: Color.fireOrange.opacity(0.4), radius: 12)
                }
                .padding(.top, 32)

                Spacer().frame(height: 24)

                // ── Title ──────────────────────────────────────
                Text(NSLocalizedString("update_title", comment: ""))
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 8)

                // ── Subtitle ───────────────────────────────────
                Text(NSLocalizedString("update_subtitle", comment: ""))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer().frame(height: 12)

                // ── Version badge ──────────────────────────────
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.greenClean)
                        .frame(width: 8, height: 8)
                    Text("v\(latestVersion)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.greenClean)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.greenClean.opacity(0.12))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.greenClean.opacity(0.25), lineWidth: 1)
                        )
                )

                Spacer().frame(height: 28)

                // ── Update button ──────────────────────────────
                Button {
                    openAppStore()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(NSLocalizedString("update_button", comment: ""))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppGradient.fire)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                Spacer().frame(height: 12)

                // ── Later button ───────────────────────────────
                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("update_later", comment: ""))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textMuted)
                }

                Spacer().frame(height: 24)
            }
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.cardBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.fireOrange.opacity(0.3), Color.purpleAccent.opacity(0.15), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.fireOrange.opacity(0.15), radius: 40, y: 10)
            )
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: appeared)
        .onAppear {
            appeared = true
            iconPulse = true
        }
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: iconPulse)
    }

    // MARK: - Actions

    private func openAppStore() {
        guard let url = URL(string: appStoreURL), !appStoreURL.isEmpty else { return }
        UIApplication.shared.open(url)
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
