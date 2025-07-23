//
//  StatCard.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Modern Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}

#Preview {
    HStack {
        StatCard(
            title: "Total Events",
            value: "12",
            icon: "calendar.circle.fill",
            color: .blue
        )
        
        StatCard(
            title: "Today",
            value: "3",
            icon: "calendar.badge.clock",
            color: .orange
        )
        
        StatCard(
            title: "Upcoming",
            value: "8",
            icon: "clock.circle.fill",
            color: .green
        )
    }
    .padding()
}