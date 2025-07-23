//
//  AIConfiguration.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import Foundation
import SwiftUI
// MARK: - AI Mode
enum AIMode: String, CaseIterable {
    case localOnly = "local"
    case groqCloud = "groq"
    
    var displayName: String {
        switch self {
        case .localOnly: return "Local AI Only"
        case .groqCloud: return "Groq Cloud AI"
        }
    }
    
    var description: String {
        switch self {
        case .localOnly: return "Fast, private suggestions using on-device intelligence"
        case .groqCloud: return "Enhanced suggestions powered by Groq's cloud AI"
        }
    }
    
    var icon: String {
        switch self {
        case .localOnly: return "brain.head.profile"
        case .groqCloud: return "cloud.bolt"
        }
    }
}

// MARK: - AI Configuration Manager
class AIConfiguration: ObservableObject {
    static let shared = AIConfiguration()
    
    @Published var hasValidAPIKey: Bool = false
    @Published var currentMode: AIMode = .localOnly
    
    private let apiKeyKey = "Groq_API_Key"
    private let aiModeKey = "AI_Mode"
    
    private init() {
        loadConfiguration()
    }
    
    var apiKey: String {
        get {
            return UserDefaults.standard.string(forKey: apiKeyKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: apiKeyKey)
            checkAPIKeyStatus()
        }
    }
    
    private func loadConfiguration() {
        // Load AI mode
        if let modeString = UserDefaults.standard.string(forKey: aiModeKey),
           let mode = AIMode(rawValue: modeString) {
            currentMode = mode
        }
        
        checkAPIKeyStatus()
    }
    
    private func checkAPIKeyStatus() {
        let key = apiKey
        hasValidAPIKey = !key.isEmpty && key != "your-groq-api-key" && key.hasPrefix("gsk_")
    }
    
    func setMode(_ mode: AIMode) {
        currentMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: aiModeKey)
    }
    
    func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: apiKeyKey)
        checkAPIKeyStatus()
    }
    
    // For development - you can set your API key here
    func setDevelopmentAPIKey() {
        apiKey = "***REMOVED***"
    }
}

// MARK: - AI Settings View
struct AISettingsView: View {
    @StateObject private var config = AIConfiguration.shared
    @State private var apiKeyInput = ""
    @State private var showingInfo = false
    @State private var showingDevSetup = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // AI Mode Selection Section
                Section {
                    ForEach(AIMode.allCases, id: \.self) { mode in
                        AIModeRow(
                            mode: mode,
                            isSelected: config.currentMode == mode,
                            isAvailable: mode == .localOnly || config.hasValidAPIKey,
                            onSelect: {
                                if mode == .localOnly || config.hasValidAPIKey {
                                    config.setMode(mode)
                                }
                            }
                        )
                    }
                } header: {
                    Text("AI Mode")
                } footer: {
                    Text("Choose how you want to get item suggestions for your events.")
                }
                
                // Current Status Section
                Section {
                    HStack {
                        Image(systemName: config.currentMode.icon)
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Currently using: \(config.currentMode.displayName)")
                                .font(.headline)
                            
                            Text(config.currentMode.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if config.currentMode == .groqCloud && config.hasValidAPIKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Current Configuration")
                }
                
                // Groq API Key Section (only show if Groq mode is selected or available)
                if config.currentMode == .groqCloud || !config.hasValidAPIKey {
                    Section {
                        if !config.hasValidAPIKey {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Groq API key required for cloud AI features")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        SecureField("gsk_...", text: $apiKeyInput)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        HStack {
                            Button("Save API Key") {
                                config.apiKey = apiKeyInput
                                apiKeyInput = ""
                                // Auto-switch to Groq mode when API key is added
                                if config.hasValidAPIKey {
                                    config.setMode(.groqCloud)
                                }
                            }
                            .disabled(apiKeyInput.isEmpty)
                            
                            Spacer()
                            
                            // Development helper button
                            Button("Use Dev Key") {
                                showingDevSetup = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if config.hasValidAPIKey {
                            Button("Remove API Key", role: .destructive) {
                                config.clearAPIKey()
                                config.setMode(.localOnly) // Switch back to local mode
                                apiKeyInput = ""
                            }
                        }
                    } header: {
                        HStack {
                            Text("Groq API Key")
                            Button(action: { showingInfo = true }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    } footer: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your API key is stored securely on your device and never shared.")
                            Text("Privacy: Only event titles are sent to Groq for suggestions.")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Features Comparison Section
                Section {
                    LocalAIFeaturesView()
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    CloudAIFeaturesView()
                } header: {
                    Text("Feature Comparison")
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Don't pre-fill the API key for security
                apiKeyInput = ""
            }
        }
        .alert("How to get a Groq API Key", isPresented: $showingInfo) {
            Button("OK") { }
        } message: {
            Text("1. Visit console.groq.com\n2. Sign up for a free account\n3. Go to API Keys section\n4. Create a new API key\n5. Copy and paste it here\n\nNote: Groq offers generous free tier limits - perfect for item suggestions!")
        }
        .alert("Development Setup", isPresented: $showingDevSetup) {
            Button("Use Dev Key") {
                config.setDevelopmentAPIKey()
                config.setMode(.groqCloud)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will set up the development API key for testing. Use only for development purposes.")
        }
    }
}

// MARK: - AI Mode Row Component
struct AIModeRow: View {
    let mode: AIMode
    let isSelected: Bool
    let isAvailable: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Mode icon
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Mode info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(mode.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !isAvailable {
                            Text("Requires API Key")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}

// MARK: - Feature Components
struct LocalAIFeaturesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("Local AI Features")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                FeatureRow(icon: "checkmark.circle", text: "10+ event categories", color: .green)
                FeatureRow(icon: "checkmark.circle", text: "Seasonal awareness", color: .green)
                FeatureRow(icon: "checkmark.circle", text: "Instant suggestions", color: .green)
                FeatureRow(icon: "checkmark.circle", text: "100% private", color: .green)
                FeatureRow(icon: "checkmark.circle", text: "Works offline", color: .green)
            }
        }
    }
}

struct CloudAIFeaturesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cloud.bolt")
                    .foregroundColor(.purple)
                Text("Cloud AI Features")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                FeatureRow(icon: "plus.circle", text: "All local features", color: .blue)
                FeatureRow(icon: "sparkles", text: "Advanced context understanding", color: .purple)
                FeatureRow(icon: "globe", text: "Real-world knowledge", color: .purple)
                FeatureRow(icon: "wand.and.stars", text: "Creative suggestions", color: .purple)
                FeatureRow(icon: "bolt", text: "Lightning fast (Groq)", color: .purple)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    var color: Color = .blue
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)
            Text(text)
                .font(.caption)
        }
    }
}

#Preview {
    AISettingsView()
}
