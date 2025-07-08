import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_facility_model.dart';
import '../../widgets/voice_button.dart';

class FacilitiesManagementScreen extends StatefulWidget {
  const FacilitiesManagementScreen({super.key});

  @override
  State<FacilitiesManagementScreen> createState() =>
      _FacilitiesManagementScreenState();
}

class _FacilitiesManagementScreenState extends State<FacilitiesManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<HealthFacility> _facilities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFacilities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      _facilities = [
        HealthFacility(
          id: 'HC001',
          name: 'Kimisagara Health Center',
          facilityType: FacilityType.healthCenter,
          address: 'Kimisagara, Nyarugenge, Kigali',
          district: 'Nyarugenge',
          sector: 'Kimisagara',
          latitude: -1.9441,
          longitude: 30.0619,
          phoneNumber: '+250788111222',
          servicesOffered: [
            'Family Planning',
            'Maternal Health',
            'Child Health',
          ],
          operatingHours:
              '08:00-17:00 (Mon-Fri), 08:00-12:00 (Sat), Closed (Sun)',
          hasFamilyPlanning: true,
          rating: 4.5,
          totalReviews: 128,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        HealthFacility(
          id: 'HC002',
          name: 'Kigali University Teaching Hospital',
          facilityType: FacilityType.hospital,
          address: 'Nyarugenge, Kigali',
          district: 'Nyarugenge',
          sector: 'Nyarugenge',
          latitude: -1.9536,
          longitude: 30.0606,
          phoneNumber: '+250788333444',
          servicesOffered: ['Emergency', 'Surgery', 'Maternity', 'Pediatrics'],
          operatingHours: '24/7',
          hasFamilyPlanning: true,
          hasEmergencyServices: true,
          rating: 4.8,
          totalReviews: 256,
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amavuriro');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    } else if (lowerCommand.contains('kongeraho') ||
        lowerCommand.contains('add')) {
      _showAddFacilityDialog();
    } else if (lowerCommand.contains('gusiba') ||
        lowerCommand.contains('filter')) {
      _showFilterDialog();
    }
  }

  void _showAddFacilityDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kongeraho ikigo'),
            content: const Text('Iyi fonctionnalité izaza vuba...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Siga'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Gusiba amavuriro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Byose'),
                  leading: Radio<String>(
                    value: 'all',
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Ibitaro'),
                  leading: Radio<String>(
                    value: 'Hospital',
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Ibigo by\'ubuzima'),
                  leading: Radio<String>(
                    value: 'Health Center',
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Amavuriro'),
                  leading: Radio<String>(
                    value: 'Clinic',
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Amafarumasi'),
                  leading: Radio<String>(
                    value: 'Pharmacy',
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(isTablet),
            _buildSearchAndFilter(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFacilitiesList(isTablet),
                    _buildServicesTab(isTablet),
                    _buildAnalyticsTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_facility',
            onPressed: _showAddFacilityDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt:
                'Vuga: "Kongeraho" kugira ngo wongeraho ikigo, "Gushaka" kugira ngo ushake, cyangwa "Gusiba" kugira ngo usibe',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga amavuriro',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 120 : 100,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Gucunga amavuriro',
          style: AppTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Shakisha amavuriro...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            SizedBox(width: AppTheme.spacing16),
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textTertiary,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: 'Amavuriro', icon: Icon(Icons.domain)),
          Tab(text: 'Serivisi', icon: Icon(Icons.medical_services)),
          Tab(text: 'Imibare', icon: Icon(Icons.analytics)),
        ],
      ),
    );
  }

  Widget _buildFacilitiesList(bool isTablet) {
    final filteredFacilities =
        _facilities.where((facility) {
          final matchesSearch =
              facility.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              facility.address.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          final matchesFilter =
              _selectedFilter == 'all' ||
              facility.facilityTypeDisplayName == _selectedFilter;

          return matchesSearch && matchesFilter;
        }).toList();

    if (filteredFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textTertiary),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta mavuriro aboneka',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'Gerageza guhindura amashakiro cyangwa gusiba',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
      ),
      itemCount: filteredFacilities.length,
      itemBuilder: (context, index) {
        final facility = filteredFacilities[index];
        return _buildFacilityCard(
          facility,
          isTablet,
        ).animate(delay: (index * 100).ms).fadeIn().slideX();
      },
    );
  }

  Widget _buildFacilityCard(HealthFacility facility, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: _getFacilityColor(
                      facility.facilityTypeDisplayName,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getFacilityIcon(facility.facilityTypeDisplayName),
                    color: _getFacilityColor(facility.facilityTypeDisplayName),
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        facility.facilityTypeDisplayName,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Hindura'),
                        ),
                        const PopupMenuItem(value: 'view', child: Text('Reba')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Siba'),
                        ),
                      ],
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value - Izaza vuba...')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Expanded(
                  child: Text(
                    facility.address,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  facility.phoneNumber ?? 'N/A',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppTheme.warningColor),
                    SizedBox(width: AppTheme.spacing4),
                    Text(
                      '${facility.rating ?? 0.0} (${facility.totalReviews})',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Wrap(
              spacing: AppTheme.spacing8,
              runSpacing: AppTheme.spacing4,
              children:
                  (facility.servicesOffered ?? [])
                      .take(3)
                      .map(
                        (service) => Chip(
                          label: Text(service, style: AppTheme.bodySmall),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab(bool isTablet) {
    return const Center(child: Text('Serivisi z\'amavuriro - Izaza vuba...'));
  }

  Widget _buildAnalyticsTab(bool isTablet) {
    return const Center(child: Text('Imibare y\'amavuriro - Izaza vuba...'));
  }

  Color _getFacilityColor(String type) {
    switch (type) {
      case 'Hospital':
        return AppTheme.errorColor;
      case 'Health Center':
        return AppTheme.primaryColor;
      case 'Clinic':
        return AppTheme.secondaryColor;
      case 'Pharmacy':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getFacilityIcon(String type) {
    switch (type) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Health Center':
        return Icons.medical_services;
      case 'Clinic':
        return Icons.healing;
      case 'Pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.domain;
    }
  }
}
