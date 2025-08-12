import 'package:flutter/foundation.dart';

/// User model for the family planning platform
class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String role;
  final String status;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? additionalInfo;

  User({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    required this.role,
    required this.status,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both 'name' and 'firstName'/'lastName' formats robustly
    String? firstName;
    String? lastName;
    if (json['name'] != null && (json['name'] as String).trim().isNotEmpty) {
      final nameParts = (json['name'] as String).trim().split(' ');
      if (nameParts.length == 1) {
        firstName = nameParts[0];
        lastName = '';
      } else {
        firstName = nameParts.first;
        lastName = nameParts.sublist(1).join(' ');
      }
    } else {
      firstName = json['firstName'] ?? '';
      lastName = json['lastName'] ?? '';
    }

    // Normalize role for frontend logic
    String rawRole = json['role'] ?? 'client';
    String normalizedRole = rawRole
        .toString()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');
    if (normalizedRole == 'healthworker' || normalizedRole == 'health_worker') {
      normalizedRole = 'healthworker';
    } else if (normalizedRole == 'admin') {
      normalizedRole = 'admin';
    } else if (normalizedRole == 'client' || normalizedRole == 'user') {
      normalizedRole = 'client';
    }

    debugPrint(
      '[User.fromJson] Parsed user: id=${json['id']}, email=${json['email']}, role=$rawRole, normalizedRole=$normalizedRole',
    );

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.tryParse(value);
      } else if (value is List && value.length >= 3) {
        // [year, month, day, ...]
        return DateTime(
          value[0] as int,
          value[1] as int,
          value[2] as int,
          value.length > 3 ? value[3] as int : 0,
          value.length > 4 ? value[4] as int : 0,
          value.length > 5 ? value[5] as int : 0,
          value.length > 6 ? value[6] as int : 0,
        );
      }
      return null;
    }

    return User(
      id: json['id'],
      firstName: firstName,
      lastName: lastName,
      email: json['email'] ?? '',
      phoneNumber:
          json['phone'] ??
          json['phoneNumber'], // Handle both 'phone' and 'phoneNumber'
      dateOfBirth: parseDate(json['dateOfBirth']),
      gender: json['gender'],
      role: normalizedRole,
      status: json['status'] ?? 'ACTIVE',
      profileImageUrl:
          json['profilePictureUrl'] ??
          json['profileImageUrl'], // Handle both formats
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'role': role,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? role,
    String? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// Get full name
  String get fullName {
    if ((firstName ?? '').isNotEmpty && (lastName ?? '').isNotEmpty) {
      return '$firstName $lastName';
    } else if ((firstName ?? '').isNotEmpty) {
      return firstName!;
    } else if ((lastName ?? '').isNotEmpty) {
      return lastName!;
    } else {
      return email;
    }
  }

  /// Get name (alias for fullName for backward compatibility)
  String get name => fullName;

  /// Get display name (first name or full name)
  String get displayName =>
      (firstName ?? '').isNotEmpty ? firstName! : fullName;

  /// Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Check if user is health worker
  bool get isHealthWorker =>
      role.toLowerCase() == 'healthworker' ||
      role.toLowerCase() == 'health_worker';

  /// Check if user is client/patient
  bool get isClient =>
      role.toLowerCase() == 'client' || role.toLowerCase() == 'user';

  /// Check if user is active
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// Get user initials for avatar
  String get initials {
    String firstInitial =
        (firstName != null && firstName!.isNotEmpty)
            ? firstName![0].toUpperCase()
            : '';
    String lastInitial =
        (lastName != null && lastName!.isNotEmpty)
            ? lastName![0].toUpperCase()
            : '';
    return '$firstInitial$lastInitial';
  }

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Get role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'healthworker':
      case 'health_worker':
        return 'Health Worker';
      case 'client':
      case 'user':
        return 'Client';
      default:
        return role;
    }
  }

  /// Get gender display name
  String get genderDisplayName {
    switch (gender?.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return (firstName ?? '').isNotEmpty &&
        email.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty &&
        dateOfBirth != null &&
        gender != null &&
        gender!.isNotEmpty;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields =
        7; // firstName, lastName, email, phone, dob, gender, profileImage

    if ((firstName ?? '').isNotEmpty) completedFields++;
    if ((lastName ?? '').isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (gender != null && gender!.isNotEmpty) completedFields++;
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      completedFields++;
    }

    return completedFields / totalFields;
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, email: $email, role: $role, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
