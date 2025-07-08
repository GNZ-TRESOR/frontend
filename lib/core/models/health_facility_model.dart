import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'health_facility_model.g.dart';

enum FacilityType {
  @JsonValue('HOSPITAL')
  hospital,
  @JsonValue('HEALTH_CENTER')
  healthCenter,
  @JsonValue('CLINIC')
  clinic,
  @JsonValue('DISPENSARY')
  dispensary,
  @JsonValue('PHARMACY')
  pharmacy,
  @JsonValue('LABORATORY')
  laboratory,
  @JsonValue('MATERNITY_WARD')
  maternityWard,
  @JsonValue('COMMUNITY_HEALTH_POST')
  communityHealthPost,
}

@JsonSerializable()
class HealthFacility {
  final String id;
  final String name;
  final String? description;
  final FacilityType facilityType;
  final String? licenseNumber;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String address;
  final String district;
  final String sector;
  final String? cell;
  final String? village;
  final double? latitude;
  final double? longitude;
  final String? operatingHours;
  final String? emergencyContact;
  final int? bedCapacity;
  final int? staffCount;
  final List<String>? servicesOffered;
  final List<String>? equipmentAvailable;
  final bool is24Hours;
  final bool hasEmergencyServices;
  final bool hasMaternityWard;
  final bool hasFamilyPlanning;
  final bool hasLaboratory;
  final bool hasPharmacy;
  final bool hasAmbulance;
  final String? accreditationLevel;
  final double? rating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const HealthFacility({
    required this.id,
    required this.name,
    this.description,
    required this.facilityType,
    this.licenseNumber,
    this.phoneNumber,
    this.email,
    this.website,
    required this.address,
    required this.district,
    required this.sector,
    this.cell,
    this.village,
    this.latitude,
    this.longitude,
    this.operatingHours,
    this.emergencyContact,
    this.bedCapacity,
    this.staffCount,
    this.servicesOffered,
    this.equipmentAvailable,
    this.is24Hours = false,
    this.hasEmergencyServices = false,
    this.hasMaternityWard = false,
    this.hasFamilyPlanning = true,
    this.hasLaboratory = false,
    this.hasPharmacy = false,
    this.hasAmbulance = false,
    this.accreditationLevel,
    this.rating,
    this.totalReviews = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> json) =>
      _$HealthFacilityFromJson(json);
  Map<String, dynamic> toJson() => _$HealthFacilityToJson(this);

  // Utility methods
  String get facilityTypeDisplayName {
    switch (facilityType) {
      case FacilityType.hospital:
        return 'Hospital';
      case FacilityType.healthCenter:
        return 'Health Center';
      case FacilityType.clinic:
        return 'Clinic';
      case FacilityType.dispensary:
        return 'Dispensary';
      case FacilityType.pharmacy:
        return 'Pharmacy';
      case FacilityType.laboratory:
        return 'Laboratory';
      case FacilityType.maternityWard:
        return 'Maternity Ward';
      case FacilityType.communityHealthPost:
        return 'Community Health Post';
    }
  }

  String get facilityTypeDisplayNameKinyarwanda {
    switch (facilityType) {
      case FacilityType.hospital:
        return 'Ibitaro';
      case FacilityType.healthCenter:
        return 'Ikigo cy\'ubuzima';
      case FacilityType.clinic:
        return 'Kliniki';
      case FacilityType.dispensary:
        return 'Dispenseri';
      case FacilityType.pharmacy:
        return 'Farumasi';
      case FacilityType.laboratory:
        return 'Laboratoire';
      case FacilityType.maternityWard:
        return 'Icyumba cy\'ababyeyi';
      case FacilityType.communityHealthPost:
        return 'Ikigo cy\'ubuzima cy\'abaturage';
    }
  }

  String get fullAddress {
    final parts = <String>[address];
    if (cell != null && cell!.isNotEmpty) parts.add(cell!);
    parts.add(sector);
    parts.add(district);
    return parts.join(', ');
  }

  String get formattedRating {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} (${totalReviews} reviews)';
  }

