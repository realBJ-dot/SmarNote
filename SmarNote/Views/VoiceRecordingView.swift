//
//  VoiceRecordingView.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import SwiftUI



// MARK: - Voice Recording Tab View
struct VoiceRecordingView: View {
    @StateObject private var speechService = SpeechService.shared
    @StateObject private var aiService = AIService.shared
    @EnvironmentObject var dataManager: SharedDataManager
    
    @State private var isProcessing = false
    @State private var parsedEvent: ParsedEvent?
    @State private var errorMessage = ""
    @State private var showingEventCreated = false
    @State private var showingAddDishView = false
    @State private var createdEvent: Dish?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 16) {
                        // App Icon or Illustration
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "waveform.and.mic")
                                .font(.system(size: 50, weight: .light))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Voice Event Creator")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Describe your event naturally and let AI handle the rest")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Recording Status
                    VStack(spacing: 16) {
                        if speechService.isRecording {
                            RecordingStatusView()
                        } else if !speechService.transcribedText.isEmpty {
                            TranscriptionDisplayView(text: speechService.transcribedText)
                        } else {
                            InstructionsView()
                        }
                    }
                    
                    // Main Recording Button
                    VStack(spacing: 20) {
                        RecordingButton(
                            isRecording: speechService.isRecording,
                            isAuthorized: speechService.isAuthorized,
                            action: toggleRecording
                        )
                        
                        // Recording Instructions
                        if !speechService.isRecording && speechService.transcribedText.isEmpty {
                            Text("Tap and hold to record, or tap once to start/stop")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Processing State
                    if isProcessing {
                        ProcessingView()
                    }
                    
                    // Action Buttons
                    if !speechService.transcribedText.isEmpty && !speechService.isRecording {
                        ActionButtonsView(
                            hasTranscription: !speechService.transcribedText.isEmpty,
                            isProcessing: isProcessing,
                            onProcess: processTranscription,
                            onClear: clearAll
                        )
                    }
                    
                    // Removed inline event preview - now shows as modal dialog
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        ErrorView(
                            message: errorMessage,
                            hasTranscription: !speechService.transcribedText.isEmpty,
                            onRetry: processTranscription
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Voice Events")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                requestPermissions()
            }
            .onDisappear {
                speechService.cleanup()
            }
            .sheet(isPresented: $showingAddDishView) {
                if let event = parsedEvent {
                    AddDishView(
                        onAdd: { dish in
                            dataManager.addDish(dish)
                            showingAddDishView = false
                            createdEvent = dish
                            showingEventCreated = true
                        },
                        parsedEvent: event
                    )
                }
            }
            .alert("Event Created! 🎉", isPresented: $showingEventCreated) {
                Button("View Event") {
                    if let event = createdEvent {
                        // Navigate to event detail - we'll implement this
                        navigateToEventDetail(event)
                    }
                }
                Button("Create Another", role: .cancel) {
                    clearAll()
                }
            } message: {
                if let event = createdEvent {
                    Text("'\(event.title)' has been added to your events!")
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: speechService.isRecording)
        .animation(.easeInOut(duration: 0.3), value: isProcessing)
        .animation(.easeInOut(duration: 0.3), value: parsedEvent != nil)
        .animation(.easeInOut(duration: 0.3), value: !errorMessage.isEmpty)
    }
    
    // MARK: - Helper Methods
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
            print("❌ VoiceRecordingView: No transcribed text to process")
            return 
        }
        
        print("🎤 VoiceRecordingView: Processing transcription: '\(speechService.transcribedText)'")
        isProcessing = true
        errorMessage = ""
        parsedEvent = nil
        
        let cloudEngine = CloudSuggestionEngine()
        cloudEngine.parseEventFromSpeech(speechService.transcribedText) { result in
            print("🔄 VoiceRecordingView: Received parsing result: \(result != nil ? "Success" : "Failed")")
            
            DispatchQueue.main.async {
                print("📱 VoiceRecordingView: Updating UI on main thread")
                self.isProcessing = false
                
                if let event = result {
                    print("✅ VoiceRecordingView: Setting parsed event: '\(event.title)'")
                    self.parsedEvent = event
                    self.showingAddDishView = true // Navigate to AddDishView
                    
                    // Success haptic feedback
                    let haptics = UINotificationFeedbackGenerator()
                    haptics.notificationOccurred(.success)
                } else {
                    print("❌ VoiceRecordingView: No event parsed, showing error")
                    self.errorMessage = "Could not understand your event description. Please try speaking more clearly with specific details."
                    
                    // Error haptic feedback
                    let haptics = UINotificationFeedbackGenerator()
                    haptics.notificationOccurred(.error)
                }
                
                print("📊 VoiceRecordingView: Final state - parsedEvent: \(self.parsedEvent?.title ?? "nil"), errorMessage: '\(self.errorMessage)'")
            }
        }
    }
    
    private func createEventFromParsed(_ event: ParsedEvent) {
        let newDish = Dish(
            title: event.title,
            date: event.suggestedDate,
            items: event.items,
            details: event.details
        )
        
        dataManager.addDish(newDish)
        createdEvent = newDish
        showingEventCreated = true
        
        // Success haptic feedback
        let haptics = UINotificationFeedbackGenerator()
        haptics.notificationOccurred(.success)
    }
    
    private func clearAll() {
        speechService.transcribedText = ""
        parsedEvent = nil
        errorMessage = ""
        isProcessing = false
        createdEvent = nil
    }
    
    private func navigateToEventDetail(_ event: Dish) {
        // For now, we'll just dismiss the alert and let user find the event in Events tab
        // In a full implementation, you could use NavigationPath or coordinator pattern
        print("📱 Navigate to event detail: \(event.title)")
    }
}

