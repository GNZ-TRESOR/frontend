import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Location service for handling geolocation functionality
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static LocationService get instance => _instance;

  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationEnabled = false;

  /// Get current position
  Position? get currentPosition => _currentPosition;

  /// Get current address
  String? get currentAddress => _currentAddress;

  /// Check if location is enabled
  bool get isLocationEnabled => _isLocationEnabled;

  /// Initialize location service
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return false;
      }

      _isLocationEnabled = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      if (!_isLocationEnabled && !await initialize()) {
        return null;
      }

      if (_currentPosition != null && !forceRefresh) {
        return _currentPosition;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      if (_currentPosition != null) {
        await _updateAddressFromPosition(_currentPosition!);
      }

      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Update address from position
  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = _formatAddress(placemark);
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      _currentAddress = 'Unknown location';
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }

    return addressParts.join(', ');
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
    ) / 1000; // Convert to kilometers
  }

  /// Get distance to facility
  double? getDistanceToFacility(double facilityLat, double facilityLng) {
    if (_currentPosition == null) return null;

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      facilityLat,
      facilityLng,
    );
  }

  /// Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get location stream for real-time updates
  Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update every 100 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Check if coordinates are in Rwanda (approximate bounds)
  bool isInRwanda(double latitude, double longitude) {
    // Rwanda approximate bounds
    const double minLat = -2.9;
    const double maxLat = -1.0;
    const double minLng = 28.8;
    const double maxLng = 30.9;

    return latitude >= minLat &&
           latitude <= maxLat &&
           longitude >= minLng &&
           longitude <= maxLng;
  }

  /// Get Rwanda districts based on coordinates (simplified)
  String? getRwandaDistrict(double latitude, double longitude) {
    if (!isInRwanda(latitude, longitude)) return null;

    // Simplified district mapping (in real app, use proper geocoding service)
    if (latitude > -2.0 && longitude > 30.0) return 'Kigali';
    if (latitude > -2.0 && longitude < 29.5) return 'Rubavu';
    if (latitude < -2.5 && longitude > 30.0) return 'Huye';
    if (latitude < -2.5 && longitude < 29.5) return 'Rusizi';
    
    return 'Rwanda'; // Default
  }

  /// Clear cached location data
  void clearCache() {
    _currentPosition = null;
    _currentAddress = null;
  }

  /// Dispose resources
  void dispose() {
    clearCache();
  }
}
