// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioContent _$AudioContentFromJson(Map<String, dynamic> json) => AudioContent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: $enumDecode(_$ContentCategoryEnumMap, json['category']),
  language: json['language'] as String? ?? 'rw',
  filePath: json['filePath'] as String,
  fileUrl: json['fileUrl'] as String?,
  fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  status:
      $enumDecodeNullable(_$ContentStatusEnumMap, json['status']) ??
      ContentStatus.draft,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  transcript: json['transcript'] as String?,
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList(),
  targetAudience: json['targetAudience'] as String?,
  ageGroup: json['ageGroup'] as String?,
  difficultyLevel: json['difficultyLevel'] as String? ?? 'BASIC',
  playCount: (json['playCount'] as num?)?.toInt() ?? 0,
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble(),
  totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
  isFeatured: json['isFeatured'] as bool? ?? false,
  isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? true,
  publishedAt:
      json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
  expiresAt:
      json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AudioContentToJson(AudioContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': _$ContentCategoryEnumMap[instance.category]!,
      'language': instance.language,
      'filePath': instance.filePath,
      'fileUrl': instance.fileUrl,
      'fileSizeBytes': instance.fileSizeBytes,
      'durationSeconds': instance.durationSeconds,
      'mimeType': instance.mimeType,
      'status': _$ContentStatusEnumMap[instance.status]!,
      'tags': instance.tags,
      'transcript': instance.transcript,
      'keywords': instance.keywords,
      'targetAudience': instance.targetAudience,
      'ageGroup': instance.ageGroup,
      'difficultyLevel': instance.difficultyLevel,
      'playCount': instance.playCount,
      'downloadCount': instance.downloadCount,
      'rating': instance.rating,
      'totalRatings': instance.totalRatings,
      'isFeatured': instance.isFeatured,
      'isOfflineAvailable': instance.isOfflineAvailable,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ContentCategoryEnumMap = {
  ContentCategory.familyPlanning: 'FAMILY_PLANNING',
  ContentCategory.contraception: 'CONTRACEPTION',
  ContentCategory.reproductiveHealth: 'REPRODUCTIVE_HEALTH',
  ContentCategory.maternalHealth: 'MATERNAL_HEALTH',
  ContentCategory.prenatalCare: 'PRENATAL_CARE',
  ContentCategory.postnatalCare: 'POSTNATAL_CARE',
  ContentCategory.adolescentHealth: 'ADOLESCENT_HEALTH',
  ContentCategory.sexualHealth: 'SEXUAL_HEALTH',
  ContentCategory.stiPrevention: 'STI_PREVENTION',
  ContentCategory.hivAids: 'HIV_AIDS',
  ContentCategory.nutrition: 'NUTRITION',
  ContentCategory.hygiene: 'HYGIENE',
  ContentCategory.mentalHealth: 'MENTAL_HEALTH',
  ContentCategory.generalHealth: 'GENERAL_HEALTH',
  ContentCategory.emergencyCare: 'EMERGENCY_CARE',
  ContentCategory.childHealth: 'CHILD_HEALTH',
  ContentCategory.vaccination: 'VACCINATION',
  ContentCategory.breastfeeding: 'BREASTFEEDING',
  ContentCategory.healthEducation: 'HEALTH_EDUCATION',
  ContentCategory.communityHealth: 'COMMUNITY_HEALTH',
};

const _$ContentStatusEnumMap = {
  ContentStatus.draft: 'DRAFT',
  ContentStatus.underReview: 'UNDER_REVIEW',
  ContentStatus.approved: 'APPROVED',
  ContentStatus.published: 'PUBLISHED',
  ContentStatus.archived: 'ARCHIVED',
  ContentStatus.rejected: 'REJECTED',
  ContentStatus.expired: 'EXPIRED',
};

T $enumDecode<T>(Map<T, Object> enumValues, Object? source, {T? unknownValue}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries
      .singleWhere(
        (e) => e.value == source,
        orElse: () {
          if (unknownValue == null) {
            throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}',
            );
          }
          return MapEntry(unknownValue, enumValues.values.first);
        },
      )
      .key;
}

T? $enumDecodeNullable<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return $enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}
