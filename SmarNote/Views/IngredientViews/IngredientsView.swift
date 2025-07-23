//
//  IngredientsView.swift
//  Yes!Chef
//
//  Created by 金培元 on 6/22/25.
//

import SwiftUI

// MARK: - Legacy Model Type References
// To resolve ambiguity, we explicitly reference the legacy models
// Using internal access level to match the computed properties that use this type
internal typealias LegacyDish = Dish

// MARK: - Modern Dashboard View (formerly IngredientsView)
struct IngredientsView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var showingGroceryList = false
    @State private var showingAddEvent = false
    @State private var showingAISettings = false
    
    var upcomingEvents: [LegacyDish] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let filteredEvents = dataManager.dishes.filter { event in
            event.date >= startOfToday
        }
        let sortedEvents = filteredEvents.sorted { $0.date < $1.date }
        return Array(sortedEvents.prefix(3))
    }
    
    var todaysEvents: [LegacyDish] {
        let calendar = Calendar.current
        return dataManager.dishes.filter { calendar.isDateInToday($0.date) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            let backgroundGradient = LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Circle()
                                .fill(backgroundGradient)
                                .frame(width: 100, height: 100)
                            
                            let iconGradient = LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Image(systemName: "house.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(iconGradient)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Dashboard")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Your event management hub")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    // Quick Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRowHeader(
                            icon: "chart.bar.fill",
                            label: "Quick Stats",
                            color: .blue
                        )
                        
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Total Events",
                                value: "\(dataManager.dishes.count)",
                                icon: "calendar.circle.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Today",
                                value: "\(todaysEvents.count)",
                                icon: "calendar.badge.clock",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Upcoming",
                                value: "\(upcomingEvents.count)",
                                icon: "clock.circle.fill",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Today's Events Section
                    if !todaysEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRowHeader(
                                icon: "calendar.badge.clock",
                                label: "Today's Events",
                                color: .orange
                            )
                            
                            LazyVStack(spacing: 12) {
                                ForEach(todaysEvents) { event in
                                    NavigationLink(destination: DishDetailView(dish: event)) {
                                        TodayDishCard(dish: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(16)
                    }
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRowHeader(
                            icon: "bolt.circle.fill",
                            label: "Quick Actions",
                            color: .purple
                        )
                        
                        VStack(spacing: 12) {
                            // Add Event Button with AI indicator
                            Button(action: {
                                showingAddEvent = true
                            }) {
                                AIEnhancedActionCard(
                                    title: "Add New Event",
                                    subtitle: "Create a new event with AI-powered suggestions",
                                    icon: "plus.circle.fill",
                                    color: .blue
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Shopping List Button
                            Button(action: {
                                showingGroceryList = true
                            }) {
                                ActionCard(
                                    title: "Create Shopping List",
                                    subtitle: "Generate a list from your upcoming events",
                                    icon: "cart.fill",
                                    color: .green
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Upcoming Events Preview Section
                    if !upcomingEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRowHeader(
                                icon: "clock.circle.fill",
                                label: "Next Up",
                                color: .green
                            )
                            
                            LazyVStack(spacing: 12) {
                                ForEach(upcomingEvents) { event in
                                    NavigationLink(destination: DishDetailView(dish: event)) {
                                        UpcomingDishCard(dish: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(16)
                    }
                    
                    // Empty State
                    if dataManager.dishes.isEmpty {
                        let emptyStateGradient = LinearGradient(
                            gradient: Gradient(colors: [.gray, .secondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(emptyStateGradient)
                            
                            Text("Welcome!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Start by adding your first event")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Add Event") {
                                showingAddEvent = true
                            }
                            .buttonStyle(ModernPrimaryButtonStyle())
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(16)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    let toolbarGradient = LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Button(action: {
                        showingAISettings = true
                    }) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(toolbarGradient)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingGroceryList) {
                GroceryListGeneratorView()
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showingAddEvent) {
                AddDishView { event in
                    dataManager.addDish(event)
                    showingAddEvent = false
                }
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
        }
    }
}

// MARK: - UI Components
// StatCard, TodayEventCard, UpcomingEventCard, ActionCard, and AIEnhancedActionCard
// are now properly organized in SmarNote/Shared/UI/Cards/ for better modularity

// ModernActionCard moved to SmarNote/Shared/UI/Cards/ActionCards.swift

// MARK: - Modern Action Cards (now in ActionCards.swift)
// Components moved to SmarNote/Shared/UI/Cards/ActionCards.swift for better organization

// TodayEventCard is now in SmarNote/Shared/UI/Cards/EventCards.swift

// UpcomingEventCard is now in SmarNote/Shared/UI/Cards/EventCards.swift

// MARK: - Modern Button Styles (now in ActionCards.swift)
// ModernPrimaryButtonStyle moved to SmarNote/Shared/UI/Cards/ActionCards.swift

#Preview {
    IngredientsView()
        .environmentObject(SharedDataManager.shared)
}
