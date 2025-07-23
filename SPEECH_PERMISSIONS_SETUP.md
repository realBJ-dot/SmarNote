# Speech Recognition Setup

## Required Info.plist Permissions

Add these keys to your `Info.plist` file for the speech-to-text feature to work:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>SmarNote needs microphone access to convert your speech into event details and suggestions.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>SmarNote uses speech recognition to help you create events by describing them verbally.</string>
```

## How to Add:

1. Open your `Info.plist` file in Xcode
2. Right-click and select "Add Row"
3. Add both keys above with their descriptions
4. Build and run the app

## What This Enables:

- **Microphone Access**: Required to capture audio for speech recognition
- **Speech Recognition**: Required to convert speech to text using iOS Speech framework

The app will automatically request these permissions when the user first tries to use the speech-to-event feature.
