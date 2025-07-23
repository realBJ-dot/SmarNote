//
//  AIService.swift
//  SmarNote
//
//  Created by AI Assistant on 7/16/25.
//

import Foundation
import CoreML



// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func getSuggestedItems(for eventTitle: String, completion: @escaping ([String]) -> Void)
    func getSuggestedItems(for eventTitle: String, eventDate: Date, completion: @escaping ([String]) -> Void)
}

// MARK: - Suggestion Source
enum SuggestionSource {
    case local
    case cloud
    case hybrid
}

// MARK: - Event Category Priority
enum Priority: Int {
    case high = 3
    case medium = 2
    case low = 1
}

// MARK: - Event Category
struct EventCategory {
    let keywords: [String]
    let contextWords: [String]
    let items: [String]
    let priority: Priority
    
    init(keywords: [String], contextWords: [String], items: [String], priority: Priority) {
        self.keywords = keywords
        self.contextWords = contextWords
        self.items = items
        self.priority = priority
    }
}

// MARK: - AI Service Implementation
class AIService: AIServiceProtocol, ObservableObject {
    static let shared = AIService()
    
    private let localSuggestionEngine = LocalSuggestionEngine()
    private let cloudSuggestionEngine = CloudSuggestionEngine()
    
    // Configuration
    private let useCloudFallback = true
    private let maxLocalSuggestions = 8
    private let maxCloudSuggestions = 5
    
    private init() {}
    
    // MARK: - Main Suggestion Method
    func getSuggestedItems(for eventTitle: String, completion: @escaping ([String]) -> Void) {
        getSuggestedItems(for: eventTitle, eventDate: Date(), completion: completion)
    }
    
    func getSuggestedItems(for eventTitle: String, eventDate: Date, completion: @escaping ([String]) -> Void) {
        // Start with local suggestions (always available)
        let localSuggestions = localSuggestionEngine.getSuggestions(for: eventTitle, date: eventDate)
        
        // Check user's AI mode preference
        let config = AIConfiguration.shared
        let shouldUseCloud = config.currentMode == .groqCloud && config.hasValidAPIKey && useCloudFallback
        
        if !shouldUseCloud || localSuggestions.count >= maxLocalSuggestions {
            // Return local suggestions only
            completion(Array(localSuggestions.prefix(maxLocalSuggestions)))
        } else {
            // Return local suggestions immediately, then enhance with cloud
            completion(localSuggestions)
            
            // Get cloud suggestions to enhance the list
            cloudSuggestionEngine.getSuggestions(for: eventTitle, date: eventDate) { [weak self] cloudSuggestions in
                guard let self = self else { return }
                
                // Combine and deduplicate suggestions
                let combinedSuggestions = self.combineAndRankSuggestions(
                    local: localSuggestions,
                    cloud: cloudSuggestions
                )
                
                // Only call completion again if we got new suggestions
                if combinedSuggestions.count > localSuggestions.count {
                    DispatchQueue.main.async {
                        completion(combinedSuggestions)
                    }
                }
            }
        }
    }
    
    // MARK: - Suggestion Combination Logic
    private func combineAndRankSuggestions(local: [String], cloud: [String]) -> [String] {
        var combined = Set<String>()
        var result: [String] = []
        
        // Add local suggestions first (they're faster and more reliable)
        for suggestion in local.prefix(maxLocalSuggestions) {
            if combined.insert(suggestion.lowercased()).inserted {
                result.append(suggestion)
            }
        }
        
        // Add cloud suggestions that aren't duplicates
        for suggestion in cloud.prefix(maxCloudSuggestions) {
            if combined.insert(suggestion.lowercased()).inserted {
                result.append(suggestion)
            }
        }
        
        return Array(result.prefix(maxLocalSuggestions + maxCloudSuggestions))
    }
}

