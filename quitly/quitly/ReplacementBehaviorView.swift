//
//  ReplacementBehaviorView.swift
//  quitly
//
//  Full-screen "Instead of PMO, try this" replacement behavior system.
//  Accessible from UrgeModeView and standalone from tab.
//

import SwiftUI

// MARK: - Main View (shown during urge as overlay)

struct ReplacementBehaviorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = ReplacementActivityStore.shared
    @State private var appeared = false
    @State private var completedId: UUID? = nil

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.cardSurface, Color.appBG],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Glow
            Circle()
                .fill(Color.greenClean.opacity(0.10))
                .frame(width: 350, height: 350)
                .blur(radius: 90)
                .offset(y: -100)

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Try This Instead")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Pick one and fight the urge")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(store.enabled) { activity in
                            ActivityCard(
                                activity: activity,
                                isCompleted: completedId == activity.id,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if completedId == activity.id {
                                            completedId = nil
                                        } else {
                                            completedId = activity.id
                                            let gen = UIImpactFeedbackGenerator(style: .medium)
                                            gen.impactOccurred()
                                        }
                                    }
                                }
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(x: appeared ? 0 : -20)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.78)
                                    .delay(Double(store.enabled.firstIndex(of: activity) ?? 0) * 0.06),
                                value: appeared
                            )
                        }

                        // Empty state
                        if store.enabled.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Color.textMuted)
                                Text("No activities enabled.\nGo to Manage to add some.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.textMuted)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                }
            }

            // Bottom done button
            if completedId != nil {
                VStack {
                    Spacer()
                    Button {
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.success)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Done — Urge Defeated!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    .buttonStyle(FireButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - ActivityCard

private struct ActivityCard: View {
    let activity: ReplacementActivity
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isCompleted
                                ? AnyShapeStyle(activity.swiftUIColor.opacity(0.3))
                                : AnyShapeStyle(activity.swiftUIColor.opacity(0.12))
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    activity.swiftUIColor.opacity(isCompleted ? 0.6 : 0.2),
                                    lineWidth: 1
                                )
                        )

                    Image(systemName: activity.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(activity.swiftUIColor)
                }

                // Label
                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(isCompleted ? activity.swiftUIColor : Color.textPrimary)

                    Text(isCompleted ? "✓ Done! Urge resisted." : "Tap to try this now")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(isCompleted ? activity.swiftUIColor.opacity(0.8) : Color.textMuted)
                }

                Spacer()

                // Check
                ZStack {
                    Circle()
                        .fill(isCompleted ? activity.swiftUIColor : Color.white.opacity(0.06))
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        isCompleted
                            ? AnyShapeStyle(activity.swiftUIColor.opacity(0.08))
                            : AnyShapeStyle(Color.white.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                isCompleted
                                    ? activity.swiftUIColor.opacity(0.3)
                                    : Color.white.opacity(0.07),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: isCompleted ? activity.swiftUIColor.opacity(0.15) : .clear,
                    radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Management View (from Settings/Journey)

struct ManageReplacementsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = ReplacementActivityStore.shared
    @State private var showingAddSheet = false
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .top) {
            AppGradient.background.ignoresSafeArea()

            Circle()
                .fill(Color.purpleAccent.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -100)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Text("My Alternatives")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.soberBlue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Info card
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.goldAccent)
                            Text("When an urge hits, pick one of these to redirect your energy.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.goldAccent.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.goldAccent.opacity(0.2), lineWidth: 1)
                                )
                        )

                        // Defaults section
                        sectionHeader("Built-in Activities")

                        ForEach(store.activities.filter { !$0.isCustom }) { activity in
                            ManageRow(activity: activity, store: store)
                                .opacity(appeared ? 1 : 0)
                                .animation(.easeOut(duration: 0.3).delay(Double(store.activities.firstIndex(of: activity) ?? 0) * 0.04), value: appeared)
                        }

                        // Custom section
                        if !store.activities.filter({ $0.isCustom }).isEmpty {
                            sectionHeader("My Custom Activities")
                                .padding(.top, 8)

                            ForEach(store.activities.filter { $0.isCustom }) { activity in
                                ManageRow(activity: activity, store: store, isDeletable: true)
                            }
                        }

                        // Add custom hint
                        Button {
                            showingAddSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.soberBlue)
                                Text("Add Custom Activity")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.soberBlue)
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.soberBlue.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color.soberBlue.opacity(0.25), lineWidth: 1, antialiased: true)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddActivitySheet(store: store)
        }
    }

    private func sectionHeader(_ label: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSecondary)
                .textCase(.uppercase)
                .tracking(0.6)
            Spacer()
        }
    }
}

