//
//  SharedUIComponents.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Shared UI Components for Modern Styling

struct DetailRowHeader: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

struct ModernTextAreaStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .frame(minHeight: 80)
    }
}

struct ModernButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Chip Components (ItemChip only - SuggestionChip is in SuggestionComponents.swift)
struct ItemChip: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Modern Card Backgrounds
extension View {
    func modernCardBackground(_ color: Color = Color(.systemGray6)) -> some View {
        self
            .padding()
            .background(color.opacity(0.5))
            .cornerRadius(16)
    }
    
    func modernGradientBackground(_ colors: [Color]) -> some View {
        self
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors.map { $0.opacity(0.1) }),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        DetailRowHeader(
            icon: "calendar.badge.checkmark",
            label: "Sample Header",
            color: .blue
        )
        
        ItemChip(text: "Sample Item") { }
    }
    .padding()
}