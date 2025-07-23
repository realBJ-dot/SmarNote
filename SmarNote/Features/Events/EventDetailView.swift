//
//  EventDetailView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: Event
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingShoppingView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.UI.largePadding) {
                // Header Section
                EventDetailHeaderView(
                    event: event,
                    onEdit: { showingEditView = true }
                )
                
                Divider()
                    .padding(.horizontal)
                
                // Items Section
                if !event.items.isEmpty {
                    EventDetailItemsView(
                        event: event,
                        coordinator: coordinator,
                        onStartShopping: { showingShoppingView = true }
                    )
                }
                
                // Details Section
                if !event.details.isEmpty {
                    EventDetailDetailsView(event: event)
                }
                
                // Actions Section
                EventDetailActionsView(
                    event: event,
                    onDelete: deleteEvent
                )
                
                Spacer(minLength: 20)
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
            EditEventView(event: event)
                .environmentObject(coordinator)
        }
        .sheet(isPresented: $showingShoppingView) {
            SingleEventShoppingView(event: event)
                .environmentObject(coordinator)
        }
    }
    
    private func deleteEvent() {
        coordinator.deleteEvent(event)
        dismiss()
    }
}

// MARK: - Event Detail Header View
struct EventDetailHeaderView: View {
    let event: Event
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(event.formattedDate)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Event Detail Items View
struct EventDetailItemsView: View {
    let event: Event
    let coordinator: AppCoordinator
    let onStartShopping: () -> Void
    
    private var hasAllItems: Bool {
        event.items.allSatisfy { coordinator.hasItem($0) }
    }
    
    private var availableCount: Int {
        event.items.filter { coordinator.hasItem($0) }.count
    }
    
    var body: some View {
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
                if hasAllItems {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Ready")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("\(availableCount)/\(event.items.count)")
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
                ForEach(event.items, id: \.self) { item in
                    let hasItem = coordinator.hasItem(item)
                    
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
                    .cornerRadius(AppConstants.UI.cornerRadius)
                }
            }
            .padding(.horizontal)
            
            // Start Shopping Button
            if !event.items.isEmpty && !event.isCompleted {
                Button(action: onStartShopping) {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Start Shopping")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(AppConstants.UI.cornerRadius)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Event Detail Details View
struct EventDetailDetailsView: View {
    let event: Event
    
    var body: some View {
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
            
            Text(event.details)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppConstants.UI.cornerRadius)
                .padding(.horizontal)
        }
    }
}

// MARK: - Event Detail Actions View
struct EventDetailActionsView: View {
    let event: Event
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onDelete) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Event")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(AppConstants.UI.cornerRadius)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    NavigationView {
        EventDetailView(event: Event(
            title: "Weekend Camping Trip",
            date: Date(),
            items: ["Tent", "Sleeping bag", "Flashlight", "First aid kit", "Food supplies", "Water bottles"],
            details: "Remember to check the weather forecast before leaving. Pack warm clothes and extra batteries for the flashlight."
        ))
        .environmentObject(AppCoordinator.shared)
    }
}