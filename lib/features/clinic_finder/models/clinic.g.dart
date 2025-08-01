// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClinicImpl _$$ClinicImplFromJson(Map<String, dynamic> json) => _$ClinicImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  phone: json['phone'] as String,
  email: json['email'] as String?,
  website: json['website'] as String?,
  services:
      (json['services'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  workingHours: json['workingHours'] as String? ?? '08:00-17:00',
  isActive: json['isActive'] as bool? ?? true,
  description: json['description'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  imageUrl: json['imageUrl'] as String?,
  type: json['type'] as String? ?? 'public',
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  district: json['district'] as String?,
  sector: json['sector'] as String?,
  cell: json['cell'] as String?,
);

Map<String, dynamic> _$$ClinicImplToJson(_$ClinicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'services': instance.services,
      'workingHours': instance.workingHours,
      'isActive': instance.isActive,
      'description': instance.description,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'type': instance.type,
      'specialties': instance.specialties,
      'district': instance.district,
      'sector': instance.sector,
      'cell': instance.cell,
    };
