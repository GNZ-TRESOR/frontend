import 'package:json_annotation/json_annotation.dart';

part 'audio_content_model.g.dart';

enum ContentCategory {
  @JsonValue('FAMILY_PLANNING')
  familyPlanning,
  @JsonValue('CONTRACEPTION')
  contraception,
  @JsonValue('REPRODUCTIVE_HEALTH')
  reproductiveHealth,
  @JsonValue('MATERNAL_HEALTH')
  maternalHealth,
  @JsonValue('PRENATAL_CARE')
  prenatalCare,
  @JsonValue('POSTNATAL_CARE')
  postnatalCare,
  @JsonValue('ADOLESCENT_HEALTH')
  adolescentHealth,
  @JsonValue('SEXUAL_HEALTH')
  sexualHealth,
  @JsonValue('STI_PREVENTION')
  stiPrevention,
  @JsonValue('HIV_AIDS')
  hivAids,
  @JsonValue('NUTRITION')
  nutrition,
  @JsonValue('HYGIENE')
  hygiene,
  @JsonValue('MENTAL_HEALTH')
  mentalHealth,
  @JsonValue('GENERAL_HEALTH')
  generalHealth,
  @JsonValue('EMERGENCY_CARE')
  emergencyCare,
  @JsonValue('CHILD_HEALTH')
  childHealth,
  @JsonValue('VACCINATION')
  vaccination,
  @JsonValue('BREASTFEEDING')
  breastfeeding,
  @JsonValue('HEALTH_EDUCATION')
  healthEducation,
  @JsonValue('COMMUNITY_HEALTH')
  communityHealth,
}

enum ContentStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('UNDER_REVIEW')
  underReview,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('EXPIRED')
  expired,
}

