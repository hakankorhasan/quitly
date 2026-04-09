//
//  HealthMilestone.swift
//  quitly
//

import SwiftUI

struct HealthMilestone: Identifiable {
    let id = UUID()
    let hours: Double
    let icon: String
    let titleKey: String
    let descKey: String
    let color: Color
}

extension HealthMilestone {
    static let all: [HealthMilestone] = [
        .init(hours: 0.333, icon: "heart.fill", titleKey: "milestone_20min_title", descKey: "milestone_20min_desc", color: .fireOrange),
        .init(hours: 8,     icon: "drop.fill", titleKey: "milestone_8hr_title",   descKey: "milestone_8hr_desc",   color: .purpleAccent),
        .init(hours: 24,    icon: "bolt.heart.fill", titleKey: "milestone_24hr_title",  descKey: "milestone_24hr_desc",  color: .fireOrange),
        .init(hours: 48,    icon: "eye.fill", titleKey: "milestone_48hr_title",  descKey: "milestone_48hr_desc",  color: .purpleAccent),
        .init(hours: 72,    icon: "lungs.fill", titleKey: "milestone_72hr_title",  descKey: "milestone_72hr_desc",  color: .greenClean),
        .init(hours: 168,   icon: "bolt.fill", titleKey: "milestone_1w_title",    descKey: "milestone_1w_desc",    color: .greenClean),
        .init(hours: 336,   icon: "figure.run", titleKey: "milestone_2w_title",    descKey: "milestone_2w_desc",    color: .greenClean),
        .init(hours: 720,   icon: "wind", titleKey: "milestone_1m_title",   descKey: "milestone_1m_desc",   color: .greenClean),
        .init(hours: 2160,  icon: "dumbbell.fill", titleKey: "milestone_3m_title",    descKey: "milestone_3m_desc",    color: .goldAccent),
        .init(hours: 8760,  icon: "trophy.fill", titleKey: "milestone_1y_title",    descKey: "milestone_1y_desc",    color: .goldAccent),
    ]

    var timeLabel: String {
        switch hours {
        case 0.333: return "20m"
        case 8:     return "8h"
        case 24:    return "1d"
        case 48:    return "2d"
        case 72:    return "3d"
        case 168:   return "1w"
        case 336:   return "2w"
        case 720:   return "1mo"
        case 2160:  return "3mo"
        case 8760:  return "1yr"
        default:    return "\(Int(hours))h"
        }
    }
}
