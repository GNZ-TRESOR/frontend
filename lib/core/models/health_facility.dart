import 'dart:math';

/// Health Facility model for the family planning platform
class HealthFacility {
  final int? id;
  final String name;
  final String type;
  final String address;
  final String? phoneNumber;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String status;
  final List<String> services;
  final Map<String, dynamic>? operatingHours;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional properties for admin management
  String get location => address;
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  HealthFacility({
    this.id,
    required this.name,
    required this.type,
    required this.address,
    this.phoneNumber,
    this.email,
    this.latitude,
    this.longitude,
    required this.status,
    required this.services,
    this.operatingHours,
    this.description,
    this.rating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> json) {
    try {
      return HealthFacility(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        type:
            json['facilityType'] ??
            json['type'] ??
            '', // Handle both field names
        address: json['address'] ?? '',
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        status:
            json['isActive'] == true
                ? 'ACTIVE'
                : json['status'] ?? 'ACTIVE', // Handle isActive field
        services: _parseServices(
          json['servicesOffered'] ?? json['services'],
        ), // Handle both field names
        operatingHours: _parseOperatingHours(json['operatingHours']),
        description: json['description'],
        rating: json['rating']?.toDouble(),
        reviewCount: json['reviewCount'],
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to parse ID with error handling
  static int? _parseId(dynamic idData) {
    if (idData == null) return null;

    try {
      if (idData is int) {
        return idData;
      } else if (idData is String) {
        return int.parse(idData);
      } else if (idData is double) {
        return idData.toInt();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper method to parse DateTime with error handling
  static DateTime? _parseDateTime(dynamic dateData) {
    if (dateData == null) return null;

    try {
      if (dateData is String) {
        return DateTime.parse(dateData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper method to parse operating hours
  static Map<String, dynamic>? _parseOperatingHours(dynamic hoursData) {
    if (hoursData == null) return null;

    if (hoursData is Map<String, dynamic>) {
      return hoursData;
    } else if (hoursData is String) {
      // Convert string to a simple map format
      return {'hours': hoursData};
    }

    return null;
  }

  // Helper method to parse services from string or list
  static List<String> _parseServices(dynamic servicesData) {
    if (servicesData == null) return [];
    if (servicesData is List) {
      return List<String>.from(servicesData);
    }
    if (servicesData is String) {
      // Split comma-separated services
      return servicesData
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'services': services,
      'operatingHours': operatingHours,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get facility type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'hospital':
        return 'Hospital';
      case 'clinic':
        return 'Clinic';
      case 'health_center':
        return 'Health Center';
      case 'pharmacy':
        return 'Pharmacy';
      default:
        return type;
    }
  }

  /// Check if facility is open now
  bool get isOpenNow {
    if (operatingHours == null) return false;

    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final todayHours = operatingHours![dayOfWeek];
    if (todayHours == null) return false;

    final openTime = todayHours['open'];
    final closeTime = todayHours['close'];

    if (openTime == null || closeTime == null) return false;

    return currentTime.compareTo(openTime) >= 0 &&
        currentTime.compareTo(closeTime) <= 0;
  }

  /// Get distance from user location (requires user coordinates)
  double? getDistanceFrom(double userLat, double userLng) {
    if (latitude == null || longitude == null) return null;

    // Haversine formula for calculating distance
    const double earthRadius = 6371; // km

    double dLat = _toRadians(latitude! - userLat);
    double dLng = _toRadians(longitude! - userLng);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(userLat) * cos(latitude!) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Get services display string
  String get servicesString => services.join(', ');

  /// Check if facility offers specific service
  bool hasService(String service) {
    return services.any((s) => s.toLowerCase().contains(service.toLowerCase()));
  }

  /// Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
  }

  /// Get today's operating hours
  String get todayHours {
    if (operatingHours == null) return 'Hours not available';

    final today = _getDayOfWeek(DateTime.now().weekday);
    final todayHours = operatingHours![today];

    if (todayHours == null) return 'Closed today';

    final openTime = todayHours['open'];
    final closeTime = todayHours['close'];

    if (openTime == null || closeTime == null) return 'Hours not available';

    return '$openTime - $closeTime';
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Get display name for facility type
  String get facilityTypeDisplay {
    switch (type.toUpperCase()) {
      case 'HOSPITAL':
        return 'Hospital';
      case 'HEALTH_CENTER':
        return 'Health Center';
      case 'CLINIC':
        return 'Clinic';
      case 'DISPENSARY':
        return 'Dispensary';
      case 'PHARMACY':
        return 'Pharmacy';
      case 'LABORATORY':
        return 'Laboratory';
      case 'MATERNITY_CENTER':
        return 'Maternity Center';
      case 'COMMUNITY_HEALTH_POST':
        return 'Community Health Post';
      case 'PRIVATE_PRACTICE':
        return 'Private Practice';
      default:
        return type;
    }
  }

  @override
  String toString() {
    return 'HealthFacility{id: $id, name: $name, type: $type, address: $address}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthFacility && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
