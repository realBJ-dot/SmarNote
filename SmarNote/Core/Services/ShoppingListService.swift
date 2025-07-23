//
//  ShoppingListService.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation
import Combine



// MARK: - Shopping List Service Protocol
protocol ShoppingListServiceProtocol {
    func getAllShoppingLists() -> [ShoppingList]
    func getShoppingList(by id: UUID) -> ShoppingList?
    func createShoppingList(eventIds: [UUID], items: [String]) -> ShoppingList
    func updateShoppingList(_ list: ShoppingList)
    func deleteShoppingList(_ list: ShoppingList)
    func getActiveShoppingLists() -> [ShoppingList]
    func getCompletedShoppingLists() -> [ShoppingList]
}

// MARK: - Shopping List Service Implementation
class ShoppingListService: ShoppingListServiceProtocol, ObservableObject {
    @Published internal var shoppingLists: [ShoppingList] = []
    
    private let repository: ShoppingListRepositoryProtocol
    
    init(repository: ShoppingListRepositoryProtocol = ShoppingListRepository()) {
        self.repository = repository
        loadShoppingLists()
    }
    
    // MARK: - Public Methods
    func getAllShoppingLists() -> [ShoppingList] {
        return shoppingLists.sorted { $0.createdDate > $1.createdDate }
    }
    
    func getShoppingList(by id: UUID) -> ShoppingList? {
        return shoppingLists.first { $0.id == id }
    }
    
    func createShoppingList(eventIds: [UUID], items: [String]) -> ShoppingList {
        let newList = ShoppingList(eventIds: eventIds, items: items)
        shoppingLists.append(newList)
        saveShoppingLists()
        return newList
    }
    
    func updateShoppingList(_ list: ShoppingList) {
        if let index = shoppingLists.firstIndex(where: { $0.id == list.id }) {
            shoppingLists[index] = list
            saveShoppingLists()
        }
    }
    
    func deleteShoppingList(_ list: ShoppingList) {
        shoppingLists.removeAll { $0.id == list.id }
        saveShoppingLists()
    }
    
    func getActiveShoppingLists() -> [ShoppingList] {
        return shoppingLists.filter { !$0.isCompleted }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    func getCompletedShoppingLists() -> [ShoppingList] {
        return shoppingLists.filter { $0.isCompleted }
            .sorted { $0.completedDate ?? Date() > $1.completedDate ?? Date() }
    }
    
    // MARK: - Private Methods
    private func loadShoppingLists() {
        shoppingLists = repository.loadShoppingLists()
    }
    
    private func saveShoppingLists() {
        repository.saveShoppingLists(shoppingLists)
    }
}

// MARK: - Shopping List Repository Protocol
protocol ShoppingListRepositoryProtocol {
    func loadShoppingLists() -> [ShoppingList]
    func saveShoppingLists(_ lists: [ShoppingList])
}

// MARK: - Shopping List Repository Implementation
class ShoppingListRepository: ShoppingListRepositoryProtocol {
    func loadShoppingLists() -> [ShoppingList] {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.shoppingLists) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ShoppingList].self, from: data)
        } catch {
            print("Failed to load shopping lists: \(error)")
            return []
        }
    }
    
    func saveShoppingLists(_ lists: [ShoppingList]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(lists)
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.shoppingLists)
        } catch {
            print("Failed to save shopping lists: \(error)")
        }
    }
}