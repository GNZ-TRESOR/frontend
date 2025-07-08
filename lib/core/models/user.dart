/// User model for Ubuzima App
class User {
  final int? id;
  final String uuid;
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
    required this.uuid,
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
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.client,
      ),
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
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
    String? uuid,
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
      uuid: uuid ?? this.uuid,
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
    return 'User(id: $id, uuid: $uuid, name: $name, email: $email, phone: $phone, role: $role, dateOfBirth: $dateOfBirth, gender: $gender, location: $location, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.uuid == uuid &&
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
      uuid.hashCode ^
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

/// User roles in the Ubuzima app
enum UserRole {
  client,
  healthWorker,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.healthWorker:
        return 'Health Worker';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get displayNameKinyarwanda {
    switch (this) {
      case UserRole.client:
        return 'Umukiriya';
      case UserRole.healthWorker:
        return 'Umukozi w\'ubuzima';
      case UserRole.admin:
        return 'Umuyobozi';
    }
  }

  String get displayNameFrench {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.healthWorker:
        return 'Agent de santé';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}
