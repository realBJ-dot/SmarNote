//
//  FavDishView.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/22/25.
//

import SwiftUI

// MARK: - Modern Events List View
struct FavoriteDishesView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var showingAddEvent = false
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .all
    
    enum EventFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case past = "Past"
    }
    
    var filteredEvents: [Dish] {
        let events = dataManager.searchDishes(query: searchText)
        let calendar = Calendar.current
        
        switch selectedFilter {
        case .all:
            return events.sorted { $0.date > $1.date }
        case .today:
            return events.filter { calendar.isDateInToday($0.date) }
                .sorted { $0.date > $1.date }
        case .upcoming:
            return events.filter { $0.date > Date() }
                .sorted { $0.date < $1.date }
        case .past:
            return events.filter { $0.date < calendar.startOfDay(for: Date()) }
                .sorted { $0.date > $1.date }
        }
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
                                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("My Events")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Manage and track your upcoming events")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    // Filter Section
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRowHeader(
                            icon: "line.3.horizontal.decrease.circle",
                            label: "Filter Events",
                            color: .blue
                        )
                        
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(EventFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Events List
                    if filteredEvents.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: searchText.isEmpty ? "calendar.badge.plus" : "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.gray, .secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            
                            Text(searchText.isEmpty ? "No events yet!" : "No events found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            if searchText.isEmpty {
                                Text("Tap the + button to add your first event")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    showingAddEvent = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add First Event")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(16)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                DetailRowHeader(
                                    icon: "calendar.circle.fill",
                                    label: "\(selectedFilter.rawValue) Events",
                                    color: .green
                                )
                                
                                Spacer()
                                
                                Text("\(filteredEvents.count) events")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(destination: DishDetailView(dish: event)) {
                                        ModernEventRowView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search events...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddDishView { event in
                    dataManager.addDish(event)
                    showingAddEvent = false
                    
                    // Haptic feedback
                    let haptics = UINotificationFeedbackGenerator()
                    haptics.notificationOccurred(.success)
                }
            }
        }
    }
    
    private var groupedEvents: [String: [Dish]] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        return Dictionary(grouping: filteredEvents) { event in
            if calendar.isDateInToday(event.date) {
                return "Today"
            } else if calendar.isDateInTomorrow(event.date) {
                return "Tomorrow"
            } else if calendar.isDateInYesterday(event.date) {
                return "Yesterday"
            } else {
                return dateFormatter.string(from: event.date)
            }
        }
    }
    
    private func deleteEvents(from dateGroup: String, at offsets: IndexSet) {
        let eventsInGroup = groupedEvents[dateGroup] ?? []
        let eventsToDelete = offsets.map { eventsInGroup[$0] }
        
        for event in eventsToDelete {
            dataManager.deleteDish(event)
        }
    }
}
// MARK: - Modern Event Row View
struct ModernEventRowView: View {
    let event: Dish
    @EnvironmentObject var dataManager: SharedDataManager
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(event.date)
    }
    
    private var isPast: Bool {
        event.date < Calendar.current.startOfDay(for: Date())
    }
    
    private var hasAllItems: Bool {
        guard !event.items.isEmpty else { return false }
        return event.items.allSatisfy { dataManager.myItems.contains($0) }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator with modern styling
            VStack(spacing: 4) {
                Text(event.date, format: .dateTime.day())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: isToday ? [.orange, .red] : [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text(event.date, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isToday ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            )
            
            // Event details
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    // Items count with icon
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
                    
                    // Completion status
                    if hasAllItems && !event.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Ready")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Event details preview
                if !event.details.isEmpty {
                    Text(event.details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Status indicators
            VStack(spacing: 8) {
                if isToday {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 8, height: 8)
                }
                
                if event.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
        .opacity(event.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Legacy Event Row View (renamed to avoid conflict with EventCards.swift)
struct LegacyEventRowView: View {
    let event: Dish
    @EnvironmentObject var dataManager: SharedDataManager
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(event.date)
    }
    
    private var isPast: Bool {
        event.date < Calendar.current.startOfDay(for: Date())
    }
    
    private var hasAllItems: Bool {
        guard !event.items.isEmpty else { return false }
        return event.items.allSatisfy { dataManager.myItems.contains($0) }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion indicator dot
            Circle()
                .fill(hasAllItems ? Color.green : Color.clear)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(hasAllItems ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Date indicator
            VStack(spacing: 2) {
                Text(event.date, format: .dateTime.day())
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(event.date, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 40)
            .foregroundColor(isToday ? .blue : (event.isCompleted ? .secondary : .primary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(event.isCompleted ? .secondary : .primary)
                
                if !event.items.isEmpty {
                    HStack {
                        Text("\(event.items.count) items")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        if hasAllItems && !event.isCompleted {
                            Text("• Ready")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if !event.details.isEmpty {
                    Text(event.details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if isToday {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .opacity(event.isCompleted ? 0.7 : 1.0)
    }
}

#Preview {
    FavoriteDishesView()
        .environmentObject(SharedDataManager.shared)
}
