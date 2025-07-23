//
//  EventCards.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Today Event Card
struct TodayEventCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            // Today indicator
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.orange, .red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 12, height: 12)
                .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
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
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppConstants.UI.cardCornerRadius)
    }
}

// MARK: - Upcoming Event Card
struct UpcomingEventCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator with modern styling
            VStack(spacing: 4) {
                Text(event.dayOfMonth)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text(event.monthAbbreviation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .fill(Color.green.opacity(0.1))
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("\(event.items.count) items")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppConstants.UI.cardCornerRadius)
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator with modern styling
            VStack(spacing: 4) {
                Text(event.dayOfMonth)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: event.isToday ? [.orange, .red] : [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text(event.monthAbbreviation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .fill(event.isToday ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
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
                    
                    // Status indicator
                    if event.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Completed")
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
                if event.isToday {
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
        .cornerRadius(AppConstants.UI.cardCornerRadius)
        .opacity(event.isCompleted ? 0.7 : 1.0)
    }
}

#Preview {
    VStack(spacing: 16) {
        TodayEventCard(event: Event(
            title: "Team Meeting",
            date: Date(),
            items: ["notebook", "pen", "laptop"],
            details: "Weekly team sync"
        ))
        
        UpcomingEventCard(event: Event(
            title: "Weekend Camping",
            date: Date().addingTimeInterval(86400 * 3),
            items: ["tent", "sleeping bag", "flashlight"],
            details: "Mountain camping trip"
        ))
        
        EventRowView(event: Event(
            title: "Grocery Shopping",
            date: Date().addingTimeInterval(86400),
            items: ["milk", "bread", "eggs"],
            details: "Weekly grocery run"
        ))
    }
    .padding()
}