// MARK: - Recording Status View
struct RecordingStatusView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .scaleEffect(1.5)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: true)
                
                Text("Recording...")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            
            Text("Speak naturally about your event")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Transcription Display View
struct TranscriptionDisplayView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.blue)
                Text("What you said:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ScrollView {
                Text(text)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .frame(maxHeight: 120)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Instructions View
struct InstructionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("💡 How to use Voice Events")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(
                    icon: "1.circle.fill",
                    text: "Tap the record button and describe your event",
                    color: .blue
                )
                
                InstructionRow(
                    icon: "2.circle.fill",
                    text: "Include what, when, where, and what you need",
                    color: .green
                )
                
                InstructionRow(
                    icon: "3.circle.fill",
                    text: "AI will extract details and create your event",
                    color: .purple
                )
            }
            
            VStack(spacing: 8) {
                Text("Example:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("\"I'm planning a weekend camping trip next Saturday. I need to bring a tent, sleeping bag, flashlight, and food for the mountains.\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

// MARK: - Instruction Row
struct InstructionRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Recording Button
struct RecordingButton: View {
    let isRecording: Bool
    let isAuthorized: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring animation
                Circle()
                    .stroke(
                        isRecording ? Color.red.opacity(0.3) : Color.blue.opacity(0.3),
                        lineWidth: 4
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(isRecording ? 1.2 : 1.0)
                    .opacity(isRecording ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isRecording ? [.red, .pink] : [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: isRecording ? .red.opacity(0.3) : .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Icon
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(isRecording ? 0.8 : 1.0)
            }
        }
        .buttonStyle(RecordingButtonStyle())
        .disabled(!isAuthorized)
        .opacity(isAuthorized ? 1.0 : 0.5)
    }
}

// MARK: - Recording Button Style
struct RecordingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Processing View
struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            VStack(spacing: 4) {
                Text("Processing your event...")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("AI is extracting details from your speech")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    let hasTranscription: Bool
    let isProcessing: Bool
    let onProcess: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Process Button
            Button(action: onProcess) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                    Text("Create Event from Speech")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            
            // Clear Button
            Button(action: onClear) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    Text("Start Over")
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let hasTranscription: Bool
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            
            if hasTranscription {
                Button(action: onRetry) {
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
            }
            
            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Tips for better results:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


// MARK: - Event Preview Modal
struct EventPreviewModal: View {
    let event: ParsedEvent
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Success Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Event Ready!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("AI has extracted the following details from your speech")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Event Details Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        DetailRow(
                            icon: "calendar.badge.checkmark",
                            label: "Event Title",
                            value: event.title,
                            color: .blue
                        )
                        
                        Divider()
                        
                        // Date
                        DetailRow(
                            icon: "calendar",
                            label: "Date",
                            value: event.suggestedDate.formatted(date: .abbreviated, time: .omitted),
                            color: .green
                        )
                        
                        // Items
                        if !event.items.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "list.bullet.circle")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                    
                                    Text("Items to Bring")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text("\(event.items.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(event.items, id: \.self) { item in
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            
                                            Text(item)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        // Details
                        if !event.details.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                    
                                    Text("Event Details")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                
                                Text(event.details)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Confirm Button
                        Button(action: onConfirm) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Add This Event")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        // Cancel Button
                        Button(action: onCancel) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.title3)
                                Text("Cancel")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Review Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    VoiceRecordingView()
        .environmentObject(SharedDataManager.shared)
}
