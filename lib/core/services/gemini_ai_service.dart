import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/ai_config.dart';
import 'rural_optimization_service.dart';

class GeminiAIService {
  final Dio _dio = Dio();
  final RuralOptimizationService _ruralService = RuralOptimizationService();

  GeminiAIService() {
    _dio.options.connectTimeout = AIConfig.connectTimeout;
    _dio.options.receiveTimeout = AIConfig.receiveTimeout;
  }

  /// Offline fallback responses for common health questions
  static const Map<String, Map<String, String>> _offlineResponses = {
    'family_planning': {
      'rw':
          '''Kubana n'ubwiyunge ni ukwihitamo igihe n'umubare w'abana ushaka kubana.

Uburyo bwo kurinda inda:
• Imiti yo kurinda inda (pilule)
• Urushinge (condom)
• Inkingo zo kurinda inda
• Uburyo bw'ibanze (gukurikirana imihango)

Saba inama ku muganga cyangwa umukozi w'ubuzima hafi yawe.''',
      'en': '''Family planning is choosing when and how many children to have.

Contraceptive methods:
• Birth control pills
• Condoms
• Contraceptive injections
• Natural methods (cycle tracking)

Consult a doctor or health worker near you for advice.''',
      'fr':
          '''La planification familiale consiste à choisir quand et combien d'enfants avoir.

Méthodes contraceptives:
• Pilules contraceptives
• Préservatifs
• Injections contraceptives
• Méthodes naturelles (suivi du cycle)

Consultez un médecin ou un agent de santé près de chez vous.''',
    },
    'menstrual_health': {
      'rw':
          '''Imihango ni ibintu bisanzwe ku bagore. Imihango isanzwe igenda iminsi 3-7 buri kwezi.

Ibikenewe:
• Gukoresha ibikoresho byiza (pads)
• Kwiyuhagira neza
• Kurya neza
• Gukoresha imiti y'ububabare niba bikenewe

Saba ubufasha niba imihango yawe idahwitse cyangwa ifite ibibazo.''',
      'en':
          '''Menstruation is normal for women. A normal period lasts 3-7 days each month.

What you need:
• Use proper hygiene products (pads)
• Maintain good hygiene
• Eat well
• Use pain medication if needed

Seek help if your periods are irregular or problematic.''',
      'fr':
          '''Les menstruations sont normales chez les femmes. Des règles normales durent 3-7 jours chaque mois.

Ce dont vous avez besoin:
• Utilisez des produits d'hygiène appropriés (serviettes)
• Maintenez une bonne hygiène
• Mangez bien
• Utilisez des analgésiques si nécessaire

Demandez de l'aide si vos règles sont irrégulières ou problématiques.''',
    },
    'pregnancy_planning': {
      'rw': '''Gutegura inda ni ukwihitamo igihe cyo gusama.

Ibikenewe mbere yo gusama:
• Kuraguza muganga
• Gufata vitamine (acide folique)
• Kureka kunywa inzoga n'itabi
• Kurya neza
• Gukora siporo

Kugira ubuzima bwiza ni ngombwa mbere yo gusama.''',
      'en': '''Pregnancy planning is choosing when to get pregnant.

What you need before pregnancy:
• Visit a doctor
• Take vitamins (folic acid)
• Stop drinking alcohol and smoking
• Eat well
• Exercise

Being healthy is important before getting pregnant.''',
      'fr':
          '''La planification de grossesse consiste à choisir quand tomber enceinte.

Ce dont vous avez besoin avant la grossesse:
• Consultez un médecin
• Prenez des vitamines (acide folique)
• Arrêtez de boire de l'alcool et de fumer
• Mangez bien
• Faites de l'exercice

Être en bonne santé est important avant de tomber enceinte.''',
    },
    'emergency': {
      'rw': '''IHUTIRWA:

Hamagara vuba:
• 912 - Ubufasha bw'ihutirwa
• Jya ku bitaro hafi yawe
• Hamagara umukozi w'ubuzima

Ibimenyetso by'ihutirwa:
• Amaraso menshi
• Ububabare bukabije
• Kunanirwa
• Guhinduka ubwoba

Ntutegereze - saba ubufasha vuba!''',
      'en': '''EMERGENCY:

Call immediately:
• 912 - Emergency services
• Go to nearest hospital
• Call a health worker

Emergency signs:
• Heavy bleeding
• Severe pain
• Difficulty breathing
• Loss of consciousness

Don't wait - get help immediately!''',
      'fr': '''URGENCE:

Appelez immédiatement:
• 912 - Services d'urgence
• Allez à l'hôpital le plus proche
• Appelez un agent de santé

Signes d'urgence:
• Saignements abondants
• Douleur sévère
• Difficulté à respirer
• Perte de conscience

N'attendez pas - obtenez de l'aide immédiatement!''',
    },
    'reproductive_health': {
      'rw': '''Ubuzima bw'imyororokere ni ngombwa cyane ku bagore n'abagabo.

Ibikenewe:
• Gusuzuma ubuzima buri kwezi
• Gukoresha uburyo bwo kurinda inda
• Kwita ku buzima bw'imihango
• Gukurikirana inda neza

Saba inama ku muganga buri gihe.''',
      'en': '''Reproductive health is very important for women and men.

What you need:
• Regular health checkups
• Use contraceptive methods
• Take care of menstrual health
• Monitor pregnancy properly

Always consult a doctor for advice.''',
      'fr':
          '''La santé reproductive est très importante pour les femmes et les hommes.

Ce dont vous avez besoin:
• Examens de santé réguliers
• Utilisez des méthodes contraceptives
• Prenez soin de la santé menstruelle
• Surveillez bien la grossesse

Consultez toujours un médecin pour des conseils.''',
    },
    'youth_education': {
      'rw': '''Urubyiruko rukeneye amahugurwa ku buzima bw'imyororokere.

Ibikenewe:
• Kwiga ku buzima bw'imyororokere
• Gukoresha uburyo bwo kurinda inda
• Kwirinda indwara zandurira mu mibonano
• Gufata ibyemezo byiza

Ntugire ubwoba kubaza ibibazo.''',
      'en': '''Youth need education about reproductive health.

What you need:
• Learn about reproductive health
• Use contraceptive methods
• Prevent sexually transmitted infections
• Make good decisions

Don't be afraid to ask questions.''',
      'fr': '''Les jeunes ont besoin d'éducation sur la santé reproductive.

Ce dont vous avez besoin:
• Apprenez sur la santé reproductive
• Utilisez des méthodes contraceptives
• Prévenez les infections sexuellement transmissibles
• Prenez de bonnes décisions

N'ayez pas peur de poser des questions.''',
    },
    'sti_prevention': {
      'rw': '''Kurinda indwara zandurira mu mibonano ni ngombwa.

Uburyo bwo kurinda:
• Gukoresha urushinge (condom)
• Kugira umukunzi umwe gusa
• Gusuzuma ubuzima buri gihe
• Kwirinda gukoresha ibikoresho byatandukanye

Niba ufite ibibazo, jya ku muganga vuba.''',
      'en': '''Preventing sexually transmitted infections is important.

Ways to prevent:
• Use condoms
• Have only one partner
• Get regular health checkups
• Avoid sharing personal items

If you have problems, see a doctor immediately.''',
      'fr':
          '''Prévenir les infections sexuellement transmissibles est important.

Moyens de prévention:
• Utilisez des préservatifs
• N'ayez qu'un seul partenaire
• Faites des examens de santé réguliers
• Évitez de partager des objets personnels

Si vous avez des problèmes, consultez un médecin immédiatement.''',
    },
  };

