//
//  Untitled.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/22/25.
//

import SwiftUI
import Foundation

// MARK: - Simplified Dish Model
struct Dish: Identifiable, Codable, Equatable {
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

// MARK: - Simplified Data Manager
class SharedDataManager: ObservableObject {
    static let shared = SharedDataManager() // Singleton
    
    @Published var dishes: [Dish] = [] {
        didSet {
            saveDishesToUserDefaults()
        }
    }
    
    @Published var shoppingLists: [ShoppingList] = [] {
        didSet {
            saveShoppingListsToUserDefaults()
        }
    }
    
    @Published var myItems: [String] = [] {
        didSet {
            saveMyItemsToUserDefaults()
        }
    }
    
    // UserDefaults keys
    private let dishesKey = "SavedDishes"
    private let shoppingListsKey = "SavedShoppingLists"
    private let myItemsKey = "SavedMyItems"
    
    private init() {
        loadLocalData()
    }
    
    // MARK: - Local Storage
    private func saveDishesToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(dishes)
            UserDefaults.standard.set(data, forKey: dishesKey)
        } catch {
            print("Failed to save dishes: \(error)")
        }
    }
    
    private func saveShoppingListsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(shoppingLists)
            UserDefaults.standard.set(data, forKey: shoppingListsKey)
        } catch {
            print("Failed to save shopping lists: \(error)")
        }
    }
    
    private func saveMyItemsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(myItems)
            UserDefaults.standard.set(data, forKey: myItemsKey)
        } catch {
            print("Failed to save my items: \(error)")
        }
    }
    
    private func loadLocalData() {
        // Load dishes
        if let dishesData = UserDefaults.standard.data(forKey: dishesKey) {
            do {
                let decoder = JSONDecoder()
                dishes = try decoder.decode([Dish].self, from: dishesData)
            } catch {
                print("Failed to load dishes: \(error)")
                dishes = []
            }
        }
        
        // Load shopping lists
        if let shoppingListsData = UserDefaults.standard.data(forKey: shoppingListsKey) {
            do {
                let decoder = JSONDecoder()
                shoppingLists = try decoder.decode([ShoppingList].self, from: shoppingListsData)
            } catch {
                print("Failed to load shopping lists: \(error)")
                shoppingLists = []
            }
        }
        
        // Load my items
        if let myItemsData = UserDefaults.standard.data(forKey: myItemsKey) {
            do {
                let decoder = JSONDecoder()
                myItems = try decoder.decode([String].self, from: myItemsData)
            } catch {
                print("Failed to load my items: \(error)")
                myItems = []
            }
        }
    }
    
    // MARK: - Dish Management
    func addDish(_ dish: Dish) {
        dishes.append(dish)
        // Check if event can be completed immediately
        checkEventCompletion(dish)
    }

    
    func deleteDish(_ dish: Dish) {
        dishes.removeAll { $0.id == dish.id }
    }
    
    func deleteDishes(at offsets: IndexSet) {
        dishes.remove(atOffsets: offsets)
    }
    
    func markEventCompleted(_ dish: Dish) {
        if let index = dishes.firstIndex(where: { $0.id == dish.id }) {
            dishes[index].isCompleted = true
            dishes[index].completedDate = Date()
        }
    }
    
    func markEventIncomplete(_ dish: Dish) {
        if let index = dishes.firstIndex(where: { $0.id == dish.id }) {
            dishes[index].isCompleted = false
            dishes[index].completedDate = nil
        }
    }
    
    // MARK: - Shopping List Management
    func createShoppingList(eventIds: [UUID], items: [String]) -> ShoppingList {
        let newList = ShoppingList(eventIds: eventIds, items: items)
        shoppingLists.append(newList)
        return newList
    }
    
    func updateShoppingList(_ list: ShoppingList) {
        if let index = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            shoppingLists[index] = list
        }
    }
    
    func deleteShoppingList(_ list: ShoppingList) {
        shoppingLists.removeAll { $0.id == list.id }
    }
    
    func addItem(_ item: String) {
        let trimmedItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedItem.isEmpty && !myItems.contains(trimmedItem) {
            myItems.append(trimmedItem)
            // Comment out this line temporarily to test:
            // checkAllEventsCompletion()
        }
    }

    func updateDish(_ dish: Dish) {
        if let index = dishes.firstIndex(where: { $0.id == dish.id }) {
            dishes[index] = dish
            // Check if updated event can be completed
            checkEventCompletion(dish)
        }
    }

    private func checkEventCompletion(_ dish: Dish) {
        guard !dish.items.isEmpty else { return }
            
            // Check if all required items are available
            let hasAllItems = dish.items.allSatisfy { myItems.contains($0) }
            
            if hasAllItems && !dish.isCompleted {
                // Mark as completed if has all items but not yet completed
                markEventCompleted(dish)
            } else if !hasAllItems && dish.isCompleted {
                // Mark as incomplete if missing items but currently marked complete
                markEventIncomplete(dish)
            }

    }

    private func checkAllEventsCompletion() {
        for dish in dishes.filter({ !$0.isCompleted }) {
            checkEventCompletion(dish)
        }
    }
    func addItems(_ items: [String]) {
        for item in items {
            addItem(item)
        }
    }
    
    func removeItem(_ item: String) {
        myItems.removeAll { $0 == item }
        // Check if any events can still be completed after removing this item
        checkAllEventsCompletion()
    }
    
    func clearAllItems() {
        myItems.removeAll()
    }
    
    // MARK: - Search & Filter Methods
    func searchDishes(query: String) -> [Dish] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return dishes
        }
        
        let searchTerm = query.lowercased()
        return dishes.filter { dish in
            dish.title.lowercased().contains(searchTerm) ||
            dish.details.lowercased().contains(searchTerm) ||
            dish.items.contains { item in
                item.lowercased().contains(searchTerm)
            }
        }
    }
    
    func activeEvents() -> [Dish] {
        return dishes.filter { !$0.isCompleted }.sorted { $0.date > $1.date }
    }
    
    func completedEvents() -> [Dish] {
        return dishes.filter { $0.isCompleted }.sorted { $0.completedDate ?? Date() > $1.completedDate ?? Date() }
    }
    
    func dishesByDate() -> [Dish] {
        return dishes.sorted { $0.date > $1.date }
    }
    
    func dishesForDate(_ date: Date) -> [Dish] {
        let calendar = Calendar.current
        return dishes.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func activeShoppingLists() -> [ShoppingList] {
        return shoppingLists.filter {
            if case .completed = $0.status { return false }
            return true
        }.sorted { $0.createdDate > $1.createdDate }
    }
    
    func completedShoppingLists() -> [ShoppingList] {
        return shoppingLists.filter {
            if case .completed = $0.status { return true }
            return false
        }.sorted { $0.completedDate ?? Date() > $1.completedDate ?? Date() }
    }
    
    // MARK: - Utility Methods
    func clearAllDishes() {
        dishes.removeAll()
    }
    
    func dishCount() -> Int {
        return dishes.count
    }
}
