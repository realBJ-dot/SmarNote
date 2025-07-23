//
//  ActionCards.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Action Card
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(AppConstants.UI.cardCornerRadius)
    }
}

// MARK: - AI Enhanced Action Card
struct AIEnhancedActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @StateObject private var aiConfig = AIConfiguration.shared
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // AI indicator badge
                if aiConfig.hasValidAPIKey {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.yellow)
                        .background(Circle().fill(Color.purple).frame(width: 16, height: 16))
                        .offset(x: 15, y: -15)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if aiConfig.hasValidAPIKey {
                        Text("AI")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(4)
                    }
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(AppConstants.UI.cardCornerRadius)
    }
}

// MARK: - Modern Primary Button Style
struct ModernPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppConstants.UI.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: AppConstants.UI.shortAnimation), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionCard(
            title: "Create Shopping List",
            subtitle: "Generate a list from your upcoming events",
            icon: "cart.fill",
            color: .green
        )
        
        AIEnhancedActionCard(
            title: "Add New Event",
            subtitle: "Create a new event with AI-powered suggestions",
            icon: "plus.circle.fill",
            color: .blue
        )
        
        Button("Primary Button") { }
            .buttonStyle(ModernPrimaryButtonStyle())
    }
    .padding()
}