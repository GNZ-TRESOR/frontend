/// User model for the family planning platform
class User {
  final int? id;
  final String firstName;
  final String lastName;
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
    required this.firstName,
    required this.lastName,
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
    // Handle both 'name' and 'firstName'/'lastName' formats
    String firstName = '';
    String lastName = '';

    if (json['name'] != null) {
      final nameParts = (json['name'] as String).split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    } else {
      firstName = json['firstName'] ?? '';
      lastName = json['lastName'] ?? '';
    }

    return User(
      id: json['id'],
      firstName: firstName,
      lastName: lastName,
      email: json['email'] ?? '',
      phoneNumber:
          json['phone'] ??
          json['phoneNumber'], // Handle both 'phone' and 'phoneNumber'
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      gender: json['gender'],
      role: json['role'] ?? 'client',
      status: json['status'] ?? 'ACTIVE',
      profileImageUrl:
          json['profilePictureUrl'] ??
          json['profileImageUrl'], // Handle both formats
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
  String get fullName => '$firstName $lastName';

  /// Get name (alias for fullName for backward compatibility)
  String get name => fullName;

  /// Get display name (first name or full name)
  String get displayName => firstName.isNotEmpty ? firstName : fullName;

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
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
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
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
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

    if (firstName.isNotEmpty) completedFields++;
    if (lastName.isNotEmpty) completedFields++;
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
