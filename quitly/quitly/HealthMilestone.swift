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
    
    var isCustomIcon: Bool {
        icon == "lungs" || icon == "heart_attack" || icon == "oxygen_block" || icon == "energy_flash" || icon == "burning_fire"
    }
}

extension HealthMilestone {
    static let all: [HealthMilestone] = [
        .init(hours: 0.333, icon: "heart_attack", titleKey: "milestone_20min_title", descKey: "milestone_20min_desc", color: .fireOrange),
        .init(hours: 8,     icon: "oxygen_block", titleKey: "milestone_8hr_title",   descKey: "milestone_8hr_desc",   color: .purpleAccent),
        .init(hours: 24,    icon: "energy_flash", titleKey: "milestone_24hr_title",  descKey: "milestone_24hr_desc",  color: .fireOrange),
        .init(hours: 48,    icon: "lungs",        titleKey: "milestone_48hr_title",  descKey: "milestone_48hr_desc",  color: .purpleAccent),
        .init(hours: 72,    icon: "lungs.fill", titleKey: "milestone_72hr_title",  descKey: "milestone_72hr_desc",  color: .greenClean),
        
        .init(hours: 168,   icon: "star.fill",   titleKey: "milestone_1w_title",   descKey: "milestone_1w_desc",   color: .greenClean),
        .init(hours: 336,   icon: "figure.walk", titleKey: "milestone_2w_title",   descKey: "milestone_2w_desc",   color: .greenClean),
        .init(hours: 504,   icon: "figure.run",  titleKey: "milestone_3w_title",   descKey: "milestone_3w_desc",   color: .greenClean),
        .init(hours: 672,   icon: "wind",        titleKey: "milestone_4w_title",   descKey: "milestone_4w_desc",   color: .greenClean),
        .init(hours: 840,   icon: "leaf.fill",   titleKey: "milestone_5w_title",   descKey: "milestone_5w_desc",   color: .greenClean),
        .init(hours: 1008,  icon: "shield.fill", titleKey: "milestone_6w_title",   descKey: "milestone_6w_desc",   color: .greenClean),
        .init(hours: 1176,  icon: "sun.max.fill",titleKey: "milestone_7w_title",   descKey: "milestone_7w_desc",   color: .greenClean),
        .init(hours: 1344,  icon: "moon.stars.fill", titleKey: "milestone_8w_title", descKey: "milestone_8w_desc", color: .purpleAccent),
        .init(hours: 1512,  icon: "bolt.fill",   titleKey: "milestone_9w_title",   descKey: "milestone_9w_desc",   color: .purpleAccent),
        .init(hours: 1680,  icon: "burning_fire",  titleKey: "milestone_10w_title",  descKey: "milestone_10w_desc",  color: .purpleAccent),
        .init(hours: 1848,  icon: "hare.fill",   titleKey: "milestone_11w_title",  descKey: "milestone_11w_desc",  color: .purpleAccent),
        .init(hours: 2016,  icon: "crown.fill",  titleKey: "milestone_12w_title",  descKey: "milestone_12w_desc",  color: .goldAccent),

        .init(hours: 2880,  icon: "calendar",    titleKey: "milestone_4mo_title",  descKey: "milestone_4mo_desc",  color: .goldAccent),
        .init(hours: 3600,  icon: "calendar.day.timeline.left", titleKey: "milestone_5mo_title",  descKey: "milestone_5mo_desc",  color: .goldAccent),
        .init(hours: 4320,  icon: "clock.badge.checkmark", titleKey: "milestone_6mo_title",  descKey: "milestone_6mo_desc",  color: .goldAccent),
        .init(hours: 5040,  icon: "sparkles",    titleKey: "milestone_7mo_title",  descKey: "milestone_7mo_desc",  color: .goldAccent),
        .init(hours: 5760,  icon: "medal.fill",  titleKey: "milestone_8mo_title",  descKey: "milestone_8mo_desc",  color: .goldAccent),
        .init(hours: 6480,  icon: "wand.and.stars", titleKey: "milestone_9mo_title", descKey: "milestone_9mo_desc", color: .goldAccent),
        .init(hours: 7200,  icon: "diamond.fill",titleKey: "milestone_10mo_title", descKey: "milestone_10mo_desc", color: .goldAccent),
        .init(hours: 7920,  icon: "rosette",     titleKey: "milestone_11mo_title", descKey: "milestone_11mo_desc", color: .goldAccent),
        
        .init(hours: 8760,  icon: "trophy.fill", titleKey: "milestone_1yr_title",  descKey: "milestone_1yr_desc",  color: .goldAccent),
        .init(hours: 17520, icon: "crown.fill",  titleKey: "milestone_2yr_title",  descKey: "milestone_2yr_desc",  color: .goldAccent)
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
        case 504:   return "3w"
        case 672:   return "4w"
        case 840:   return "5w"
        case 1008:  return "6w"
        case 1176:  return "7w"
        case 1344:  return "8w"
        case 1512:  return "9w"
        case 1680:  return "10w"
        case 1848:  return "11w"
        case 2016:  return "12w"
        case 2880:  return "4mo"
        case 3600:  return "5mo"
        case 4320:  return "6mo"
        case 5040:  return "7mo"
        case 5760:  return "8mo"
        case 6480:  return "9mo"
        case 7200:  return "10mo"
        case 7920:  return "11mo"
        case 8760:  return "1yr"
        case 17520: return "2yr"
        default:    return "\(Int(hours))h"
        }
    }
}
