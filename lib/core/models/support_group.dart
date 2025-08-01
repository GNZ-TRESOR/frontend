import 'package:json_annotation/json_annotation.dart';

part 'support_group.g.dart';

@JsonSerializable()
class SupportGroup {
  final int? id;
  final String category;
  final String? contactInfo;
  final DateTime createdAt;
  final String? description;
  final bool isActive;
  final bool isPrivate;
  final int? maxMembers;
  final String? meetingLocation;
  final String? meetingSchedule;
  final int memberCount;
  final String name;
  final DateTime updatedAt;
  final int creatorId;
  final List<String>? tags;

  const SupportGroup({
    this.id,
    required this.category,
    this.contactInfo,
    required this.createdAt,
    this.description,
    required this.isActive,
    required this.isPrivate,
    this.maxMembers,
    this.meetingLocation,
    this.meetingSchedule,
    required this.memberCount,
    required this.name,
    required this.updatedAt,
    required this.creatorId,
    this.tags,
  });

  factory SupportGroup.fromJson(Map<String, dynamic> json) =>
      _$SupportGroupFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGroupToJson(this);

  SupportGroup copyWith({
    int? id,
    String? category,
    String? contactInfo,
    DateTime? createdAt,
    String? description,
    bool? isActive,
    bool? isPrivate,
    int? maxMembers,
    String? meetingLocation,
    String? meetingSchedule,
    int? memberCount,
    String? name,
    DateTime? updatedAt,
    int? creatorId,
    List<String>? tags,
  }) {
    return SupportGroup(
      id: id ?? this.id,
      category: category ?? this.category,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isPrivate: isPrivate ?? this.isPrivate,
      maxMembers: maxMembers ?? this.maxMembers,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      memberCount: memberCount ?? this.memberCount,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorId: creatorId ?? this.creatorId,
      tags: tags ?? this.tags,
    );
  }

  bool get isFull => maxMembers != null && memberCount >= maxMembers!;
  
  String get privacyStatus => isPrivate ? 'Private' : 'Public';
  
  String get statusText => isActive ? 'Active' : 'Inactive';
}

@JsonSerializable()
class SupportGroupMember {
  final int? id;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime? lastActivityAt;
  final GroupMemberRole role;
  final int groupId;
  final int userId;

  const SupportGroupMember({
    this.id,
    required this.isActive,
    required this.joinedAt,
    this.lastActivityAt,
    required this.role,
    required this.groupId,
    required this.userId,
  });

  factory SupportGroupMember.fromJson(Map<String, dynamic> json) =>
      _$SupportGroupMemberFromJson(json);

  Map<String, dynamic> toJson() => _$SupportGroupMemberToJson(this);

  SupportGroupMember copyWith({
    int? id,
    bool? isActive,
    DateTime? joinedAt,
    DateTime? lastActivityAt,
    GroupMemberRole? role,
    int? groupId,
    int? userId,
  }) {
    return SupportGroupMember(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case GroupMemberRole.member:
        return 'Member';
      case GroupMemberRole.moderator:
        return 'Moderator';
      case GroupMemberRole.admin:
        return 'Admin';
    }
  }
}

enum GroupMemberRole {
  @JsonValue('MEMBER')
  member,
  @JsonValue('MODERATOR')
  moderator,
  @JsonValue('ADMIN')
  admin,
}
