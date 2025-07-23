//
//  AddEventView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Add Event View
struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var eventTitle = ""
    @State private var selectedDate = Date()
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var details = ""
    @State private var showingAlert = false
    
    let onAdd: (Event) -> Void
    let parsedEvent: ParsedEvent?
    
    init(onAdd: @escaping (Event) -> Void, parsedEvent: ParsedEvent? = nil) {
        self.onAdd = onAdd
        self.parsedEvent = parsedEvent
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.UI.largePadding) {
                    // Header Section
                    AddEventHeaderView(parsedEvent: parsedEvent)
                    
                    // Event Details Form
                    AddEventFormView(
                        eventTitle: $eventTitle,
                        selectedDate: $selectedDate,
                        items: $items,
                        newItem: $newItem,
                        details: $details
                    )
                    
                    // Action Buttons
                    AddEventActionsView(
                        eventTitle: eventTitle,
                        onAdd: addEvent,
                        onCancel: { dismiss() }
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Add Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Event Added", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(eventTitle) has been added!")
        }
        .onAppear {
            if let event = parsedEvent {
                fillFormFromParsedEvent(event)
            }
        }
    }
    
    private func addEvent() {
        let trimmed = eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newEvent = Event(
            title: trimmed,
            date: selectedDate,
            items: items,
            details: details
        )
        
        onAdd(newEvent)
        showingAlert = true
    }
    
    private func fillFormFromParsedEvent(_ event: ParsedEvent) {
        eventTitle = event.title
        selectedDate = event.suggestedDate
        items = event.items
        details = event.details
    }
}

// MARK: - Add Event Header View
struct AddEventHeaderView: View {
    let parsedEvent: ParsedEvent?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: parsedEvent != nil ? 
                            [Color.green.opacity(0.1), Color.blue.opacity(0.1)] :
                            [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: parsedEvent != nil ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: parsedEvent != nil ? 
                            [.green, .blue] : [.blue, .purple]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            
            VStack(spacing: 8) {
                Text(parsedEvent != nil ? "Event Ready!" : "Create New Event")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(parsedEvent != nil ? 
                    "Review and edit the details extracted from your speech" :
                    "Fill in the details for your upcoming event"
                )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top)
    }
}

// MARK: - Add Event Form View
struct AddEventFormView: View {
    @Binding var eventTitle: String
    @Binding var selectedDate: Date
    @Binding var items: [String]
    @Binding var newItem: String
    @Binding var details: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Section
            VStack(alignment: .leading, spacing: 12) {
                DetailRowHeader(
                    icon: "calendar.badge.checkmark",
                    label: "Event Title",
                    color: .blue
                )
                
                TextField(AppConstants.PlaceholderText.eventTitle, text: $eventTitle)
                    .textFieldStyle(ModernTextFieldStyle())
            }
            
            Divider()
            
            // Date Section
            VStack(alignment: .leading, spacing: 12) {
                DetailRowHeader(
                    icon: "calendar",
                    label: "Event Date",
                    color: .green
                )
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            
            Divider()
            
            // Items Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    DetailRowHeader(
                        icon: "list.bullet.circle",
                        label: "Items to Bring",
                        color: .purple
                    )
                    
                    Spacer()
                    
                    if !items.isEmpty {
                        Text("\(items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Add Item Input
                HStack {
                    TextField(AppConstants.PlaceholderText.addItem, text: $newItem)
                        .textFieldStyle(ModernTextFieldStyle())
                        .onSubmit {
                            addItem()
                        }
                    
                    Button("Add") {
                        addItem()
                    }
                    .disabled(newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(ModernButtonStyle(color: .purple))
                }
                
                // Items List
                if !items.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(items, id: \.self) { item in
                            ItemChip(
                                text: item,
                                onDelete: { deleteItem(item) }
                            )
                        }
                    }
                }
            }
            
            Divider()
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                DetailRowHeader(
                    icon: "text.alignleft",
                    label: "Event Details",
                    color: .orange
                )
                
                TextField(AppConstants.PlaceholderText.eventDetails, text: $details, axis: .vertical)
                    .textFieldStyle(ModernTextAreaStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(AppConstants.UI.cardCornerRadius)
    }
    
    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !items.contains(trimmed) {
            items.append(trimmed)
            newItem = ""
        }
    }
    
    private func deleteItem(_ item: String) {
        items.removeAll { $0 == item }
    }
}

// MARK: - Add Event Actions View
struct AddEventActionsView: View {
    let eventTitle: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Add Event Button
            Button(action: onAdd) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Add Event")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppConstants.UI.cornerRadius)
            }
            .disabled(eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            // Cancel Button
            Button("Cancel", action: onCancel)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(AppConstants.UI.cornerRadius)
        }
    }
}

#Preview {
    AddEventView(onAdd: { _ in })
        .environmentObject(AppCoordinator.shared)
}