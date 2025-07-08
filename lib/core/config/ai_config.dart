class AIConfig {
  // Replace this with your actual Gemini API key
  // Get your free API key from: https://makersuite.google.com/
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // API Configuration
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const int maxTokens = 500;
  static const double temperature = 0.7;
  static const int topK = 40;
  static const double topP = 0.95;
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Safety settings
  static const List<Map<String, String>> safetySettings = [
    {
      'category': 'HARM_CATEGORY_HARASSMENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_HATE_SPEECH',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    },
    {
      'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
    }
  ];
  
  // Validate API key
  static bool get isApiKeyValid {
    return geminiApiKey.isNotEmpty && 
           geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' &&
           geminiApiKey.length > 20;
  }
  
  // Get API key with validation
  static String get apiKey {
    if (!isApiKeyValid) {
      throw Exception(
        'Gemini API key not configured. Please set your API key in AIConfig.geminiApiKey'
      );
    }
    return geminiApiKey;
  }
}
