import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/clinic.dart';
import '../services/clinic_service.dart';

part 'clinic_provider.freezed.dart';

/// Clinic state model
@freezed
class ClinicState with _$ClinicState {
  const factory ClinicState({
    @Default([]) List<Clinic> allClinics,
    @Default([]) List<ClinicWithDistance> nearbyClinics,
    @Default([]) List<Clinic> filteredClinics,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingLocation,
    String? error,
    Position? userLocation,
    @Default(10.0) double searchRadius,
    @Default('') String searchQuery,
    @Default('all') String selectedType,
    @Default('all') String selectedService,
    Clinic? selectedClinic,
  }) = _ClinicState;
}

/// Clinic provider notifier
class ClinicNotifier extends StateNotifier<ClinicState> {
  ClinicNotifier() : super(const ClinicState()) {
    _initialize();
  }

  final ClinicService _clinicService = ClinicService();

  /// Initialize clinic data
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final clinics = _clinicService.getAllClinics();
      state = state.copyWith(
        allClinics: clinics,
        filteredClinics: clinics,
        isLoading: false,
      );

      // Try to get user location
      await getCurrentLocation();
      
      if (kDebugMode) {
        print('✅ Clinic data initialized: ${clinics.length} clinics loaded');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load clinic data: $e',
        isLoading: false,
      );
      
      if (kDebugMode) {
        print('❌ Clinic initialization failed: $e');
      }
    }
  }

  /// Get user's current location
  Future<void> getCurrentLocation() async {
    try {
      state = state.copyWith(isLoadingLocation: true);
      
      final position = await _clinicService.getCurrentLocation();
      
      if (position != null) {
        state = state.copyWith(
          userLocation: position,
          isLoadingLocation: false,
        );
        
        // Automatically load nearby clinics
        await loadNearbyClinics();
        
        if (kDebugMode) {
          print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
        }
      } else {
        state = state.copyWith(
          isLoadingLocation: false,
          error: 'Unable to get location. Please enable location services.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        error: 'Location error: $e',
      );
      
      if (kDebugMode) {
        print('❌ Location error: $e');
      }
    }
  }

  /// Load nearby clinics based on user location
  Future<void> loadNearbyClinics() async {
    final userLocation = state.userLocation;
    if (userLocation == null) return;

    try {
      state = state.copyWith(isLoading: true);
      
      final nearbyClinics = await _clinicService.getNearbyClinicsSorted(
        userLocation.latitude,
        userLocation.longitude,
        radiusKm: state.searchRadius,
      );
      
      state = state.copyWith(
        nearbyClinics: nearbyClinics,
        isLoading: false,
      );
      
      if (kDebugMode) {
        print('✅ Nearby clinics loaded: ${nearbyClinics.length} clinics found');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load nearby clinics: $e',
        isLoading: false,
      );
    }
  }

  /// Search clinics
  void searchClinics(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Filter by type
  void filterByType(String type) {
    state = state.copyWith(selectedType: type);
    _applyFilters();
  }

  /// Filter by service
  void filterByService(String service) {
    state = state.copyWith(selectedService: service);
    _applyFilters();
  }

  /// Update search radius
  void updateSearchRadius(double radius) {
    state = state.copyWith(searchRadius: radius);
    loadNearbyClinics();
  }

  /// Apply all filters
  void _applyFilters() {
    List<Clinic> filtered = state.allClinics;

    // Apply search query
    if (state.searchQuery.isNotEmpty) {
      filtered = _clinicService.searchClinics(state.searchQuery);
    }

    // Apply type filter
    if (state.selectedType != 'all') {
      filtered = filtered.where((clinic) => clinic.type == state.selectedType).toList();
    }

    // Apply service filter
    if (state.selectedService != 'all') {
      filtered = filtered.where((clinic) => 
          clinic.services.any((s) => s.toLowerCase().contains(state.selectedService.toLowerCase()))
      ).toList();
    }

    state = state.copyWith(filteredClinics: filtered);
  }

  /// Select a clinic
  void selectClinic(Clinic clinic) {
    state = state.copyWith(selectedClinic: clinic);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedClinic: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh data
  Future<void> refresh() async {
    await _initialize();
  }

  /// Get available clinic types
  List<String> getClinicTypes() {
    final types = state.allClinics.map((clinic) => clinic.type).toSet().toList();
    types.sort();
    return ['all', ...types];
  }

  /// Get available services
  List<String> getAvailableServices() {
    final services = <String>{};
    for (final clinic in state.allClinics) {
      services.addAll(clinic.services);
    }
    final servicesList = services.toList();
    servicesList.sort();
    return ['all', ...servicesList];
  }
}

/// Clinic provider
final clinicProvider = StateNotifierProvider<ClinicNotifier, ClinicState>((ref) {
  return ClinicNotifier();
});

/// Convenience providers
final nearbyClinicProvider = Provider<List<ClinicWithDistance>>((ref) {
  return ref.watch(clinicProvider).nearbyClinics;
});

final filteredClinicsProvider = Provider<List<Clinic>>((ref) {
  return ref.watch(clinicProvider).filteredClinics;
});

final userLocationProvider = Provider<Position?>((ref) {
  return ref.watch(clinicProvider).userLocation;
});

final selectedClinicProvider = Provider<Clinic?>((ref) {
  return ref.watch(clinicProvider).selectedClinic;
});
