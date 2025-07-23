//
//  SpeechService.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import AVFoundation

import Foundation
import Speech
// MARK: - Speech Recognition Service
class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()
    
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var transcribedText = ""
    @Published var errorMessage = ""
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Permission Handling
    func requestPermissions() async -> Bool {
        // Request speech recognition permission
        let speechStatus = await requestSpeechPermission()
        
        // Request microphone permission
        let micStatus = await requestMicrophonePermission()
        
        let authorized = speechStatus && micStatus
        
        await MainActor.run {
            self.isAuthorized = authorized
            if !authorized {
                self.errorMessage = "Speech recognition requires microphone and speech permissions"
            }
        }
        
        return authorized
    }
    
    private func requestSpeechPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    // MARK: - Recording Control
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            try startSpeechRecognition()
            isRecording = true
            transcribedText = ""
            errorMessage = ""
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        print("🛑 Stopping recording...")
        isRecording = false
        
        // Stop audio engine first
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // End audio input gracefully (don't cancel immediately)
        recognitionRequest?.endAudio()
        
        // Give recognition task time to finish processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.recognitionTask?.cancel()
            self?.recognitionTask = nil
            self?.recognitionRequest = nil
        }
    }
    
    private func startSpeechRecognition() throws {
        // Cancel any previous task and cleanup
        cleanup()
        
        // Configure audio session with better error handling
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Audio session configuration failed: \(error)")
            throw SpeechError.audioEngineFailed
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false // Allow cloud recognition
        
        // Get audio input with safety checks
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Ensure no existing tap
        inputNode.removeTap(onBus: 0)
        
        // Install tap with error handling
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine with error handling
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("❌ Audio engine failed to start: \(error)")
            cleanup()
            throw SpeechError.audioEngineFailed
        }
        
        // Start recognition task with better error handling
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    print("🎤 Transcription update: '\(self.transcribedText)'")
                    
                    // Don't auto-stop on final result - let user control when to stop
                    // This prevents premature cancellation of short phrases
                }
                
                if let error = error {
                    let nsError = error as NSError
                    print("❌ Speech recognition error: \(error)")
                    print("❌ Error domain: \(nsError.domain), code: \(nsError.code)")
                    
                    // Only show error if it's not a cancellation we initiated
                    if nsError.code != 301 || !self.isRecording {
                        self.errorMessage = "Speech recognition failed. Please try again."
                        self.stopRecording()
                    }
                }
            }
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        isRecording = false
        
        // Stop and cleanup audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Cancel recognition request and task
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }
    }
}

// MARK: - Speech Recognizer Delegate
extension SpeechService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available {
                self.errorMessage = "Speech recognition is not available"
                self.stopRecording()
            }
        }
    }
}

// MARK: - Speech Errors
enum SpeechError: Error, LocalizedError {
    case recognitionRequestFailed
    case audioEngineFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .audioEngineFailed:
            return "Audio engine failed to start"
        case .permissionDenied:
            return "Speech recognition permission denied"
        }
    }
}