// MARK: - Local Suggestion Engine
class LocalSuggestionEngine {
    // Enhanced pattern matching with context awareness
    private let eventCategories: [EventCategory] = [
        // Academic & School Events
        EventCategory(
            keywords: ["orientation", "freshman", "college", "university", "school", "academic", "semester", "graduation", "exam", "study"],
            contextWords: ["new", "student", "first", "welcome", "intro"],
            items: ["notebook", "pens", "folder", "backpack", "student ID", "schedule", "map", "water bottle", "snacks"],
            priority: .high
        ),
        
        // Professional & Work
        EventCategory(
            keywords: ["meeting", "conference", "presentation", "interview", "workshop", "seminar", "training"],
            contextWords: ["business", "work", "professional", "corporate", "office"],
            items: ["laptop", "charger", "notebook", "pen", "business cards", "portfolio", "formal attire", "water bottle"],
            priority: .high
        ),
        
        // Travel & Adventure
        EventCategory(
            keywords: ["trip", "travel", "vacation", "journey", "adventure", "explore"],
            contextWords: ["weekend", "holiday", "getaway", "visit", "tour"],
            items: ["suitcase", "passport", "tickets", "camera", "charger", "travel adapter", "sunglasses", "comfortable shoes"],
            priority: .high
        ),
        
        // Outdoor Activities
        EventCategory(
            keywords: ["camping", "hiking", "outdoor", "nature", "wilderness", "trail"],
            contextWords: ["mountain", "forest", "park", "adventure", "explore"],
            items: ["tent", "sleeping bag", "flashlight", "first aid kit", "water bottle", "trail mix", "hiking boots", "map"],
            priority: .high
        ),
        
        // Beach & Water Activities
        EventCategory(
            keywords: ["beach", "swimming", "pool", "water", "surf", "ocean", "lake"],
            contextWords: ["summer", "vacation", "relax", "sun"],
            items: ["swimsuit", "sunscreen", "beach towel", "flip flops", "water bottle", "snacks", "umbrella", "goggles"],
            priority: .high
        ),
        
        // Social Events & Parties
        EventCategory(
            keywords: ["party", "celebration", "birthday", "anniversary", "social", "gathering"],
            contextWords: ["friends", "family", "fun", "celebrate"],
            items: ["gifts", "decorations", "snacks", "drinks", "music playlist", "camera", "party supplies"],
            priority: .high
        ),
        
        // Sports & Fitness
        EventCategory(
            keywords: ["gym", "workout", "exercise", "fitness", "sports", "training", "run", "yoga"],
            contextWords: ["health", "active", "physical", "strength"],
            items: ["water bottle", "towel", "workout clothes", "sneakers", "headphones", "fitness tracker"],
            priority: .high
        ),
        
        // Food & Dining
        EventCategory(
            keywords: ["dinner", "lunch", "breakfast", "meal", "restaurant", "cooking", "bbq", "picnic"],
            contextWords: ["food", "eat", "taste", "delicious"],
            items: ["reservation", "wallet", "nice outfit", "appetite", "napkins", "utensils"],
            priority: .medium
        ),
        
        // Entertainment
        EventCategory(
            keywords: ["movie", "concert", "show", "theater", "entertainment", "performance"],
            contextWords: ["watch", "listen", "enjoy", "fun"],
            items: ["tickets", "comfortable clothes", "snacks", "phone", "cash", "earplugs"],
            priority: .medium
        ),
        
        // Home & Personal
        EventCategory(
            keywords: ["cleaning", "organizing", "home", "house", "maintenance", "repair"],
            contextWords: ["tidy", "fix", "improve", "organize"],
            items: ["cleaning supplies", "gloves", "trash bags", "tools", "vacuum", "paper towels"],
            priority: .medium
        )
    ]
    
    private let seasonalItems: [String: [String]] = [
        "winter": ["coat", "gloves", "scarf", "boots", "warm clothes"],
        "spring": ["light jacket", "umbrella", "allergy medicine", "flowers"],
        "summer": ["sunscreen", "hat", "shorts", "sandals", "water bottle"],
        "fall": ["jacket", "boots", "warm drinks", "sweater"]
    ]
    
