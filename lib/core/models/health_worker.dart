/// Enhanced Health Worker model for appointment booking
class HealthWorker {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? specialization;
  final String? qualification;
  final String? department;
  final int? healthFacilityId;
  final String? facilityName;
  final bool isAvailable;
  final String? profileImageUrl;
  final double? rating;
  final int? totalAppointments;
  final String? bio;
  final List<String>? workingDays;
  final String? workingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthWorker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.specialization,
    this.qualification,
    this.department,
    this.healthFacilityId,
    this.facilityName,
    this.isAvailable = true,
    this.profileImageUrl,
    this.rating,
    this.totalAppointments,
    this.bio,
    this.workingDays,
    this.workingHours,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthWorker.fromJson(Map<String, dynamic> json) {
    return HealthWorker(
      id: json['id'] ?? 0,
      name:
          json['name'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      specialization: json['specialization'],
      qualification: json['qualification'],
      department: json['department'],
      healthFacilityId: json['healthFacilityId'] ?? json['health_facility_id'],
      facilityName: json['facilityName'] ?? json['facility_name'],
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      rating: json['rating']?.toDouble(),
      totalAppointments:
          json['totalAppointments'] ?? json['total_appointments'],
      bio: json['bio'],
      workingDays:
          json['workingDays'] != null
              ? List<String>.from(json['workingDays'])
              : json['working_days'] != null
              ? List<String>.from(json['working_days'])
              : null,
      workingHours: json['workingHours'] ?? json['working_hours'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'qualification': qualification,
      'department': department,
      'healthFacilityId': healthFacilityId,
      'isAvailable': isAvailable,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalAppointments': totalAppointments,
      'bio': bio,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  HealthWorker copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    String? qualification,
    String? department,
    int? healthFacilityId,
    String? facilityName,
    bool? isAvailable,
    String? profileImageUrl,
    double? rating,
    int? totalAppointments,
    String? bio,
    List<String>? workingDays,
    String? workingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthWorker(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      department: department ?? this.department,
      healthFacilityId: healthFacilityId ?? this.healthFacilityId,
      facilityName: facilityName ?? this.facilityName,
      isAvailable: isAvailable ?? this.isAvailable,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      bio: bio ?? this.bio,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name with qualification
  String get displayName {
    if (qualification != null && qualification!.isNotEmpty) {
      return '$name, $qualification';
    }
    return name;
  }

  /// Get specialization display
  String get specializationDisplay {
    return specialization ?? 'General Practice';
  }

  /// Get rating display
  String get ratingDisplay {
    if (rating != null) {
      return '${rating!.toStringAsFixed(1)} ⭐';
    }
    return 'No rating';
  }

  /// Get experience display
  String get experienceDisplay {
    if (totalAppointments != null && totalAppointments! > 0) {
      return '$totalAppointments+ appointments';
    }
    return 'New practitioner';
  }

  /// Get availability status
  String get availabilityStatus {
    return isAvailable ? 'Available' : 'Unavailable';
  }

  /// Get working days display
  String get workingDaysDisplay {
    if (workingDays != null && workingDays!.isNotEmpty) {
      return workingDays!.join(', ');
    }
    return 'Schedule not specified';
  }

  /// Get working hours display
  String get workingHoursDisplay {
    return workingHours ?? 'Hours not specified';
  }

  /// Check if health worker is available today
  bool get isAvailableToday {
    if (!isAvailable) return false;

    if (workingDays != null && workingDays!.isNotEmpty) {
      final today = DateTime.now().weekday;
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final todayName = dayNames[today - 1];
      return workingDays!.any(
        (day) => day.toLowerCase().contains(todayName.toLowerCase()),
      );
    }

    return true; // Assume available if no working days specified
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'HW';
  }

  @override
  String toString() {
    return 'HealthWorker{id: $id, name: $name, specialization: $specialization}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthWorker &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
