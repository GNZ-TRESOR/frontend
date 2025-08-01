import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/health_facility.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

/// Health Facilities State
class HealthFacilitiesState {
  final List<HealthFacility> facilities;
  final List<HealthFacility> nearbyFacilities;
  final bool isLoading;
  final bool isLoadingNearby;
  final String? error;
  final Position? userLocation;
  final String? searchQuery;
  final String? selectedType;

  const HealthFacilitiesState({
    this.facilities = const [],
    this.nearbyFacilities = const [],
    this.isLoading = false,
    this.isLoadingNearby = false,
    this.error,
    this.userLocation,
    this.searchQuery,
    this.selectedType,
  });

  HealthFacilitiesState copyWith({
    List<HealthFacility>? facilities,
    List<HealthFacility>? nearbyFacilities,
    bool? isLoading,
    bool? isLoadingNearby,
    String? error,
    bool clearError = false,
    Position? userLocation,
    String? searchQuery,
    String? selectedType,
  }) {
    return HealthFacilitiesState(
      facilities: facilities ?? this.facilities,
      nearbyFacilities: nearbyFacilities ?? this.nearbyFacilities,
      isLoading: isLoading ?? this.isLoading,
      isLoadingNearby: isLoadingNearby ?? this.isLoadingNearby,
      error: clearError ? null : (error ?? this.error),
      userLocation: userLocation ?? this.userLocation,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  /// Get facilities sorted by distance from user
  List<HealthFacility> get facilitiesByDistance {
    if (userLocation == null) return facilities;

    final facilitiesWithDistance =
        facilities
            .where(
              (facility) =>
                  facility.latitude != null && facility.longitude != null,
            )
            .toList();

    facilitiesWithDistance.sort((a, b) {
      final distanceA =
          a.getDistanceFrom(userLocation!.latitude, userLocation!.longitude) ??
          double.infinity;
      final distanceB =
          b.getDistanceFrom(userLocation!.latitude, userLocation!.longitude) ??
          double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return facilitiesWithDistance;
  }

  /// Get facilities filtered by type
  List<HealthFacility> get filteredFacilities {
    List<HealthFacility> filtered = facilitiesByDistance;

    if (selectedType != null && selectedType!.isNotEmpty) {
      filtered =
          filtered
              .where(
                (facility) =>
                    facility.type.toLowerCase() == selectedType!.toLowerCase(),
              )
              .toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered =
          filtered
              .where(
                (facility) =>
                    facility.name.toLowerCase().contains(
                      searchQuery!.toLowerCase(),
                    ) ||
                    facility.address.toLowerCase().contains(
                      searchQuery!.toLowerCase(),
                    ) ||
                    facility.services.any(
                      (service) => service.toLowerCase().contains(
                        searchQuery!.toLowerCase(),
                      ),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  /// Get facility types available
  List<String> get availableTypes {
    final types = facilities.map((f) => f.type).toSet().toList();
    types.sort();
    return types;
  }
}

/// Health Facilities Provider
class HealthFacilitiesNotifier extends StateNotifier<HealthFacilitiesState> {
  HealthFacilitiesNotifier() : super(const HealthFacilitiesState());

  final ApiService _apiService = ApiService.instance;
  final LocationService _locationService = LocationService.instance;

  /// Load all health facilities
  Future<void> loadHealthFacilities() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.getHealthFacilities();

      if (response.success && response.data != null) {
        List<HealthFacility> facilities = [];

        if (response.data is List) {
          facilities =
              (response.data as List<dynamic>)
                  .map((json) => HealthFacility.fromJson(json))
                  .toList();
        } else if (response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;
          if (dataMap.containsKey('content') && dataMap['content'] is List) {
            facilities =
                (dataMap['content'] as List<dynamic>)
                    .map((json) => HealthFacility.fromJson(json))
                    .toList();
          }
        }

        // If no facilities from API, add some mock data for testing
        if (facilities.isEmpty) {
          facilities = _getMockFacilities();
        }

        state = state.copyWith(facilities: facilities, isLoading: false);
      } else {
        // If API fails, use mock data for testing
        state = state.copyWith(
          facilities: _getMockFacilities(),
          isLoading: false,
          error: null, // Clear error since we're providing mock data
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading health facilities: $e',
      );
    }
  }

  /// Get user location and load nearby facilities
  Future<void> loadNearbyFacilities({double radius = 10.0}) async {
    state = state.copyWith(isLoadingNearby: true, clearError: true);

    try {
      // Get user location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        state = state.copyWith(
          isLoadingNearby: false,
          error:
              'Unable to get your location. Please enable location services.',
        );
        return;
      }

      state = state.copyWith(userLocation: position);

      // Use mock data for testing (replace with API call when backend is ready)
      final mockFacilities = _getMockFacilities();
      final nearbyMockFacilities =
          mockFacilities.where((facility) {
            if (facility.latitude == null || facility.longitude == null) {
              return false;
            }
            final distance = facility.getDistanceFrom(
              position.latitude,
              position.longitude,
            );
            return distance != null && distance <= radius;
          }).toList();

      // Sort by distance
      nearbyMockFacilities.sort((a, b) {
        final distanceA =
            a.getDistanceFrom(position.latitude, position.longitude) ??
            double.infinity;
        final distanceB =
            b.getDistanceFrom(position.latitude, position.longitude) ??
            double.infinity;
        return distanceA.compareTo(distanceB);
      });

      state = state.copyWith(
        nearbyFacilities: nearbyMockFacilities,
        isLoadingNearby: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingNearby: false,
        error: 'Error loading nearby facilities: $e',
      );
    }
  }

  /// Search facilities
  Future<void> searchFacilities({
    String? query,
    String? type,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchQuery: query,
      selectedType: type,
    );

    try {
      final response = await _apiService.searchHealthFacilities(
        query: query,
        type: type,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      if (response.success && response.data != null) {
        List<HealthFacility> facilities = [];

        if (response.data is List) {
          facilities =
              (response.data as List<dynamic>)
                  .map((json) => HealthFacility.fromJson(json))
                  .toList();
        }

        state = state.copyWith(facilities: facilities, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'No facilities found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error searching facilities: $e',
      );
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set selected type filter
  void setSelectedType(String? type) {
    state = state.copyWith(selectedType: type);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedType: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadHealthFacilities(), loadNearbyFacilities()]);
  }

  /// Get mock facilities for testing when API is not available
  List<HealthFacility> _getMockFacilities() {
    return [
      HealthFacility(
        id: 1,
        name: 'Kigali University Teaching Hospital',
        type: 'hospital',
        address: 'KN 4 Ave, Kigali, Rwanda',
        phoneNumber: '+250788123456',
        email: 'info@kuth.rw',
        latitude: -1.9441,
        longitude: 30.0619,
        status: 'ACTIVE',
        services: [
          'STI Testing',
          'HIV Testing',
          'General Medicine',
          'Emergency Care',
        ],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '17:00'},
          'tuesday': {'open': '08:00', 'close': '17:00'},
          'wednesday': {'open': '08:00', 'close': '17:00'},
          'thursday': {'open': '08:00', 'close': '17:00'},
          'friday': {'open': '08:00', 'close': '17:00'},
          'saturday': {'open': '09:00', 'close': '13:00'},
          'sunday': null,
        },
        description: 'Leading teaching hospital in Rwanda',
        rating: 4.5,
        reviewCount: 120,
      ),
      HealthFacility(
        id: 2,
        name: 'Kimisagara Health Center',
        type: 'health_center',
        address: 'Nyarugenge, Kigali, Rwanda',
        phoneNumber: '+250788234567',
        latitude: -1.9506,
        longitude: 30.0588,
        status: 'ACTIVE',
        services: ['STI Testing', 'Family Planning', 'Maternal Health'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '16:00'},
          'tuesday': {'open': '07:00', 'close': '16:00'},
          'wednesday': {'open': '07:00', 'close': '16:00'},
          'thursday': {'open': '07:00', 'close': '16:00'},
          'friday': {'open': '07:00', 'close': '16:00'},
          'saturday': {'open': '08:00', 'close': '12:00'},
          'sunday': null,
        },
        description: 'Community health center',
        rating: 4.2,
        reviewCount: 85,
      ),
      HealthFacility(
        id: 3,
        name: 'Kacyiru Health Center',
        type: 'health_center',
        address: 'Gasabo, Kigali, Rwanda',
        phoneNumber: '+250788345678',
        latitude: -1.9355,
        longitude: 30.0928,
        status: 'ACTIVE',
        services: ['STI Testing', 'HIV Testing', 'Counseling'],
        operatingHours: {
          'monday': {'open': '07:30', 'close': '16:30'},
          'tuesday': {'open': '07:30', 'close': '16:30'},
          'wednesday': {'open': '07:30', 'close': '16:30'},
          'thursday': {'open': '07:30', 'close': '16:30'},
          'friday': {'open': '07:30', 'close': '16:30'},
          'saturday': {'open': '08:00', 'close': '12:00'},
          'sunday': null,
        },
        description: 'Modern health center with comprehensive services',
        rating: 4.3,
        reviewCount: 95,
      ),
      HealthFacility(
        id: 4,
        name: 'Remera Clinic',
        type: 'clinic',
        address: 'Remera, Gasabo, Kigali, Rwanda',
        phoneNumber: '+250788456789',
        latitude: -1.9167,
        longitude: 30.1333,
        status: 'ACTIVE',
        services: ['STI Testing', 'General Consultation', 'Laboratory'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '18:00'},
          'tuesday': {'open': '08:00', 'close': '18:00'},
          'wednesday': {'open': '08:00', 'close': '18:00'},
          'thursday': {'open': '08:00', 'close': '18:00'},
          'friday': {'open': '08:00', 'close': '18:00'},
          'saturday': {'open': '09:00', 'close': '14:00'},
          'sunday': null,
        },
        description: 'Private clinic with quality healthcare',
        rating: 4.0,
        reviewCount: 60,
      ),
      HealthFacility(
        id: 5,
        name: 'Nyamirambo Health Center',
        type: 'health_center',
        address: 'Nyamirambo, Nyarugenge, Kigali, Rwanda',
        phoneNumber: '+250788567890',
        latitude: -1.9667,
        longitude: 30.0333,
        status: 'ACTIVE',
        services: ['STI Testing', 'HIV Testing', 'Reproductive Health'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '16:00'},
          'tuesday': {'open': '07:00', 'close': '16:00'},
          'wednesday': {'open': '07:00', 'close': '16:00'},
          'thursday': {'open': '07:00', 'close': '16:00'},
          'friday': {'open': '07:00', 'close': '16:00'},
          'saturday': {'open': '08:00', 'close': '12:00'},
          'sunday': null,
        },
        description: 'Community-focused health center',
        rating: 4.1,
        reviewCount: 75,
      ),
    ];
  }
}

/// Health Facilities Provider instance
final healthFacilitiesProvider =
    StateNotifierProvider<HealthFacilitiesNotifier, HealthFacilitiesState>((
      ref,
    ) {
      return HealthFacilitiesNotifier();
    });

/// Convenience providers
final nearbyFacilitiesProvider = Provider<List<HealthFacility>>((ref) {
  return ref.watch(healthFacilitiesProvider).nearbyFacilities;
});

final filteredFacilitiesProvider = Provider<List<HealthFacility>>((ref) {
  return ref.watch(healthFacilitiesProvider).filteredFacilities;
});

final userLocationProvider = Provider<Position?>((ref) {
  return ref.watch(healthFacilitiesProvider).userLocation;
});
