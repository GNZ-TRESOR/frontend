/// Education Content model for the family planning platform
class EducationContent {
  final int? id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String type;
  final String? imageUrl;
  final String? videoUrl;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? author;
  final int? viewCount;
  final int? orderIndex;
  final List<String> tags;

  const EducationContent({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.type,
    this.imageUrl,
    this.videoUrl,
    this.isPublished = false,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.viewCount,
    this.orderIndex,
    this.tags = const [],
  });

  /// Create from JSON
  factory EducationContent.fromJson(Map<String, dynamic> json) {
    return EducationContent(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? '',
      type: json['type'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      author: json['author'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      orderIndex: json['orderIndex'] as int? ?? 0,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : const [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'type': type,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isPublished': isPublished,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'author': author,
      'viewCount': viewCount,
      'orderIndex': orderIndex,
      'tags': tags,
    };
  }

  /// Create copy with updated fields
  EducationContent copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? category,
    String? type,
    String? imageUrl,
    String? videoUrl,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? author,
    int? viewCount,
    int? orderIndex,
    List<String>? tags,
  }) {
    return EducationContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      viewCount: viewCount ?? this.viewCount,
      orderIndex: orderIndex ?? this.orderIndex,
      tags: tags ?? this.tags,
    );
  }

  /// Get content type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'article':
        return 'Article';
      case 'video':
        return 'Video';
      case 'infographic':
        return 'Infographic';
      case 'quiz':
        return 'Quiz';
      case 'interactive':
        return 'Interactive';
      default:
        return 'Content';
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'family_planning':
        return 'Family Planning';
      case 'contraception':
        return 'Contraception';
      case 'pregnancy':
        return 'Pregnancy';
      case 'menstrual_health':
        return 'Menstrual Health';
      case 'sti_prevention':
        return 'STI Prevention';
      case 'reproductive_health':
        return 'Reproductive Health';
      default:
        return category;
    }
  }

  /// Get tags as comma-separated string
  String get tagsString => tags.join(', ');

  /// Check if content has specific tag
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  /// Get estimated reading time in minutes
  int get estimatedReadingTime {
    // Average reading speed: 200 words per minute
    final wordCount = content.split(' ').length;
    return (wordCount / 200).ceil().clamp(1, 60);
  }

  /// Check if content is new (created within last 7 days)
  bool get isNew {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inDays <= 7;
  }

  /// Check if content is popular (high view count)
  bool get isPopular {
    return (viewCount ?? 0) > 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationContent &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.content == content &&
        other.category == category &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      content,
      category,
      type,
    );
  }

  @override
  String toString() {
    return 'EducationContent(id: $id, title: $title, category: $category, type: $type, isPublished: $isPublished)';
  }
}

/// Education content categories
class EducationCategory {
  static const String familyPlanning = 'family_planning';
  static const String contraception = 'contraception';
  static const String pregnancy = 'pregnancy';
  static const String menstrualHealth = 'menstrual_health';
  static const String stiPrevention = 'sti_prevention';
  static const String reproductiveHealth = 'reproductive_health';

  static const List<String> all = [
    familyPlanning,
    contraception,
    pregnancy,
    menstrualHealth,
    stiPrevention,
    reproductiveHealth,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case familyPlanning:
        return 'Family Planning';
      case contraception:
        return 'Contraception';
      case pregnancy:
        return 'Pregnancy';
      case menstrualHealth:
        return 'Menstrual Health';
      case stiPrevention:
        return 'STI Prevention';
      case reproductiveHealth:
        return 'Reproductive Health';
      default:
        return category;
    }
  }
}

/// Education content types
class EducationContentType {
  static const String article = 'article';
  static const String video = 'video';
  static const String infographic = 'infographic';
  static const String quiz = 'quiz';
  static const String interactive = 'interactive';

  static const List<String> all = [
    article,
    video,
    infographic,
    quiz,
    interactive,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case article:
        return 'Article';
      case video:
        return 'Video';
      case infographic:
        return 'Infographic';
      case quiz:
        return 'Quiz';
      case interactive:
        return 'Interactive';
      default:
        return type;
    }
  }
}