    func getSuggestions(for eventTitle: String, date: Date) -> [String] {
        let title = eventTitle.lowercased()
        var suggestions: [String] = []
        var matchedCategories: [(EventCategory, Double)] = []
        
        // Enhanced pattern matching with scoring
        for category in eventCategories {
            let score = calculateCategoryScore(title: title, category: category)
            if score > 0 {
                matchedCategories.append((category, score))
            }
        }
        
        // Sort by score and priority
        matchedCategories.sort { first, second in
            if first.0.priority != second.0.priority {
                return first.0.priority.rawValue > second.0.priority.rawValue
            }
            return first.1 > second.1
        }
        
        // Add suggestions from best matching categories
        for (category, _) in matchedCategories.prefix(3) {
            suggestions.append(contentsOf: category.items)
        }
        
        // Add seasonal suggestions only if they make sense
        if shouldAddSeasonalSuggestions(for: title) {
            let season = getCurrentSeason(for: date)
            if let seasonalItems = seasonalItems[season] {
                suggestions.append(contentsOf: seasonalItems)
            }
        }
        
        // Remove duplicates and return top suggestions
        let uniqueSuggestions = Array(Set(suggestions))
        return Array(uniqueSuggestions.prefix(8))
    }
    
    private func calculateCategoryScore(title: String, category: EventCategory) -> Double {
        var score: Double = 0
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = title.components(separatedBy: separators)
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
        
        // Check for exact keyword matches
        for keyword in category.keywords {
            if title.contains(keyword) {
                score += 2.0
            }
        }
        
        // Check for context word matches (bonus points)
        for contextWord in category.contextWords {
            if title.contains(contextWord) {
                score += 1.0
            }
        }
        
        // Check for word-level matches (more precise)
        for word in words {
            if category.keywords.contains(word) {
                score += 3.0 // Higher score for exact word matches
            }
            if category.contextWords.contains(word) {
                score += 1.5
            }
        }
        
        return score
    }
    
    private func shouldAddSeasonalSuggestions(for title: String) -> Bool {
        // Only add seasonal suggestions for outdoor or travel events
        let outdoorKeywords = ["outdoor", "trip", "vacation", "beach", "camping", "hiking", "picnic", "festival"]
        return outdoorKeywords.contains { title.contains($0) }
    }
    
    private func getCurrentSeason(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 12, 1, 2: return "winter"
        case 3, 4, 5: return "spring"
        case 6, 7, 8: return "summer"
        case 9, 10, 11: return "fall"
        default: return "summer"
        }
    }
}

// MARK: - Cloud Suggestion Engine
class CloudSuggestionEngine {
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions" // Groq API endpoint
    private let config = AIConfiguration.shared
    
    func getSuggestions(for eventTitle: String, date: Date, completion: @escaping ([String]) -> Void) {
        // Skip cloud suggestions if no valid API key
        guard config.hasValidAPIKey else {
            completion([])
            return
        }
        
        let apiKey = config.apiKey
        
        let prompt = createPrompt(for: eventTitle, date: date)
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant", // Groq's fast Llama model
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that suggests items needed for events. Return only a JSON array of item names, maximum 8 items."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating request body: \(error)")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error for '\(eventTitle)': \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data received for '\(eventTitle)'")
                completion([])
                return
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔍 Raw Groq response for '\(eventTitle)': \(responseString)")
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let choices = result?["choices"] as? [[String: Any]]
                let message = choices?.first?["message"] as? [String: Any]
                let content = message?["content"] as? String ?? ""
                
                print("🤖 Groq content for '\(eventTitle)': '\(content)'")
                
