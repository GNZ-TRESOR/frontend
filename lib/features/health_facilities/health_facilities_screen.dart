import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/simple_translated_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/health_facility.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/location_service.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/role_access_guard.dart';

/// Professional Health Facilities Screen
class HealthFacilitiesScreen extends ConsumerStatefulWidget {
  const HealthFacilitiesScreen({super.key});

  @override
  ConsumerState<HealthFacilitiesScreen> createState() =>
      _HealthFacilitiesScreenState();
}

class _HealthFacilitiesScreenState extends ConsumerState<HealthFacilitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  String _searchQuery = '';
  String _selectedType = 'All';
  bool _isLoading = false;
  List<HealthFacility> _allFacilities = [];
  List<HealthFacility> _nearbyFacilities = [];
  Position? _currentPosition;
  String? _error;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeLocationAndLoadFacilities();
  }

  /// Initialize location services and load facilities
  Future<void> _initializeLocationAndLoadFacilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize location service
      final locationService = LocationService.instance;
      _locationPermissionGranted = await locationService.initialize();

      if (_locationPermissionGranted) {
        _currentPosition = await locationService.getCurrentLocation();
      }

      // Load all facilities
      await _loadAllFacilities();

      // Load nearby facilities if location is available
      if (_currentPosition != null) {
        await _loadNearbyFacilities();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load facilities: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load all facilities from API
  Future<void> _loadAllFacilities() async {
    try {
      final response = await ApiService.instance.getHealthFacilities();

      if (response.success && response.data != null) {
        final facilitiesData =
            response.data['facilities'] as List<dynamic>? ?? [];
        _allFacilities =
            facilitiesData
                .map(
                  (json) =>
                      HealthFacility.fromJson(json as Map<String, dynamic>),
                )
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading all facilities: $e');
    }
  }

  /// Load nearby facilities from API
  Future<void> _loadNearbyFacilities() async {
    if (_currentPosition == null) return;

    try {
      final response = await ApiService.instance.getNearbyFacilities(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: 10.0,
      );

      if (response.success && response.data != null) {
        final facilitiesData =
            response.data['facilities'] as List<dynamic>? ?? [];
        _nearbyFacilities =
            facilitiesData
                .map(
                  (json) =>
                      HealthFacility.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        // Sort by distance if location is available
        _sortFacilitiesByDistance(_nearbyFacilities);
      }
    } catch (e) {
      debugPrint('Error loading nearby facilities: $e');
    }
  }

  /// Sort facilities by distance from current location
  void _sortFacilitiesByDistance(List<HealthFacility> facilities) {
    if (_currentPosition == null) return;

    final locationService = LocationService.instance;

    facilities.sort((a, b) {
      final distanceA = locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.latitude ?? 0,
        a.longitude ?? 0,
      );

      final distanceB = locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.latitude ?? 0,
        b.longitude ?? 0,
      );

      return distanceA.compareTo(distanceB);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Role-based access control - only Client and Health Worker can access
    if (user != null && !RoleAccessGuard.canAccessHealthFacilities(user.role)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Health Facilities'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature is only available for clients and health workers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Facilities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Nearby'),
            Tab(text: 'All Facilities'),
            Tab(text: 'Map View'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNearbyTab(),
                  _buildAllFacilitiesTab(),
                  _buildMapTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search facilities, services...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'All',
                    'Hospital',
                    'Clinic',
                    'Health Center',
                    'Pharmacy',
                  ].map((type) => _buildFilterChip(type)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: type.str(),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = type;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNearbyTab() {
    // Check if location permission is granted
    if (!_locationPermissionGranted) {
      return _buildLocationPermissionRequest();
    }

    // Check if location is available
    if (_currentPosition == null) {
      return _buildLocationLoadingState();
    }

    // Show nearby facilities
    if (_nearbyFacilities.isEmpty) {
      return _buildEmptyState(
        'No nearby facilities found',
        'Try expanding your search radius or check your location',
        Icons.location_off,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNearbyFacilities,
      child: Column(
        children: [
          _buildLocationHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _nearbyFacilities.length,
              itemBuilder: (context, index) {
                final facility = _nearbyFacilities[index];
                return _buildFacilityCard(facility, showDistance: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build location permission request widget
  Widget _buildLocationPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_disabled,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To find nearby health facilities, we need access to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestLocationPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location loading state
  Widget _buildLocationLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Getting your location...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Build location header showing current location
  Widget _buildLocationHeader() {
    final locationService = LocationService.instance;
    final address = locationService.currentAddress ?? 'Unknown location';

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(Icons.my_location, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _refreshLocation,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Request location permission
  Future<void> _requestLocationPermission() async {
    final locationService = LocationService.instance;
    final granted = await locationService.requestLocationPermission();

    if (granted) {
      setState(() {
        _locationPermissionGranted = true;
      });

      // Get current location and load nearby facilities
      _currentPosition = await locationService.getCurrentLocation();
      if (_currentPosition != null) {
        await _loadNearbyFacilities();
        setState(() {});
      }
    } else {
      // Show dialog to open settings
      _showLocationSettingsDialog();
    }
  }

  /// Refresh location and nearby facilities
  Future<void> _refreshLocation() async {
    final locationService = LocationService.instance;
    _currentPosition = await locationService.getCurrentLocation(
      forceRefresh: true,
    );

    if (_currentPosition != null) {
      await _loadNearbyFacilities();
      setState(() {});
    }
  }

  /// Refresh nearby facilities
  Future<void> _refreshNearbyFacilities() async {
    await _loadNearbyFacilities();
    setState(() {});
  }

  /// Show location settings dialog
  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'To find nearby health facilities, please enable location permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  LocationService.instance.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Widget _buildAllFacilitiesTab() {
    final filteredFacilities = _filterFacilities(_allFacilities);

    if (filteredFacilities.isEmpty && !_isLoading) {
      return _buildEmptyState(
        'No facilities found',
        'Try adjusting your search or filters',
        Icons.location_off,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAllFacilities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFacilities.length,
        itemBuilder: (context, index) {
          final facility = filteredFacilities[index];
          return _buildFacilityCard(facility);
        },
      ),
    );
  }

  /// Refresh all facilities
  Future<void> _refreshAllFacilities() async {
    await _loadAllFacilities();
    setState(() {});
  }

  Widget _buildMapTab() {
    if (_currentPosition == null) {
      return _buildLocationLoadingState();
    }

    final facilitiesToShow =
        _nearbyFacilities.isNotEmpty ? _nearbyFacilities : _allFacilities;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 12.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      markers: _buildMapMarkers(facilitiesToShow),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
    );
  }

  /// Build map markers for facilities
  Set<Marker> _buildMapMarkers(List<HealthFacility> facilities) {
    final markers = <Marker>{};

    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }

    // Add facility markers
    for (final facility in facilities) {
      if (facility.latitude != null && facility.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId('facility_${facility.id}'),
            position: LatLng(facility.latitude!, facility.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(facility.type),
            ),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: '${facility.type.toUpperCase()} • ${facility.address}',
              onTap: () => _viewFacilityDetails(facility),
            ),
          ),
        );
      }
    }

    return markers;
  }

  /// Get marker color based on facility type
  double _getMarkerColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return BitmapDescriptor.hueRed;
      case 'clinic':
        return BitmapDescriptor.hueGreen;
      case 'health center':
        return BitmapDescriptor.hueOrange;
      case 'pharmacy':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  Widget _buildFacilityCard(
    HealthFacility facility, {
    bool showDistance = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewFacilityDetails(facility),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFacilityIcon(facility.type),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility.typeDisplayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showDistance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '2.5 km',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      facility.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (facility.services.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      facility.services.take(3).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (showDistance &&
                      _currentPosition != null &&
                      facility.latitude != null &&
                      facility.longitude != null) ...[
                    Icon(Icons.near_me, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _getDistanceText(facility),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (facility.rating != null) ...[
                    Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      facility.ratingDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    facility.isOpenNow
                        ? Icons.access_time
                        : Icons.access_time_filled,
                    size: 16,
                    color:
                        facility.isOpenNow
                            ? AppColors.success
                            : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    facility.isOpenNow ? 'Open now' : 'Closed',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          facility.isOpenNow
                              ? AppColors.success
                              : AppColors.error,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _bookAppointment(facility),
                    child: const Text('Book Appointment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<HealthFacility> _filterFacilities(List<HealthFacility> facilities) {
    return facilities.where((facility) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          facility.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          facility.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          facility.services.any(
            (service) =>
                service.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      final matchesType =
          _selectedType == 'All' ||
          facility.type.toLowerCase() ==
              _selectedType.toLowerCase().replaceAll(' ', '_');

      return matchesSearch && matchesType;
    }).toList();
  }

  IconData _getFacilityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'clinic':
        return Icons.medical_services;
      case 'health_center':
        return Icons.health_and_safety;
      case 'pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.location_on;
    }
  }

  /// Get distance text for facility
  String _getDistanceText(HealthFacility facility) {
    if (_currentPosition == null ||
        facility.latitude == null ||
        facility.longitude == null) {
      return '';
    }

    final locationService = LocationService.instance;
    final distance = locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      facility.latitude!,
      facility.longitude!,
    );

    return locationService.formatDistance(distance);
  }

  void _viewFacilityDetails(HealthFacility facility) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Viewing ${facility.name} details')));
  }

  void _bookAppointment(HealthFacility facility) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking appointment at ${facility.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
