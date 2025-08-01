import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

/// AI Chat Service with intelligent rule-based responses
/// Completely free and works offline!
class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  final Random _random = Random();

  /// Send message to AI and get intelligent response
  Future<String> sendMessage(
    String message,
    List<ChatMessage> chatHistory,
  ) async {
    try {
      // Use intelligent rule-based system for reliable responses
      final response = _getIntelligentResponse(message, chatHistory);

      if (kDebugMode) {
        print('✅ AI response generated: ${response.substring(0, 50)}...');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI Service Error: $e');
      }
      return _getDefaultResponse(message);
    }
  }

  /// Intelligent rule-based response system
  String _getIntelligentResponse(
    String message,
    List<ChatMessage> chatHistory,
  ) {
    final lowerMessage = message.toLowerCase().trim();

    // Greeting responses
    if (_isGreeting(lowerMessage)) {
      return _getGreetingResponse();
    }

    // Family planning specific questions
    if (_isFamilyPlanningQuestion(lowerMessage)) {
      return _getFamilyPlanningResponse(lowerMessage);
    }

    // Contraception questions
    if (_isContraceptionQuestion(lowerMessage)) {
      return _getContraceptionResponse(lowerMessage);
    }

    // Pregnancy questions
    if (_isPregnancyQuestion(lowerMessage)) {
      return _getPregnancyResponse(lowerMessage);
    }

    // Health questions
    if (_isHealthQuestion(lowerMessage)) {
      return _getHealthResponse(lowerMessage);
    }

    // Thank you responses
    if (_isThankYou(lowerMessage)) {
      return _getThankYouResponse();
    }

    // Fallback to contextual response
    return _getContextualResponse(message, chatHistory);
  }

  /// Build conversation context for better AI responses
  String _buildConversationContext(
    String currentMessage,
    List<ChatMessage> history,
  ) {
    final context = StringBuffer();

    // Add system context for family planning
    context.write(
      "You are Ubuzima Assistant, a helpful family planning advisor. ",
    );
    context.write(
      "Provide accurate, supportive information about family planning, reproductive health, and general wellness. ",
    );

    // Add recent conversation history (last 3 messages)
    final recentMessages =
        history
            .where((msg) => !msg.isLoading && !msg.hasError)
            .take(3)
            .toList();

    for (final msg in recentMessages) {
      if (msg.sender == MessageSender.user) {
        context.write("Human: ${msg.content} ");
      } else if (msg.sender == MessageSender.assistant) {
        context.write("Assistant: ${msg.content} ");
      }
    }

    // Add current message
    context.write("Human: $currentMessage ");
    context.write("Assistant:");

    return context.toString();
  }

  /// Clean up AI response
  String _cleanAIResponse(String response, String context) {
    // Remove the context from the response
    String cleaned = response.replaceFirst(context, '').trim();

    // Remove common AI artifacts
    cleaned =
        cleaned
            .replaceAll(
              RegExp(r'^(Assistant:|AI:|Bot:)\s*', caseSensitive: false),
              '',
            )
            .replaceAll(RegExp(r'Human:.*$'), '')
            .replaceAll(RegExp(r'\[.*?\]'), '') // Remove [tags]
            .trim();

    // Ensure response ends properly
    if (cleaned.isNotEmpty &&
        !cleaned.endsWith('.') &&
        !cleaned.endsWith('!') &&
        !cleaned.endsWith('?')) {
      cleaned += '.';
    }

    return cleaned;
  }

  /// Check if message needs family planning context
  bool _needsFamilyPlanningContext(String message) {
    final familyPlanningKeywords = [
      'contraception',
      'birth control',
      'pregnancy',
      'fertility',
      'family planning',
      'reproductive',
      'menstrual',
      'ovulation',
      'condom',
      'pill',
      'iud',
      'implant',
      'injection',
    ];

    final lowerMessage = message.toLowerCase();
    return familyPlanningKeywords.any(
      (keyword) => lowerMessage.contains(keyword),
    );
  }

  /// Add family planning context to generic responses
  String _addFamilyPlanningContext(String response, String originalMessage) {
    if (response.length < 20) {
      return _getDefaultResponse(originalMessage);
    }
    return response;
  }

  /// Get default response for various scenarios
  String _getDefaultResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm here to help with family planning and health questions. What would you like to know?";
    }

    if (lowerMessage.contains('contraception') ||
        lowerMessage.contains('birth control')) {
      return "There are many contraceptive options available. Would you like to know about specific methods like pills, IUDs, implants, or condoms?";
    }

    if (lowerMessage.contains('pregnancy')) {
      return "I can help with pregnancy-related questions. Are you looking for information about planning, prevention, or pregnancy health?";
    }

    if (lowerMessage.contains('thank')) {
      return "You're welcome! I'm always here to help with your family planning and health questions.";
    }

    return "I'm here to help with family planning and health questions. Could you please rephrase your question or ask about a specific topic?";
  }

  // === DETECTION METHODS ===

  bool _isGreeting(String message) {
    final greetings = [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ];
    return greetings.any((greeting) => message.contains(greeting));
  }

  bool _isFamilyPlanningQuestion(String message) {
    final keywords = [
      'family planning',
      'plan family',
      'reproductive health',
      'fertility',
      'conception',
    ];
    return keywords.any((keyword) => message.contains(keyword));
  }

  bool _isContraceptionQuestion(String message) {
    final keywords = [
      'contraception',
      'birth control',
      'prevent pregnancy',
      'condom',
      'pill',
      'iud',
      'implant',
      'injection',
    ];
    return keywords.any((keyword) => message.contains(keyword));
  }

  bool _isPregnancyQuestion(String message) {
    final keywords = [
      'pregnancy',
      'pregnant',
      'expecting',
      'baby',
      'prenatal',
      'antenatal',
    ];
    return keywords.any((keyword) => message.contains(keyword));
  }

  bool _isHealthQuestion(String message) {
    final keywords = [
      'health',
      'symptoms',
      'pain',
      'infection',
      'sti',
      'std',
      'menstrual',
      'period',
    ];
    return keywords.any((keyword) => message.contains(keyword));
  }

  bool _isThankYou(String message) {
    final thanks = ['thank', 'thanks', 'appreciate', 'grateful'];
    return thanks.any((thank) => message.contains(thank));
  }

  // === RESPONSE METHODS ===

  String _getGreetingResponse() {
    final responses = [
      "Hello! I'm your Ubuzima Assistant. I'm here to help with family planning and reproductive health questions. What would you like to know?",
      "Hi there! Welcome to Ubuzima. I can help you with family planning, contraception, pregnancy, and general health questions. How can I assist you today?",
      "Good day! I'm here to provide information about family planning and reproductive health. What questions do you have?",
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getFamilyPlanningResponse(String message) {
    if (message.contains('what is') || message.contains('define')) {
      return "Family planning is the practice of controlling the number and spacing of children through the use of contraceptive methods and fertility awareness. It helps individuals and couples decide when to have children, how many to have, and the spacing between pregnancies for optimal health outcomes.";
    }

    if (message.contains('benefit') || message.contains('advantage')) {
      return "Family planning offers many benefits: better maternal and child health, reduced infant mortality, economic advantages for families, women's empowerment, and reduced population growth pressure. It allows couples to plan pregnancies when they're physically, emotionally, and financially ready.";
    }

    return "Family planning involves making informed decisions about reproduction. This includes choosing contraceptive methods, planning pregnancy timing, and understanding fertility. Would you like specific information about contraceptive options or pregnancy planning?";
  }

  String _getContraceptionResponse(String message) {
    if (message.contains('pill') || message.contains('oral')) {
      return "Birth control pills are hormonal contraceptives taken daily. They're 91-99% effective when used correctly. There are combination pills (estrogen + progestin) and progestin-only pills. Common side effects include nausea, breast tenderness, and mood changes. Consult a healthcare provider to determine if they're right for you.";
    }

    if (message.contains('iud') || message.contains('intrauterine')) {
      return "IUDs (Intrauterine Devices) are small T-shaped devices inserted into the uterus. They're over 99% effective and can last 3-10 years depending on the type. There are hormonal IUDs (like Mirena) and copper IUDs. They're reversible and don't require daily attention.";
    }

    if (message.contains('condom')) {
      return "Condoms are barrier methods that prevent pregnancy and protect against STIs. Male condoms are 85-98% effective, while female condoms are 79-95% effective. They're the only contraceptive method that provides dual protection against pregnancy and sexually transmitted infections.";
    }

    if (message.contains('implant')) {
      return "Contraceptive implants are small rods inserted under the skin of the upper arm. They release hormones to prevent pregnancy for 3-4 years and are over 99% effective. The procedure is quick and reversible. Some women experience irregular bleeding initially.";
    }

    return "There are many contraceptive options available: pills, IUDs, implants, injections, condoms, diaphragms, and natural methods. Each has different effectiveness rates, benefits, and considerations. Would you like detailed information about any specific method?";
  }

  String _getPregnancyResponse(String message) {
    if (message.contains('planning') || message.contains('trying')) {
      return "When planning pregnancy: take folic acid supplements, maintain a healthy weight, avoid alcohol and smoking, get vaccinated if needed, and have a preconception checkup. Track your menstrual cycle to identify fertile days. Most couples conceive within 6-12 months of trying.";
    }

    if (message.contains('prevent') || message.contains('avoid')) {
      return "To prevent pregnancy, use reliable contraception consistently. Options include hormonal methods (pills, implants, injections), barrier methods (condoms), IUDs, or permanent methods (sterilization). Emergency contraception is available if regular contraception fails.";
    }

    if (message.contains('signs') || message.contains('symptoms')) {
      return "Early pregnancy signs include missed period, nausea, breast tenderness, fatigue, frequent urination, and mood changes. However, these symptoms can vary greatly. A pregnancy test is the most reliable way to confirm pregnancy, ideally taken after a missed period.";
    }

    return "I can help with pregnancy-related questions including planning, prevention, early signs, and prenatal care. What specific aspect of pregnancy would you like to know about?";
  }

  String _getHealthResponse(String message) {
    if (message.contains('sti') ||
        message.contains('std') ||
        message.contains('infection')) {
      return "STIs (Sexually Transmitted Infections) are infections passed through sexual contact. Common ones include chlamydia, gonorrhea, syphilis, herpes, and HIV. Many are treatable with antibiotics. Prevention includes using condoms, getting tested regularly, and limiting sexual partners. Consult a healthcare provider for testing and treatment.";
    }

    if (message.contains('menstrual') || message.contains('period')) {
      return "Menstrual cycles typically last 21-35 days. Normal periods last 3-7 days. Track your cycle to understand your fertility window. Irregular periods can indicate hormonal imbalances or other health issues. Severe pain, very heavy bleeding, or missed periods warrant medical consultation.";
    }

    if (message.contains('pain') || message.contains('symptoms')) {
      return "Reproductive health symptoms like pelvic pain, unusual discharge, irregular bleeding, or painful intercourse should be evaluated by a healthcare provider. Early detection and treatment of issues is important for reproductive health.";
    }

    return "I can provide general health information, but for specific symptoms or concerns, please consult a qualified healthcare provider. They can provide personalized advice and proper medical care. What general health topic would you like to know about?";
  }

  String _getThankYouResponse() {
    final responses = [
      "You're very welcome! I'm always here to help with your family planning and health questions. Feel free to ask anything else!",
      "Happy to help! Remember, I'm here whenever you need information about family planning or reproductive health.",
      "You're welcome! Take care of your health, and don't hesitate to ask if you have more questions.",
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getContextualResponse(String message, List<ChatMessage> chatHistory) {
    // Analyze recent conversation for context
    final recentTopics = chatHistory
        .where((msg) => msg.sender == MessageSender.user)
        .take(3)
        .map((msg) => msg.content.toLowerCase())
        .join(' ');

    if (recentTopics.contains('contraception') ||
        recentTopics.contains('birth control')) {
      return "Based on our conversation about contraception, would you like more details about any specific method, their effectiveness, or side effects?";
    }

    if (recentTopics.contains('pregnancy')) {
      return "Continuing our discussion about pregnancy - would you like information about prenatal care, nutrition during pregnancy, or pregnancy planning?";
    }

    // Default contextual response
    return "I understand you're looking for information. I specialize in family planning, contraception, pregnancy, and reproductive health. Could you please ask a more specific question so I can provide you with the most helpful information?";
  }

  /// Test connection to AI service
  Future<bool> testConnection() async {
    try {
      // Since we're using a local rule-based system, always return true
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AI Connection test failed: $e');
      }
      return false;
    }
  }
}
