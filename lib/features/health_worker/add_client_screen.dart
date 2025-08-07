import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({super.key});

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _facilityIdController = TextEditingController();

  // Form values
  String? _selectedGender;
  String? _selectedDistrict;
  String? _selectedSector;
  String? _selectedCell;
  String? _selectedVillage;
  String? _selectedLanguage;
  DateTime? _selectedDateOfBirth;
  String _selectedRole = 'CLIENT';
  String _selectedStatus = 'ACTIVE';

  // Options
  final List<String> _genderOptions = [
    'MALE',
    'FEMALE',
    'OTHER',
    'PREFER_NOT_TO_SAY',
  ];

  final List<String> _roleOptions = ['CLIENT', 'HEALTH_WORKER'];

  final List<String> _statusOptions = [
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED',
    'PENDING_VERIFICATION',
  ];

  final List<String> _languageOptions = [
    'rw', // Kinyarwanda
    'en', // English
    'fr', // French
    'sw', // Swahili
  ];

  final List<String> _districtOptions = [
    'Kigali',
    'Eastern Province',
    'Northern Province',
    'Southern Province',
    'Western Province',
  ];

  final Map<String, List<String>> _sectorOptions = {
    'Kigali': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Eastern Province': [
      'Rwamagana',
      'Kayonza',
      'Kirehe',
      'Ngoma',
      'Bugesera',
      'Gatsibo',
      'Nyagatare',
    ],
    'Northern Province': ['Rulindo', 'Gicumbi', 'Musanze', 'Burera', 'Gakenke'],
    'Southern Province': [
      'Nyanza',
      'Gisagara',
      'Nyaruguru',
      'Huye',
      'Nyamagabe',
      'Ruhango',
      'Muhanga',
      'Kamonyi',
    ],
    'Western Province': [
      'Karongi',
      'Rutsiro',
      'Rubavu',
      'Nyabihu',
      'Ngororero',
      'Rusizi',
      'Nyamasheke',
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyContactController.dispose();
    _facilityIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Client'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 16),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Contact Information'),
                const SizedBox(height: 16),
                _buildContactInfoSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Location Information'),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Account Settings'),
                const SizedBox(height: 16),
                _buildAccountSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter full name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          items:
              _genderOptions.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(_formatGenderDisplay(gender)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            hintText:
                _selectedDateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDateOfBirth!)
                    : 'Select date of birth',
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
          onTap: _selectDateOfBirth,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: const InputDecoration(
            labelText: 'Preferred Language',
            prefixIcon: Icon(Icons.language),
            border: OutlineInputBorder(),
          ),
          items:
              _languageOptions.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(_formatLanguageDisplay(language)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _selectedLanguage = value);
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+250788000000',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (!RegExp(r'^\+250\d{9}$').hasMatch(value)) {
              return 'Please enter a valid Rwandan phone number (+250XXXXXXXXX)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emergencyContactController,
          decoration: const InputDecoration(
            labelText: 'Emergency Contact',
            hintText: '+250788000000',
            prefixIcon: Icon(Icons.emergency),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (!RegExp(r'^\+250\d{9}$').hasMatch(value)) {
                return 'Please enter a valid Rwandan phone number (+250XXXXXXXXX)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: const InputDecoration(
            labelText: 'District',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
          items:
              _districtOptions.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDistrict = value;
              _selectedSector = null; // Reset sector when district changes
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSector,
          decoration: const InputDecoration(
            labelText: 'Sector',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          items:
              _selectedDistrict != null
                  ? _sectorOptions[_selectedDistrict]?.map((sector) {
                    return DropdownMenuItem<String>(
                      value: sector,
                      child: Text(sector),
                    );
                  }).toList()
                  : [],
          onChanged: (value) {
            setState(() => _selectedSector = value);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Cell',
            hintText: 'Enter cell name',
            prefixIcon: Icon(Icons.place),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _selectedCell = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Village',
            hintText: 'Enter village name',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _selectedVillage = value;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _facilityIdController,
          decoration: const InputDecoration(
            labelText: 'Facility ID',
            hintText: 'Enter facility ID (optional)',
            prefixIcon: Icon(Icons.local_hospital),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(
            labelText: 'Role *',
            prefixIcon: Icon(Icons.admin_panel_settings),
            border: OutlineInputBorder(),
          ),
          items:
              _roleOptions.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(_formatRoleDisplay(role)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _selectedRole = value!);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Status *',
            prefixIcon: Icon(Icons.toggle_on),
            border: OutlineInputBorder(),
          ),
          items:
              _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(_formatStatusDisplay(status)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _selectedStatus = value!);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password *',
            hintText: 'Enter password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirm Password *',
            hintText: 'Confirm password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitForm,
        icon: const Icon(Icons.person_add),
        label: Text(_isLoading ? 'Creating...' : 'Create User'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Helper methods
  String _formatGenderDisplay(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      case 'PREFER_NOT_TO_SAY':
        return 'Prefer not to say';
      default:
        return gender;
    }
  }

  String _formatLanguageDisplay(String language) {
    switch (language) {
      case 'rw':
        return 'Kinyarwanda';
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      case 'sw':
        return 'Swahili';
      default:
        return language;
    }
  }

  String _formatRoleDisplay(String role) {
    switch (role) {
      case 'CLIENT':
        return 'Client';
      case 'HEALTH_WORKER':
        return 'Health Worker';
      case 'ADMIN':
        return 'Administrator';
      default:
        return role;
    }
  }

  String _formatStatusDisplay(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'INACTIVE':
        return 'Inactive';
      case 'SUSPENDED':
        return 'Suspended';
      case 'PENDING_VERIFICATION':
        return 'Pending Verification';
      default:
        return status;
    }
  }

  // Action methods
  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDateOfBirth = date);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _emergencyContactController.clear();
    _facilityIdController.clear();

    setState(() {
      _selectedGender = null;
      _selectedDistrict = null;
      _selectedSector = null;
      _selectedCell = null;
      _selectedVillage = null;
      _selectedLanguage = null;
      _selectedDateOfBirth = null;
      _selectedRole = 'CLIENT';
      _selectedStatus = 'ACTIVE';
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
        'status': _selectedStatus,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String().split('T')[0],
        'district': _selectedDistrict,
        'sector': _selectedSector,
        'cell': _selectedCell?.trim(),
        'village': _selectedVillage?.trim(),
        'emergencyContact':
            _emergencyContactController.text.trim().isNotEmpty
                ? _emergencyContactController.text.trim()
                : null,
        'facilityId':
            _facilityIdController.text.trim().isNotEmpty
                ? _facilityIdController.text.trim()
                : null,
        'preferredLanguage': _selectedLanguage ?? 'rw',
        'emailVerified': false,
        'phoneVerified': false,
      };

      final response = await ApiService.instance.dio.post(
        '/users/register',
        data: userData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User ${_nameController.text} created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user: ${e.toString()}'),
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