@JsonSerializable()
class AudioContent {
  final String id;
  final String title;
  final String? description;
  final ContentCategory category;
  final String language;
  final String filePath;
  final String? fileUrl;
  final int? fileSizeBytes;
  final int? durationSeconds;
  final String? mimeType;
  final ContentStatus status;
  final List<String>? tags;
  final String? transcript;
  final List<String>? keywords;
  final String? targetAudience;
  final String? ageGroup;
  final String difficultyLevel;
  final int playCount;
  final int downloadCount;
  final double? rating;
  final int totalRatings;
  final bool isFeatured;
  final bool isOfflineAvailable;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AudioContent({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.language = 'rw',
    required this.filePath,
    this.fileUrl,
    this.fileSizeBytes,
    this.durationSeconds,
    this.mimeType,
    this.status = ContentStatus.draft,
    this.tags,
    this.transcript,
    this.keywords,
    this.targetAudience,
    this.ageGroup,
    this.difficultyLevel = 'BASIC',
    this.playCount = 0,
    this.downloadCount = 0,
    this.rating,
    this.totalRatings = 0,
    this.isFeatured = false,
    this.isOfflineAvailable = true,
    this.publishedAt,
    this.expiresAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AudioContent.fromJson(Map<String, dynamic> json) => _$AudioContentFromJson(json);
  Map<String, dynamic> toJson() => _$AudioContentToJson(this);

  // Utility methods
  String get categoryDisplayName {
    switch (category) {
      case ContentCategory.familyPlanning:
        return 'Family Planning';
      case ContentCategory.contraception:
        return 'Contraception';
      case ContentCategory.reproductiveHealth:
        return 'Reproductive Health';
      case ContentCategory.maternalHealth:
        return 'Maternal Health';
      case ContentCategory.prenatalCare:
        return 'Prenatal Care';
      case ContentCategory.postnatalCare:
        return 'Postnatal Care';
      case ContentCategory.adolescentHealth:
        return 'Adolescent Health';
      case ContentCategory.sexualHealth:
        return 'Sexual Health';
      case ContentCategory.stiPrevention:
        return 'STI Prevention';
      case ContentCategory.hivAids:
        return 'HIV/AIDS';
      case ContentCategory.nutrition:
        return 'Nutrition';
      case ContentCategory.hygiene:
        return 'Hygiene';
      case ContentCategory.mentalHealth:
        return 'Mental Health';
      case ContentCategory.generalHealth:
        return 'General Health';
      case ContentCategory.emergencyCare:
        return 'Emergency Care';
      case ContentCategory.childHealth:
        return 'Child Health';
      case ContentCategory.vaccination:
        return 'Vaccination';
      case ContentCategory.breastfeeding:
        return 'Breastfeeding';
      case ContentCategory.healthEducation:
        return 'Health Education';
      case ContentCategory.communityHealth:
        return 'Community Health';
    }
  }

  String get categoryDisplayNameKinyarwanda {
    switch (category) {
      case ContentCategory.familyPlanning:
        return 'Kurinda inda';
      case ContentCategory.contraception:
        return 'Kurinda inda';
      case ContentCategory.reproductiveHealth:
        return 'Ubuzima bw\'imyororokere';
      case ContentCategory.maternalHealth:
        return 'Ubuzima bw\'ababyeyi';
      case ContentCategory.prenatalCare:
        return 'Kwita ku nda';
      case ContentCategory.postnatalCare:
        return 'Kwita nyuma yo kubyara';
      case ContentCategory.adolescentHealth:
        return 'Ubuzima bw\'ingimbi';
      case ContentCategory.sexualHealth:
        return 'Ubuzima bw\'imibonano mpuzabitsina';
      case ContentCategory.stiPrevention:
        return 'Kurinda indwara zandurira';
      case ContentCategory.hivAids:
        return 'SIDA';
      case ContentCategory.nutrition:
        return 'Imirire myiza';
      case ContentCategory.hygiene:
        return 'Isuku';
      case ContentCategory.mentalHealth:
        return 'Ubuzima bwo mu mutwe';
      case ContentCategory.generalHealth:
        return 'Ubuzima rusange';
      case ContentCategory.emergencyCare:
        return 'Ubufasha bw\'ihutirwa';
      case ContentCategory.childHealth:
        return 'Ubuzima bw\'abana';
      case ContentCategory.vaccination:
        return 'Gukingira';
      case ContentCategory.breastfeeding:
        return 'Konka';
      case ContentCategory.healthEducation:
        return 'Kwigisha ubuzima';
      case ContentCategory.communityHealth:
        return 'Ubuzima bw\'abaturage';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ContentStatus.draft:
        return 'Draft';
      case ContentStatus.underReview:
        return 'Under Review';
      case ContentStatus.approved:
        return 'Approved';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.archived:
        return 'Archived';
      case ContentStatus.rejected:
        return 'Rejected';
      case ContentStatus.expired:
        return 'Expired';
    }
  }

  String get statusDisplayNameKinyarwanda {
    switch (status) {
      case ContentStatus.draft:
        return 'Igishushanyo';
      case ContentStatus.underReview:
        return 'Gisuzumwa';
      case ContentStatus.approved:
        return 'Cyemejwe';
      case ContentStatus.published:
        return 'Cyasohowe';
      case ContentStatus.archived:
        return 'Cyashyizwe mu bubiko';
      case ContentStatus.rejected:
        return 'Cyanze';
      case ContentStatus.expired:
        return 'Cyarangiye';
    }
  }

  String get formattedDuration {
    if (durationSeconds == null) return '0:00';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    if (fileSizeBytes == null) return '0 KB';
    if (fileSizeBytes! < 1024) return '${fileSizeBytes} B';
    if (fileSizeBytes! < 1024 * 1024) return '${(fileSizeBytes! / 1024).round()} KB';
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedRating {
    if (rating == null || totalRatings == 0) return 'No rating';
    return '${rating!.toStringAsFixed(1)} (${totalRatings} ratings)';
  }

  bool get isPublished => status == ContentStatus.published && publishedAt != null;

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isAvailable => isPublished && !isExpired;

  String get categoryIcon {
    switch (category) {
      case ContentCategory.familyPlanning:
      case ContentCategory.contraception:
        return 'family_planning';
      case ContentCategory.reproductiveHealth:
      case ContentCategory.sexualHealth:
        return 'reproductive_health';
      case ContentCategory.maternalHealth:
      case ContentCategory.prenatalCare:
      case ContentCategory.postnatalCare:
        return 'maternal_health';
      case ContentCategory.adolescentHealth:
        return 'youth_health';
      case ContentCategory.stiPrevention:
      case ContentCategory.hivAids:
        return 'prevention';
      case ContentCategory.nutrition:
        return 'nutrition';
      case ContentCategory.hygiene:
        return 'hygiene';
      case ContentCategory.mentalHealth:
        return 'mental_health';
      case ContentCategory.emergencyCare:
        return 'emergency';
      case ContentCategory.childHealth:
        return 'child_health';
      case ContentCategory.vaccination:
        return 'vaccination';
      case ContentCategory.breastfeeding:
        return 'breastfeeding';
      default:
        return 'general_health';
    }
  }

  String get categoryColor {
    switch (category) {
      case ContentCategory.familyPlanning:
      case ContentCategory.contraception:
        return '#FF6B35'; // Orange
      case ContentCategory.reproductiveHealth:
      case ContentCategory.sexualHealth:
        return '#E91E63'; // Pink
      case ContentCategory.maternalHealth:
      case ContentCategory.prenatalCare:
      case ContentCategory.postnatalCare:
        return '#9C27B0'; // Purple
      case ContentCategory.adolescentHealth:
        return '#2196F3'; // Blue
      case ContentCategory.stiPrevention:
      case ContentCategory.hivAids:
        return '#F44336'; // Red
      case ContentCategory.nutrition:
        return '#4CAF50'; // Green
      case ContentCategory.hygiene:
        return '#00BCD4'; // Cyan
      case ContentCategory.mentalHealth:
        return '#673AB7'; // Deep Purple
      case ContentCategory.emergencyCare:
        return '#FF5722'; // Deep Orange
      case ContentCategory.childHealth:
        return '#FFEB3B'; // Yellow
      case ContentCategory.vaccination:
        return '#795548'; // Brown
      case ContentCategory.breastfeeding:
        return '#FFC107'; // Amber
      default:
        return '#607D8B'; // Blue Grey
    }
  }

  AudioContent copyWith({
    String? id,
    String? title,
    String? description,
    ContentCategory? category,
    String? language,
    String? filePath,
    String? fileUrl,
    int? fileSizeBytes,
    int? durationSeconds,
    String? mimeType,
    ContentStatus? status,
    List<String>? tags,
    String? transcript,
    List<String>? keywords,
    String? targetAudience,
    String? ageGroup,
    String? difficultyLevel,
    int? playCount,
    int? downloadCount,
    double? rating,
    int? totalRatings,
    bool? isFeatured,
    bool? isOfflineAvailable,
    DateTime? publishedAt,
    DateTime? expiresAt,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      language: language ?? this.language,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      transcript: transcript ?? this.transcript,
      keywords: keywords ?? this.keywords,
      targetAudience: targetAudience ?? this.targetAudience,
      ageGroup: ageGroup ?? this.ageGroup,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      playCount: playCount ?? this.playCount,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isFeatured: isFeatured ?? this.isFeatured,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioContent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AudioContent(id: $id, title: $title, category: $category)';
}
