//
//  JournalInterventionView.swift
//  quitly
//
//  Journaling interface for logging feelings during an urge.
//

import SwiftUI

struct JournalEntry: Codable, Identifiable {
    var id = UUID()
    var timestamp: Date
    var text: String
    var mood: String
    var urgeLevel: Int // 1-10
}

@Observable
class JournalStore {
    static let shared = JournalStore()
    private let key = "journal_entries_v1"
    
    private(set) var entries: [JournalEntry] = []
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func add(text: String, mood: String, urgeLevel: Int) {
        let entry = JournalEntry(timestamp: Date(), text: text, mood: mood, urgeLevel: urgeLevel)
        entries.insert(entry, at: 0) // Newest first
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct JournalInterventionView: View {
    var onComplete: () -> Void
    var requestDismiss: () -> Void
    
    @State private var text: String = .init()
    @State private var urgeLevel: Double = 5.0
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        requestDismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textMuted)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }
                    
                    Spacer()
                    
                    Text("Duygusal Boşaltım")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        saveAndComplete()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(text.isEmpty ? Color.textMuted : Color.greenClean)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }
                    .disabled(text.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Prompt
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Şu an ne hissediyorsun?")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Bu dürtüyü ne tetikledi? İçindekileri yaz.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                        }
                        
                        // Text Area
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Buraya yaz...\nFiltrelemeden, dürüstçe.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(Color.textMuted)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                            }
                            
                            TextEditor(text: $text)
                                .focused($isFocused)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 180)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(isFocused ? Color.soberBlue.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                        
                        // Urge Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dürtü Şiddeti: \(Int(urgeLevel))/10")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.textSecondary)
                            
                            HStack {
                                Text("1")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.textMuted)
                                
                                Slider(value: $urgeLevel, in: 1...10, step: 1)
                                    .tint(.soberBlue)
                                
                                Text("10")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.textMuted)
                            }
                        }
                        .padding(.top, 16)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    
    private func saveAndComplete() {
        let entryText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !entryText.isEmpty else { return }
        
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        
        JournalStore.shared.add(text: entryText, mood: "neutral", urgeLevel: Int(urgeLevel))
        
        isFocused = false
        onComplete()
    }
}
