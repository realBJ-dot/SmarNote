//
//  DishDetailView.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/22/25.
//

import SwiftUI

// MARK: - Dish to Event Conversion Extension
// This extension allows converting legacy Dish models to Core Event models
extension Dish {
    func toEvent() -> Event {
        var event = Event(
            title: self.title,
            date: self.date,
            items: self.items,
            details: self.details
        )
        event.isCompleted = self.isCompleted
        event.completedDate = self.completedDate
        return event
    }
}

// MARK: - Simplified Event Detail View
struct DishDetailView: View {
    let dish: Dish
    @EnvironmentObject var dataManager: SharedDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingShoppingView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(dish.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button {
                            showingEditView = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(dish.date, style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
                
                // Items Section
                if !dish.items.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Items")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            // Items status indicator
                            let hasAllItems = dish.items.allSatisfy { dataManager.myItems.contains($0) }
                            let availableCount = dish.items.filter { dataManager.myItems.contains($0) }.count
                            
                            if hasAllItems {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Ready")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            } else {
                                Text("\(availableCount)/\(dish.items.count)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(dish.items, id: \.self) { item in
                                let hasItem = dataManager.myItems.contains(item)
                                
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(hasItem ? .green : .blue)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(item)
                                        .font(.body)
                                        .lineLimit(2)
                                        .foregroundColor(hasItem ? .secondary : .primary)
                                    
                                    Spacer()
                                    
                                    if hasItem {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(hasItem ? Color.green.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Start Shopping Button - moved outside items section
                if !dish.items.isEmpty && !dish.isCompleted {
                    Button(action: {
                        startShoppingForEvent()
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Start Shopping")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingShoppingView) {
                        SingleEventShoppingView(event: dish.toEvent())
                    }
                }
                
                // Details Section
                if !dish.details.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Details")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        
                        Text(dish.details)
                            .font(.body)
                            .lineSpacing(4)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                
                // Delete Button
                Button(action: deleteEvent) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Event")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditEventView(event: dish.toEvent())
        }
    }
    
    private func startShoppingForEvent() {
        // Create a shopping list for this event if one doesn't exist already
        let existingActiveList = dataManager.shoppingLists.first { list in
            list.eventIds.contains(dish.id) && list.status != .completed
        }
        
        if existingActiveList == nil {
            // Create new shopping list for this event
            let _ = dataManager.createShoppingList(eventIds: [dish.id], items: dish.items)
        }
        
        // Show the shopping view
        showingShoppingView = true
    }
    
    private func deleteEvent() {
        dataManager.deleteDish(dish)
        dismiss()
    }
}

#Preview {
    let sampleDish = Dish(
        title: "Weekend Camping Trip",
        date: Date(),
        items: ["Tent", "Sleeping bag", "Flashlight", "First aid kit", "Food supplies", "Water bottles"],
        details: "Remember to check the weather forecast before leaving. Pack warm clothes and extra batteries for the flashlight."
    )
    
    NavigationView {
        DishDetailView(dish: sampleDish)
            .environmentObject(SharedDataManager.shared)
    }
}
