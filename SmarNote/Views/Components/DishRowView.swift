//
//  DishRowView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/21/25.
//

import SwiftUI

// MARK: - Dish Row View for Events List
struct DishRowView: View {
    let dish: Dish
    
    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: dish.date)
    }
    
    private var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: dish.date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(dish.date)
    }
    
    private var isUpcoming: Bool {
        dish.date > Date()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator with modern styling
            VStack(spacing: 4) {
                Text(dayOfMonth)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: isToday ? [.orange, .red] : [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text(monthAbbreviation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isToday ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            )
            
            // Event details
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.title)
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
                        
                        Text("\(dish.items.count) items")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Status indicator
                    if dish.isCompleted {
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
                if !dish.details.isEmpty {
                    Text(dish.details)
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
                
                if dish.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .opacity(dish.isCompleted ? 0.7 : 1.0)
    }
}

#Preview {
    List {
        DishRowView(dish: Dish(
            title: "Team Meeting",
            date: Date(),
            items: ["notebook", "pen", "laptop"],
            details: "Weekly team sync"
        ))
        
        DishRowView(dish: Dish(
            title: "Weekend Camping",
            date: Date().addingTimeInterval(86400 * 3),
            items: ["tent", "sleeping bag", "flashlight"],
            details: "Mountain camping trip"
        ))
        
        DishRowView(dish: Dish(
            title: "Grocery Shopping",
            date: Date().addingTimeInterval(86400),
            items: ["milk", "bread", "eggs"],
            details: "Weekly grocery run"
        ))
    }
}