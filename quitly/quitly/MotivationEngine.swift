//
//  MotivationEngine.swift
//  quitly
//
//  PMO Recovery — science-backed motivational quotes
//

import Foundation

final class MotivationEngine {
    static let shared = MotivationEngine()

    private let quotes: [String] = [
        // Science & Brain
        "Every day clean, your dopamine receptors are healing.",
        "At day 7, testosterone levels surge. You can feel it.",
        "90 days rewires your brain. You're building toward that.",
        "Urges peak between days 7–14. Push through — it gets easier.",
        "Your prefrontal cortex grows stronger every day you resist.",
        "Neuroplasticity is real. Your brain literally changes shape.",
        "The flatline is temporary. Your brain is recalibrating.",
        "Dopamine sensitivity increases every clean day.",
        "Three weeks in, new neural pathways are forming.",
        "Science says 90 days. Your streak is proof it's possible.",

        // Mindset & Identity
        "You are not fighting urges. You are choosing who you are.",
        "Every 'no' is a vote for the person you want to become.",
        "The urge will pass whether you act on it or not. Wait it out.",
        "Discipline is just choosing long-term you over short-term you.",
        "An urge is just a wave. Surf it, don't drown in it.",
        "The version of you that never started — that's who you left behind.",
        "You don't need it. You just think you do — that's the addiction talking.",
        "Your past doesn't predict your future. This streak does.",
        "One decision at a time. Right now, just this moment.",
        "You are not your urges. You are your responses to them.",

        // Strength & Power
        "Every push-up instead of a relapse is a superpower move.",
        "Cold shower. Right now. You'll thank yourself in 3 minutes.",
        "Get up. Move. The urge can't follow you on a run.",
        "Channel this energy. The gym is waiting.",
        "Transmute this energy into something that builds you up.",
        "Your ancestors survived hardship. You can survive an urge.",
        "This discomfort is temporary. Your strength is permanent.",
        "The strongest version of you is on the other side of this urge.",
        "You've beaten it before. You're beating it again right now.",
        "Hard mode: chosen. Easy mode is for people who stay stuck.",

        // Community & Hope
        "Thousands of others are going through this exact moment too.",
        "The 90-day reboot is real. Thousands have proven it works.",
        "You are not alone. You are part of a quiet revolution.",
        "Every man who beat this became a better version of himself.",
        "The relapse rate is high — surviving another day makes you exceptional.",
        "Your future self is watching. Make him proud.",
        "One day, this will just be something that happened, not who you are.",
        "Progress, not perfection. Keep going.",
        "The craving is the proof that you're healing.",
        "You started. That's the hardest part. Keep going.",
    ]

    private var unshownIndexes: [Int] = []

    init() {
        unshownIndexes = Array(0..<quotes.count).shuffled()
    }

    func getRandomQuote() -> String {
        if unshownIndexes.isEmpty {
            unshownIndexes = Array(0..<quotes.count).shuffled()
        }
        let index = unshownIndexes.removeLast()
        return quotes[index]
    }
}