  /// Get health advice from Gemini AI with offline fallback
  Future<String> getHealthAdvice(
    String question, {
    String language = 'kinyarwanda',
  }) async {
    // Check if we're offline or have limited connectivity
    if (_ruralService.isOfflineMode || _ruralService.hasLimitedConnectivity) {
      final offlineResponse = _getOfflineResponse(question, language);
      if (offlineResponse != null) {
        return offlineResponse;
      }
    }

    try {
      final prompt = _buildHealthPrompt(question, language);
      final response = await _makeRequest(prompt);
      return _extractResponse(response);
    } catch (e) {
      debugPrint('Gemini AI Error: $e');

      // Try offline response as fallback
      final offlineResponse = _getOfflineResponse(question, language);
      if (offlineResponse != null) {
        return offlineResponse;
      }

      return _getErrorMessage(language);
    }
  }

  /// Get offline response for common questions
  String? _getOfflineResponse(String question, String language) {
    final lowerQuestion = question.toLowerCase();
    final langCode = _getLanguageCode(language);

    // Check for family planning questions
    if (lowerQuestion.contains('family planning') ||
        lowerQuestion.contains('kubana') ||
        lowerQuestion.contains('ubwiyunge') ||
        lowerQuestion.contains('contraception') ||
        lowerQuestion.contains('kurinda inda')) {
      return _offlineResponses['family_planning']?[langCode];
    }

    // Check for menstrual health questions
    if (lowerQuestion.contains('menstruation') ||
        lowerQuestion.contains('imihango') ||
        lowerQuestion.contains('period') ||
        lowerQuestion.contains('règles')) {
      return _offlineResponses['menstrual_health']?[langCode];
    }

    // Check for pregnancy planning questions
    if (lowerQuestion.contains('pregnancy') ||
        lowerQuestion.contains('inda') ||
        lowerQuestion.contains('gusama') ||
        lowerQuestion.contains('grossesse')) {
      return _offlineResponses['pregnancy_planning']?[langCode];
    }

    // Check for emergency questions
    if (lowerQuestion.contains('emergency') ||
        lowerQuestion.contains('ihutirwa') ||
        lowerQuestion.contains('urgence') ||
        lowerQuestion.contains('help') ||
        lowerQuestion.contains('ubufasha')) {
      return _offlineResponses['emergency']?[langCode];
    }

    // Check for reproductive health questions
    if (lowerQuestion.contains('reproductive') ||
        lowerQuestion.contains('imyororokere') ||
        lowerQuestion.contains('reproductif') ||
        lowerQuestion.contains('sexual health')) {
      return _offlineResponses['reproductive_health']?[langCode];
    }

    // Check for youth education questions
    if (lowerQuestion.contains('youth') ||
        lowerQuestion.contains('urubyiruko') ||
        lowerQuestion.contains('jeunes') ||
        lowerQuestion.contains('teenager') ||
        lowerQuestion.contains('adolescent')) {
      return _offlineResponses['youth_education']?[langCode];
    }

    // Check for STI prevention questions
    if (lowerQuestion.contains('sti') ||
        lowerQuestion.contains('std') ||
        lowerQuestion.contains('infection') ||
        lowerQuestion.contains('indwara') ||
        lowerQuestion.contains('condom') ||
        lowerQuestion.contains('urushinge')) {
      return _offlineResponses['sti_prevention']?[langCode];
    }

    return null;
  }

