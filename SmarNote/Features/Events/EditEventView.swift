//
//  EditEventView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Edit Event View
struct EditEventView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var eventTitle: String
    @State private var selectedDate: Date
    @State private var items: [String]
    @State private var details: String
    @State private var showingAlert = false
    
    init(event: Event) {
        self.event = event
        self._eventTitle = State(initialValue: event.title)
        self._selectedDate = State(initialValue: event.date)
        self._items = State(initialValue: event.items)
        self._details = State(initialValue: event.details)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.UI.largePadding) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.orange, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Edit Event")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Update your event details")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    // Form (reuse from AddEventView)
                    AddEventFormView(
                        eventTitle: $eventTitle,
                        selectedDate: $selectedDate,
                        items: $items,
                        newItem: .constant(""),
                        details: $details
                    )
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: updateEvent) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Update Event")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppConstants.UI.cornerRadius)
                        }
                        .disabled(eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(AppConstants.UI.cornerRadius)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Event Updated", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(eventTitle) has been updated!")
        }
    }
    
    private func updateEvent() {
        let trimmed = eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var updatedEvent = event
        updatedEvent.title = trimmed
        updatedEvent.date = selectedDate
        updatedEvent.items = items
        updatedEvent.details = details
        
        coordinator.updateEvent(updatedEvent)
        showingAlert = true
    }
}

#Preview {
    EditEventView(event: Event(
        title: "Sample Event",
        date: Date(),
        items: ["item1", "item2"],
        details: "Sample details"
    ))
    .environmentObject(AppCoordinator.shared)
}