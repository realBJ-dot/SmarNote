//
//  ContentView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab: CaseIterable {
        case dashboard
        case events
        case voice
        case items
        
        var title: String {
            switch self {
            case .dashboard: return "Home"
            case .events: return "Events"
            case .voice: return "Voice"
            case .items: return "Items"
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .events: return "calendar"
            case .voice: return "mic.circle"
            case .items: return "bag"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .events: return "calendar.badge.checkmark"
            case .voice: return "mic.circle.fill"
            case .items: return "bag.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == .dashboard ? Tab.dashboard.selectedIcon : Tab.dashboard.icon)
                    Text(Tab.dashboard.title)
                }
                .tag(Tab.dashboard)
            
            // Events Tab
            EventsListView()
                .tabItem {
                    Image(systemName: selectedTab == .events ? Tab.events.selectedIcon : Tab.events.icon)
                    Text(Tab.events.title)
                }
                .tag(Tab.events)
            
            // Voice Tab
            VoiceRecordingView()
                .tabItem {
                    Image(systemName: selectedTab == .voice ? Tab.voice.selectedIcon : Tab.voice.icon)
                    Text(Tab.voice.title)
                }
                .tag(Tab.voice)
            
            // Items Tab
            MyItemsView()
                .tabItem {
                    Image(systemName: selectedTab == .items ? Tab.items.selectedIcon : Tab.items.icon)
                    Text(Tab.items.title)
                }
                .tag(Tab.items)
        }
        .environmentObject(coordinator)
        .environmentObject(SharedDataManager.shared)
        .accentColor(.blue)
    }
}

// MARK: - Legacy Events List View (to be refactored)
struct EventsListView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var searchText = ""
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    var filteredEvents: [Dish] {
        if searchText.isEmpty {
            return dataManager.dishes.sorted { $0.date > $1.date }
        } else {
            return dataManager.dishes.filter { dish in
                dish.title.localizedCaseInsensitiveContains(searchText) ||
                dish.details.localizedCaseInsensitiveContains(searchText) ||
                dish.items.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredEvents) { dish in
                    NavigationLink(destination: DishDetailView(dish: dish)) {
                        DishRowView(dish: dish)
                    }
                }
                .onDelete(perform: deleteEvents)
            }
            .navigationTitle("Events")
            .searchable(text: $searchText, prompt: "Search events...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filter by Date") {
                        showingDatePicker = true
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DateFilterView(selectedDate: $selectedDate) { date in
                    // Filter by selected date - to be implemented
                }
            }
        }
    }
    
    private func deleteEvents(at offsets: IndexSet) {
        let eventsToDelete = offsets.map { filteredEvents[$0] }
        for dish in eventsToDelete {
            dataManager.deleteDish(dish)
        }
    }
}

// MARK: - Legacy Items List View (to be refactored)
struct ItemsListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            List {
                ForEach(coordinator.items, id: \.self) { item in
                    Text(item)
                }
            }
            .navigationTitle("Items")
        }
    }
}

// MARK: - Date Filter View
struct DateFilterView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Filter by Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onDateSelected(selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}