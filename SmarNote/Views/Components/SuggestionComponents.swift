//
//  SuggestionComponents.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import SwiftUI

// MARK: - Suggestion Chip Component
struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.blue)
                
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.blue.opacity(0.1), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.blue.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(SuggestionChipButtonStyle())
    }
}

// MARK: - Custom Button Style for Suggestion Chips
struct SuggestionChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Flow Layout for Suggestion Chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            if index < result.frames.count {
                let frame = result.frames[index]
                subview.place(
                    at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                    proposal: ProposedViewSize(frame.size)
                )
            }
        }
    }
}

// MARK: - Flow Layout Helper
struct FlowResult {
    var frames: [CGRect] = []
    var size: CGSize = .zero
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentX + subviewSize.width > maxWidth && currentX > 0 {
                // Move to next line
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(
                x: currentX,
                y: currentY,
                width: subviewSize.width,
                height: subviewSize.height
            ))
            
            currentX += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
        
        size = CGSize(
            width: maxWidth,
            height: currentY + lineHeight
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Suggestion Chips Preview")
            .font(.headline)
        
        FlowLayout(spacing: 8) {
            SuggestionChip(text: "tent") { }
            SuggestionChip(text: "sleeping bag") { }
            SuggestionChip(text: "flashlight") { }
            SuggestionChip(text: "first aid kit") { }
            SuggestionChip(text: "water bottle") { }
            SuggestionChip(text: "trail mix") { }
            SuggestionChip(text: "hiking boots") { }
            SuggestionChip(text: "map") { }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        
        Spacer()
    }
    .padding()
}