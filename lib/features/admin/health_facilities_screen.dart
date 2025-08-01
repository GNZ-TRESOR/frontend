import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import '../../core/models/health_facility.dart';

/// Admin Health Facilities Management Screen
class HealthFacilitiesScreen extends ConsumerStatefulWidget {
  const HealthFacilitiesScreen({super.key});

  @override
  ConsumerState<HealthFacilitiesScreen> createState() =>
      _HealthFacilitiesScreenState();
}

class _HealthFacilitiesScreenState
    extends ConsumerState<HealthFacilitiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<HealthFacility> _facilities = [];
  List<HealthFacility> _filteredFacilities = [];

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getHealthFacilities();

      if (response.success && response.data != null) {
        List<dynamic> facilitiesData = [];

        if (response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;
          facilitiesData = dataMap['data'] as List<dynamic>? ?? [];
        } else if (response.data is List<dynamic>) {
          facilitiesData = response.data as List<dynamic>;
        }

        _facilities =
            facilitiesData
                .map(
                  (json) =>
                      HealthFacility.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        _filterFacilities();
      } else {
        _error = response.message ?? 'Failed to load health facilities';
      }
    } catch (e) {
      _error = 'Error loading health facilities: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterFacilities() {
    String query = _searchController.text.toLowerCase();

    _filteredFacilities =
        _facilities.where((facility) {
          final matchesSearch =
              facility.name.toLowerCase().contains(query) ||
              facility.location.toLowerCase().contains(query);
          final matchesType =
              _selectedType == 'All' ||
              facility.type.toLowerCase() == _selectedType.toLowerCase();

          return matchesSearch && matchesType;
        }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Facilities'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFacilities,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildFacilitiesStats(),
            Expanded(
              child:
                  _error != null ? _buildErrorState() : _buildFacilitiesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFacilityDialog,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search facilities...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.secondary),
              ),
            ),
            onChanged: (_) => _filterFacilities(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Type: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items:
                      [
                            'All',
                            'Hospital',
                            'Health Center',
                            'Clinic',
                            'Dispensary',
                          ]
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                    _filterFacilities();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesStats() {
    final totalFacilities = _facilities.length;
    final activeFacilities = _facilities.where((f) => f.isActive).length;
    final inactiveFacilities = totalFacilities - activeFacilities;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          _buildStatCard('Total', totalFacilities, AppColors.primary),
          _buildStatCard('Active', activeFacilities, AppColors.success),
          _buildStatCard('Inactive', inactiveFacilities, AppColors.warning),
          _buildStatCard(
            'Filtered',
            _filteredFacilities.length,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesList() {
    if (_filteredFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No health facilities found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFacilities.length,
      itemBuilder: (context, index) {
        final facility = _filteredFacilities[index];
        return _buildFacilityCard(facility);
      },
    );
  }

  Widget _buildFacilityCard(HealthFacility facility) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFacilityTypeColor(facility.type),
          child: Icon(_getFacilityTypeIcon(facility.type), color: Colors.white),
        ),
        title: Text(
          facility.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.location),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getFacilityTypeColor(
                      facility.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    facility.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getFacilityTypeColor(facility.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        facility.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    facility.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          facility.isActive
                              ? AppColors.success
                              : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleFacilityAction(facility, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Facility'),
                ),
                PopupMenuItem(
                  value: facility.isActive ? 'deactivate' : 'activate',
                  child: Text(facility.isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading facilities',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFacilities,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getFacilityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return AppColors.error;
      case 'health center':
        return AppColors.primary;
      case 'clinic':
        return AppColors.secondary;
      case 'dispensary':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  IconData _getFacilityTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'health center':
        return Icons.medical_services;
      case 'clinic':
        return Icons.healing;
      case 'dispensary':
        return Icons.medication;
      default:
        return Icons.location_on;
    }
  }

  void _handleFacilityAction(HealthFacility facility, String action) {
    switch (action) {
      case 'view':
        _viewFacilityDetails(facility);
        break;
      case 'edit':
        _editFacility(facility);
        break;
      case 'activate':
      case 'deactivate':
        _toggleFacilityStatus(facility);
        break;
      case 'delete':
        _showDeleteConfirmation(facility);
        break;
    }
  }

  void _viewFacilityDetails(HealthFacility facility) {
    // TODO: Navigate to facility details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details for ${facility.name} - Coming Soon'),
      ),
    );
  }

  void _editFacility(HealthFacility facility) {
    showDialog(
      context: context,
      builder:
          (context) => _EditFacilityDialog(
            facility: facility,
            onFacilityUpdated: () {
              _loadFacilities();
            },
          ),
    );
  }

  void _showCreateFacilityDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _CreateFacilityDialog(
            onFacilityCreated: () {
              _loadFacilities();
            },
          ),
    );
  }

  Future<void> _toggleFacilityStatus(HealthFacility facility) async {
    setState(() => _isLoading = true);

    try {
      final newStatus = !facility.isActive;
      final response = await ApiService.instance.updateHealthFacility(
        facility.id!,
        {'isActive': newStatus},
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${facility.name} ${newStatus ? 'activated' : 'deactivated'} successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _loadFacilities(); // Refresh the list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Failed to update facility status',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating facility status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation(HealthFacility facility) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Facility'),
            content: Text(
              'Are you sure you want to delete "${facility.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteFacility(facility);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteFacility(HealthFacility facility) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.deleteHealthFacility(
        facility.id!,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${facility.name} deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _loadFacilities(); // Refresh the list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to delete facility'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting facility: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Create Health Facility Dialog
class _CreateFacilityDialog extends StatefulWidget {
  final VoidCallback onFacilityCreated;

  const _CreateFacilityDialog({required this.onFacilityCreated});

  @override
  State<_CreateFacilityDialog> createState() => _CreateFacilityDialogState();
}

class _CreateFacilityDialogState extends State<_CreateFacilityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _servicesController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String _selectedType = 'HOSPITAL';
  bool _isLoading = false;

  final List<String> _facilityTypes = [
    'HOSPITAL',
    'HEALTH_CENTER',
    'CLINIC',
    'DISPENSARY',
    'PHARMACY',
    'LABORATORY',
    'MATERNITY_CENTER',
    'COMMUNITY_HEALTH_POST',
    'PRIVATE_PRACTICE',
    'OTHER',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _operatingHoursController.dispose();
    _servicesController.dispose();
    _websiteController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Create Health Facility',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Facility Name *',
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? 'Name is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address *',
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? 'Address is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _operatingHoursController,
                        label: 'Operating Hours',
                        hint: 'e.g., Mon-Fri: 8:00 AM - 5:00 PM',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _servicesController,
                        label: 'Services Offered',
                        maxLines: 3,
                        hint: 'List the services provided by this facility',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _websiteController,
                              label: 'Website URL',
                              keyboardType: TextInputType.url,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emergencyContactController,
                              label: 'Emergency Contact',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createFacility,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text(
                              'Create Facility',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Facility Type *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
      ),
      items:
          _facilityTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type
                    .replaceAll('_', ' ')
                    .toLowerCase()
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' '),
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
      validator: (value) => value == null ? 'Facility type is required' : null,
    );
  }

  Future<void> _createFacility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final facilityData = {
        'name': _nameController.text.trim(),
        'facilityType': _selectedType,
        'address': _addressController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        'email':
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        'latitude':
            _latitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_latitudeController.text.trim()),
        'longitude':
            _longitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_longitudeController.text.trim()),
        'operatingHours':
            _operatingHoursController.text.trim().isEmpty
                ? null
                : _operatingHoursController.text.trim(),
        'servicesOffered':
            _servicesController.text.trim().isEmpty
                ? null
                : _servicesController.text.trim(),
        'websiteUrl':
            _websiteController.text.trim().isEmpty
                ? null
                : _websiteController.text.trim(),
        'emergencyContact':
            _emergencyContactController.text.trim().isEmpty
                ? null
                : _emergencyContactController.text.trim(),
      };

      final response = await ApiService.instance.createHealthFacility(
        facilityData,
      );

      if (response.success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health facility created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onFacilityCreated();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Failed to create health facility',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating health facility: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Edit Health Facility Dialog
class _EditFacilityDialog extends StatefulWidget {
  final HealthFacility facility;
  final VoidCallback onFacilityUpdated;

  const _EditFacilityDialog({
    required this.facility,
    required this.onFacilityUpdated,
  });

  @override
  State<_EditFacilityDialog> createState() => _EditFacilityDialogState();
}

class _EditFacilityDialogState extends State<_EditFacilityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _servicesController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String _selectedType = 'HOSPITAL';
  bool _isLoading = false;

  final List<String> _facilityTypes = [
    'HOSPITAL',
    'HEALTH_CENTER',
    'CLINIC',
    'DISPENSARY',
    'PHARMACY',
    'LABORATORY',
    'MATERNITY_CENTER',
    'COMMUNITY_HEALTH_POST',
    'PRIVATE_PRACTICE',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final facility = widget.facility;
    _nameController.text = facility.name;
    _addressController.text = facility.address;
    _phoneController.text = facility.phoneNumber ?? '';
    _emailController.text = facility.email ?? '';
    _latitudeController.text = facility.latitude?.toString() ?? '';
    _longitudeController.text = facility.longitude?.toString() ?? '';
    _operatingHoursController.text = facility.operatingHours?.toString() ?? '';
    _servicesController.text = facility.services.join(', ');
    _selectedType = facility.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _operatingHoursController.dispose();
    _servicesController.dispose();
    _websiteController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.facility.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Facility Name'),
                  validator:
                      (value) =>
                          value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Facility Type'),
                  items:
                      _facilityTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator:
                      (value) =>
                          value?.isEmpty == true ? 'Address is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _servicesController,
                  decoration: const InputDecoration(
                    labelText: 'Services (comma-separated)',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateFacility,
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateFacility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final facilityData = {
        'name': _nameController.text.trim(),
        'facilityType': _selectedType,
        'address': _addressController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        'email':
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        'latitude':
            _latitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_latitudeController.text.trim()),
        'longitude':
            _longitudeController.text.trim().isEmpty
                ? null
                : double.tryParse(_longitudeController.text.trim()),
        'operatingHours':
            _operatingHoursController.text.trim().isEmpty
                ? null
                : _operatingHoursController.text.trim(),
        'servicesOffered':
            _servicesController.text.trim().isEmpty
                ? null
                : _servicesController.text.trim(),
      };

      final response = await ApiService.instance.updateHealthFacility(
        widget.facility.id!,
        facilityData,
      );

      if (response.success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health facility updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onFacilityUpdated();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Failed to update health facility',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating health facility: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
