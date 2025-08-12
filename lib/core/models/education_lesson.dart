import 'package:json_annotation/json_annotation.dart';

part 'education_lesson.g.dart';

/// Education Category Enum
enum EducationCategory {
  @JsonValue('FAMILY_PLANNING')
  familyPlanning,
  @JsonValue('CONTRACEPTION')
  contraception,
  @JsonValue('MENSTRUAL_HEALTH')
  menstrualHealth,
  @JsonValue('PREGNANCY')
  pregnancy,
  @JsonValue('STI_PREVENTION')
  stiPrevention,
  @JsonValue('REPRODUCTIVE_HEALTH')
  reproductiveHealth,
  @JsonValue('MATERNAL_HEALTH')
  maternalHealth,
  @JsonValue('NUTRITION')
  nutrition,
  @JsonValue('GENERAL_HEALTH')
  generalHealth,
  @JsonValue('MENTAL_HEALTH')
  mentalHealth,
}

/// Education Level Enum
enum EducationLevel {
  @JsonValue('BEGINNER')
  beginner,
  @JsonValue('INTERMEDIATE')
  intermediate,
  @JsonValue('ADVANCED')
  advanced,
  @JsonValue('EXPERT')
  expert,
}

/// Helper functions for enum conversion
EducationCategory _educationCategoryFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'FAMILY_PLANNING':
      return EducationCategory.familyPlanning;
    case 'CONTRACEPTION':
      return EducationCategory.contraception;
    case 'MENSTRUAL_HEALTH':
      return EducationCategory.menstrualHealth;
    case 'PREGNANCY':
      return EducationCategory.pregnancy;
    case 'STI_PREVENTION':
      return EducationCategory.stiPrevention;
    case 'REPRODUCTIVE_HEALTH':
      return EducationCategory.reproductiveHealth;
    case 'MATERNAL_HEALTH':
      return EducationCategory.maternalHealth;
    case 'NUTRITION':
      return EducationCategory.nutrition;
    case 'GENERAL_HEALTH':
      return EducationCategory.generalHealth;
    case 'MENTAL_HEALTH':
      return EducationCategory.mentalHealth;
    default:
      return EducationCategory.generalHealth;
  }
}

String _educationCategoryToJson(EducationCategory category) {
  switch (category) {
    case EducationCategory.familyPlanning:
      return 'FAMILY_PLANNING';
    case EducationCategory.contraception:
      return 'CONTRACEPTION';
    case EducationCategory.menstrualHealth:
      return 'MENSTRUAL_HEALTH';
    case EducationCategory.pregnancy:
      return 'PREGNANCY';
    case EducationCategory.stiPrevention:
      return 'STI_PREVENTION';
    case EducationCategory.reproductiveHealth:
      return 'REPRODUCTIVE_HEALTH';
    case EducationCategory.maternalHealth:
      return 'MATERNAL_HEALTH';
    case EducationCategory.nutrition:
      return 'NUTRITION';
    case EducationCategory.generalHealth:
      return 'GENERAL_HEALTH';
    case EducationCategory.mentalHealth:
      return 'MENTAL_HEALTH';
  }
}

EducationLevel _educationLevelFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'BEGINNER':
      return EducationLevel.beginner;
    case 'INTERMEDIATE':
      return EducationLevel.intermediate;
    case 'ADVANCED':
      return EducationLevel.advanced;
    case 'EXPERT':
      return EducationLevel.expert;
    default:
      return EducationLevel.beginner;
  }
}

String _educationLevelToJson(EducationLevel level) {
  switch (level) {
    case EducationLevel.beginner:
      return 'BEGINNER';
    case EducationLevel.intermediate:
      return 'INTERMEDIATE';
    case EducationLevel.advanced:
      return 'ADVANCED';
    case EducationLevel.expert:
      return 'EXPERT';
  }
}

