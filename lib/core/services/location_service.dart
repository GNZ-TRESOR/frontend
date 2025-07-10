import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/health_facility.dart';
import 'health_facility_service.dart';

/// Location service for handling GPS, permissions, and nearby facility searches
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final HealthFacilityService _facilityService = HealthFacilityService();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Open app settings for user to manually enable location
      await openAppSettings();
    }

    return permission;
  }

  /// Get current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check and request permission
      LocationPermission permission = await requestLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return null;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }

      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Get nearby health facilities
  Future<List<HealthFacility>> getNearbyFacilities({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    FacilityType? type,
    int limit = 20,
  }) async {
    try {
      // Get facilities from backend
      List<HealthFacility> facilities = await _facilityService
          .getNearbyFacilities(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            type: type,
            limit: limit,
          );

      // Calculate distances and sort by distance
      for (var facility in facilities) {
        if (facility.latitude != null && facility.longitude != null) {
          final distance = calculateDistance(
            latitude,
            longitude,
            facility.latitude!,
            facility.longitude!,
          );
          // Store distance in metadata for sorting
          facility.copyWith(
            metadata: {...(facility.metadata ?? {}), 'distance': distance},
          );
        }
      }

      // Sort by distance
      facilities.sort((a, b) {
        final distanceA = a.metadata?['distance'] ?? double.infinity;
        final distanceB = b.metadata?['distance'] ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      return facilities;
    } catch (e) {
      debugPrint('Error getting nearby facilities: $e');
      return [];
    }
  }

  /// Search facilities by location name
  Future<List<HealthFacility>> searchFacilitiesByLocation(
    String locationName,
  ) async {
    try {
      // First get coordinates for the location
      Position? position = await getCoordinatesFromAddress(locationName);

      if (position != null) {
        return await getNearbyFacilities(
          latitude: position.latitude,
          longitude: position.longitude,
          radiusKm: 20.0, // Larger radius for search
        );
      }

      return [];
    } catch (e) {
      debugPrint('Error searching facilities by location: $e');
      return [];
    }
  }

  /// Get user's current district and sector
  Future<Map<String, String?>> getCurrentLocationDetails() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return {};

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'district': place.administrativeArea,
          'sector': place.locality,
          'address': '${place.street}, ${place.locality}',
          'country': place.country,
        };
      }

      return {};
    } catch (e) {
      debugPrint('Error getting current location details: $e');
      return {};
    }
  }

  /// Check if user is in Rwanda
  Future<bool> isUserInRwanda() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return false;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.country?.toLowerCase() == 'rwanda' ||
            place.isoCountryCode?.toLowerCase() == 'rw';
      }

      return false;
    } catch (e) {
      debugPrint('Error checking if user is in Rwanda: $e');
      return false;
    }
  }

  /// Get facilities in specific district
  Future<List<HealthFacility>> getFacilitiesInDistrict(String district) async {
    try {
      return await _facilityService.getFacilitiesByDistrict(district);
    } catch (e) {
      debugPrint('Error getting facilities in district: $e');
      return [];
    }
  }

  /// Get emergency facilities nearby (hospitals only)
  Future<List<HealthFacility>> getEmergencyFacilities({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    return await getNearbyFacilities(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      type: FacilityType.HOSPITAL,
      limit: 10,
    );
  }

  /// Get facilities with specific services
  Future<List<HealthFacility>> getFacilitiesWithService({
    required double latitude,
    required double longitude,
    required String service,
    double radiusKm = 15.0,
  }) async {
    try {
      List<HealthFacility> allFacilities = await getNearbyFacilities(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

      // Filter facilities that offer the specific service
      return allFacilities.where((facility) {
        return facility.services.any(
          (s) => s.toLowerCase().contains(service.toLowerCase()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting facilities with service: $e');
      return [];
    }
  }

  /// Start location tracking (for real-time updates)
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
