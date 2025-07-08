import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';

class ScheduleManagementScreen extends StatefulWidget {
  final User healthWorker;

  const ScheduleManagementScreen({super.key, required this.healthWorker});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'day';

  final List<ScheduleEvent> _events = [
    ScheduleEvent(
      id: '1',
      title: 'Inama na Mukamana Marie',
      description: 'Inama yo guhitamo uburyo bwo kurinda inda',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      type: 'Consultation',
      clientId: 'client_1',
      status: 'Scheduled',
    ),
    ScheduleEvent(
      id: '2',
      title: 'Raporo y\'ukwezi',
      description: 'Gukora raporo y\'ibikorwa by\'ukwezi',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      type: 'Administrative',
      clientId: null,
      status: 'Scheduled',
    ),
    ScheduleEvent(
      id: '3',
      title: 'Inama n\'itsinda',
      description: 'Inama n\'itsinda ry\'abagore',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      type: 'Group Session',
      clientId: null,
      status: 'Scheduled',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka gahunda');
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
      _addNewEvent();
    } else if (lowerCommand.contains('uyu munsi') || lowerCommand.contains('today')) {
      _goToToday();
    } else if (lowerCommand.contains('ejo') || lowerCommand.contains('tomorrow')) {
      _goToTomorrow();
    }
  }

  void _addNewEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kongeraho igikorwa'),
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

  void _goToToday() {
    setState(() => _selectedDate = DateTime.now());
  }

  void _goToTomorrow() {
    setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1)));
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
            _buildDateSelector(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDayView(isTablet),
                  _buildWeekView(isTablet),
                  _buildMonthView(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_event',
            onPressed: _addNewEvent,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Gushya" kugira ngo wongeraho igikorwa, "Uyu munsi" kugira ngo ugere ku munsi w\'uyu',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga gahunda',
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
          'Gahunda y\'igihe',
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
      actions: [
        IconButton(
          onPressed: _goToToday,
          icon: const Icon(Icons.today),
          tooltip: 'Jya ku munsi w\'uyu',
        ),
      ],
    );
  }

  Widget _buildDateSelector(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
              icon: const Icon(Icons.chevron_right),
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
          Tab(text: 'Umunsi', icon: Icon(Icons.view_day)),
          Tab(text: 'Icyumweru', icon: Icon(Icons.view_week)),
          Tab(text: 'Ukwezi', icon: Icon(Icons.view_module)),
        ],
      ),
    );
  }

  Widget _buildDayView(bool isTablet) {
    final dayEvents = _events.where((event) {
      return event.startTime.year == _selectedDate.year &&
          event.startTime.month == _selectedDate.month &&
          event.startTime.day == _selectedDate.day;
    }).toList();

    dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dayEvents.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: AppTheme.spacing64),
                  Icon(
                    Icons.event_available,
                    size: isTablet ? 64 : 48,
                    color: AppTheme.textTertiary,
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Nta bikorwa ku munsi w\'uyu',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
                  ),
                ],
              ),
            )
          else
            ...dayEvents.map((event) => _buildEventCard(event, isTablet)).toList(),
        ],
      ),
    );
  }

  Widget _buildWeekView(bool isTablet) {
    return const Center(
      child: Text('Reba icyumweru - Izaza vuba...'),
    );
  }

  Widget _buildMonthView(bool isTablet) {
    return const Center(
      child: Text('Reba ukwezi - Izaza vuba...'),
    );
  }

  Widget _buildEventCard(ScheduleEvent event, bool isTablet) {
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
                    color: _getEventTypeColor(event.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getEventTypeIcon(event.type),
                    color: _getEventTypeColor(event.type),
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        event.type,
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
                    color: _getStatusColor(event.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    event.status,
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(event.status),
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
                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
            if (event.description.isNotEmpty) ...[
              SizedBox(height: AppTheme.spacing8),
              Text(
                event.description,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editEvent(event),
                    icon: const Icon(Icons.edit),
                    label: const Text('Hindura'),
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startEvent(event),
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
    ).animate().fadeIn().slideX();
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'Consultation':
        return AppTheme.primaryColor;
      case 'Administrative':
        return AppTheme.secondaryColor;
      case 'Group Session':
        return AppTheme.accentColor;
      case 'Training':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'Consultation':
        return Icons.medical_services;
      case 'Administrative':
        return Icons.description;
      case 'Group Session':
        return Icons.group;
      case 'Training':
        return Icons.school;
      default:
        return Icons.event;
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
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  void _editEvent(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hindura ${event.title} - Izaza vuba...')),
    );
  }

  void _startEvent(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tangira ${event.title} - Izaza vuba...')),
    );
  }
}

class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String? clientId;
  final String status;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.clientId,
    required this.status,
  });
}
