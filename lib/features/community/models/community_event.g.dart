// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityEvent _$CommunityEventFromJson(Map<String, dynamic> json) =>
    CommunityEvent(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      eventType: json['eventType'] as String,
      category: json['category'] as String,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      organizerName: json['organizerName'] as String?,
      organizerId: (json['organizerId'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CommunityEventToJson(CommunityEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'eventDate': instance.eventDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'eventType': instance.eventType,
      'category': instance.category,
      'maxParticipants': instance.maxParticipants,
      'currentParticipants': instance.currentParticipants,
      'isPublic': instance.isPublic,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
      'organizerName': instance.organizerName,
      'organizerId': instance.organizerId,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
