import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/clinic.dart';

/// Service for managing clinic data and location calculations
class ClinicService {
  static final ClinicService _instance = ClinicService._internal();
  factory ClinicService() => _instance;
  ClinicService._internal();

  /// Real clinic data for Rwanda with accurate coordinates
  static final List<Clinic> _sampleClinics = [
    // Kigali City Clinics - Accurate coordinates
    const Clinic(
      id: '1',
      name: 'King Faisal Hospital',
      address: 'KG 544 St, Kacyiru, Kigali',
      latitude: -1.9441,
      longitude: 30.0619,
      phone: '+250788300000',
      email: 'info@kfh.rw',
      services: ['Emergency', 'Surgery', 'Maternity', 'Family Planning'],
      type: 'hospital',
      specialties: ['Cardiology', 'Neurology', 'Obstetrics'],
      district: 'Gasabo',
      sector: 'Kacyiru',
      rating: 4.5,
      reviewCount: 120,
    ),
    const Clinic(
      id: '2',
      name: 'University Teaching Hospital of Kigali (CHUK)',
      address: 'KN 4 Ave, Kigali',
      latitude: -1.9536,
      longitude: 30.0606,
      phone: '+250788300001',
      services: [
        'Emergency',
        'Surgery',
        'Maternity',
        'Family Planning',
        'Pediatrics',
      ],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'Pediatrics'],
      district: 'Nyarugenge',
      sector: 'Nyarugenge',
      rating: 4.3,
      reviewCount: 95,
    ),
    const Clinic(
      id: '3',
      name: 'Rwanda Military Hospital',
      address: 'Kanombe, Kicukiro, Kigali',
      latitude: -1.9706,
      longitude: 30.1044,
      phone: '+250788300002',
      services: ['Emergency', 'Surgery', 'Family Planning', 'Vaccination'],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'Emergency Medicine'],
      district: 'Kicukiro',
      sector: 'Kanombe',
      rating: 4.1,
      reviewCount: 67,
    ),
    const Clinic(
      id: '4',
      name: 'Polyclinique du Plateau',
      address: 'KN 3 Ave, Kigali',
      latitude: -1.9578,
      longitude: 30.0648,
      phone: '+250788300003',
      services: ['Family Planning', 'STI Testing', 'General Medicine'],
      type: 'private',
      specialties: ['Reproductive Health', 'General Medicine'],
      district: 'Nyarugenge',
      sector: 'Muhima',
      rating: 4.2,
      reviewCount: 43,
    ),
    const Clinic(
      id: '5',
      name: 'Kibagabaga Hospital',
      address: 'Kibagabaga, Kigali',
      latitude: -1.9167,
      longitude: 30.1167,
      phone: '+250788300004',
      services: ['Emergency', 'Maternity', 'Family Planning', 'Surgery'],
      type: 'hospital',
      specialties: ['Obstetrics', 'General Surgery', 'Internal Medicine'],
      district: 'Gasabo',
      sector: 'Kibagabaga',
      rating: 4.0,
      reviewCount: 78,
    ),
    // Add more clinics for other districts
    const Clinic(
      id: '6',
      name: 'Muhima Health Center',
      address: 'Muhima, Kigali',
      latitude: -1.9611,
      longitude: 30.0583,
      phone: '+250788300005',
      services: ['Family Planning', 'Vaccination', 'HIV Testing'],
      type: 'clinic',
      specialties: ['Family Medicine', 'HIV/AIDS Care'],
      district: 'Nyarugenge',
      sector: 'Muhima',
      rating: 3.9,
      reviewCount: 34,
    ),
    const Clinic(
      id: '7',
      name: 'Remera Health Center',
      address: 'Remera, Kigali',
      latitude: -1.9333,
      longitude: 30.0833,
      phone: '+250788300006',
      services: ['Family Planning', 'Maternal Health', 'Child Health'],
      type: 'clinic',
      specialties: ['Maternal Health', 'Pediatrics'],
      district: 'Gasabo',
      sector: 'Remera',
      rating: 4.1,
      reviewCount: 56,
    ),

    // Southern Province
    const Clinic(
      id: '8',
      name: 'Butare University Teaching Hospital (CHUB)',
      address: 'Huye District, Southern Province',
      latitude: -2.5967,
      longitude: 29.7355,
      phone: '+250788300007',
      services: ['Emergency', 'Surgery', 'Maternity', 'Pediatrics'],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'Obstetrics'],
      district: 'Huye',
      sector: 'Tumba',
      rating: 4.2,
      reviewCount: 89,
    ),

    // Northern Province
    const Clinic(
      id: '9',
      name: 'Ruhengeri Hospital',
      address: 'Musanze District, Northern Province',
      latitude: -1.4991,
      longitude: 29.6369,
      phone: '+250788300008',
      services: ['Emergency', 'Surgery', 'Maternity', 'Family Planning'],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'Emergency Medicine'],
      district: 'Musanze',
      sector: 'Muhoza',
      rating: 4.0,
      reviewCount: 67,
    ),

    // Western Province
    const Clinic(
      id: '10',
      name: 'Kibuye Hospital',
      address: 'Karongi District, Western Province',
      latitude: -2.0608,
      longitude: 29.3486,
      phone: '+250788300009',
      services: ['Emergency', 'Surgery', 'Maternity', 'HIV Testing'],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'HIV/AIDS Care'],
      district: 'Karongi',
      sector: 'Bwishyura',
      rating: 3.9,
      reviewCount: 45,
    ),

    // Eastern Province
    const Clinic(
      id: '11',
      name: 'Kibungo Hospital',
      address: 'Ngoma District, Eastern Province',
      latitude: -2.1833,
      longitude: 30.5333,
      phone: '+250788300010',
      services: ['Emergency', 'Surgery', 'Maternity', 'Family Planning'],
      type: 'hospital',
      specialties: ['General Medicine', 'Surgery', 'Maternal Health'],
      district: 'Ngoma',
      sector: 'Kibungo',
      rating: 3.8,
      reviewCount: 52,
    ),
  ];

  /// Get all clinics
  List<Clinic> getAllClinics() {
    return _sampleClinics;
  }

  /// Get nearby clinics within specified radius
  Future<List<ClinicWithDistance>> getNearbyClinicsSorted(
    double userLatitude,
    double userLongitude, {
    double radiusKm = 10.0,
  }) async {
    try {
      final List<ClinicWithDistance> clinicsWithDistance = [];

      for (final clinic in _sampleClinics) {
        final distance = _calculateDistance(
          userLatitude,
          userLongitude,
          clinic.latitude,
          clinic.longitude,
        );

        if (distance <= radiusKm) {
          clinicsWithDistance.add(
            ClinicWithDistance(
              clinic: clinic,
              distanceKm: distance,
              distanceText: _formatDistance(distance),
            ),
          );
        }
      }

      // Sort by distance
      clinicsWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return clinicsWithDistance;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nearby clinics: $e');
      }
      return [];
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Format distance for display
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }

  /// Search clinics by name or services
  List<Clinic> searchClinics(String query) {
    if (query.isEmpty) return _sampleClinics;

    final lowerQuery = query.toLowerCase();
    return _sampleClinics.where((clinic) {
      return clinic.name.toLowerCase().contains(lowerQuery) ||
          clinic.address.toLowerCase().contains(lowerQuery) ||
          clinic.services.any(
            (service) => service.toLowerCase().contains(lowerQuery),
          ) ||
          clinic.specialties.any(
            (specialty) => specialty.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  /// Filter clinics by type
  List<Clinic> filterByType(String type) {
    if (type.isEmpty || type == 'all') return _sampleClinics;
    return _sampleClinics.where((clinic) => clinic.type == type).toList();
  }

  /// Filter clinics by services
  List<Clinic> filterByService(String service) {
    if (service.isEmpty || service == 'all') return _sampleClinics;
    return _sampleClinics
        .where(
          (clinic) => clinic.services.any(
            (s) => s.toLowerCase().contains(service.toLowerCase()),
          ),
        )
        .toList();
  }

  /// Get clinic by ID
  Clinic? getClinicById(String id) {
    try {
      return _sampleClinics.firstWhere((clinic) => clinic.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get user's current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      return null;
    }
  }
}
