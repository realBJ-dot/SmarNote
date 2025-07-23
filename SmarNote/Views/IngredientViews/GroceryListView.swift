//
//  GroceryListView.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/28/25.
//

import SwiftUI

// MARK: - Modern Shopping List Generator View
struct GroceryListGeneratorView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var selectedEvents: Set<UUID> = []
    @State private var shoppingList: [String] = []
    @State private var checkedItems: Set<String> = []
    @State private var showingCompletionAlert = false
    @State private var currentShoppingList: ShoppingList?
    @Environment(\.dismiss) private var dismiss
    
    var upcomingEvents: [Dish] {
        let calendar = Calendar.current
        return dataManager.dishes.filter { event in
            // Include today and future events
            event.date >= calendar.startOfDay(for: Date())
        }.sorted { $0.date < $1.date }
    }
    
    // Break down complex expressions into computed properties
    private var isShoppingComplete: Bool {
        checkedItems.count == shoppingList.count
    }
    
    private var completionButtonIcon: String {
        isShoppingComplete ? "checkmark.circle.fill" : "cart.fill"
    }
    
    private var completionButtonText: String {
        isShoppingComplete ? "All items collected!" : "Finish Shopping"
    }
    
    private var completionButtonColors: [Color] {
        isShoppingComplete ? [.green, .blue] : [.blue, .purple]
    }
    
    private var completionButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: completionButtonColors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "cart.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Shopping List")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Generate a shopping list from your upcoming events")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    if upcomingEvents.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.gray, .secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            
                            Text("No upcoming events")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("Add some events to generate shopping lists")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(16)
                    } else {
                        // Event selection section
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRowHeader(
                                icon: "calendar.badge.checkmark",
                                label: "Select Events",
                                color: .blue
                            )
                            
                            Text("Choose which events to prepare for:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(upcomingEvents) { event in
                                    ModernEventSelectionRow(
                                        event: event,
                                        isSelected: selectedEvents.contains(event.id),
                                        onToggle: { toggleEventSelection(event.id) }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(16)
                        
                        // Generated shopping list section
                        if !shoppingList.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    DetailRowHeader(
                                        icon: "list.bullet.circle.fill",
                                        label: "Shopping List",
                                        color: .green
                                    )
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(shoppingList.count) items")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(checkedItems.count) collected")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                Text("Tap items as you collect them")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                LazyVStack(spacing: 8) {
                                    ForEach(shoppingList.sorted(), id: \.self) { item in
                                        ModernShoppingListItem(
                                            item: item,
                                            isChecked: checkedItems.contains(item),
                                            onToggle: { toggleCheckedItem(item) }
                                        )
                                    }
                                }
                                
                                // Complete Shopping button
                                if !checkedItems.isEmpty {
                                    Button(action: {
                                        showingCompletionAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: completionButtonIcon)
                                            Text(completionButtonText)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(completionButtonGradient)
                                        .cornerRadius(12)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(16)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !shoppingList.isEmpty {
                        Button("Share") {
                            shareShoppingList()
                        }
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    }
                }
            }
            .onChange(of: selectedEvents) { _, _ in
                generateShoppingList()
            }
            .onChange(of: checkedItems) { _, _ in
                updateShoppingListStatus()
            }
            .alert("Shopping Complete!", isPresented: $showingCompletionAlert) {
                Button("Finish") {
                    completeShoppingList()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if isShoppingComplete {
                    Text("You've collected all items for your selected events. Great job!")
                } else {
                    Text("You've collected \(checkedItems.count) out of \(shoppingList.count) items. Are you sure you want to finish shopping?")
                }
            }
        }
    }
    
    private func toggleEventSelection(_ eventId: UUID) {
        if selectedEvents.contains(eventId) {
            selectedEvents.remove(eventId)
        } else {
            selectedEvents.insert(eventId)
        }
    }
    
    private func toggleCheckedItem(_ item: String) {
        if checkedItems.contains(item) {
            checkedItems.remove(item)
            // Remove from my items when unchecked
            dataManager.removeItem(item)
        } else {
            checkedItems.insert(item)
            // Add to my items when checked
            dataManager.addItem(item)
            
            // Haptic feedback when checking an item
            let haptics = UIImpactFeedbackGenerator(style: .light)
            haptics.impactOccurred()
        }
    }
    
    private func generateShoppingList() {
        let selectedEventsArray = upcomingEvents.filter { selectedEvents.contains($0.id) }
        
        // Collect all items from selected events
        var allNeededItems: [String] = []
        for event in selectedEventsArray {
            allNeededItems.append(contentsOf: event.items)
        }
        
        // Remove duplicates
        shoppingList = Array(Set(allNeededItems))
        
        // Pre-check items that are already in myItems
        checkedItems = Set(shoppingList.filter { dataManager.myItems.contains($0) })
        
        // Create or update shopping list in data manager
        if !shoppingList.isEmpty {
            let eventIds = Array(selectedEvents)
            if let existingList = currentShoppingList {
                // Update existing list
                var updatedList = existingList
                updatedList.status = checkedItems.isEmpty ? .notStarted : .inProgress(checkedItems: checkedItems)
                dataManager.updateShoppingList(updatedList)
                currentShoppingList = updatedList
            } else {
                // Create new list
                let newList = dataManager.createShoppingList(eventIds: eventIds, items: shoppingList)
                currentShoppingList = newList
            }
        }
    }
    
    private func updateShoppingListStatus() {
        guard let shoppingList = currentShoppingList else { return }
        
        var updatedList = shoppingList
        if checkedItems.isEmpty {
            updatedList.status = .notStarted
        } else {
            updatedList.status = .inProgress(checkedItems: checkedItems)
        }
        
        dataManager.updateShoppingList(updatedList)
        currentShoppingList = updatedList
    }
    
    private func completeShoppingList() {
        guard let shoppingList = currentShoppingList else { return }
        
        var completedList = shoppingList
        completedList.status = .completed
        completedList.completedDate = Date()
        completedList.completedItemsCount = checkedItems.count
        
        dataManager.updateShoppingList(completedList)
    }
    
    private func shareShoppingList() {
        // Break down complex chained operations
        let selectedEventsForSharing = upcomingEvents.filter { selectedEvents.contains($0.id) }
        let eventTitles = selectedEventsForSharing.map { $0.title }
        let selectedEventNames = eventTitles.joined(separator: ", ")
        
        // Break down complex map operation
        let sortedItems = shoppingList.sorted()
        let formattedItems = sortedItems.map { item in
            let status = checkedItems.contains(item) ? "✅" : "☐"
            return "\(status) \(item)"
        }
        let itemsList = formattedItems.joined(separator: "\n")
        
        let shareText = """
        Shopping List for: \(selectedEventNames)
        
        \(itemsList)
        
        Generated from Events App
        """
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
}

// MARK: - Modern Event Selection Row
struct ModernEventSelectionRow: View {
    let event: Dish
    let isSelected: Bool
    let onToggle: () -> Void
    
    // Break down complex expressions into computed properties
    private var selectionIconColors: [Color] {
        isSelected ? [.blue, .purple] : [.gray, .secondary]
    }
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var dateGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: selectionIconColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .font(.title2)
                
                // Date indicator
                VStack(spacing: 4) {
                    Text(event.date, format: .dateTime.day())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(dateGradient)
                    
                    Text(event.date, format: .dateTime.month(.abbreviated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                .frame(width: 40)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
                
                // Event details
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("\(event.items.count) items")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .background(backgroundGradient)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Shopping List Item Component
struct ModernShoppingListItem: View {
    let item: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    // Break down complex expressions into computed properties
    private var iconColors: [Color] {
        isChecked ? [.green, .blue] : [.blue, .purple]
    }
    
    private var backgroundColors: [Color] {
        if isChecked {
            return [Color.green.opacity(0.1), Color.blue.opacity(0.1)]
        } else {
            return [Color(.systemGray6).opacity(0.5), Color(.systemGray6).opacity(0.5)]
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: backgroundColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: iconColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(iconGradient)
                    .font(.title3)
                
                Text(item)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked)
                
                Spacer()
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(backgroundGradient)
            .cornerRadius(12)
            .animation(.easeInOut(duration: 0.2), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Legacy Event Selection Row (for compatibility)
struct EventSelectionRow: View {
    let event: Dish
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(event.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(event.items.count) items")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Legacy Shopping List Item Component (for compatibility)
struct ShoppingListItem: View {
    let item: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .blue)
                    .font(.title3)
                
                Text(item)
                    .font(.body)
                    .foregroundColor(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(isChecked ? Color.green.opacity(0.1) : Color.clear)
            .animation(.easeInOut(duration: 0.2), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    GroceryListGeneratorView()
        .environmentObject(SharedDataManager.shared)
}