  /// Convert language parameter to language code
  String _getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'kinyarwanda':
        return 'rw';
      case 'french':
        return 'fr';
      case 'english':
      default:
        return 'en';
    }
  }

  /// Analyze symptoms and provide recommendations
  Future<Map<String, dynamic>> analyzeSymptoms(
    List<String> symptoms, {
    String language = 'kinyarwanda',
  }) async {
    try {
      final prompt = _buildSymptomsPrompt(symptoms, language);
      final response = await _makeRequest(prompt);
      final aiResponse = _extractResponse(response);

      return {
        'analysis': aiResponse,
        'recommendations': _parseRecommendations(aiResponse),
        'urgency': _assessUrgency(symptoms),
      };
    } catch (e) {
      debugPrint('Symptoms Analysis Error: $e');
      return {
        'analysis': _getErrorMessage(language),
        'recommendations': <String>[],
        'urgency': 'low',
      };
    }
  }

  /// Get contraceptive advice based on user profile
  Future<String> getContraceptiveAdvice(
    String method,
    Map<String, dynamic> userProfile, {
    String language = 'kinyarwanda',
  }) async {
    try {
      final prompt = _buildContraceptivePrompt(method, userProfile, language);
      final response = await _makeRequest(prompt);
      return _extractResponse(response);
    } catch (e) {
      debugPrint('Contraceptive Advice Error: $e');
      return _getErrorMessage(language);
    }
  }

  /// Get family planning guidance
  Future<String> getFamilyPlanningGuidance(
    Map<String, dynamic> context, {
    String language = 'kinyarwanda',
  }) async {
    try {
      final prompt = _buildFamilyPlanningPrompt(context, language);
      final response = await _makeRequest(prompt);
      return _extractResponse(response);
    } catch (e) {
      debugPrint('Family Planning Guidance Error: $e');
      return _getErrorMessage(language);
    }
  }

  /// Get pregnancy planning advice
  Future<String> getPregnancyPlanningAdvice(
    Map<String, dynamic> planningData, {
    String language = 'kinyarwanda',
  }) async {
    try {
      final prompt = _buildPregnancyPlanningPrompt(planningData, language);
      final response = await _makeRequest(prompt);
      return _extractResponse(response);
    } catch (e) {
      debugPrint('Pregnancy Planning Error: $e');
      return _getErrorMessage(language);
    }
  }

  /// Make HTTP request to Gemini API
  Future<Response> _makeRequest(String prompt) async {
    final response = await _dio.post(
      '${AIConfig.geminiBaseUrl}?key=${AIConfig.apiKey}',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': AIConfig.temperature,
          'topK': AIConfig.topK,
          'topP': AIConfig.topP,
          'maxOutputTokens': AIConfig.maxTokens,
        },
        'safetySettings': AIConfig.safetySettings,
      },
    );
    return response;
  }

  /// Extract response text from Gemini API response
  String _extractResponse(Response response) {
    try {
      final data = response.data;
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null) {
          final parts = candidate['content']['parts'];
          if (parts.isNotEmpty && parts[0]['text'] != null) {
            return parts[0]['text'].toString().trim();
          }
        }
      }
      return 'Ntabwo nashoboye gusubiza. Ongera ugerageze.';
    } catch (e) {
      debugPrint('Response extraction error: $e');
      return 'Ikosa ryabaye mu gusoma igisubizo.';
    }
  }

  /// Build health advice prompt
  String _buildHealthPrompt(String question, String language) {
    final languageInstruction =
        language == 'kinyarwanda'
            ? 'Subiza mu Kinyarwanda cyangwa mu Cyongereza bitewe n\'ikibazo.'
            : language == 'french'
            ? 'Répondez en français ou en anglais selon la question.'
            : 'Respond in English or the appropriate language.';

    return '''
Wowe uri umujyanama w'ubuzima bw'ababyeyi mu cyaro cya Rwanda. Ufite ubumenyi bw'ibanze ku buzima bw'abagore n'abagabo, gukingira inda, no kubana neza mu muryango.

$languageInstruction

Ikibazo: $question

Tanga inama:
1. Z'ukuri kandi z'ubwoba
2. Z'ubushobozi bw'abantu bo mu cyaro
3. Z'ubwubahane bw'umuco w'u Rwanda
4. Z'ingenzi ku buzima

Ntukavuge ko uri muganga. Saba abantu bajye ku bitaro iyo bikenewe.
''';
  }

  /// Build symptoms analysis prompt
  String _buildSymptomsPrompt(List<String> symptoms, String language) {
    final symptomsText = symptoms.join(', ');
    final languageInstruction =
        language == 'kinyarwanda'
            ? 'Subiza mu Kinyarwanda.'
            : language == 'french'
            ? 'Répondez en français.'
            : 'Respond in English.';

    return '''
Nk'umujyanama w'ubuzima mu cyaro cya Rwanda, suzuma ibi bimenyetso:

Ibimenyetso: $symptomsText

$languageInstruction

Tanga:
1. Icyo bishobora kuba (ntukavuge ko ari indwara runaka)
2. Inama z'ubwoba zo kwikingira
3. Igihe cyo kujya ku bitaro
4. Ibintu by'ingenzi byo kwirinda

Wibuke ko utari muganga. Saba umuntu ajye ku bitaro iyo bibaye ngombwa.
''';
  }

  /// Build contraceptive advice prompt
  String _buildContraceptivePrompt(
    String method,
    Map<String, dynamic> userProfile,
    String language,
  ) {
    final age = userProfile['age'] ?? 'unknown';
    final languageInstruction =
        language == 'kinyarwanda'
            ? 'Subiza mu Kinyarwanda.'
            : language == 'french'
            ? 'Répondez en français.'
            : 'Respond in English.';

    return '''
Umukobwa cyangwa umugabo w'imyaka $age abaza ku buryo bwo kurinda inda: $method

$languageInstruction

Mumuhe amakuru:
1. Uburyo bukora bute
2. Ingaruka nziza
3. Ingaruka zishobora kubaho
4. Inama z'ingenzi zo gukoresha
5. Aho bashobora kubona ubufasha

Ntukavuge ko uri muganga. Saba ajye ku bitaro kugira ngo abone inama z'umuganga.
''';
  }

  /// Build family planning prompt
  String _buildFamilyPlanningPrompt(
    Map<String, dynamic> context,
    String language,
  ) {
    final languageInstruction =
        language == 'kinyarwanda'
            ? 'Subiza mu Kinyarwanda.'
            : language == 'french'
            ? 'Répondez en français.'
            : 'Respond in English.';

    return '''
Nk'umujyanama w'ababyeyi mu cyaro cya Rwanda, fasha aba bantu mu gutegura umuryango wabo.

Amakuru: ${context.toString()}

$languageInstruction

Tanga inama ku:
1. Gutegura umuryango
2. Igihe cyo kubyara
3. Ubuzima bw'umubyeyi
4. Gufasha abana
5. Ubushobozi bw'umuryango

Wibuke umuco w'u Rwanda n'agaciro k'umuryango.
''';
  }

  /// Build pregnancy planning prompt
  String _buildPregnancyPlanningPrompt(
    Map<String, dynamic> planningData,
    String language,
  ) {
    final languageInstruction =
        language == 'kinyarwanda'
            ? 'Subiza mu Kinyarwanda.'
            : language == 'french'
            ? 'Répondez en français.'
            : 'Respond in English.';

    return '''
Umugore arimo gutegura inda. Amakuru ye: ${planningData.toString()}

$languageInstruction

Mumuhe inama ku:
1. Gutegura umubiri
2. Kurya neza
3. Gufata vitamini
4. Kwirinda ibintu bibi
5. Gusura muganga

Mwirinde kutanga inama z'ubuvuzi. Musabe ajye ku bitaro.
''';
  }

  /// Parse recommendations from AI response
  List<String> _parseRecommendations(String response) {
    final lines = response.split('\n');
    final recommendations = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('•') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('*') ||
          RegExp(r'^\d+\.').hasMatch(trimmed)) {
        recommendations.add(trimmed);
      }
    }

    return recommendations.isNotEmpty ? recommendations : [response];
  }

  /// Assess urgency based on symptoms
  String _assessUrgency(List<String> symptoms) {
    final urgentSymptoms = [
      'kubabara cyane',
      'amaraso',
      'umuriro',
      'guhema bigoye',
      'severe pain',
      'bleeding',
      'fever',
      'difficulty breathing',
    ];

    for (final symptom in symptoms) {
      for (final urgent in urgentSymptoms) {
        if (symptom.toLowerCase().contains(urgent.toLowerCase())) {
          return 'high';
        }
      }
    }

    return 'low';
  }

  /// Get error message in appropriate language
  String _getErrorMessage(String language) {
    switch (language) {
      case 'kinyarwanda':
        return 'Ntabwo nashoboye gusubiza. Reba ko ufite internet hanyuma ongera ugerageze.';
      case 'french':
        return 'Je n\'ai pas pu répondre. Vérifiez votre connexion internet et réessayez.';
      default:
        return 'I couldn\'t respond. Please check your internet connection and try again.';
    }
  }
}
