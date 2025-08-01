// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportGroup _$SupportGroupFromJson(Map<String, dynamic> json) => SupportGroup(
  id: (json['id'] as num?)?.toInt(),
  category: json['category'] as String,
  contactInfo: json['contactInfo'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  isPrivate: json['isPrivate'] as bool,
  maxMembers: (json['maxMembers'] as num?)?.toInt(),
  meetingLocation: json['meetingLocation'] as String?,
  meetingSchedule: json['meetingSchedule'] as String?,
  memberCount: (json['memberCount'] as num).toInt(),
  name: json['name'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  creatorId: (json['creatorId'] as num).toInt(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$SupportGroupToJson(SupportGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'contactInfo': instance.contactInfo,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'isActive': instance.isActive,
      'isPrivate': instance.isPrivate,
      'maxMembers': instance.maxMembers,
      'meetingLocation': instance.meetingLocation,
      'meetingSchedule': instance.meetingSchedule,
      'memberCount': instance.memberCount,
      'name': instance.name,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'creatorId': instance.creatorId,
      'tags': instance.tags,
    };

SupportGroupMember _$SupportGroupMemberFromJson(Map<String, dynamic> json) =>
    SupportGroupMember(
      id: (json['id'] as num?)?.toInt(),
      isActive: json['isActive'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActivityAt:
          json['lastActivityAt'] == null
              ? null
              : DateTime.parse(json['lastActivityAt'] as String),
      role: $enumDecode(_$GroupMemberRoleEnumMap, json['role']),
      groupId: (json['groupId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$SupportGroupMemberToJson(SupportGroupMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isActive': instance.isActive,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'role': _$GroupMemberRoleEnumMap[instance.role]!,
      'groupId': instance.groupId,
      'userId': instance.userId,
    };

const _$GroupMemberRoleEnumMap = {
  GroupMemberRole.member: 'MEMBER',
  GroupMemberRole.moderator: 'MODERATOR',
  GroupMemberRole.admin: 'ADMIN',
};
