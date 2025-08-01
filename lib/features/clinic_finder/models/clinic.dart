import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';
part 'clinic.g.dart';

/// Clinic model for nearby clinic finder
@freezed
class Clinic with _$Clinic {
  const factory Clinic({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
    String? email,
    String? website,
    @Default([]) List<String> services,
    @Default('08:00-17:00') String workingHours,
    @Default(true) bool isActive,
    String? description,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    String? imageUrl,
    @Default('public') String type, // public, private, clinic, hospital
    @Default([]) List<String> specialties,
    String? district,
    String? sector,
    String? cell,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}

/// Distance calculation result
@freezed
class ClinicWithDistance with _$ClinicWithDistance {
  const factory ClinicWithDistance({
    required Clinic clinic,
    required double distanceKm,
    required String distanceText,
  }) = _ClinicWithDistance;
}
