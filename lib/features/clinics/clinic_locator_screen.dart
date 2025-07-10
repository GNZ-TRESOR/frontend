import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_facility.dart';
import '../../core/services/location_service.dart';
import '../../core/services/health_facility_service.dart';
import '../../core/services/data_service.dart';
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
  FacilityType? _selectedFilter;
  String _searchQuery = '';

  final Set<Marker> _markers = {};
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final HealthFacilityService _facilityService = HealthFacilityService();

  final List<FacilityType> _facilityTypes = [
    FacilityType.HOSPITAL,
    FacilityType.HEALTH_CENTER,
    FacilityType.CLINIC,
    FacilityType.DISPENSARY,
    FacilityType.PHARMACY,
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current position using LocationService
      _currentPosition = await _locationService.getCurrentPosition();

      if (_currentPosition == null) {
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
          'Dukoresha aho Kigali iri kuko tutashobora kubona aho uri',
        );
      }

      // Load nearby facilities
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
    if (_currentPosition == null) return;

    try {
      // Load facilities from API
      _facilities = await _locationService.getNearbyFacilities(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 25.0,
        type: _selectedFilter,
        limit: 50,
      );

      // If no facilities found, try loading all facilities
      if (_facilities.isEmpty) {
        final dataService = DataService();
        _facilities = await dataService.getHealthFacilities();
      }

      // Update markers on map
      _updateMapMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading facilities: $e');
      // Try loading all facilities as fallback
      try {
        final dataService = DataService();
        _facilities = await dataService.getHealthFacilities();
      } catch (fallbackError) {
        debugPrint('Fallback also failed: $fallbackError');
        _facilities = []; // Empty list if all fails
      }
      _updateMapMarkers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sample facilities method removed - now using real API data from DataService
  List<HealthFacility> _getSampleFacilities() {
    return [
      HealthFacility(
        id: '1',
        name: 'Kimisagara Health Center',
        type: FacilityType.HEALTH_CENTER,
        address: 'Kimisagara, Nyarugenge, Kigali',
        district: 'Nyarugenge',
        sector: 'Kimisagara',
        latitude: -1.9441,
        longitude: 30.0619,
        phone: '+250788111222',
        email: 'kimisagara@health.gov.rw',
        services: [
          'Family Planning',
          'Maternal Health',
          'General Medicine',
          'Vaccination',
        ],
        operatingHours: {
          'Monday': '08:00-17:00',
          'Tuesday': '08:00-17:00',
          'Wednesday': '08:00-17:00',
          'Thursday': '08:00-17:00',
          'Friday': '08:00-17:00',
          'Saturday': '08:00-12:00',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      HealthFacility(
        id: '2',
        name: 'King Faisal Hospital',
        type: FacilityType.HOSPITAL,
        address: 'Kacyiru, Gasabo, Kigali',
        district: 'Gasabo',
        sector: 'Kacyiru',
        latitude: -1.9355,
        longitude: 30.0928,
        phone: '+250788333444',
        email: 'info@kfh.rw',
        services: [
          'Emergency Care',
          'Surgery',
          'Maternity',
          'Pediatrics',
          'Cardiology',
        ],
        operatingHours: {
          'Monday': '24/7',
          'Tuesday': '24/7',
          'Wednesday': '24/7',
          'Thursday': '24/7',
          'Friday': '24/7',
          'Saturday': '24/7',
          'Sunday': '24/7',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      HealthFacility(
        id: '3',
        name: 'Remera Health Center',
        type: FacilityType.HEALTH_CENTER,
        address: 'Remera, Gasabo, Kigali',
        district: 'Gasabo',
        sector: 'Remera',
        latitude: -1.9578,
        longitude: 30.1127,
        phone: '+250788555666',
        email: 'remera@health.gov.rw',
        services: [
          'Family Planning',
          'HIV Testing',
          'Vaccination',
          'General Medicine',
        ],
        operatingHours: {
          'Monday': '07:30-17:00',
          'Tuesday': '07:30-17:00',
          'Wednesday': '07:30-17:00',
          'Thursday': '07:30-17:00',
          'Friday': '07:30-17:00',
          'Saturday': '08:00-13:00',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      HealthFacility(
        id: '4',
        name: 'Nyamirambo Health Center',
        type: FacilityType.HEALTH_CENTER,
        address: 'Nyamirambo, Nyarugenge, Kigali',
        district: 'Nyarugenge',
        sector: 'Nyamirambo',
        latitude: -1.9706,
        longitude: 30.0394,
        phone: '+250788777888',
        email: 'nyamirambo@health.gov.rw',
        services: [
          'Maternal Health',
          'Child Health',
          'Family Planning',
          'TB Treatment',
        ],
        operatingHours: {
          'Monday': '08:00-17:00',
          'Tuesday': '08:00-17:00',
          'Wednesday': '08:00-17:00',
          'Thursday': '08:00-17:00',
          'Friday': '08:00-17:00',
          'Saturday': '08:00-12:00',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      HealthFacility(
        id: '5',
        name: 'Kigali University Teaching Hospital',
        type: FacilityType.HOSPITAL,
        address: 'Nyarugenge, Kigali',
        district: 'Nyarugenge',
        sector: 'Nyarugenge',
        latitude: -1.9536,
        longitude: 30.0606,
        phone: '+250788999000',
        email: 'info@chuk.rw',
        services: [
          'Emergency Care',
          'Surgery',
          'Oncology',
          'Neurology',
          'Cardiology',
          'Maternity',
        ],
        operatingHours: {
          'Monday': '24/7',
          'Tuesday': '24/7',
          'Wednesday': '24/7',
          'Thursday': '24/7',
          'Friday': '24/7',
          'Saturday': '24/7',
          'Sunday': '24/7',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _updateMapMarkers() {
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
    for (int i = 0; i < _facilities.length; i++) {
      final facility = _facilities[i];
      if (facility.latitude != null && facility.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(facility.id),
            position: LatLng(facility.latitude!, facility.longitude!),
            icon: _getMarkerIcon(facility.type),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: facility.type.displayName,
            ),
            onTap: () {
              setState(() {
                _selectedFacility = facility;
              });
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        );
      }
    }

    setState(() {});
  }

  BitmapDescriptor _getMarkerIcon(FacilityType type) {
    switch (type) {
      case FacilityType.HOSPITAL:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case FacilityType.HEALTH_CENTER:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case FacilityType.CLINIC:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case FacilityType.PHARMACY:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case FacilityType.DISPENSARY:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Shakisha amavuriro cyangwa ahantu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadNearbyFacilities();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: _performSearch,
          ),
          const SizedBox(height: 12),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Byose'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                    _loadNearbyFacilities();
                  },
                ),
                const SizedBox(width: 8),
                ..._facilityTypes.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: _selectedFilter == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? type : null;
                        });
                        _loadNearbyFacilities();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        setState(() {
          _isMapReady = true;
        });
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 13.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onTap: (LatLng position) {
        setState(() {
          _selectedFacility = null;
        });
      },
    );
  }

  Widget _buildFacilityList() {
    if (_facilities.isEmpty) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Nta mavuriro aboneka hafi yawe. Gerageza guhindura filter cyangwa gushaka ahantu handi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _facilities.length,
          onPageChanged: (index) {
            final facility = _facilities[index];
            setState(() {
              _selectedFacility = facility;
            });
            if (facility.latitude != null && facility.longitude != null) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(facility.latitude!, facility.longitude!),
                ),
              );
            }
          },
          itemBuilder: (context, index) {
            final facility = _facilities[index];
            return _buildFacilityCard(facility);
          },
        ),
      ),
    );
  }

  Widget _buildFacilityCard(HealthFacility facility) {
    final distance = facility.metadata?['distance'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  facility.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(facility.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  facility.type.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  facility.fullAddress,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              if (distance != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (facility.services.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  facility.services.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(facility),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Icyerekezo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bookAppointment(facility),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Gahunda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3).fadeIn();
  }

  Color _getTypeColor(FacilityType type) {
    switch (type) {
      case FacilityType.HOSPITAL:
        return Colors.red;
      case FacilityType.HEALTH_CENTER:
        return Colors.green;
      case FacilityType.CLINIC:
        return Colors.orange;
      case FacilityType.PHARMACY:
        return Colors.purple;
      case FacilityType.DISPENSARY:
        return Colors.amber;
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _loadNearbyFacilities();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Search by location name
      final facilities = await _locationService.searchFacilitiesByLocation(
        query,
      );

      if (facilities.isNotEmpty) {
        setState(() {
          _facilities = facilities;
          _isLoading = false;
        });
        _updateMapMarkers();

        // Move camera to first result
        final firstFacility = facilities.first;
        if (firstFacility.latitude != null && firstFacility.longitude != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(firstFacility.latitude!, firstFacility.longitude!),
            ),
          );
        }
      } else {
        // Search by facility name
        final allFacilities = await _facilityService.searchHealthFacilities(
          query,
        );
        setState(() {
          _facilities = allFacilities;
          _isLoading = false;
        });
        _updateMapMarkers();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Habaye ikosa mu gushaka');
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();

    if (lowerCommand.contains('ibitaro') || lowerCommand.contains('hospital')) {
      setState(() {
        _selectedFilter = FacilityType.HOSPITAL;
      });
      _loadNearbyFacilities();
    } else if (lowerCommand.contains('amavuriro') ||
        lowerCommand.contains('clinic')) {
      setState(() {
        _selectedFilter = FacilityType.CLINIC;
      });
      _loadNearbyFacilities();
    } else if (lowerCommand.contains('farumasi') ||
        lowerCommand.contains('pharmacy')) {
      setState(() {
        _selectedFilter = FacilityType.PHARMACY;
      });
      _loadNearbyFacilities();
    } else if (lowerCommand.contains('gushaka') ||
        lowerCommand.contains('search')) {
      // Extract search term after "gushaka"
      final searchTerm =
          command
              .replaceAll(RegExp(r'gushaka|search', caseSensitive: false), '')
              .trim();
      if (searchTerm.isNotEmpty) {
        _searchController.text = searchTerm;
        _performSearch(searchTerm);
      }
    }
  }

  Future<void> _openDirections(HealthFacility facility) async {
    if (facility.latitude == null || facility.longitude == null) {
      _showErrorSnackBar('Ntabwo hari amakuru y\'aho iri');
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Ntabwo dushobora gufungura Google Maps');
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gufungura icyerekezo');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gushaka Amavuriro'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initializeLocation,
            tooltip: 'Subira aho uri',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Turashaka amavuriro hafi yawe...'),
                  ],
                ),
              )
              : Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child: Stack(children: [_buildMap(), _buildFacilityList()]),
                  ),
                ],
              ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga "gushaka ibitaro" cyangwa "gushaka amavuriro"',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushaka',
      ),
    );
  }
}
