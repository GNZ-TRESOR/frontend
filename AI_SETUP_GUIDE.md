# 🤖 AI Integration Setup Guide for Ubuzima App

## 🎯 Overview
This guide will help you set up Google Gemini AI integration in your Ubuzima app. The integration is **completely FREE** for students and provides intelligent health assistance in Kinyarwanda, French, and English.

## 📋 Prerequisites
- Flutter development environment
- Internet connection
- Google account

## 🚀 Step 1: Get Your Free Gemini API Key

### 1.1 Visit Google AI Studio
1. Go to [Google AI Studio](https://makersuite.google.com/)
2. Sign in with your Google account (use your student email if available)
3. Accept the terms of service

### 1.2 Create API Key
1. Click on "Get API Key" in the left sidebar
2. Click "Create API Key"
3. Select "Create API key in new project" or choose existing project
4. Copy your API key (it will look like: `AIzaSyC...`)

⚠️ **Important**: Keep your API key secure and never commit it to public repositories!

## 🔧 Step 2: Configure the Ubuzima App

### 2.1 Add Your API Key
1. Open `frontend/ubuzima_app/lib/core/config/ai_config.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:

```dart
class AIConfig {
  // Replace with your actual API key
  static const String geminiApiKey = 'AIzaSyC_your_actual_api_key_here';
  // ... rest of the configuration
}
```

### 2.2 Install Dependencies
Run the following command in your project directory:
```bash
cd frontend/ubuzima_app
flutter pub get
```

## 🧪 Step 3: Test the Integration

### 3.1 Run the App
```bash
flutter run
```

### 3.2 Test AI Features
1. **Dashboard**: Look for the purple "Umujyanama w'AI" card
2. **Health Tracking**: Tap the AI assistant floating action button
3. **Chat Interface**: Ask questions in Kinyarwanda, French, or English

### 3.3 Sample Questions to Test
**In Kinyarwanda:**
- "Ni gute nshobora kurinda inda?"
- "Ni iki gikenewe mu gihe cy'inda?"
- "Ese ni ngombwa gusura muganga?"

**In English:**
- "How can I prevent pregnancy?"
- "What contraceptive methods are available?"
- "When should I see a doctor?"

**In French:**
- "Comment puis-je éviter une grossesse?"
- "Quelles méthodes contraceptives sont disponibles?"
- "Quand dois-je consulter un médecin?"

## 📊 Step 4: Monitor Usage (Free Limits)

### Free Tier Limits:
- **15 requests per minute**
- **1,500 requests per day**
- **No monthly limit**

### Check Usage:
1. Visit [Google AI Studio](https://makersuite.google.com/)
2. Go to "API Keys" section
3. Monitor your usage statistics

## 🎨 Step 5: Customize AI Responses

### 5.1 Modify Prompts
Edit prompts in `frontend/ubuzima_app/lib/core/services/gemini_ai_service.dart`:

```dart
String _buildHealthPrompt(String question, String language) {
  // Customize the system prompt here
  return '''
  Wowe uri umujyanama w'ubuzima bw'ababyeyi mu cyaro cya Rwanda.
  // Add your custom instructions here
  ''';
}
```

### 5.2 Add New AI Features
You can extend the AI service by adding new methods:

```dart
Future<String> getCustomAdvice(String topic) async {
  // Add your custom AI functionality
}
```

## 🔍 Step 6: Troubleshooting

### Common Issues:

#### 6.1 "API Key not configured" Error
- **Solution**: Make sure you've replaced `YOUR_GEMINI_API_KEY_HERE` with your actual API key

#### 6.2 "Network Error" or "Connection Failed"
- **Solution**: Check your internet connection
- **Solution**: Verify your API key is correct
- **Solution**: Check if you've exceeded the rate limits

#### 6.3 "Invalid API Key" Error
- **Solution**: Generate a new API key from Google AI Studio
- **Solution**: Make sure there are no extra spaces in your API key

#### 6.4 AI Responses in Wrong Language
- **Solution**: The AI automatically detects language based on the question
- **Solution**: You can force a specific language by asking in that language

### Debug Mode:
Enable debug logging by adding this to your main.dart:
```dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    print('AI Debug mode enabled');
  }
  runApp(UbuzimaApp());
}
```

## 🎓 Step 7: For University Presentation

### Demo Script:
1. **Show the AI card** on the dashboard
2. **Ask a health question** in Kinyarwanda
3. **Demonstrate real-time response** 
4. **Show multilingual support** by asking in English/French
5. **Highlight cultural sensitivity** of responses

### Key Points to Mention:
- ✅ **Free AI integration** - No cost for students
- ✅ **Culturally appropriate** - Responses in Kinyarwanda
- ✅ **Real-time assistance** - Instant health advice
- ✅ **Multilingual support** - English, French, Kinyarwanda
- ✅ **Privacy-focused** - No personal data stored by AI

## 📈 Step 8: Future Enhancements

### Possible Improvements:
1. **Voice Input/Output** - Add speech-to-text and text-to-speech
2. **Personalized Responses** - Based on user profile and history
3. **Offline AI** - Cache common responses for offline use
4. **Medical Image Analysis** - Add image recognition capabilities
5. **Appointment Scheduling** - AI-powered appointment booking

## 🆘 Support

### If You Need Help:
1. **Check the console** for error messages
2. **Verify API key** is correctly set
3. **Test with simple questions** first
4. **Check internet connection**
5. **Review Google AI Studio documentation**

### Resources:
- [Google AI Studio Documentation](https://ai.google.dev/)
- [Gemini API Reference](https://ai.google.dev/api)
- [Flutter Dio Package](https://pub.dev/packages/dio)

---

## 🎉 Congratulations!

You've successfully integrated AI into your Ubuzima app! This will make your final year project stand out and provide real value to users in rural Rwanda.

**Your app now has intelligent health assistance that can:**
- Answer family planning questions
- Provide contraceptive advice
- Offer health guidance in local languages
- Support users 24/7 with reliable information

**Perfect for your university presentation!** 🎓✨
