// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationLesson _$EducationLessonFromJson(Map<String, dynamic> json) =>
    EducationLesson(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      content: json['content'] as String?,
      category: _educationCategoryFromJson(json['category'] as String),
      level: _educationLevelFromJson(json['level'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPublished: json['isPublished'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      language: json['language'] as String? ?? 'rw',
      author: json['author'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EducationLessonToJson(EducationLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'category': _educationCategoryToJson(instance.category),
      'level': _educationLevelToJson(instance.level),
      'durationMinutes': instance.durationMinutes,
      'tags': instance.tags,
      'videoUrl': instance.videoUrl,
      'audioUrl': instance.audioUrl,
      'imageUrls': instance.imageUrls,
      'isPublished': instance.isPublished,
      'viewCount': instance.viewCount,
      'language': instance.language,
      'author': instance.author,
      'orderIndex': instance.orderIndex,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
