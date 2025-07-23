//
//  DashboardView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showingGroceryList = false
    @State private var showingAddEvent = false
    @State private var showingAISettings = false
    
    private var statistics: EventStatistics {
        coordinator.getEventStatistics()
    }
    
    private var upcomingEvents: [Event] {
        coordinator.getUpcomingEvents(limit: 3)
    }
    
    private var todaysEvents: [Event] {
        coordinator.getTodaysEvents()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.UI.largePadding) {
                    // Header Section
                    DashboardHeaderView()
                    
                    // Quick Stats Section
                    DashboardStatsView(statistics: statistics)
                    
                    // Today's Events Section
                    if !todaysEvents.isEmpty {
                        DashboardTodayEventsView(events: todaysEvents)
                    }
                    
                    // Quick Actions Section
                    DashboardQuickActionsView(
                        onAddEvent: { showingAddEvent = true },
                        onCreateShoppingList: { showingGroceryList = true }
                    )
                    
                    // Upcoming Events Section
                    if !upcomingEvents.isEmpty {
                        DashboardUpcomingEventsView(events: upcomingEvents)
                    }
                    
                    // Empty State
                    if statistics.total == 0 {
                        DashboardEmptyStateView(onAddEvent: { showingAddEvent = true })
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAISettings = true }) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingGroceryList) {
                GroceryListGeneratorView()
                    .environmentObject(coordinator)
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView { event in
                    coordinator.addEvent(event)
                    showingAddEvent = false
                }
                .environmentObject(coordinator)
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
        }
    }
}

// MARK: - Dashboard Header View
struct DashboardHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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
    }
}

// MARK: - Dashboard Stats View
struct DashboardStatsView: View {
    let statistics: EventStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRowHeader(
                icon: "chart.bar.fill",
                label: "Quick Stats",
                color: .blue
            )
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Events",
                    value: "\(statistics.total)",
                    icon: "calendar.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Today",
                    value: "\(statistics.today)",
                    icon: "calendar.badge.clock",
                    color: .orange
                )
                
                StatCard(
                    title: "Upcoming",
                    value: "\(statistics.upcoming)",
                    icon: "clock.circle.fill",
                    color: .green
                )
            }
        }
        .modernCardBackground()
    }
}

// MARK: - Dashboard Today Events View
struct DashboardTodayEventsView: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRowHeader(
                icon: "calendar.badge.clock",
                label: "Today's Events",
                color: .orange
            )
            
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        TodayEventCard(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .modernCardBackground()
    }
}

// MARK: - Dashboard Quick Actions View
struct DashboardQuickActionsView: View {
    let onAddEvent: () -> Void
    let onCreateShoppingList: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRowHeader(
                icon: "bolt.circle.fill",
                label: "Quick Actions",
                color: .purple
            )
            
            VStack(spacing: 12) {
                Button(action: onAddEvent) {
                    AIEnhancedActionCard(
                        title: "Add New Event",
                        subtitle: "Create a new event with AI-powered suggestions",
                        icon: "plus.circle.fill",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onCreateShoppingList) {
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
        .modernCardBackground()
    }
}

// MARK: - Dashboard Upcoming Events View
struct DashboardUpcomingEventsView: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRowHeader(
                icon: "clock.circle.fill",
                label: "Next Up",
                color: .green
            )
            
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        UpcomingEventCard(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .modernCardBackground()
    }
}

// MARK: - Dashboard Empty State View
struct DashboardEmptyStateView: View {
    let onAddEvent: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [.gray, .secondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text("Welcome!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start by adding your first event")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Event", action: onAddEvent)
                .buttonStyle(ModernPrimaryButtonStyle())
        }
        .padding()
        .modernCardBackground(Color(.systemGray6).opacity(0.3))
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppCoordinator.shared)
}