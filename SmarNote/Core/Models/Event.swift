//
//  Event.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation

// MARK: - Event Model
struct Event: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var items: [String]
    var details: String
    var isCompleted: Bool = false
    var completedDate: Date?
    
    init(title: String, date: Date = Date(), items: [String] = [], details: String = "") {
        self.title = title
        self.date = date
        self.items = items
        self.details = details
    }
}

// MARK: - Event Extensions
extension Event {
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isPast: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }
    
    var isUpcoming: Bool {
        date > Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Event Status
enum EventStatus {
    case notStarted
    case inProgress
    case completed
    case overdue
    
    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .overdue: return "Overdue"
        }
    }
    
    var color: String {
        switch self {
        case .notStarted: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .overdue: return "red"
        }
    }
}

extension Event {
    var status: EventStatus {
        if isCompleted {
            return .completed
        } else if isPast {
            return .overdue
        } else if items.isEmpty {
            return .notStarted
        } else {
            return .inProgress
        }
    }
}