//
//  AppCoordinator.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation
import Combine



// MARK: - App Coordinator
class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()
    
    // MARK: - Services
    let eventService: EventService
    let itemService: ItemService
    let shoppingListService: ShoppingListService
    let aiService: AIService
    let speechService: SpeechService
    let aiConfiguration: AIConfiguration
    
    // MARK: - Published Properties
    @Published internal var events: [Event] = []
    @Published var items: [String] = []
    @Published internal var shoppingLists: [ShoppingList] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Initialize services
        self.eventService = EventService()
        self.itemService = ItemService()
        self.shoppingListService = ShoppingListService()
        self.aiService = AIService.shared
        self.speechService = SpeechService.shared
        self.aiConfiguration = AIConfiguration.shared
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind service changes to published properties
        eventService.$events
            .assign(to: \.events, on: self)
            .store(in: &cancellables)
        
        itemService.$items
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
        
        shoppingListService.$shoppingLists
            .assign(to: \.shoppingLists, on: self)
            .store(in: &cancellables)
        
        // Setup cross-service dependencies
        setupEventItemDependencies()
    }
    
    private func setupEventItemDependencies() {
        // When items change, check if any events can be completed
        itemService.$items
            .sink { [weak self] _ in
                self?.checkEventCompletions()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        // Services automatically load their data on initialization
        // This method can be used for any additional setup
    }
    
    // MARK: - Event Management
    func addEvent(_ event: Event) {
        eventService.addEvent(event)
        checkEventCompletion(event)
    }
    
    func updateEvent(_ event: Event) {
        eventService.updateEvent(event)
        checkEventCompletion(event)
    }
    
    func deleteEvent(_ event: Event) {
        eventService.deleteEvent(event)
    }
    
    func searchEvents(query: String) -> [Event] {
        return eventService.searchEvents(query: query)
    }
    
    func getUpcomingEvents(limit: Int? = 3) -> [Event] {
        return eventService.getUpcomingEvents(limit: limit)
    }
    
    func getTodaysEvents() -> [Event] {
        return eventService.getTodaysEvents()
    }
    
    // MARK: - Item Management
    func addItem(_ item: String) {
        itemService.addItem(item)
    }
    
    func addItems(_ items: [String]) {
        itemService.addItems(items)
    }
    
    func removeItem(_ item: String) {
        itemService.removeItem(item)
        checkAllEventCompletions()
    }
    
    func hasItem(_ item: String) -> Bool {
        return itemService.hasItem(item)
    }
    
    func clearAllItems() {
        itemService.clearAllItems()
        checkAllEventCompletions()
    }
    
    // MARK: - Shopping List Management
    func createShoppingList(eventIds: [UUID], items: [String]) -> ShoppingList {
        return shoppingListService.createShoppingList(eventIds: eventIds, items: items)
    }
    
    func updateShoppingList(_ list: ShoppingList) {
        shoppingListService.updateShoppingList(list)
    }
    
    func getActiveShoppingLists() -> [ShoppingList] {
        return shoppingListService.getActiveShoppingLists()
    }
    
    // MARK: - Event Completion Logic
    private func checkEventCompletion(_ event: Event) {
        guard !event.items.isEmpty else { return }
        
        let hasAllItems = event.items.allSatisfy { itemService.hasItem($0) }
        
        if hasAllItems && !event.isCompleted {
            eventService.markEventCompleted(event)
        } else if !hasAllItems && event.isCompleted {
            eventService.markEventIncomplete(event)
        }
    }
    
    private func checkEventCompletions() {
        let incompleteEvents = events.filter { !$0.isCompleted }
        for event in incompleteEvents {
            checkEventCompletion(event)
        }
    }
    
    private func checkAllEventCompletions() {
        for event in events {
            checkEventCompletion(event)
        }
    }
    
    // MARK: - Statistics
    func getEventStatistics() -> EventStatistics {
        let totalEvents = events.count
        let todaysEvents = getTodaysEvents().count
        let upcomingEvents = getUpcomingEvents().count
        let completedEvents = events.filter { $0.isCompleted }.count
        
        return EventStatistics(
            total: totalEvents,
            today: todaysEvents,
            upcoming: upcomingEvents,
            completed: completedEvents
        )
    }
}

// MARK: - Event Statistics
struct EventStatistics {
    let total: Int
    let today: Int
    let upcoming: Int
    let completed: Int
    
    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}