                // Validate and parse the response
                let validatedItems = self.validateAndParseResponse(content, for: eventTitle)
                completion(validatedItems)
                
            } catch {
                print("❌ JSON parsing error for '\(eventTitle)': \(error)")
                completion([])
            }
        }.resume()
    }
    
    private func createPrompt(for eventTitle: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        
        // Extract key context words to help LLM focus
        let contextAnalysis = analyzeEventContext(eventTitle)
        
        return """
        Event: "\(eventTitle)" on \(dateString)
        
        STEP 1 - Event Analysis:
        Identify the PRIMARY activity: \(contextAnalysis.primaryActivity)
        Location type: \(contextAnalysis.locationType)
        My role: \(contextAnalysis.myRole)
        
        STEP 2 - Item Selection Rules:
        - ONLY suggest items I personally need to bring or prepare
        - EXCLUDE items provided by venues, hosts, or services
        - Focus on preparation, participation, or personal needs
        - Be specific and practical
        
        STEP 3 - Context Validation:
        - Shopping/grocery → ingredients, shopping list, bags, wallet
        - Meeting/chat → notebook, pen, business cards, phone
        - Cooking/meal prep → ingredients, utensils, recipe
        - Dining out → wallet, reservation confirmation, nice clothes
        - Travel → luggage, documents, comfort items
        
        Return ONLY a valid JSON array of 3-8 specific items:
        ["item1", "item2", "item3"]
        
        NO explanations, NO categories, NO venue items.
        """
    }
    
    private func analyzeEventContext(_ eventTitle: String) -> EventContext {
        let title = eventTitle.lowercased()
        
        // Detect primary activity
        let primaryActivity: String
        let locationType: String
        let myRole: String
        
        if title.contains("grocery") || title.contains("shopping") || title.contains("buy") {
            primaryActivity = "shopping/purchasing"
            locationType = "store/market"
            myRole = "shopper"
        } else if title.contains("coffee") || title.contains("chat") || title.contains("meeting") {
            primaryActivity = "meeting/discussion"
            locationType = "café/office"
            myRole = "participant"
        } else if title.contains("cooking") || title.contains("meal prep") || title.contains("recipe") {
            primaryActivity = "cooking/preparation"
            locationType = "kitchen/home"
            myRole = "cook"
        } else if title.contains("dinner") || title.contains("restaurant") || title.contains("dining") {
            primaryActivity = "dining out"
            locationType = "restaurant"
            myRole = "diner"
        } else if title.contains("travel") || title.contains("trip") || title.contains("vacation") {
            primaryActivity = "traveling"
            locationType = "various"
            myRole = "traveler"
        } else {
            primaryActivity = "general activity"
            locationType = "to be determined"
            myRole = "participant"
        }
        
        return EventContext(
            primaryActivity: primaryActivity,
            locationType: locationType,
            myRole: myRole
        )
    }
    
    private struct EventContext {
        let primaryActivity: String
        let locationType: String
        let myRole: String
    }
    
    private func validateAndParseResponse(_ content: String, for eventTitle: String) -> [String] {
        // Step 1: Try to parse as JSON array
        if let jsonData = content.data(using: .utf8),
           let items = try? JSONSerialization.jsonObject(with: jsonData) as? [String] {
            let validatedItems = validateItems(items, for: eventTitle)
            print("✅ JSON parsed successfully for '\(eventTitle)': \(validatedItems)")
            return validatedItems
        }
        
        // Step 2: Try to extract JSON array from text
        if let jsonMatch = extractJSONArray(from: content) {
            let validatedItems = validateItems(jsonMatch, for: eventTitle)
            print("✅ JSON extracted from text for '\(eventTitle)': \(validatedItems)")
            return validatedItems
        }
        
        // Step 3: Fallback to comma-separated parsing
        let fallbackItems = content
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 1 }
        
        let validatedItems = validateItems(fallbackItems, for: eventTitle)
        print("⚠️ Fallback parsing for '\(eventTitle)': \(validatedItems)")
        return validatedItems
    }
    
    private func extractJSONArray(from text: String) -> [String]? {
        // Look for JSON array pattern in the text
        let pattern = #"\[([^\]]+)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return nil
        }
        
        let jsonString = String(text[range])
        guard let data = jsonString.data(using: .utf8),
              let items = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return nil
        }
        
        return items
    }
    
    private func validateItems(_ items: [String], for eventTitle: String) -> [String] {
        let title = eventTitle.lowercased()
        let contextAnalysis = analyzeEventContext(eventTitle)
        
        return items
            .filter { item in
                let itemLower = item.lowercased()
                
                // Filter out obviously wrong suggestions based on context
                if contextAnalysis.primaryActivity == "shopping/purchasing" {
                    // For shopping, exclude dining/restaurant items
                    let diningItems = ["reservation", "nice outfit", "formal attire", "dress", "suit"]
                    return !diningItems.contains { itemLower.contains($0) }
                }
                
                if contextAnalysis.primaryActivity == "meeting/discussion" {
                    // For meetings, exclude venue/service items
                    let venueItems = ["coffee", "coffee machine", "beans", "menu", "table"]
                    return !venueItems.contains { itemLower.contains($0) }
                }
                
                if contextAnalysis.primaryActivity == "dining out" {
                    // For dining out, exclude cooking items
                    let cookingItems = ["ingredients", "recipe", "cooking utensils", "stove", "pan"]
                    return !cookingItems.contains { itemLower.contains($0) }
                }
                
                // General validation - exclude obviously wrong items
                let invalidItems = ["venue", "location", "host", "service", "staff", "menu", "table", "chair"]
                return !invalidItems.contains { itemLower.contains($0) }
            }
            .prefix(8)
            .map { $0 }
    }
    
    
    // MARK: - Speech-to-Event Parsing
    func parseEventFromSpeech(_ speechText: String, completion: @escaping (ParsedEvent?) -> Void) {
        print("🎤 Starting to parse speech: '\(speechText)'")
        
        // Skip cloud parsing if not in Groq mode or no API key
        let config = AIConfiguration.shared
        print("🔧 AI Mode: \(config.currentMode), Has API Key: \(config.hasValidAPIKey)")
        
        guard config.currentMode == .groqCloud && config.hasValidAPIKey else {
            print("⚠️ Using local parsing fallback")
            // Use local parsing as fallback
            let localParsed = parseEventLocally(speechText)
            print("📝 Local parsing result: \(localParsed?.title ?? "nil")")
            completion(localParsed)
            return
        }
        
        print("🌐 Using cloud parsing with Groq")
        
        let prompt = createEventParsingPrompt(speechText)
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an expert at parsing event descriptions and extracting structured information. Always return valid JSON."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 300,
            "temperature": 0.3
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Error creating event parsing request: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error for event parsing: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data received for event parsing")
                completion(nil)
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let choices = result?["choices"] as? [[String: Any]]
                let message = choices?.first?["message"] as? [String: Any]
                let content = message?["content"] as? String ?? ""
                
                print("🤖 Event parsing response: '\(content)'")
                
                let parsedEvent = self.parseEventResponse(content)
                print("🔍 Parsed event result: \(parsedEvent?.title ?? "nil")")
                
                DispatchQueue.main.async {
                    completion(parsedEvent)
                }
                
            } catch {
                print("❌ JSON parsing error for event: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func createEventParsingPrompt(_ speechText: String) -> String {
        return """
        Parse this event description and extract structured information:
        
        "\(speechText)"
        
        Extract:
        1. Event title (concise, 2-5 words)
        2. Event details (what, when, where, why)
        3. Items needed (things to bring/prepare)
        4. Suggested date (if mentioned, otherwise use today + 1 day)
        
        Return ONLY this JSON format:
        {
          "title": "Event Title",
          "details": "Detailed description of the event",
          "items": ["item1", "item2", "item3"],
          "suggestedDate": "2025-07-18"
        }
        
        Rules:
        - Title should be short and descriptive
        - Details should capture the essence and context
        - Items should be things the person needs to bring/prepare
        - Date format: YYYY-MM-DD
        - Maximum 8 items
        """
    }
    
    private func parseEventResponse(_ content: String) -> ParsedEvent? {
        print("🔍 Parsing event response content: '\(content)'")
        
        // Try to extract JSON from the response
        guard let jsonData = extractEventJSON(from: content) else {
            print("❌ Failed to extract JSON from event response")
            print("🔍 Raw content was: '\(content)'")
            
            // Try fallback parsing if JSON extraction fails
            return parseEventFallback(content)
        }
        
        print("🔍 Extracted JSON: '\(jsonData)'")
        
        guard let data = jsonData.data(using: .utf8) else {
            print("❌ Failed to convert JSON string to data")
            return parseEventFallback(content)
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let parsedEvent = try decoder.decode(ParsedEvent.self, from: data)
            print("✅ Successfully parsed event: \(parsedEvent.title)")
            return parsedEvent
        } catch {
            print("❌ Failed to decode parsed event: \(error)")
            print("🔍 JSON data was: '\(jsonData)'")
            
            // Try fallback parsing
            return parseEventFallback(content)
        }
    }
    
    private func parseEventFallback(_ content: String) -> ParsedEvent? {
        print("🔄 Attempting fallback parsing")
        
        // Simple fallback parsing
        let lines = content.components(separatedBy: .newlines)
        var title = "New Event"
        var details = content
        var items: [String] = []
        
        // Look for title patterns
        for line in lines {
            if line.lowercased().contains("title") || line.lowercased().contains("event") {
                // Extract title from line
                let cleaned = line.replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: "title:", with: "")
                    .replacingOccurrences(of: "Title:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty && cleaned.count > 2 {
                    title = cleaned
                    break
                }
            }
        }
        
        // Look for items in brackets or comma-separated
        let itemPattern = #"\[(.*?)\]"#
        if let regex = try? NSRegularExpression(pattern: itemPattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            let itemsString = String(content[range])
            items = itemsString.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") }
                .filter { !$0.isEmpty }
        }
        
        let result = ParsedEvent(
            title: title,
            details: details,
            items: items,
            suggestedDate: Date().addingTimeInterval(86400)
        )
        
        print("🔄 Fallback parsing result: Title='\(result.title)', Items=\(result.items)")
        return result
    }
    
    private func extractEventJSON(from text: String) -> String? {
        // Look for JSON object in the text
        let pattern = #"\{[^{}]*\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return nil
        }
        
        return String(text[range])
    }
    
    private func parseEventLocally(_ speechText: String) -> ParsedEvent? {
        print("🔧 Local parsing started for: '\(speechText)'")
        
        // Simple local parsing as fallback
        let words = speechText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard words.count >= 3 else { 
            print("❌ Not enough words for local parsing")
            return nil 
        }
        
        // Extract title - look for event keywords or use first few words
        var title = ""
        let eventKeywords = ["hiking", "trip", "meeting", "party", "dinner", "shopping", "interview", "chat", "vacation", "camping", "workout", "gym", "run", "walk", "bike", "swim"]
        
        // Try to find a meaningful title based on activity
        let lowerText = speechText.lowercased()
        for keyword in eventKeywords {
            if lowerText.contains(keyword) {
                // Create a meaningful title based on the activity
                switch keyword {
                case "hiking":
                    title = "Hiking Trip"
                case "trip":
                    title = "Trip"
                case "meeting":
                    title = "Meeting"
                case "party":
                    title = "Party"
                case "dinner":
                    title = "Dinner"
                case "shopping":
                    title = "Shopping"
                case "workout", "gym":
                    title = "Workout"
                default:
                    title = keyword.capitalized
                }
                
                // Add context if available
                if lowerText.contains("next week") {
                    title = "Next Week \(title)"
                } else if lowerText.contains("weekend") {
                    title = "Weekend \(title)"
                }
                
                break
            }
        }
        
        // Fallback: extract meaningful phrases
        if title.isEmpty {
            // Look for "going to/for" patterns
            if lowerText.contains("going for") || lowerText.contains("going to") {
                let pattern = #"going (?:for|to) (?:a |an )?(\w+(?:\s+\w+)?)"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: speechText, range: NSRange(speechText.startIndex..., in: speechText)),
                   let range = Range(match.range(at: 1), in: speechText) {
                    title = String(speechText[range]).capitalized
                }
            }
            
            // Final fallback
            if title.isEmpty {
                title = words.prefix(3).joined(separator: " ").capitalized
            }
        }
        
        // Clean up title
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Use the full speech as details
        let details = speechText
        
        // Enhanced item extraction with context-aware suggestions
        var items: [String] = []
        
        // Context-based item suggestions
        if title.lowercased().contains("hiking") || lowerText.contains("hiking") || lowerText.contains("outside") {
            items = ["hiking boots", "backpack", "water bottle", "trail snacks", "first aid kit", "map", "flashlight", "rain jacket"]
        } else if title.lowercased().contains("camping") || lowerText.contains("camping") {
            items = ["tent", "sleeping bag", "camping stove", "food supplies", "water", "flashlight", "matches"]
        } else if title.lowercased().contains("trip") && lowerText.contains("outside") {
            items = ["outdoor gear", "weather protection", "navigation tools", "emergency supplies"]
        } else if title.lowercased().contains("workout") || lowerText.contains("gym") {
            items = ["workout clothes", "water bottle", "towel", "protein shake"]
        } else if title.lowercased().contains("shopping") {
            items = ["shopping list", "reusable bags", "wallet"]
        } else if title.lowercased().contains("meeting") {
            items = ["notebook", "pen", "laptop", "documents"]
        }
        
        // Also try to extract explicitly mentioned items
        let itemKeywords = ["bring", "need", "get", "buy", "pack", "prepare", "take", "grab", "purchase", "kit"]
        
        for (index, word) in words.enumerated() {
            if itemKeywords.contains(word.lowercased()) && index + 1 < words.count {
                // Take next few words as potential items
                let remainingWords = Array(words[(index + 1)...])
                
                // Look for items until we hit a stop word
                let stopWords = ["for", "to", "at", "on", "in", "and", "or", "but", "because", "so", "when", "where", "i", "i'm", "going"]
                var itemWords: [String] = []
                
                for nextWord in remainingWords {
                    if stopWords.contains(nextWord.lowercased()) || itemWords.count >= 3 {
                        break
                    }
                    itemWords.append(nextWord)
                }
                
                if !itemWords.isEmpty {
                    let extractedItem = itemWords.joined(separator: " ")
                    if !items.contains(extractedItem) {
                        items.append(extractedItem)
                    }
                }
            }
        }
        
        // Extract date if mentioned
        var suggestedDate = Date().addingTimeInterval(86400) // Default to tomorrow
        let lowerSpeech = speechText.lowercased()
        
        if lowerSpeech.contains("today") {
            suggestedDate = Date()
        } else if lowerSpeech.contains("tomorrow") {
            suggestedDate = Date().addingTimeInterval(86400)
        } else if lowerSpeech.contains("next week") {
            // Next week = 7 days from now
            suggestedDate = Date().addingTimeInterval(86400 * 7)
        } else if lowerSpeech.contains("weekend") {
            // This weekend = next Saturday
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            let daysUntilSaturday = (7 - weekday + 7) % 7 // Days until next Saturday
            suggestedDate = calendar.date(byAdding: .day, value: daysUntilSaturday, to: today) ?? Date()
        } else if lowerSpeech.contains("this week") {
            // This week = in 2-3 days
            suggestedDate = Date().addingTimeInterval(86400 * 3)
        }
        
        let result = ParsedEvent(
            title: title,
            details: details,
            items: Array(items.prefix(6)),
            suggestedDate: suggestedDate
        )
        
        print("✅ Local parsing result: Title='\(result.title)', Items=\(result.items), Date=\(result.suggestedDate)")
        print("🔍 Parsing details: Original text='\(speechText)', Detected activity='\(title)', Item count=\(result.items.count)")
        return result
    }
}

// MARK: - ParsedEvent model is now in Core/Models/ParsedEvent.swift