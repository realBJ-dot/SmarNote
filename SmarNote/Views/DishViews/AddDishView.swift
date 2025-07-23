//
//  AddDishView.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/22/25.
//

import SwiftUI


// MARK: - Add Dish View
struct AddDishView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dishTitle = ""
    @State private var selectedDate = Date()
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var details = ""
    @State private var showingAlert = false
    @State private var isInTabView = false
    @State private var suggestedItems: [String] = []
    @State private var isLoadingSuggestions = false
    @State private var showingSpeechToEvent = false
    @StateObject private var aiService = AIService.shared
    
    let onAdd: (Dish) -> Void
    let parsedEvent: ParsedEvent?
    
    init(onAdd: @escaping (Dish) -> Void, parsedEvent: ParsedEvent? = nil) {
        self.onAdd = onAdd
        self.parsedEvent = parsedEvent
        self._isInTabView = State(initialValue: parsedEvent == nil) // Not in tab view if coming from voice
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    if parsedEvent != nil {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.green, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Event Ready!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Review and edit the details extracted from your speech")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top)
                    } else {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Create New Event")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Fill in the details for your upcoming event")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top)
                    }
                    
                    // Event Details Form
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRowHeader(
                                icon: "calendar.badge.checkmark",
                                label: "Event Title",
                                color: .blue
                            )
                            
                            HStack {
                                TextField("Enter event title", text: $dishTitle)
                                    .textFieldStyle(ModernTextFieldStyle())
                                
                                if parsedEvent == nil {
                                    Button(action: {
                                        showingSpeechToEvent = true
                                    }) {
                                        Image(systemName: "mic.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
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
                                TextField("Add item", text: $newItem)
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
                        
                        // AI Suggestions Section
                        if !suggestedItems.isEmpty || isLoadingSuggestions {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                DetailRowHeader(
                                    icon: "sparkles",
                                    label: "AI Suggestions",
                                    color: .orange
                                )
                                
                                if isLoadingSuggestions {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .controlSize(.small)
                                        Text("Getting suggestions...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    FlowLayout(spacing: 8) {
                                        ForEach(suggestedItems.filter { !items.contains($0) }, id: \.self) { suggestion in
                                            SuggestionChip(
                                                text: suggestion,
                                                action: { addSuggestedItem(suggestion) }
                                            )
                                        }
                                    }
                                    
                                    if !suggestedItems.filter({ !items.contains($0) }).isEmpty {
                                        Text("Tap to add items to your event")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Details Section
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRowHeader(
                                icon: "text.alignleft",
                                label: "Event Details",
                                color: .orange
                            )
                            
                            TextField("Add event details...", text: $details, axis: .vertical)
                                .textFieldStyle(ModernTextAreaStyle())
                                .lineLimit(3...6)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Voice Input Option (only if not from voice)
                    if parsedEvent == nil {
                        Button(action: {
                            showingSpeechToEvent = true
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .font(.title3)
                                Text("Describe Event with Voice")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Add Event Button
                        Button(action: addDish) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text(parsedEvent != nil ? "Create This Event" : "Add Event")
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
                            .cornerRadius(12)
                        }
                        .disabled(dishTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        // Cancel Button (only if not in tab view)
                        if !isInTabView {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Add Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isInTabView {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSpeechToEvent = true
                }) {
                    Image(systemName: "mic.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
        }
        .alert("Event Added", isPresented: $showingAlert) {
            Button("OK") {
                if !isInTabView {
                    dismiss()
                } else {
                    // Clear form for next entry
                    clearForm()
                }
            }
        } message: {
            Text("\(dishTitle) has been added!")
        }
        .onChange(of: dishTitle) { _, newTitle in
            getSuggestions(for: newTitle)
        }
        .onChange(of: selectedDate) { _, newDate in
            if !dishTitle.isEmpty {
                getSuggestions(for: dishTitle)
            }
        }
        .sheet(isPresented: $showingSpeechToEvent) {
            SpeechToEventView { parsedEvent in
                // Auto-fill the form with the parsed event
                fillFormFromParsedEvent(parsedEvent)
            }
        }
        .onAppear {
            // Auto-fill form if coming from voice recording
            if let event = parsedEvent {
                fillFormFromParsedEvent(event)
            }
        }
    }
    
    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !items.contains(trimmed) {
            items.append(trimmed)
            newItem = ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func addDish() {
        let trimmed = dishTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let newDish = Dish(
                title: trimmed,
                date: selectedDate,
                items: items,
                details: details
            )
            onAdd(newDish)
            showingAlert = true
        }
    }
    
    private func clearForm() {
        dishTitle = ""
        selectedDate = Date()
        items = []
        newItem = ""
        details = ""
        suggestedItems = []
    }
    
    private func addSuggestedItem(_ item: String) {
        if !items.contains(item) {
            items.append(item)
            // Add haptic feedback
            let haptics = UIImpactFeedbackGenerator(style: .light)
            haptics.impactOccurred()
        }
    }
    
    private func getSuggestions(for title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear previous suggestions if title is too short
        guard trimmedTitle.count >= 3 else {
            suggestedItems = []
            return
        }
        
        isLoadingSuggestions = true
        
        // Debounce the API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if the title is still the same (user hasn't changed it)
            guard dishTitle == title else { return }
            
            aiService.getSuggestedItems(for: trimmedTitle, eventDate: selectedDate) { suggestions in
                DispatchQueue.main.async {
                    isLoadingSuggestions = false
                    suggestedItems = suggestions
                }
            }
        }
    }
    
    private func fillFormFromParsedEvent(_ event: ParsedEvent) {
        dishTitle = event.title
        selectedDate = event.suggestedDate
        items = event.items
        details = event.details
        
        // Get suggestions for the new title
        getSuggestions(for: event.title)
        
        // Add haptic feedback
        let haptics = UINotificationFeedbackGenerator()
        haptics.notificationOccurred(.success)
    }
}

// MARK: - Supporting UI Components
// Note: Shared components are now in SharedUIComponents.swift and SuggestionComponents.swift

// MARK: - Helper Methods Extension
extension AddDishView {
    func deleteItem(_ item: String) {
        items.removeAll { $0 == item }
    }
}

#Preview {
    AddDishView(
        onAdd: { _ in }
    )
}
