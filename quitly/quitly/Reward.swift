//
//  Reward.swift
//  quitly
//

import Foundation
import SwiftData

@Model
final class Reward {
    var id: UUID
    var title: String
    var price: Double
    var iconName: String
    var isPurchased: Bool
    var createdAt: Date
    
    var habit: Habit?

    init(
        title: String,
        price: Double,
        iconName: String = "gift.fill",
        isPurchased: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.price = price
        self.iconName = iconName
        self.isPurchased = isPurchased
        self.createdAt = Date()
    }
}
