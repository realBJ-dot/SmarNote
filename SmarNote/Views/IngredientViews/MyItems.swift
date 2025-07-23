//
//  MyItems.swift
//  Yes!Chef
//
//  Created by 金培元 on 7/10/25.
//


import SwiftUI

// MARK: - Modern My Items View
struct MyItemsView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var showingClearAlert = false
    @State private var newItemText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var filteredItems: [String] {
        return dataManager.myItems.sorted()
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
                            
                            Image(systemName: "bag.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("My Items")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Manage your inventory of available items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    // Add Item Section
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRowHeader(
                            icon: "plus.circle.fill",
                            label: "Add New Item",
                            color: .blue
                        )
                        
                        HStack(spacing: 12) {
                            TextField("Enter item name...", text: $newItemText)
                                .textFieldStyle(ModernTextFieldStyle())
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    addItem()
                                }
                            
                            Button(action: {
                                addItem()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            }
                            .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Items List Section
                    if filteredItems.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "bag.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.gray, .secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            
                            Text("No items yet!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("Add items above to build your inventory")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(16)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                DetailRowHeader(
                                    icon: "checkmark.circle.fill",
                                    label: "Your Items",
                                    color: .green
                                )
                                
                                Spacer()
                                
                                Text("\(filteredItems.count) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(filteredItems, id: \.self) { item in
                                    ModernMyItemRow(item: item)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(16)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        showingClearAlert = true
                    }
                    .foregroundColor(.red)
                    .disabled(dataManager.myItems.isEmpty)
                }
            }
            .alert("Clear All Items", isPresented: $showingClearAlert) {
                Button("Clear All", role: .destructive) {
                    dataManager.clearAllItems()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to remove all items from your inventory? This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func addItem() {
        let trimmedName = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedName.isEmpty && !dataManager.myItems.contains(trimmedName) {
            // Use the proper data manager method
            dataManager.addItem(trimmedName)
            newItemText = ""
            isTextFieldFocused = false
            
            // Add haptic feedback
            let haptics = UIImpactFeedbackGenerator(style: .light)
            haptics.impactOccurred()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        for item in itemsToDelete {
            dataManager.removeItem(item)
        }
    }
}

// MARK: - Modern My Item Row
struct ModernMyItemRow: View {
    let item: String
    @EnvironmentObject var dataManager: SharedDataManager
    
    var eventsNeedingItem: [Dish] {
        return dataManager.dishes.filter { event in
            !event.isCompleted && event.items.contains(item)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .font(.title3)
                
                Text(item)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {
                    dataManager.removeItem(item)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !eventsNeedingItem.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Text("Used in \(eventsNeedingItem.count) event\(eventsNeedingItem.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Legacy My Item Row (for compatibility)
struct MyItemRow: View {
    let item: String
    @EnvironmentObject var dataManager: SharedDataManager
    
    var eventsNeedingItem: [Dish] {
        return dataManager.dishes.filter { event in
            !event.isCompleted && event.items.contains(item)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item)
                    .font(.headline)
            }
            
            Spacer()
            
            if !eventsNeedingItem.isEmpty {
                Text("\(eventsNeedingItem.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MyItemsView()
        .environmentObject(SharedDataManager.shared)
}
