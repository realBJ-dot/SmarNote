//
//  LegacyEventCards.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Legacy Dish Cards for IngredientsView
// These components work with the legacy Dish model from DataModel.swift

// MARK: - Today Dish Card
struct TodayDishCard: View {
    let dish: Dish
    
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
                Text(dish.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
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
        .cornerRadius(12)
    }
}

// MARK: - Upcoming Dish Card
struct UpcomingDishCard: View {
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
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator with modern styling
            VStack(spacing: 4) {
                Text(dayOfMonth)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
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
                    .fill(Color.green.opacity(0.1))
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("\(dish.items.count) items")
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
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        TodayDishCard(dish: Dish(
            title: "Team Meeting",
            date: Date(),
            items: ["notebook", "pen", "laptop"],
            details: "Weekly team sync"
        ))
        
        UpcomingDishCard(dish: Dish(
            title: "Weekend Camping",
            date: Date().addingTimeInterval(86400 * 3),
            items: ["tent", "sleeping bag", "flashlight"],
            details: "Mountain camping trip"
        ))
    }
    .padding()
}