  List<String> get availableServices {
    final services = <String>[];
    if (hasFamilyPlanning) services.add('Family Planning');
    if (hasEmergencyServices) services.add('Emergency Services');
    if (hasMaternityWard) services.add('Maternity Ward');
    if (hasLaboratory) services.add('Laboratory');
    if (hasPharmacy) services.add('Pharmacy');
    if (hasAmbulance) services.add('Ambulance');
    if (servicesOffered != null) services.addAll(servicesOffered!);
    return services;
  }

  List<String> get availableServicesKinyarwanda {
    final services = <String>[];
    if (hasFamilyPlanning) services.add('Kurinda inda');
    if (hasEmergencyServices) services.add('Serivisi z\'ihutirwa');
    if (hasMaternityWard) services.add('Icyumba cy\'ababyeyi');
    if (hasLaboratory) services.add('Laboratoire');
    if (hasPharmacy) services.add('Farumasi');
    if (hasAmbulance) services.add('Ambulansi');
    return services;
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  double? distanceFrom(double userLatitude, double userLongitude) {
    if (!hasCoordinates) return null;

    // Haversine formula for calculating distance
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = userLatitude * (3.14159265359 / 180);
    final double lat2Rad = latitude! * (3.14159265359 / 180);
    final double deltaLatRad =
        (latitude! - userLatitude) * (3.14159265359 / 180);
    final double deltaLonRad =
        (longitude! - userLongitude) * (3.14159265359 / 180);

    final double a =
        pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLonRad / 2), 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  String? formattedDistance(double userLatitude, double userLongitude) {
    final distance = distanceFrom(userLatitude, userLongitude);
    if (distance == null) return null;

    if (distance < 1) {
      return '${(distance * 1000).round()}m away';
    } else {
      return '${distance.toStringAsFixed(1)}km away';
    }
  }

  bool get isOpen {
    if (is24Hours) return true;
    if (operatingHours == null) {
      return true; // Assume open if no hours specified
    }

    // Simple check - in a real app, you'd parse the operating hours
    final now = DateTime.now();
    final currentHour = now.hour;
    return currentHour >= 8 && currentHour < 17; // Assume 8 AM - 5 PM
  }

  String get statusText {
    if (!isActive) return 'Closed';
    if (is24Hours) return 'Open 24/7';
    if (isOpen) return 'Open';
    return 'Closed';
  }

  String get statusTextKinyarwanda {
    if (!isActive) return 'Gufunga';
    if (is24Hours) return 'Gufungura igihe cyose';
    if (isOpen) return 'Gufungura';
    return 'Gufunga';
  }

  HealthFacility copyWith({
    String? id,
    String? name,
    String? description,
    FacilityType? facilityType,
    String? licenseNumber,
    String? phoneNumber,
    String? email,
    String? website,
    String? address,
    String? district,
    String? sector,
    String? cell,
    String? village,
    double? latitude,
    double? longitude,
    String? operatingHours,
    String? emergencyContact,
    int? bedCapacity,
    int? staffCount,
    List<String>? servicesOffered,
    List<String>? equipmentAvailable,
    bool? is24Hours,
    bool? hasEmergencyServices,
    bool? hasMaternityWard,
    bool? hasFamilyPlanning,
    bool? hasLaboratory,
    bool? hasPharmacy,
    bool? hasAmbulance,
    String? accreditationLevel,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return HealthFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      facilityType: facilityType ?? this.facilityType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      cell: cell ?? this.cell,
      village: village ?? this.village,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      operatingHours: operatingHours ?? this.operatingHours,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bedCapacity: bedCapacity ?? this.bedCapacity,
      staffCount: staffCount ?? this.staffCount,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      equipmentAvailable: equipmentAvailable ?? this.equipmentAvailable,
      is24Hours: is24Hours ?? this.is24Hours,
      hasEmergencyServices: hasEmergencyServices ?? this.hasEmergencyServices,
      hasMaternityWard: hasMaternityWard ?? this.hasMaternityWard,
      hasFamilyPlanning: hasFamilyPlanning ?? this.hasFamilyPlanning,
      hasLaboratory: hasLaboratory ?? this.hasLaboratory,
      hasPharmacy: hasPharmacy ?? this.hasPharmacy,
      hasAmbulance: hasAmbulance ?? this.hasAmbulance,
      accreditationLevel: accreditationLevel ?? this.accreditationLevel,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthFacility &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HealthFacility(id: $id, name: $name, type: $facilityType)';
}
