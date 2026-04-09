//
//  MotivationEngine.swift
//  quitly
//

import Foundation

final class MotivationEngine {
    static let shared = MotivationEngine()
    
    // We have 200 quotes synced to Localizable.xcstrings as mq_quote_0 to mq_quote_199
    let totalQuotesCount = 200
    
    private var unshownIndexes: [Int] = []

    init() {
        unshownIndexes = Array(0..<totalQuotesCount).shuffled()
    }

    func getRandomQuote() -> String {
        if unshownIndexes.isEmpty {
            unshownIndexes = Array(0..<totalQuotesCount).shuffled()
        }
        let index = unshownIndexes.removeLast()
        return NSLocalizedString("mq_quote_\(index)", comment: "Motivational quote")
    }
}
