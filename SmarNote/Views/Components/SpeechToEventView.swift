//
//  SpeechToEventView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import SwiftUI

// MARK: - Speech to Event View
struct SpeechToEventView: View {
    @StateObject private var speechService = SpeechService.shared
    @StateObject private var aiService = AIService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isProcessing = false
    @State private var parsedEvent: ParsedEvent?
    @State private var showingEventForm = false
    @State private var errorMessage = ""
    
    let onEventCreated: (ParsedEvent) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(speechService.isRecording ? .red : .blue)
                        .scaleEffect(speechService.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechService.isRecording)
                    
                    Text(speechService.isRecording ? "Listening..." : "Describe Your Event")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(speechService.isRecording ? "Tell me about your event" : "Tap the microphone to start")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Transcribed Text Display
                if !speechService.transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you said:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(speechService.transcribedText)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .frame(maxHeight: 120)
                    }
                }
                
                // Processing State
                if isProcessing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Processing your event...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Parsed Event Preview
                if let event = parsedEvent {
                    EventPreviewCard(event: event) {
                        createEventFromParsed(event)
                    }
                }
                
                Spacer()
                
                // Controls
                VStack(spacing: 16) {
                    // Record Button
                    Button(action: toggleRecording) {
                        HStack {
                            Image(systemName: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                            Text(speechService.isRecording ? "Stop Recording" : "Start Recording")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(speechService.isRecording ? Color.red : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(!speechService.isAuthorized)
                    
                    // Process Button
                    if !speechService.transcribedText.isEmpty && !speechService.isRecording {
                        Button(action: processTranscription) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("Create Event from Speech")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                    
                    // Clear Button
                    if !speechService.transcribedText.isEmpty {
                        Button("Clear & Start Over") {
                            clearAll()
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                // Error Message with Retry
                if !errorMessage.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Retry Button
                        if !speechService.transcribedText.isEmpty {
                            Button(action: {
                                processTranscription()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                            .disabled(isProcessing)
                        }
                        
                        // Tips for better results
                        VStack(alignment: .leading, spacing: 4) {
                            Text("💡 Tips for better results:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text("• Speak clearly and at normal pace")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("• Include specific details (what, when, where)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("• Mention items you need to bring")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .navigationTitle("Voice Event Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                requestPermissions()
            }
            .onDisappear {
                speechService.cleanup()
            }
        }
    }
    
    private func requestPermissions() {
        Task {
            let granted = await speechService.requestPermissions()
            if !granted {
                errorMessage = "Speech recognition requires microphone and speech permissions. Please enable them in Settings."
            }
        }
    }
    
    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            speechService.startRecording()
            errorMessage = ""
            parsedEvent = nil
        }
    }
    
    private func processTranscription() {
        guard !speechService.transcribedText.isEmpty else { 
            print("❌ No transcribed text to process")
            showError("No speech was recorded. Please try again.")
            return 
        }
        
        print("🎤 Processing transcription: '\(speechService.transcribedText)'")
        isProcessing = true
        errorMessage = ""
        parsedEvent = nil // Clear any previous result
        
        // Add timeout for parsing
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            DispatchQueue.main.async {
                if self.isProcessing {
                    self.isProcessing = false
                    self.showError("Processing took too long. Please try again with a shorter description.")
                }
            }
        }
        
        // Use CloudSuggestionEngine to parse the speech
        let cloudEngine = CloudSuggestionEngine()
        cloudEngine.parseEventFromSpeech(speechService.transcribedText) { result in
            print("🔄 Received parsing result: \(result != nil ? "Success" : "Failed")")
            
            DispatchQueue.main.async {
                timeoutTimer.invalidate() // Cancel timeout
                print("📱 Updating UI on main thread")
                self.isProcessing = false
                
                if let event = result {
                    print("✅ Setting parsed event: '\(event.title)'")
                    self.parsedEvent = event
                    self.errorMessage = "" // Clear any error
                    
                    // Add success haptic feedback
                    let haptics = UINotificationFeedbackGenerator()
                    haptics.notificationOccurred(.success)
                } else {
                    print("❌ No event parsed, showing error")
                    self.showError("Could not understand your event description. Please try speaking more clearly with specific details about what you're planning.")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        parsedEvent = nil
        
        // Add error haptic feedback
        let haptics = UINotificationFeedbackGenerator()
        haptics.notificationOccurred(.error)
    }
    
    private func createEventFromParsed(_ event: ParsedEvent) {
        onEventCreated(event)
        dismiss()
    }
    
    private func clearAll() {
        speechService.transcribedText = ""
        parsedEvent = nil
        errorMessage = ""
        isProcessing = false
    }
}

// MARK: - Event Preview Card
struct EventPreviewCard: View {
    let event: ParsedEvent
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Event Created!")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Title
                HStack {
                    Text("Title:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Date
                HStack {
                    Text("Date:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(event.suggestedDate, style: .date)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Items
                if !event.items.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Items:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 6) {
                            ForEach(event.items, id: \.self) { item in
                                Text(item)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Details
                if !event.details.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Details:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(event.details)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
            }
            
            // Confirm Button
            Button(action: onConfirm) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Add This Event")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    SpeechToEventView { _ in }
}
