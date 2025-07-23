//
//  ItemService.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation
import Combine

// MARK: - Item Service Protocol
protocol ItemServiceProtocol {
    func getAllItems() -> [String]
    func addItem(_ item: String)
    func addItems(_ items: [String])
    func removeItem(_ item: String)
    func clearAllItems()
    func hasItem(_ item: String) -> Bool
    func getItemsCount() -> Int
}

// MARK: - Item Service Implementation
class ItemService: ItemServiceProtocol, ObservableObject {
    @Published internal var items: [String] = []
    
    private let repository: ItemRepositoryProtocol
    
    init(repository: ItemRepositoryProtocol = ItemRepository()) {
        self.repository = repository
        loadItems()
    }
    
    // MARK: - Public Methods
    func getAllItems() -> [String] {
        return items.sorted()
    }
    
    func addItem(_ item: String) {
        let trimmedItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty && !items.contains(trimmedItem) else { return }
        
        items.append(trimmedItem)
        saveItems()
    }
    
    func addItems(_ items: [String]) {
        for item in items {
            addItem(item)
        }
    }
    
    func removeItem(_ item: String) {
        items.removeAll { $0 == item }
        saveItems()
    }
    
    func clearAllItems() {
        items.removeAll()
        saveItems()
    }
    
    func hasItem(_ item: String) -> Bool {
        return items.contains(item)
    }
    
    func getItemsCount() -> Int {
        return items.count
    }
    
    // MARK: - Private Methods
    private func loadItems() {
        items = repository.loadItems()
    }
    
    private func saveItems() {
        repository.saveItems(items)
    }
}

// MARK: - Item Repository Protocol
protocol ItemRepositoryProtocol {
    func loadItems() -> [String]
    func saveItems(_ items: [String])
}

// MARK: - Item Repository Implementation
class ItemRepository: ItemRepositoryProtocol {
    func loadItems() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.myItems) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([String].self, from: data)
        } catch {
            print("Failed to load items: \(error)")
            return []
        }
    }
    
    func saveItems(_ items: [String]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.myItems)
        } catch {
            print("Failed to save items: \(error)")
        }
    }
}