/// Education Lesson Model
@JsonSerializable()
class EducationLesson {
  final int? id;
  final String title;
  final String? description;
  final String? content;
  @JsonKey(
    fromJson: _educationCategoryFromJson,
    toJson: _educationCategoryToJson,
  )
  final EducationCategory category;
  @JsonKey(fromJson: _educationLevelFromJson, toJson: _educationLevelToJson)
  final EducationLevel level;
  final int? durationMinutes;
  final List<String> tags;
  final String? videoUrl;
  final String? audioUrl;
  final List<String> imageUrls;
  final bool isPublished;
  final int viewCount;
  final String language;
  final String? author;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EducationLesson({
    this.id,
    required this.title,
    this.description,
    this.content,
    required this.category,
    required this.level,
    this.durationMinutes,
    this.tags = const [],
    this.videoUrl,
    this.audioUrl,
    this.imageUrls = const [],
    this.isPublished = true,
    this.viewCount = 0,
    this.language = 'rw',
    this.author,
    this.orderIndex = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationLesson.fromJson(Map<String, dynamic> json) {
    // Custom date parsing function to handle both String and List formats
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.tryParse(value);
      } else if (value is List && value.length >= 3) {
        // [year, month, day, hour, minute, second, nanosecond]
        return DateTime(
          value[0] as int,
          value[1] as int,
          value[2] as int,
          value.length > 3 ? value[3] as int : 0,
          value.length > 4 ? value[4] as int : 0,
          value.length > 5 ? value[5] as int : 0,
          value.length > 6
              ? (value[6] as int) ~/ 1000000
              : 0, // Convert nanoseconds to milliseconds
        );
      }
      return null;
    }

    return EducationLesson(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      category: _educationCategoryFromJson(
        json['category'] as String? ?? 'FAMILY_PLANNING',
      ),
      level: _educationLevelFromJson(json['level'] as String? ?? 'BEGINNER'),
      durationMinutes: json['durationMinutes'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublished: json['isPublished'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      language: json['language'] as String? ?? 'en',
      author: json['author'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$EducationLessonToJson(this);

  EducationLesson copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    EducationCategory? category,
    EducationLevel? level,
    int? durationMinutes,
    List<String>? tags,
    String? videoUrl,
    String? audioUrl,
    List<String>? imageUrls,
    bool? isPublished,
    int? viewCount,
    String? language,
    String? author,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      tags: tags ?? this.tags,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      language: language ?? this.language,
      author: author ?? this.author,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (durationMinutes == null) return 'Unknown duration';
    if (durationMinutes! < 60) {
      return '${durationMinutes!} min';
    } else {
      final hours = durationMinutes! ~/ 60;
      final minutes = durationMinutes! % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case EducationCategory.familyPlanning:
        return 'Family Planning';
      case EducationCategory.contraception:
        return 'Contraception';
      case EducationCategory.menstrualHealth:
        return 'Menstrual Health';
      case EducationCategory.pregnancy:
        return 'Pregnancy';
      case EducationCategory.stiPrevention:
        return 'STI Prevention';
      case EducationCategory.reproductiveHealth:
        return 'Reproductive Health';
      case EducationCategory.maternalHealth:
        return 'Maternal Health';
      case EducationCategory.nutrition:
        return 'Nutrition';
      case EducationCategory.generalHealth:
        return 'General Health';
      case EducationCategory.mentalHealth:
        return 'Mental Health';
    }
  }

  /// Get level display name
  String get levelDisplayName {
    switch (level) {
      case EducationLevel.beginner:
        return 'Beginner';
      case EducationLevel.intermediate:
        return 'Intermediate';
      case EducationLevel.advanced:
        return 'Advanced';
      case EducationLevel.expert:
        return 'Expert';
    }
  }

  /// Check if lesson has media content
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasImages => imageUrls.isNotEmpty;
  bool get hasMediaContent => hasVideo || hasAudio || hasImages;

  /// Get primary image URL
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
}
