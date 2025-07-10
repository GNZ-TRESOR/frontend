enum UserRole {
  client('client'),
  healthWorker('healthWorker'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'client':
        return UserRole.client;
      case 'healthworker':
      case 'health_worker':
        return UserRole.healthWorker;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.client;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? facilityId;
  final String? district;
  final String? sector;
  final String? cell;
  final String? village;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.facilityId,
    this.district,
    this.sector,
    this.cell,
    this.village,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.profileImageUrl,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.client:
        return 'Umunyangire';
      case UserRole.healthWorker:
        return 'Umukozi w\'ubuzima';
      case UserRole.admin:
        return 'Umuyobozi';
    }
  }

  String get fullLocation {
    final parts = [
      village,
      cell,
      sector,
      district,
    ].where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }

  bool get canManageUsers => role == UserRole.admin;
  bool get canViewReports =>
      role == UserRole.admin || role == UserRole.healthWorker;
  bool get canManageContent =>
      role == UserRole.admin || role == UserRole.healthWorker;
  bool get canProvideConsultation =>
      role == UserRole.healthWorker || role == UserRole.admin;
  bool get canAccessClientData =>
      role == UserRole.healthWorker || role == UserRole.admin;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? facilityId,
    String? district,
    String? sector,
    String? cell,
    String? village,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      facilityId: facilityId ?? this.facilityId,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      cell: cell ?? this.cell,
      village: village ?? this.village,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'facilityId': facilityId,
      'district': district,
      'sector': sector,
      'cell': cell,
      'village': village,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.fromValue(json['role'] ?? 'client'),
      facilityId: json['facilityId'],
      district: json['district'],
      sector: json['sector'],
      cell: json['cell'],
      village: json['village'],
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      lastLoginAt:
          json['lastLoginAt'] != null || json['last_login_at'] != null
              ? DateTime.parse(
                json['lastLoginAt'] ??
                    json['last_login_at'] ??
                    DateTime.now().toIso8601String(),
              )
              : null,
      isActive: json['isActive'] ?? true,
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

// Sample users for demonstration
class SampleUsers {
  static final List<User> users = [
    User(
      id: '1',
      name: 'Mukamana Marie',
      email: 'marie@example.com',
      phone: '+250788123456',
      role: UserRole.client,
      district: 'Kigali',
      sector: 'Kimisagara',
      cell: 'Nyabugogo',
      village: 'Nyabugogo I',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    User(
      id: '2',
      name: 'Dr. Uwimana Jean',
      email: 'uwimana@health.gov.rw',
      phone: '+250788234567',
      role: UserRole.healthWorker,
      facilityId: 'HC001',
      district: 'Kigali',
      sector: 'Kimisagara',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    User(
      id: '3',
      name: 'Nkurunziza Paul',
      email: 'nkurunziza@health.gov.rw',
      phone: '+250788345678',
      role: UserRole.admin,
      facilityId: 'ADMIN001',
      district: 'Kigali',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  static User getCurrentUser() {
    // In a real app, this would come from authentication service
    return users[0]; // Default to client for demo
  }

  static User? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<User> getUsersByRole(UserRole role) {
    return users.where((user) => user.role == role).toList();
  }
}
