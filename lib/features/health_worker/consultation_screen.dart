import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';

class ConsultationScreen extends StatefulWidget {
  final User healthWorker;

  const ConsultationScreen({super.key, required this.healthWorker});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedFilter = 'today';

  final List<ConsultationItem> _consultations = [
    ConsultationItem(
      id: '1',
      clientName: 'Mukamana Marie',
      clientId: 'client_1',
      type: 'Family Planning',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      status: 'Scheduled',
      priority: 'Normal',
      notes: 'Inama yo guhitamo uburyo bwo kurinda inda',
    ),
    ConsultationItem(
      id: '2',
      clientName: 'Uwimana Jeanne',
      clientId: 'client_2',
      type: 'Prenatal Care',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'In Progress',
      priority: 'High',
      notes: 'Gusuzuma inda - ukwezi kwa 6',
    ),
    ConsultationItem(
      id: '3',
      clientName: 'Gasana Alice',
      clientId: 'client_3',
      type: 'STI Prevention',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'Completed',
      priority: 'Normal',
      notes: 'Inama yo kurinda indwara zandurira',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConsultations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultations() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka inama');
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
    if (lowerCommand.contains('gushya') || lowerCommand.contains('new')) {
      _scheduleNewConsultation();
    } else if (lowerCommand.contains('uyu munsi') || lowerCommand.contains('today')) {
      _setFilter('today');
    } else if (lowerCommand.contains('ejo') || lowerCommand.contains('tomorrow')) {
      _setFilter('tomorrow');
    }
  }

  void _scheduleNewConsultation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gushiraho inama'),
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

  void _setFilter(String filter) {
    setState(() => _selectedFilter = filter);
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
            _buildFilterChips(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(isTablet),
                  _buildUpcomingTab(isTablet),
                  _buildHistoryTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'new_consultation',
            onPressed: _scheduleNewConsultation,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Gushya" kugira ngo ushiraho inama, "Uyu munsi" kugira ngo ugere ku nama z\'uyu munsi',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga inama',
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
          'Inama n\'ubujyanama',
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

  Widget _buildFilterChips(bool isTablet) {
    final filters = ['today', 'tomorrow', 'week', 'all'];
    
    return SliverToBoxAdapter(
      child: Container(
        height: isTablet ? 60 : 50,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;

            return Container(
              margin: EdgeInsets.only(right: AppTheme.spacing8),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (selected) => _setFilter(filter),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
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
          Tab(text: 'Uyu munsi', icon: Icon(Icons.today)),
          Tab(text: 'Zizaza', icon: Icon(Icons.schedule)),
          Tab(text: 'Amateka', icon: Icon(Icons.history)),
        ],
      ),
    );
  }

  Widget _buildTodayTab(bool isTablet) {
    final todayConsultations = _consultations.where((consultation) {
      final today = DateTime.now();
      final consultationDate = consultation.scheduledTime;
      return consultationDate.year == today.year &&
          consultationDate.month == today.month &&
          consultationDate.day == today.day;
    }).toList();

    return _buildConsultationsList(todayConsultations, isTablet);
  }

  Widget _buildUpcomingTab(bool isTablet) {
    final upcomingConsultations = _consultations.where((consultation) {
      return consultation.scheduledTime.isAfter(DateTime.now()) &&
          consultation.status != 'Completed';
    }).toList();

    return _buildConsultationsList(upcomingConsultations, isTablet);
  }

  Widget _buildHistoryTab(bool isTablet) {
    final completedConsultations = _consultations.where((consultation) {
      return consultation.status == 'Completed';
    }).toList();

    return _buildConsultationsList(completedConsultations, isTablet);
  }

  Widget _buildConsultationsList(List<ConsultationItem> consultations, bool isTablet) {
    if (consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta nama ziboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return _buildConsultationCard(consultation, isTablet).animate(delay: (index * 100).ms).fadeIn().slideX();
      },
    );
  }

  Widget _buildConsultationCard(ConsultationItem consultation, bool isTablet) {
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
                    color: _getTypeColor(consultation.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getTypeIcon(consultation.type),
                    color: _getTypeColor(consultation.type),
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.clientName,
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        consultation.type,
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(consultation.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    consultation.status,
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(consultation.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  _formatTime(consultation.scheduledTime),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
                const Spacer(),
                if (consultation.priority == 'High')
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      'Byihutirwa',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (consultation.notes.isNotEmpty) ...[
              SizedBox(height: AppTheme.spacing8),
              Text(
                consultation.notes,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewConsultationDetails(consultation),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Reba'),
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startConsultation(consultation),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Tangira'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
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

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'today':
        return 'Uyu munsi';
      case 'tomorrow':
        return 'Ejo';
      case 'week':
        return 'Iki cyumweru';
      case 'all':
        return 'Byose';
      default:
        return filter;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Family Planning':
        return AppTheme.primaryColor;
      case 'Prenatal Care':
        return AppTheme.secondaryColor;
      case 'STI Prevention':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Family Planning':
        return Icons.family_restroom;
      case 'Prenatal Care':
        return Icons.pregnant_woman;
      case 'STI Prevention':
        return Icons.health_and_safety;
      default:
        return Icons.medical_services;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return AppTheme.warningColor;
      case 'In Progress':
        return AppTheme.primaryColor;
      case 'Completed':
        return AppTheme.successColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _viewConsultationDetails(ConsultationItem consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reba inama ya ${consultation.clientName} - Izaza vuba...')),
    );
  }

  void _startConsultation(ConsultationItem consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tangira inama ya ${consultation.clientName} - Izaza vuba...')),
    );
  }
}

class ConsultationItem {
  final String id;
  final String clientName;
  final String clientId;
  final String type;
  final DateTime scheduledTime;
  final String status;
  final String priority;
  final String notes;

  ConsultationItem({
    required this.id,
    required this.clientName,
    required this.clientId,
    required this.type,
    required this.scheduledTime,
    required this.status,
    required this.priority,
    required this.notes,
  });
}
