import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import 'models/clinic.dart';
import 'providers/clinic_provider.dart';

/// Modern Clinic Finder Screen with OpenStreetMap Integration
class ClinicFinderScreen extends ConsumerStatefulWidget {
  const ClinicFinderScreen({super.key});

  @override
  ConsumerState<ClinicFinderScreen> createState() => _ClinicFinderScreenState();
}

class _ClinicFinderScreenState extends ConsumerState<ClinicFinderScreen>
    with TickerProviderStateMixin {
  late MapController _mapController;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Default location (Kigali center, Rwanda) if user location is not available
  static const LatLng _defaultLocation = LatLng(-1.9441, 30.0619);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicProvider);
    final userLocation = clinicState.userLocation;
    final nearbyClinics = clinicState.nearbyClinics;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Find Nearby Clinics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed:
                () => ref.read(clinicProvider.notifier).getCurrentLocation(),
            tooltip: 'Get my location',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(clinicProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.list), text: 'List'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),

          // Content based on selected tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(userLocation, nearbyClinics),
                _buildListView(nearbyClinics),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final clinicState = ref.watch(clinicProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search clinics, services...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(clinicProvider.notifier).searchClinics('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              ref.read(clinicProvider.notifier).searchClinics(value);
            },
          ),

          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', clinicState.selectedType),
                _buildFilterChip(
                  'Hospital',
                  'hospital',
                  clinicState.selectedType,
                ),
                _buildFilterChip('Clinic', 'clinic', clinicState.selectedType),
                _buildFilterChip(
                  'Private',
                  'private',
                  clinicState.selectedType,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedType) {
    final isSelected = selectedType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(clinicProvider.notifier).filterByType(value);
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMapView(
    Position? userLocation,
    List<ClinicWithDistance> nearbyClinics,
  ) {
    final center =
        userLocation != null
            ? LatLng(userLocation.latitude, userLocation.longitude)
            : _defaultLocation;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom:
            userLocation != null
                ? 13.0
                : 8.0, // Zoom out to show more of Rwanda when no user location
        minZoom: 7.0, // Allow zooming out to see all of Rwanda
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          ref.read(clinicProvider.notifier).clearSelection();
        },
      ),
      children: [
        // OpenStreetMap tiles (completely free!)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'rw.health.ubuzima.ubuzima_app',
          maxZoom: 18,
        ),

        // Clinic markers
        MarkerLayer(markers: _buildMarkers(nearbyClinics, userLocation)),

        // User location circle
        if (userLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(userLocation.latitude, userLocation.longitude),
                radius: 100,
                color: AppColors.primary.withValues(alpha: 0.3),
                borderColor: AppColors.primary,
                borderStrokeWidth: 2,
              ),
            ],
          ),
      ],
    );
  }

  List<Marker> _buildMarkers(
    List<ClinicWithDistance> nearbyClinics,
    Position? userLocation,
  ) {
    final markers = <Marker>[];

    // User location marker
    if (userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(userLocation.latitude, userLocation.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Clinic markers
    for (final clinicWithDistance in nearbyClinics) {
      final clinic = clinicWithDistance.clinic;
      markers.add(
        Marker(
          point: LatLng(clinic.latitude, clinic.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              ref.read(clinicProvider.notifier).selectClinic(clinic);
              _showClinicDetails(clinic, clinicWithDistance.distanceText);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _getClinicColor(clinic.type),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getClinicIcon(clinic.type),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Color _getClinicColor(String type) {
    switch (type) {
      case 'hospital':
        return Colors.red[600]!;
      case 'clinic':
        return Colors.blue[600]!;
      case 'private':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getClinicIcon(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'clinic':
        return Icons.medical_services;
      case 'private':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildListView(List<ClinicWithDistance> nearbyClinics) {
    if (nearbyClinics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No clinics found nearby',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or location',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nearbyClinics.length,
      itemBuilder: (context, index) {
        final clinicWithDistance = nearbyClinics[index];
        return _buildClinicCard(clinicWithDistance);
      },
    );
  }

  Widget _buildClinicCard(ClinicWithDistance clinicWithDistance) {
    final clinic = clinicWithDistance.clinic;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            () => _showClinicDetails(clinic, clinicWithDistance.distanceText),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getClinicColor(
                        clinic.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getClinicIcon(clinic.type),
                      color: _getClinicColor(clinic.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          clinic.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          clinicWithDistance.distanceText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (clinic.rating > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              clinic.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              if (clinic.services.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      clinic.services.take(3).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClinicDetails(Clinic clinic, String distance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: _buildClinicDetailsContent(clinic, distance),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildClinicDetailsContent(Clinic clinic, String distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getClinicColor(clinic.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getClinicIcon(clinic.type),
                color: _getClinicColor(clinic.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    clinic.address,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    distance,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Contact info
        _buildDetailSection('Contact Information', [
          _buildDetailRow(Icons.phone, 'Phone', clinic.phone),
          if (clinic.email != null)
            _buildDetailRow(Icons.email, 'Email', clinic.email!),
          if (clinic.website != null)
            _buildDetailRow(Icons.web, 'Website', clinic.website!),
        ]),

        // Services
        if (clinic.services.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildDetailSection('Services', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  clinic.services.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ]),
        ],

        // Working hours
        const SizedBox(height: 24),
        _buildDetailSection('Working Hours', [
          _buildDetailRow(Icons.access_time, 'Hours', clinic.workingHours),
        ]),

        // Action buttons
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _callClinic(clinic.phone),
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _getDirections(clinic),
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _callClinic(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _getDirections(Clinic clinic) async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/directions?from=&to=${clinic.latitude},${clinic.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
