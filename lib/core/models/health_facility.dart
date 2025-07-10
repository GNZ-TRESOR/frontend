import 'dart:math' as math;

/// Health facility type enum matching backend
enum FacilityType {
  HOSPITAL('HOSPITAL'),
  HEALTH_CENTER('HEALTH_CENTER'),
  CLINIC('CLINIC'),
  DISPENSARY('DISPENSARY'),
  PHARMACY('PHARMACY');

  const FacilityType(this.value);
  final String value;

  static FacilityType fromValue(String value) {
    return FacilityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FacilityType.CLINIC,
    );
  }

  String get displayName {
    switch (this) {
      case FacilityType.HOSPITAL:
        return 'Ibitaro';
      case FacilityType.HEALTH_CENTER:
        return 'Ikigo cy\'ubuzima';
      case FacilityType.CLINIC:
        return 'Kliniki';
      case FacilityType.DISPENSARY:
        return 'Farumasi';
      case FacilityType.PHARMACY:
        return 'Farumasi';
    }
  }
}

/// Health facility model matching backend entity
class HealthFacility {
  final String id;
  final String name;
  final FacilityType type;
  final String? description;
  final String? address;
  final String district;
  final String sector;
  final String? cell;
  final String? village;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> services;
  final Map<String, String> operatingHours;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.address,
    required this.district,
    required this.sector,
    this.cell,
    this.village,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.services = const [],
    this.operatingHours = const {},
    this.metadata,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> json) {
    return HealthFacility(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: FacilityType.fromValue(json['type'] ?? 'CLINIC'),
      description: json['description'],
      address: json['address'],
      district: json['district'] ?? '',
      sector: json['sector'] ?? '',
      cell: json['cell'],
      village: json['village'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : [],
      operatingHours:
          json['operatingHours'] != null
              ? Map<String, String>.from(json['operatingHours'])
              : {},
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] ?? json['active'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'description': description,
      'address': address,
      'district': district,
      'sector': sector,
      'cell': cell,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'services': services,
      'operatingHours': operatingHours,
      'metadata': metadata,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HealthFacility copyWith({
    String? id,
    String? name,
    FacilityType? type,
    String? description,
    String? address,
    String? district,
    String? sector,
    String? cell,
    String? village,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    List<String>? services,
    Map<String, String>? operatingHours,
    Map<String, dynamic>? metadata,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      cell: cell ?? this.cell,
      village: village ?? this.village,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      services: services ?? this.services,
      operatingHours: operatingHours ?? this.operatingHours,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full address string
  String get fullAddress {
    final parts =
        [
          address,
          cell,
          village,
          sector,
          district,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Check if facility is open now
  bool get isOpenNow {
    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final todayHours = operatingHours[dayOfWeek];
    if (todayHours == null || todayHours.isEmpty) return false;

    // Parse operating hours (format: "08:00-17:00")
    final parts = todayHours.split('-');
    if (parts.length != 2) return false;

    final openTime = parts[0].trim();
    final closeTime = parts[1].trim();

    return currentTime.compareTo(openTime) >= 0 &&
        currentTime.compareTo(closeTime) <= 0;
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  /// Calculate distance from given coordinates (in kilometers)
  double? distanceFrom(double? userLat, double? userLng) {
    if (latitude == null ||
        longitude == null ||
        userLat == null ||
        userLng == null) {
      return null;
    }

    // Haversine formula for calculating distance
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(latitude! - userLat);
    final double dLng = _toRadians(longitude! - userLng);

    final double a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(userLat)) *
            math.cos(_toRadians(latitude!)) *
            math.pow(math.sin(dLng / 2), 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  String toString() {
    return 'HealthFacility(id: $id, name: $name, type: ${type.displayName}, district: $district)';
  }
}
