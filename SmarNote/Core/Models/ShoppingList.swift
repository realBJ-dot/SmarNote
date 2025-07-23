//
//  ShoppingList.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation

// MARK: - Shopping List Status
enum ShoppingListStatus: Codable, Equatable {
    case notStarted
    case inProgress(checkedItems: Set<String>)
    case completed
    
    // Custom encoding/decoding to handle Set<String>
    enum CodingKeys: String, CodingKey {
        case type
        case checkedItems
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "notStarted":
            self = .notStarted
        case "inProgress":
            let checkedItemsArray = try container.decode([String].self, forKey: .checkedItems)
            self = .inProgress(checkedItems: Set(checkedItemsArray))
        case "completed":
            self = .completed
        default:
            self = .notStarted
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .notStarted:
            try container.encode("notStarted", forKey: .type)
        case .inProgress(let checkedItems):
            try container.encode("inProgress", forKey: .type)
            try container.encode(Array(checkedItems), forKey: .checkedItems)
        case .completed:
            try container.encode("completed", forKey: .type)
        }
    }
}

// MARK: - Shopping List Model
struct ShoppingList: Identifiable, Codable {
    let id = UUID()
    let eventIds: [UUID]
    let items: [String]
    var status: ShoppingListStatus
    let createdDate: Date
    var completedDate: Date?
    var completedItemsCount: Int?
    
    init(eventIds: [UUID], items: [String]) {
        self.eventIds = eventIds
        self.items = items
        self.status = .notStarted
        self.createdDate = Date()
        self.completedItemsCount = nil
    }
}

// MARK: - Shopping List Extensions
extension ShoppingList {
    var isCompleted: Bool {
        if case .completed = status {
            return true
        }
        return false
    }
    
    var checkedItemsCount: Int {
        if case .inProgress(let checkedItems) = status {
            return checkedItems.count
        }
        return isCompleted ? items.count : 0
    }
    
    var progressPercentage: Double {
        guard !items.isEmpty else { return 0 }
        return Double(checkedItemsCount) / Double(items.count)
    }
    
    var displayStatus: String {
        switch status {
        case .notStarted:
            return "Not Started"
        case .inProgress(let checkedItems):
            return "\(checkedItems.count)/\(items.count) items"
        case .completed:
            return "Completed"
        }
    }
}