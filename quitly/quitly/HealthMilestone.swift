//
//  HealthMilestone.swift
//  quitly
//
//  Alcohol recovery health milestones
//

import SwiftUI

struct HealthMilestone: Identifiable {
    let id = UUID()
    let hours: Double
    let icon: String
    let titleKey: String
    let descKey: String
    let color: Color
    
    var isCustomIcon: Bool {
        icon == "liver_icon" || icon == "brain_icon" || icon == "heart_heal"
    }
}

extension HealthMilestone {
    static let all: [HealthMilestone] = [
        // ── Early Recovery (Hours) ─────────────────────────────
        .init(hours: 6,     icon: "drop.fill",          titleKey: "milestone_6hr_title",    descKey: "milestone_6hr_desc",    color: .soberBlue),
        .init(hours: 12,    icon: "arrow.triangle.2.circlepath", titleKey: "milestone_12hr_title", descKey: "milestone_12hr_desc", color: .soberBlue),
        .init(hours: 24,    icon: "brain.head.profile",  titleKey: "milestone_24hr_title",   descKey: "milestone_24hr_desc",   color: .aquaTeal),
        .init(hours: 48,    icon: "bed.double.fill",     titleKey: "milestone_48hr_title",   descKey: "milestone_48hr_desc",   color: .aquaTeal),
        .init(hours: 72,    icon: "liver.fill",          titleKey: "milestone_72hr_title",   descKey: "milestone_72hr_desc",   color: .greenClean),

        // ── Weekly Milestones ──────────────────────────────────
        .init(hours: 168,   icon: "sparkles",            titleKey: "milestone_1w_title",     descKey: "milestone_1w_desc",     color: .greenClean),
        .init(hours: 336,   icon: "stomach",             titleKey: "milestone_2w_title",     descKey: "milestone_2w_desc",     color: .greenClean),
        .init(hours: 504,   icon: "heart.fill",          titleKey: "milestone_3w_title",     descKey: "milestone_3w_desc",     color: .greenClean),
        .init(hours: 672,   icon: "liver.fill",          titleKey: "milestone_4w_title",     descKey: "milestone_4w_desc",     color: .amberGold),

        // ── Monthly Milestones ─────────────────────────────────
        .init(hours: 1008,  icon: "shield.fill",         titleKey: "milestone_6w_title",     descKey: "milestone_6w_desc",     color: .amberGold),
        .init(hours: 1344,  icon: "figure.strengthtraining.traditional", titleKey: "milestone_8w_title", descKey: "milestone_8w_desc", color: .amberGold),
        .init(hours: 2016,  icon: "crown.fill",          titleKey: "milestone_12w_title",    descKey: "milestone_12w_desc",    color: .amberGold),

        // ── Long-term Recovery ─────────────────────────────────
        .init(hours: 4320,  icon: "face.smiling.inverse",titleKey: "milestone_6mo_title",    descKey: "milestone_6mo_desc",    color: .goldAccent),
        .init(hours: 6480,  icon: "brain.fill",          titleKey: "milestone_9mo_title",    descKey: "milestone_9mo_desc",    color: .goldAccent),
        .init(hours: 8760,  icon: "trophy.fill",         titleKey: "milestone_1yr_title",    descKey: "milestone_1yr_desc",    color: .goldAccent),
        .init(hours: 17520, icon: "medal.fill",          titleKey: "milestone_2yr_title",    descKey: "milestone_2yr_desc",    color: .goldAccent),
    ]

    var timeLabel: String {
        switch hours {
        case 6:     return "6h"
        case 12:    return "12h"
        case 24:    return "1d"
        case 48:    return "2d"
        case 72:    return "3d"
        case 168:   return "1w"
        case 336:   return "2w"
        case 504:   return "3w"
        case 672:   return "1mo"
        case 1008:  return "6w"
        case 1344:  return "2mo"
        case 2016:  return "3mo"
        case 4320:  return "6mo"
        case 6480:  return "9mo"
        case 8760:  return "1yr"
        case 17520: return "2yr"
        default:    return "\(Int(hours))h"
        }
    }
}
