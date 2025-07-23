//
//  ParsedEvent.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation



// MARK: - Parsed Event Model
struct ParsedEvent: Codable {
    let title: String
    let details: String
    let items: [String]
    let suggestedDate: Date
    
    init(title: String, details: String, items: [String], suggestedDate: Date) {
        self.title = title
        self.details = details
        self.items = items
        self.suggestedDate = suggestedDate
    }
}

// MARK: - Parsed Event Extensions
extension ParsedEvent {
    internal func toEvent() -> Event {
        return Event(
            title: title,
            date: suggestedDate,
            items: items,
            details: details
        )
    }
    
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var itemsCount: Int {
        return items.count
    }
    
    var hasItems: Bool {
        return !items.isEmpty
    }
    
    var hasDetails: Bool {
        return !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}