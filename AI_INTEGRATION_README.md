# SmarNote - AI-Powered Event Planning

## Overview

SmarNote is an intelligent event planning and management app that combines **hybrid AI suggestions**, **voice-to-event creation**, and **smart inventory management** to revolutionize how you plan and organize events. The app features a sophisticated AI system that works both locally and in the cloud for the best user experience.

## Core Features

### 🎤 Voice Event Creation (New!)

- **Natural Speech Processing**: Describe your event naturally and let AI extract all the details
- **Real-time Transcription**: Live speech-to-text conversion with visual feedback
- **Intelligent Parsing**: AI automatically identifies event title, date, items needed, and details
- **Hands-free Operation**: Complete event creation without typing
- **Smart Error Handling**: Helpful tips and retry options for better recognition

### 🧠 Enhanced Local AI (Always Available)

- **Context-aware suggestions**: Advanced category system with 10+ specialized event types
- **Smart word analysis**: Understands context and related terms, not just simple keywords
- **Priority-based ranking**: Academic and professional events get higher-quality suggestions
- **Intelligent seasonal logic**: Only adds weather items when contextually relevant
- **Advanced scoring system**: Ranks suggestions by relevance and context
- **Lightning-fast response**: Instant suggestions without internet dependency
- **100% Privacy-focused**: No data leaves your device

### ⚡ Groq Cloud AI (Optional - Lightning Fast)

- **Ultra-fast processing**: Powered by Groq's optimized Llama 3.1 models
- **Advanced contextual understanding**: More nuanced and creative suggestions
- **Real-world knowledge**: Leverages extensive training data for better suggestions
- **Smart context analysis**: Understands your role and event type for precise recommendations
- **Intelligent validation**: Filters out irrelevant suggestions automatically

## How It Works

### Hybrid Approach

1. **Local suggestions appear instantly** when you type an event title
2. **Cloud suggestions enhance the list** if you have an API key configured
3. **Smart deduplication** ensures no duplicate suggestions
4. **Seamless fallback** to local-only mode if cloud is unavailable

### Trigger Conditions

- Suggestions appear when event title is **3+ characters**
- Updates automatically as you type (with 0.5s debounce)
- Considers both event title and selected date for seasonal relevance

## Setup Instructions

### 1. Local AI (No Setup Required)

The local AI works immediately with built-in patterns for:

- Travel & Vacation (trip, beach, camping, hiking)
- Events & Parties (birthday, wedding, dinner, bbq)
- Work & Business (meeting, conference, presentation)
- Sports & Fitness (gym, workout, yoga, swimming)
- Home & Maintenance (cleaning, cooking, gardening)
- Seasonal activities (winter, summer, spring, fall)

### 2. Cloud AI Setup (Optional)

#### Step 1: Get Groq API Key

1. Visit [console.groq.com](https://console.groq.com)
2. Sign up for a free account
3. Navigate to the "API Keys" section
4. Click "Create API Key"
5. Copy the key (starts with `gsk_`)

#### Step 2: Configure in App

1. Open SmarNote app
2. Go to Dashboard (Home tab)
3. Tap the brain icon (🧠) in the top-right corner
4. Select "Groq Cloud AI" mode
5. Paste your API key in the secure field
6. Tap "Save API Key"

#### Step 3: Verify Setup

- You should see "AI Features Enabled" status
- The "Add New Event" button will show an "AI" badge
- Enhanced suggestions will appear when creating events

## Usage

### Creating Events with Voice

1. Go to the Voice tab
2. Tap the record button and describe your event naturally
3. Example: "I'm planning a weekend camping trip next Saturday. I need to bring a tent, sleeping bag, flashlight, and food for the mountains."
4. AI will process your speech and extract event details
5. Review the parsed event and tap "Add Event"

### Creating Events with AI Suggestions

1. Tap "Add New Event" from Dashboard or Events tab
2. Start typing your event title (e.g., "Beach vacation")
3. Watch as suggestions appear below the items section
4. Tap any suggestion to add it to your event
5. Local suggestions appear instantly, cloud suggestions may take 1-2 seconds

### Managing Your Inventory

1. Go to the Items tab to manage your available items
2. Add items you already have at home
3. Events automatically complete when you have all required items
4. See which events need specific items

### Example Suggestions

**"Camping trip"** might suggest:

- tent, sleeping bag, flashlight, matches, first aid kit (local)
- camping stove, insect repellent, portable charger (cloud)

**"Birthday party"** might suggest:

- cake, candles, balloons, gifts, party hats (local)
- party favors, photo props, playlist, decorations (cloud)

## Privacy & Security

### Local AI

- All processing happens on your device
- No data is transmitted anywhere
- Completely private and secure

### Cloud AI

- Only event titles and dates are sent to Groq
- API key is stored securely in your device's keychain
- No personal information or other app data is shared
- You can remove the API key anytime

## Cost Considerations

### Local AI

- Completely free
- No ongoing costs

### Cloud AI

- Uses Groq's API (pay-per-use)
- Typical cost: ~$0.001-0.002 per suggestion
- Most users spend less than $1/month
- You control usage by enabling/disabling the API key

## Troubleshooting

### No Suggestions Appearing

1. Ensure event title is at least 3 characters
2. Check internet connection (for cloud suggestions)
3. Verify API key is correctly entered
4. Try a more descriptive event title

### Cloud Suggestions Not Working

1. Check AI Settings - should show "AI Features Enabled"
2. Verify API key starts with "gsk\_"
3. Ensure you have Groq API credits
4. Local suggestions should still work

### Performance Issues

1. Cloud suggestions may take 1-2 seconds - this is normal
2. Local suggestions are always instant
3. Suggestions are cached briefly to improve performance

## Technical Implementation

### Architecture

```
AIService (Main Interface)
├── LocalSuggestionEngine (Pattern matching)
└── CloudSuggestionEngine (Groq API)
```

### Key Components

- `AIService.swift`: Main service coordinating local and cloud suggestions
- `AIConfiguration.swift`: API key management and settings UI
- `SpeechService.swift`: Voice recognition and transcription
- `VoiceRecordingView.swift`: Voice-to-event creation interface
- Enhanced `AddDishView` and `EditEventView` with suggestion UI
- Hybrid suggestion combining and ranking logic

### Integration Points

- Event creation and editing forms
- Voice-to-event creation workflow
- Real-time suggestion updates
- Settings and configuration management
- Visual indicators for AI availability

## Future Enhancements

Potential improvements for future versions:

- Smart quantity suggestions
- Location-based recommendations
- Learning from user preferences
- Offline AI model for enhanced local suggestions
- Multi-language voice recognition
- Calendar integration

## Support

If you encounter any issues:

1. Check this README for troubleshooting steps
2. Verify your Groq API key and account status
3. Try using local-only mode by removing the API key
4. Local suggestions should always work regardless of cloud issues
5. For voice issues, check microphone and speech permissions in Settings

---

**Enjoy your AI-powered event planning! 🎉**
