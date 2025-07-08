import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_record_model.dart';
import '../../widgets/voice_button.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<HealthWorker> _healthWorkers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHealthWorkers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthWorkers() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
      
      _healthWorkers = [
        HealthWorker(
          id: 'hw1',
          name: 'Dr. Marie Uwimana',
          specialization: 'Family Planning',
          facilityId: 'HC001',
          phone: '+250788111222',
          email: 'marie.uwimana@health.gov.rw',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        HealthWorker(
          id: 'hw2',
          name: 'Nurse Jean Baptiste',
          specialization: 'Maternal Health',
          facilityId: 'HC002',
          phone: '+250788333444',
          email: 'jean.baptiste@health.gov.rw',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now(),
        ),
        HealthWorker(
          id: 'hw3',
          name: 'Dr. Grace Mukamana',
          specialization: 'General Medicine',
          facilityId: 'HC001',
          phone: '+250788555666',
          email: 'grace.mukamana@health.gov.rw',
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka abakozi');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    } else if (lowerCommand.contains('kongeraho') || lowerCommand.contains('add')) {
      _showAddStaffDialog();
    } else if (lowerCommand.contains('gusiba') || lowerCommand.contains('filter')) {
      _showFilterDialog();
    }
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kongeraho umukozi'),
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
      builder: (context) => AlertDialog(
        title: const Text('Gusiba abakozi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Bose'),
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
              title: const Text('Bakora'),
              leading: Radio<String>(
                value: 'active',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Ntibakora'),
              leading: Radio<String>(
                value: 'inactive',
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildStaffList(isTablet),
                  _buildPerformanceTab(isTablet),
                  _buildScheduleTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_staff',
            onPressed: _showAddStaffDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Kongeraho" kugira ngo wongeraho umukozi, "Gushaka" kugira ngo ushake, cyangwa "Gusiba" kugira ngo usibe',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga abakozi',
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
          'Gucunga abakozi',
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
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Shakisha abakozi...',
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
          Tab(text: 'Abakozi', icon: Icon(Icons.people)),
          Tab(text: 'Imikorere', icon: Icon(Icons.analytics)),
          Tab(text: 'Gahunda', icon: Icon(Icons.schedule)),
        ],
      ),
    );
  }

  Widget _buildStaffList(bool isTablet) {
    final filteredWorkers = _healthWorkers.where((worker) {
      final matchesSearch = worker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker.specialization.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && worker.isActive) ||
          (_selectedFilter == 'inactive' && !worker.isActive);
      
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = filteredWorkers[index];
        return _buildStaffCard(worker, isTablet).animate(delay: (index * 100).ms).fadeIn().slideX();
      },
    );
  }

  Widget _buildStaffCard(HealthWorker worker, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: worker.isActive ? AppTheme.primaryColor : AppTheme.textTertiary,
          child: Text(
            worker.name.split(' ').map((n) => n[0]).take(2).join(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(worker.name, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker.specialization),
            Text(worker.phone, style: AppTheme.bodySmall),
            Row(
              children: [
                Icon(
                  worker.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: worker.isActive ? AppTheme.successColor : AppTheme.errorColor,
                ),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  worker.isActive ? 'Akora' : 'Ntakora',
                  style: AppTheme.bodySmall.copyWith(
                    color: worker.isActive ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Hindura')),
            const PopupMenuItem(value: 'toggle', child: Text('Hindura uko akora')),
            const PopupMenuItem(value: 'delete', child: Text('Siba')),
          ],
          onSelected: (value) {
            // Handle menu actions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value - Izaza vuba...')),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPerformanceTab(bool isTablet) {
    return const Center(
      child: Text('Imikorere y\'abakozi - Izaza vuba...'),
    );
  }

  Widget _buildScheduleTab(bool isTablet) {
    return const Center(
      child: Text('Gahunda y\'abakozi - Izaza vuba...'),
    );
  }
}
