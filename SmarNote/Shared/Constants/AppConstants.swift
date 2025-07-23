//
//  AppConstants.swift
//  SmarNote
//
//  Created by AI Assistant on 7/19/25.
//

import Foundation

// MARK: - App Constants
enum AppConstants {
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let events = "SavedEvents"
        static let shoppingLists = "SavedShoppingLists"
        static let myItems = "SavedMyItems"
        static let groqAPIKey = "Groq_API_Key"
        static let aiMode = "AI_Mode"
    }
    
    // MARK: - API Configuration
    enum API {
        static let groqBaseURL = "https://api.groq.com/openai/v1/chat/completions"
        static let groqModel = "llama-3.1-8b-instant"
        static let maxTokens = 300
        static let temperature = 0.7
        static let maxSuggestions = 8
    }
    
    // MARK: - UI Configuration
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        
        // Animation durations
        static let shortAnimation: Double = 0.2
        static let mediumAnimation: Double = 0.3
        static let longAnimation: Double = 0.5
    }
    
    // MARK: - Limits
    enum Limits {
        static let maxEventTitleLength = 100
        static let maxEventDetailsLength = 500
        static let maxItemsPerEvent = 20
        static let maxSuggestionsLocal = 8
        static let maxSuggestionsCloud = 5
    }
    
    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Network connection failed. Please check your internet connection."
        static let apiKeyMissing = "API key is required for cloud AI features."
        static let speechPermissionDenied = "Speech recognition requires microphone and speech permissions."
        static let audioEngineFailed = "Failed to start audio recording. Please try again."
        static let eventCreationFailed = "Failed to create event. Please try again."
        static let eventUpdateFailed = "Failed to update event. Please try again."
        static let eventDeletionFailed = "Failed to delete event. Please try again."
    }
    
    // MARK: - Success Messages
    enum SuccessMessages {
        static let eventCreated = "Event created successfully!"
        static let eventUpdated = "Event updated successfully!"
        static let eventDeleted = "Event deleted successfully!"
        static let shoppingCompleted = "Shopping completed! Great job!"
        static let itemsAdded = "Items added to your inventory!"
    }
    
    // MARK: - Placeholder Text
    enum PlaceholderText {
        static let eventTitle = "Enter event title"
        static let eventDetails = "Add event details..."
        static let addItem = "Add item"
        static let searchEvents = "Search events..."
        static let apiKeyPlaceholder = "gsk_..."
    }
}

// MARK: - App Colors
enum AppColors {
    static let primary = "blue"
    static let secondary = "purple"
    static let accent = "green"
    static let warning = "orange"
    static let error = "red"
    static let success = "green"
    
    // Gradient combinations
    static let primaryGradient = ["blue", "purple"]
    static let successGradient = ["green", "blue"]
    static let warningGradient = ["orange", "red"]
}