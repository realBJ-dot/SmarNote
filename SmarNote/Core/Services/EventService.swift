//
//  EventService.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation
import Combine



// MARK: - Event Service Protocol
protocol EventServiceProtocol {
    func getAllEvents() -> [Event]
    func getEvent(by id: UUID) -> Event?
    func addEvent(_ event: Event)
    func updateEvent(_ event: Event)
    func deleteEvent(_ event: Event)
    func deleteEvents(at offsets: IndexSet)
    func searchEvents(query: String) -> [Event]
    func getEventsForDate(_ date: Date) -> [Event]
    func getUpcomingEvents(limit: Int?) -> [Event]
    func getTodaysEvents() -> [Event]
    func getCompletedEvents() -> [Event]
    func markEventCompleted(_ event: Event)
    func markEventIncomplete(_ event: Event)
}

// MARK: - Event Service Implementation
class EventService: EventServiceProtocol, ObservableObject {
    @Published internal var events: [Event] = []
    
    private let repository: EventRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: EventRepositoryProtocol = EventRepository()) {
        self.repository = repository
        loadEvents()
    }
    
    // MARK: - Public Methods
    func getAllEvents() -> [Event] {
        return events.sorted { $0.date > $1.date }
    }
    
    func getEvent(by id: UUID) -> Event? {
        return events.first { $0.id == id }
    }
    
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func deleteEvents(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }
    
    func searchEvents(query: String) -> [Event] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return getAllEvents()
        }
        
        let searchTerm = query.lowercased()
        return events.filter { event in
            event.title.lowercased().contains(searchTerm) ||
            event.details.lowercased().contains(searchTerm) ||
            event.items.contains { item in
                item.lowercased().contains(searchTerm)
            }
        }.sorted { $0.date > $1.date }
    }
    
    func getEventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    func getUpcomingEvents(limit: Int? = nil) -> [Event] {
        let upcoming = events.filter { $0.isUpcoming && !$0.isCompleted }
            .sorted { $0.date < $1.date }
        
        if let limit = limit {
            return Array(upcoming.prefix(limit))
        }
        return upcoming
    }
    
    func getTodaysEvents() -> [Event] {
        return events.filter { $0.isToday }
            .sorted { $0.date < $1.date }
    }
    
    func getCompletedEvents() -> [Event] {
        return events.filter { $0.isCompleted }
            .sorted { $0.completedDate ?? Date() > $1.completedDate ?? Date() }
    }
    
    func markEventCompleted(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isCompleted = true
            events[index].completedDate = Date()
            saveEvents()
        }
    }
    
    func markEventIncomplete(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isCompleted = false
            events[index].completedDate = nil
            saveEvents()
        }
    }
    
    // MARK: - Private Methods
    private func loadEvents() {
        events = repository.loadEvents()
    }
    
    private func saveEvents() {
        repository.saveEvents(events)
    }
}

// MARK: - Event Repository Protocol
protocol EventRepositoryProtocol {
    func loadEvents() -> [Event]
    func saveEvents(_ events: [Event])
}

// MARK: - Event Repository Implementation
class EventRepository: EventRepositoryProtocol {
    func loadEvents() -> [Event] {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.events) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Event].self, from: data)
        } catch {
            print("Failed to load events: \(error)")
            return []
        }
    }
    
    func saveEvents(_ events: [Event]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(events)
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.events)
        } catch {
            print("Failed to save events: \(error)")
        }
    }
}