import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_facility_model.dart';
import '../../widgets/voice_button.dart';
import '../appointments/appointment_booking_screen.dart';

class ClinicLocatorScreen extends StatefulWidget {
  const ClinicLocatorScreen({super.key});

  @override
  State<ClinicLocatorScreen> createState() => _ClinicLocatorScreenState();
}

class _ClinicLocatorScreenState extends State<ClinicLocatorScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<HealthFacility> _facilities = [];
  HealthFacility? _selectedFacility;
  bool _isLoading = true;
  bool _isMapReady = false;
  String _selectedFilter = 'all';

  final Set<Marker> _markers = {};
  final PageController _pageController = PageController();

  final List<String> _facilityTypes = [
    'all',
    'Hospital',
    'Health Center',
    'Clinic',
    'Pharmacy',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Tugomba uruhushya rwo gukoresha aho uri');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(
          'Uruhushya rwo gukoresha aho uri rwahakanywe burundu',
        );
        return;
      }

      // Get current position
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Fallback to Kigali coordinates if location access fails
        _currentPosition = Position(
          latitude: -1.9441,
          longitude: 30.0619,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _showErrorSnackBar(
          'Dukoresha aho Kigali iri - emera gukoresha aho uri',
        );
      }

      await _loadNearbyFacilities();
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka aho uri');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyFacilities() async {
    try {
      // TODO: Load from API based on current location
      _facilities = [
        HealthFacility(
          id: '1',
          name: 'Kimisagara Health Center',
          facilityType: FacilityType.healthCenter,
          address: 'Kimisagara, Nyarugenge, Kigali',
          district: 'Nyarugenge',
          sector: 'Kimisagara',
          latitude: -1.9441,
          longitude: 30.0619,
          phoneNumber: '+250788111222',
          email: 'kimisagara@health.gov.rw',
          servicesOffered: [
            'Family Planning',
            'Maternal Health',
            'General Medicine',
            'Vaccination',
          ],
          operatingHours: '08:00-17:00 (Mon-Fri), 08:00-12:00 (Sat)',
          hasFamilyPlanning: true,
          hasMaternityWard: true,
          rating: 4.5,
          totalReviews: 128,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HealthFacility(
          id: '2',
          name: 'Kigali University Teaching Hospital',
          facilityType: FacilityType.hospital,
          address: 'Nyarugenge, Kigali',
          district: 'Nyarugenge',
          sector: 'Nyarugenge',
          latitude: -1.9536,
          longitude: 30.0606,
          phoneNumber: '+250788333444',
          email: 'info@kuth.rw',
          servicesOffered: [
            'Emergency',
            'Surgery',
            'Maternity',
            'Pediatrics',
            'Cardiology',
          ],
          operatingHours: '24/7',
          is24Hours: true,
          hasEmergencyServices: true,
          hasMaternityWard: true,
          hasFamilyPlanning: true,
          rating: 4.8,
          totalReviews: 256,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HealthFacility(
          id: '3',
          name: 'Remera Health Center',
          facilityType: FacilityType.healthCenter,
          address: 'Remera, Gasabo, Kigali',
          district: 'Gasabo',
          sector: 'Remera',
          latitude: -1.9167,
          longitude: 30.1167,
          phoneNumber: '+250788555666',
          servicesOffered: ['General Medicine', 'Dental Care', 'Eye Care'],
          operatingHours: '08:00-17:00 (Mon-Fri)',
          hasFamilyPlanning: false,
          rating: 4.2,
          totalReviews: 89,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HealthFacility(
          id: '4',
          name: 'Kacyiru Pharmacy',
          facilityType: FacilityType.pharmacy,
          address: 'Kacyiru, Gasabo, Kigali',
          district: 'Gasabo',
          sector: 'Kacyiru',
          latitude: -1.9333,
          longitude: 30.0833,
          phoneNumber: '+250788777888',
          servicesOffered: [
            'Prescription Drugs',
            'Over-the-counter Medicine',
            'Health Consultation',
          ],
          operatingHours:
              '08:00-20:00 (Mon-Fri), 08:00-18:00 (Sat), 10:00-16:00 (Sun)',
          hasPharmacy: true,
          rating: 4.0,
          totalReviews: 45,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _updateMarkers();
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amavuriro');
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Aho uri'),
        ),
      );
    }

    // Add facility markers
    final filteredFacilities =
        _selectedFilter == 'all'
            ? _facilities
            : _facilities
                .where((f) => f.facilityTypeDisplayName == _selectedFilter)
                .toList();

    for (int i = 0; i < filteredFacilities.length; i++) {
      final facility = filteredFacilities[i];
      if (facility.latitude != null && facility.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(facility.id),
            position: LatLng(facility.latitude!, facility.longitude!),
            icon: _getMarkerIcon(facility.facilityTypeDisplayName),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: facility.facilityTypeDisplayName,
              onTap: () => _selectFacility(facility, i),
            ),
            onTap: () => _selectFacility(facility, i),
          ),
        );
      }
    }

    setState(() {});
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'Hospital':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'Health Center':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'Clinic':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'Pharmacy':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _selectFacility(HealthFacility facility, int index) {
    setState(() {
      _selectedFacility = facility;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (facility.latitude != null && facility.longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(facility.latitude!, facility.longitude!),
          15.0,
        ),
      );
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('hafi') || lowerCommand.contains('near')) {
      _goToCurrentLocation();
    } else if (lowerCommand.contains('bitaro') ||
        lowerCommand.contains('hospital')) {
      _filterFacilities('Hospital');
    } else if (lowerCommand.contains('kigo') ||
        lowerCommand.contains('center')) {
      _filterFacilities('Health Center');
    } else if (lowerCommand.contains('farumasi') ||
        lowerCommand.contains('pharmacy')) {
      _filterFacilities('Pharmacy');
    }
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  void _filterFacilities(String type) {
    setState(() {
      _selectedFilter = type;
    });
    _updateMarkers();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Shakisha amavuriro'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _goToCurrentLocation,
            tooltip: 'Subira aho uri',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Filter chips
                  _buildFilterChips(isTablet),

                  // Map
                  Expanded(flex: 3, child: _buildMap()),

                  // Facility list
                  Expanded(flex: 2, child: _buildFacilityList(isTablet)),
                ],
              ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Hafi" kugira ngo ugere aho uri, "Bitaro" kugira ngo ushake ambitaro, cyangwa "Farumasi" kugira ngo ushake amafarumasi',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushaka',
      ),
    );
  }

  Widget _buildFilterChips(bool isTablet) {
    return Container(
      height: isTablet ? 60 : 50,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _facilityTypes.length,
        itemBuilder: (context, index) {
          final type = _facilityTypes[index];
          final isSelected = _selectedFilter == type;

          return Container(
            margin: EdgeInsets.only(right: AppTheme.spacing8),
            child: FilterChip(
              label: Text(_getFacilityTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = type;
                });
                _updateMarkers();
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: AppTheme.bodySmall.copyWith(
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, duration: 600.ms);
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Stack(
          children: [
            // Fallback map placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_rounded, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Ikarita izashyirwaho vuba',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // Try to load Google Maps
            FutureBuilder<Widget>(
              future: _buildGoogleMap(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Future<Widget> _buildGoogleMap() async {
    try {
      return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          setState(() {
            _isMapReady = true;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 13.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        mapType: MapType.normal,
      );
    } catch (e) {
      debugPrint('Google Maps error: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildFacilityList(bool isTablet) {
    final filteredFacilities =
        _selectedFilter == 'all'
            ? _facilities
            : _facilities
                .where((f) => f.facilityTypeDisplayName == _selectedFilter)
                .toList();

    if (filteredFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta mavuriro aboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: filteredFacilities.length,
      onPageChanged: (index) {
        final facility = filteredFacilities[index];
        setState(() {
          _selectedFacility = facility;
        });

        if (facility.latitude != null && facility.longitude != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(facility.latitude!, facility.longitude!),
              15.0,
            ),
          );
        }
      },
      itemBuilder: (context, index) {
        final facility = filteredFacilities[index];
        return _buildFacilityCard(facility, isTablet);
      },
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildFacilityCard(HealthFacility facility, bool isTablet) {
    final distance =
        _currentPosition != null
            ? facility.distanceFrom(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            )
            : 0.0;

    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
      ),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: _getFacilityColor(
                    facility.facilityTypeDisplayName,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Icon(
                  _getFacilityIcon(facility.facilityTypeDisplayName),
                  color: _getFacilityColor(facility.facilityTypeDisplayName),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: isTablet ? 16 : 14,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Text(
                          distance != null
                              ? '${distance.toStringAsFixed(1)} km'
                              : 'N/A',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing8),
                        Icon(
                          Icons.star_rounded,
                          size: isTablet ? 16 : 14,
                          color: AppTheme.warningColor,
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${facility.rating ?? 0.0} (${facility.totalReviews})',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacing16),

          // Address
          Row(
            children: [
              Icon(
                Icons.place_rounded,
                size: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Text(facility.address, style: AppTheme.bodyMedium),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacing8),

          // Phone
          Row(
            children: [
              Icon(
                Icons.phone_rounded,
                size: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(facility.phoneNumber ?? 'N/A', style: AppTheme.bodyMedium),
            ],
          ),

          SizedBox(height: AppTheme.spacing16),

          // Services
          if (facility.servicesOffered != null &&
              facility.servicesOffered!.isNotEmpty) ...[
            Text(
              'Serivisi:',
              style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacing8),
            Wrap(
              spacing: AppTheme.spacing4,
              runSpacing: AppTheme.spacing4,
              children:
                  facility.servicesOffered!.take(3).map((service) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.spacing4),
                      ),
                      child: Text(
                        service,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: isTablet ? 10 : 8,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: AppTheme.spacing16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callFacility(facility.phoneNumber ?? ''),
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Hamagara'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical:
                          isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bookAppointment(facility),
                  icon: const Icon(Icons.event_rounded, size: 16),
                  label: const Text('Gahunda'),
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical:
                            isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFacilityTypeLabel(String type) {
    switch (type) {
      case 'all':
        return 'Byose';
      case 'Hospital':
        return 'Ambitaro';
      case 'Health Center':
        return 'Ibigo by\'ubuzima';
      case 'Clinic':
        return 'Amavuriro';
      case 'Pharmacy':
        return 'Amafarumasi';
      default:
        return type;
    }
  }

  IconData _getFacilityIcon(String type) {
    switch (type) {
      case 'Hospital':
        return Icons.local_hospital_rounded;
      case 'Health Center':
        return Icons.medical_services_rounded;
      case 'Clinic':
        return Icons.healing_rounded;
      case 'Pharmacy':
        return Icons.medication_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getFacilityColor(String type) {
    switch (type) {
      case 'Hospital':
        return AppTheme.errorColor;
      case 'Health Center':
        return AppTheme.successColor;
      case 'Clinic':
        return AppTheme.warningColor;
      case 'Pharmacy':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  Future<void> _callFacility(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Ntidushobora gufungura telefoni');
    }
  }

  void _bookAppointment(HealthFacility facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AppointmentBookingScreen(selectedFacility: facility),
      ),
    );
  }
}
