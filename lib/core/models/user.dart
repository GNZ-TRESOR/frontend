/// User model for Ubuzima App
class User {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final UserRole role;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: UserRole.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (json['role'] as String? ?? 'client').toLowerCase(),
        orElse: () => UserRole.CLIENT,
      ),
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'] as String)
              : null,
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'location': location,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    DateTime? dateOfBirth,
    String? gender,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, role: $role, dateOfBirth: $dateOfBirth, gender: $gender, location: $location, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.dateOfBirth == dateOfBirth &&
        other.gender == gender &&
        other.location == location &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        role.hashCode ^
        dateOfBirth.hashCode ^
        gender.hashCode ^
        location.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// User roles in the Ubuzima app (matching backend UserRole enum)
enum UserRole { CLIENT, HEALTH_WORKER, ADMIN, ANONYMOUS }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.HEALTH_WORKER:
        return 'Health Worker';
      case UserRole.ADMIN:
        return 'Administrator';
      case UserRole.ANONYMOUS:
        return 'Anonymous';
    }
  }

  String get displayNameKinyarwanda {
    switch (this) {
      case UserRole.CLIENT:
        return 'Umukiriya';
      case UserRole.HEALTH_WORKER:
        return 'Umukozi w\'ubuzima';
      case UserRole.ADMIN:
        return 'Umuyobozi';
      case UserRole.ANONYMOUS:
        return 'Umunyangamugayo';
    }
  }

  String get displayNameFrench {
    switch (this) {
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.HEALTH_WORKER:
        return 'Agent de santé';
      case UserRole.ADMIN:
        return 'Administrateur';
      case UserRole.ANONYMOUS:
        return 'Anonyme';
    }
  }
}
