//
//  SingleEventShoppingView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import SwiftUI

// MARK: - Single Event Shopping View
struct SingleEventShoppingView: View {
    let event: Event
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var checkedItems: Set<String> = []
    @State private var showingCompletionAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.UI.largePadding) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "cart.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Shopping for")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(event.title)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top)
                    
                    // Shopping List
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            DetailRowHeader(
                                icon: "list.bullet.circle.fill",
                                label: "Shopping List",
                                color: .green
                            )
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(event.items.count) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(checkedItems.count) collected")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        LazyVStack(spacing: 8) {
                            ForEach(event.items.sorted(), id: \.self) { item in
                                ShoppingItemRow(
                                    item: item,
                                    isChecked: checkedItems.contains(item),
                                    onToggle: { toggleItem(item) }
                                )
                            }
                        }
                        
                        // Complete Shopping button
                        if !checkedItems.isEmpty {
                            Button(action: {
                                showingCompletionAlert = true
                            }) {
                                HStack {
                                    Image(systemName: checkedItems.count == event.items.count ? "checkmark.circle.fill" : "cart.fill")
                                    Text(checkedItems.count == event.items.count ? "All items collected!" : "Finish Shopping")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: checkedItems.count == event.items.count ? [.green, .blue] : [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(AppConstants.UI.cornerRadius)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(AppConstants.UI.cardCornerRadius)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Shopping")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            // Pre-check items that are already in inventory
            checkedItems = Set(event.items.filter { coordinator.hasItem($0) })
        }
        .alert("Shopping Complete!", isPresented: $showingCompletionAlert) {
            Button("Finish") {
                completeShopping()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if checkedItems.count == event.items.count {
                Text("You've collected all items for \(event.title). Great job!")
            } else {
                Text("You've collected \(checkedItems.count) out of \(event.items.count) items. Are you sure you want to finish shopping?")
            }
        }
    }
    
    private func toggleItem(_ item: String) {
        if checkedItems.contains(item) {
            checkedItems.remove(item)
            coordinator.removeItem(item)
        } else {
            checkedItems.insert(item)
            coordinator.addItem(item)
            
            // Haptic feedback
            let haptics = UIImpactFeedbackGenerator(style: .light)
            haptics.impactOccurred()
        }
    }
    
    private func completeShopping() {
        // Add all checked items to inventory
        for item in checkedItems {
            coordinator.addItem(item)
        }
    }
}

// MARK: - Shopping Item Row
struct ShoppingItemRow: View {
    let item: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: isChecked ? [.green, .blue] : [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .font(.title3)
                
                Text(item)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked)
                
                Spacer()
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isChecked ? 
                        [Color.green.opacity(0.1), Color.blue.opacity(0.1)] : 
                        [Color(.systemGray6).opacity(0.5), Color(.systemGray6).opacity(0.5)]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppConstants.UI.cornerRadius)
            .animation(.easeInOut(duration: AppConstants.UI.shortAnimation), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SingleEventShoppingView(event: Event(
        title: "Weekend Camping",
        date: Date(),
        items: ["tent", "sleeping bag", "flashlight", "first aid kit"],
        details: "Mountain camping trip"
    ))
    .environmentObject(AppCoordinator.shared)
}