// MARK: - Manage Row

private struct ManageRow: View {
    let activity: ReplacementActivity
    let store: ReplacementActivityStore
    var isDeletable: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            // Toggle
            Button {
                store.toggle(id: activity.id)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(activity.isEnabled ? activity.swiftUIColor.opacity(0.15) : Color.white.opacity(0.04))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    activity.isEnabled ? activity.swiftUIColor.opacity(0.3) : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    Image(systemName: activity.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(activity.isEnabled ? activity.swiftUIColor : Color.textMuted)
                }
            }
            .buttonStyle(.plain)

            Text(activity.title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(activity.isEnabled ? Color.textPrimary : Color.textMuted)

            Spacer()

            // Delete button for custom
            if isDeletable {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        store.remove(id: activity.id)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            // Toggle switch
            Toggle("", isOn: Binding(
                get: { activity.isEnabled },
                set: { _ in store.toggle(id: activity.id) }
            ))
            .tint(.soberBlue)
            .labelsHidden()
            .frame(width: 44)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

// MARK: - Add Custom Sheet

struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: ReplacementActivityStore

    @State private var title = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColorKey = "purpleAccent"

    private let iconOptions = [
        "figure.run", "dumbbell.fill", "figure.yoga", "gamecontroller.fill",
        "paintbrush.fill", "guitars.fill", "list.clipboard", "cup.and.saucer.fill",
        "car.fill", "bicycle", "leaf.fill", "pills.fill",
        "pencil.and.scribble", "photo.fill", "message.fill", "heart.fill",
        "star.fill", "bolt.fill", "flame.fill", "moon.stars.fill"
    ]

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                HStack {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("New Activity")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let activity = ReplacementActivity(
                            title: title.trimmingCharacters(in: .whitespaces),
                            icon: selectedIcon,
                            color: selectedColorKey,
                            isCustom: true,
                            isEnabled: true
                        )
                        store.add(activity)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(title.isEmpty ? Color.textMuted : Color.soberBlue)
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Preview
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedColor.opacity(0.2))
                            .frame(width: 52, height: 52)
                        Image(systemName: selectedIcon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(selectedColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title.isEmpty ? "Activity Name" : title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(title.isEmpty ? Color.textMuted : Color.textPrimary)
                        Text("Tap to try this now")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(selectedColor.opacity(0.2), lineWidth: 1))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Name field
                TextField("e.g. Go to the gym", text: $title)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // Color picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("COLOR")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .tracking(0.6)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ReplacementActivity.colorOptions, id: \.key) { opt in
                                Circle()
                                    .fill(opt.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: selectedColorKey == opt.key ? 3 : 0)
                                    )
                                    .onTapGesture { selectedColorKey = opt.key }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)

                // Icon picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("ICON")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                        .tracking(0.6)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                        ForEach(iconOptions, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.white.opacity(0.04))
                                    .frame(height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                selectedIcon == icon ? selectedColor.opacity(0.6) : Color.white.opacity(0.07),
                                                lineWidth: 1
                                            )
                                    )
                                Image(systemName: icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(selectedIcon == icon ? selectedColor : Color.textMuted)
                            }
                            .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }

    private var selectedColor: Color {
        ReplacementActivity.colorOptions.first(where: { $0.key == selectedColorKey })?.color ?? .purpleAccent
    }
}
