//
//  HealthMilestone.swift
//  quitly
//
//  PMO Recovery health milestones — science-backed dopamine & testosterone data
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
        // ── First 72 Hours — Withdrawal & Dopamine ────────────
        .init(hours: 24,  icon: "brain.head.profile",                    titleKey: "milestone_24hr_title",  descKey: "milestone_24hr_desc",  color: .soberBlue),
        .init(hours: 48,  icon: "bolt.fill",                             titleKey: "milestone_48hr_title",  descKey: "milestone_48hr_desc",  color: .soberBlue),
        .init(hours: 72,  icon: "arrow.up.heart.fill",                   titleKey: "milestone_72hr_title",  descKey: "milestone_72hr_desc",  color: .aquaTeal),

        // ── First Week — Dopamine Receptors ───────────────────
        .init(hours: 168,  icon: "sparkles",                             titleKey: "milestone_1w_title",    descKey: "milestone_1w_desc",    color: .aquaTeal),

        // ── Two Weeks — Confidence & Clarity ──────────────────
        .init(hours: 336,  icon: "eye.fill",                             titleKey: "milestone_2w_title",    descKey: "milestone_2w_desc",    color: .greenClean),

        // ── 3 Weeks — Neuroplasticity Begins ──────────────────
        .init(hours: 504,  icon: "brain.fill",                           titleKey: "milestone_3w_title",    descKey: "milestone_3w_desc",    color: .greenClean),

        // ── 30 Days — First Month ─────────────────────────────
        .init(hours: 720,  icon: "shield.fill",                          titleKey: "milestone_1mo_title",   descKey: "milestone_1mo_desc",   color: .greenClean),

        // ── 45 Days — Social Anxiety Drops ────────────────────
        .init(hours: 1080, icon: "person.2.fill",                        titleKey: "milestone_45d_title",   descKey: "milestone_45d_desc",   color: .amberGold),

        // ── 60 Days — Energy & Motivation ─────────────────────
        .init(hours: 1440, icon: "figure.strengthtraining.traditional",  titleKey: "milestone_60d_title",   descKey: "milestone_60d_desc",   color: .amberGold),

        // ── 90 Days — THE REBOOT (Classic NoFap Goal) ─────────
        .init(hours: 2160, icon: "crown.fill",                           titleKey: "milestone_90d_title",   descKey: "milestone_90d_desc",   color: .goldAccent),

        // ── 6 Months — Long-term Rewire ───────────────────────
        .init(hours: 4320, icon: "face.smiling.inverse",                 titleKey: "milestone_6mo_title",   descKey: "milestone_6mo_desc",   color: .goldAccent),

        // ── 9 Months — Deep Neurological Change ───────────────
        .init(hours: 6480, icon: "brain.fill",                           titleKey: "milestone_9mo_title",   descKey: "milestone_9mo_desc",   color: .goldAccent),

        // ── 1 Year — New Identity ─────────────────────────────
        .init(hours: 8760, icon: "trophy.fill",                          titleKey: "milestone_1yr_title",   descKey: "milestone_1yr_desc",   color: .goldAccent),

        // ── 2 Years — Permanent Change ────────────────────────
        .init(hours: 17520, icon: "medal.fill",                          titleKey: "milestone_2yr_title",   descKey: "milestone_2yr_desc",   color: .goldAccent),
    ]

    var timeLabel: String {
        switch hours {
        case 24:    return "1d"
        case 48:    return "2d"
        case 72:    return "3d"
        case 168:   return "1w"
        case 336:   return "2w"
        case 504:   return "3w"
        case 720:   return "30d"
        case 1080:  return "45d"
        case 1440:  return "60d"
        case 2160:  return "90d"
        case 4320:  return "6mo"
        case 6480:  return "9mo"
        case 8760:  return "1yr"
        case 17520: return "2yr"
        default:    return "\(Int(hours))h"
        }
    }
}

