// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthFacility _$HealthFacilityFromJson(Map<String, dynamic> json) =>
    HealthFacility(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      facilityType: $enumDecode(_$FacilityTypeEnumMap, json['facilityType']),
      licenseNumber: json['licenseNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String,
      district: json['district'] as String,
      sector: json['sector'] as String,
      cell: json['cell'] as String?,
      village: json['village'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      operatingHours: json['operatingHours'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      bedCapacity: (json['bedCapacity'] as num?)?.toInt(),
      staffCount: (json['staffCount'] as num?)?.toInt(),
      servicesOffered: (json['servicesOffered'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      equipmentAvailable: (json['equipmentAvailable'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      is24Hours: json['is24Hours'] as bool? ?? false,
      hasEmergencyServices: json['hasEmergencyServices'] as bool? ?? false,
      hasMaternityWard: json['hasMaternityWard'] as bool? ?? false,
      hasFamilyPlanning: json['hasFamilyPlanning'] as bool? ?? true,
      hasLaboratory: json['hasLaboratory'] as bool? ?? false,
      hasPharmacy: json['hasPharmacy'] as bool? ?? false,
      hasAmbulance: json['hasAmbulance'] as bool? ?? false,
      accreditationLevel: json['accreditationLevel'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$HealthFacilityToJson(HealthFacility instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'facilityType': _$FacilityTypeEnumMap[instance.facilityType]!,
      'licenseNumber': instance.licenseNumber,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'address': instance.address,
      'district': instance.district,
      'sector': instance.sector,
      'cell': instance.cell,
      'village': instance.village,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'operatingHours': instance.operatingHours,
      'emergencyContact': instance.emergencyContact,
      'bedCapacity': instance.bedCapacity,
      'staffCount': instance.staffCount,
      'servicesOffered': instance.servicesOffered,
      'equipmentAvailable': instance.equipmentAvailable,
      'is24Hours': instance.is24Hours,
      'hasEmergencyServices': instance.hasEmergencyServices,
      'hasMaternityWard': instance.hasMaternityWard,
      'hasFamilyPlanning': instance.hasFamilyPlanning,
      'hasLaboratory': instance.hasLaboratory,
      'hasPharmacy': instance.hasPharmacy,
      'hasAmbulance': instance.hasAmbulance,
      'accreditationLevel': instance.accreditationLevel,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };

const _$FacilityTypeEnumMap = {
  FacilityType.hospital: 'HOSPITAL',
  FacilityType.healthCenter: 'HEALTH_CENTER',
  FacilityType.clinic: 'CLINIC',
  FacilityType.dispensary: 'DISPENSARY',
  FacilityType.pharmacy: 'PHARMACY',
  FacilityType.laboratory: 'LABORATORY',
  FacilityType.maternityWard: 'MATERNITY_WARD',
  FacilityType.communityHealthPost: 'COMMUNITY_HEALTH_POST',
};
