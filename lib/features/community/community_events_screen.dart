import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class CommunityEventsScreen extends StatefulWidget {
  const CommunityEventsScreen({super.key});

  @override
  State<CommunityEventsScreen> createState() => _CommunityEventsScreenState();
}

class _CommunityEventsScreenState extends State<CommunityEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<CommunityEvent> _events = [
    CommunityEvent(
      id: '1',
      title: 'Amasomo y\'ubwiyunge ku bagore',
      description: 'Amasomo y\'ubwiyunge ku bagore bo mu karere ka Gasabo',
      category: 'Education',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Kigali Health Center',
      organizer: 'Dr. Marie Uwimana',
      maxParticipants: 50,
      currentParticipants: 23,
      isOnline: false,
      isFree: true,
      imageUrl: 'assets/images/women_education.jpg',
      tags: ['Ubwiyunge', 'Abagore', 'Amasomo'],
    ),
    CommunityEvent(
      id: '2',
      title: 'Ikiganiro cy\'urubyiruko',
      description: 'Ikiganiro ku buzima bw\'urubyiruko n\'imyitwarire myiza',
      category: 'Discussion',
      date: DateTime.now().add(const Duration(days: 3)),
      location: 'Online - Zoom',
      organizer: 'Youth Health Rwanda',
      maxParticipants: 100,
      currentParticipants: 67,
      isOnline: true,
      isFree: true,
      imageUrl: 'assets/images/youth_discussion.jpg',
      tags: ['Urubyiruko', 'Ikiganiro', 'Online'],
    ),
    CommunityEvent(
      id: '3',
      title: 'Isuzuma ry\'ubuzima',
      description: 'Isuzuma ry\'ubuzima bw\'imyororokere ku buntu',
      category: 'Health Screening',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'Nyamirambo Health Center',
      organizer: 'Ministry of Health',
      maxParticipants: 200,
      currentParticipants: 145,
      isOnline: false,
      isFree: true,
      imageUrl: 'assets/images/health_screening.jpg',
      tags: ['Isuzuma', 'Ubuzima', 'Ku buntu'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka ibirori');
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
    if (lowerCommand.contains('kwiyandikisha') || lowerCommand.contains('register')) {
      // Register for first available event
      if (_events.isNotEmpty) {
        _registerForEvent(_events.first);
      }
    } else if (lowerCommand.contains('kurema') || lowerCommand.contains('create')) {
      _showCreateEventDialog();
    } else if (lowerCommand.contains('reba') || lowerCommand.contains('view')) {
      // View first event
      if (_events.isNotEmpty) {
        _viewEventDetails(_events.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ibirori by\'umuryango'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildFilterSection(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingEventsTab(isTablet),
                  _buildMyEventsTab(isTablet),
                  _buildPastEventsTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'create_event',
            onPressed: _showCreateEventDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Kwiyandikisha" kugira ngo wiyandikishe, "Kurema" kugira ngo ureme ikirori, cyangwa "Reba" kugira ngo urebe ikirori',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga ibirori',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: AppTheme.softShadow,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'all',
              'Education',
              'Discussion',
              'Health Screening',
              'Workshop'
            ].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Container(
                margin: EdgeInsets.only(right: AppTheme.spacing8),
                child: FilterChip(
                  label: Text(_getFilterLabel(filter)),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedFilter = filter),
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              );
            }).toList(),
          ),
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
          Tab(text: 'Bizaza', icon: Icon(Icons.upcoming)),
          Tab(text: 'Ibyanjye', icon: Icon(Icons.person)),
          Tab(text: 'Byarangiye', icon: Icon(Icons.history)),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsTab(bool isTablet) {
    return _buildEventsList(isTablet, upcoming: true);
  }

  Widget _buildMyEventsTab(bool isTablet) {
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
            'Ntabwo wiyandikishije ku birori',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
          ),
          SizedBox(height: AppTheme.spacing8),
          TextButton(
            onPressed: () => _tabController.animateTo(0),
            child: const Text('Reba ibirori bizaza'),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventsTab(bool isTablet) {
    return _buildEventsList(isTablet, upcoming: false);
  }

  Widget _buildEventsList(bool isTablet, {required bool upcoming}) {
    final now = DateTime.now();
    final filteredEvents = _events.where((event) {
      final matchesFilter = _selectedFilter == 'all' || event.category == _selectedFilter;
      final matchesTime = upcoming ? event.date.isAfter(now) : event.date.isBefore(now);
      return matchesFilter && matchesTime;
    }).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              upcoming ? 'Nta birori bizaza' : 'Nta birori byarangiye',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
            if (upcoming) ...[
              SizedBox(height: AppTheme.spacing8),
              TextButton(
                onPressed: _showCreateEventDialog,
                child: const Text('Rema ikirori'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventCard(event, isTablet, index);
      },
    );
  }

  Widget _buildEventCard(CommunityEvent event, bool isTablet, int index) {
    final isUpcoming = event.date.isAfter(DateTime.now());
    final spotsLeft = event.maxParticipants - event.currentParticipants;

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: InkWell(
        onTap: () => _viewEventDetails(event),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                      color: _getCategoryColor(event.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      _getCategoryIcon(event.category),
                      color: _getCategoryColor(event.category),
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
                          event.category,
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  if (event.isFree)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        'Ku buntu',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppTheme.spacing12),
              Text(
                event.description,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.textTertiary),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    _formatDate(event.date),
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                  ),
                  SizedBox(width: AppTheme.spacing16),
                  Icon(
                    event.isOnline ? Icons.computer : Icons.location_on,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppTheme.textTertiary),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    event.organizer,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                  ),
                  const Spacer(),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants}',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing12),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing4,
                children: event.tags.take(3).map((tag) => Chip(
                  label: Text(
                    tag,
                    style: AppTheme.bodySmall,
                  ),
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                )).toList(),
              ),
              if (isUpcoming) ...[
                SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewEventDetails(event),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Reba'),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: spotsLeft > 0 ? () => _registerForEvent(event) : null,
                        icon: const Icon(Icons.event_available),
                        label: Text(spotsLeft > 0 ? 'Iyandikishe' : 'Byuzuye'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Byose';
      case 'Education':
        return 'Amasomo';
      case 'Discussion':
        return 'Ibiganiro';
      case 'Health Screening':
        return 'Isuzuma';
      case 'Workshop':
        return 'Amahugurwa';
      default:
        return filter;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Education':
        return AppTheme.primaryColor;
      case 'Discussion':
        return AppTheme.secondaryColor;
      case 'Health Screening':
        return AppTheme.accentColor;
      case 'Workshop':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Education':
        return Icons.school;
      case 'Discussion':
        return Icons.forum;
      case 'Health Screening':
        return Icons.health_and_safety;
      case 'Workshop':
        return Icons.build;
      default:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Uyu munsi';
    } else if (difference == 1) {
      return 'Ejo';
    } else if (difference > 0) {
      return 'Mu minsi $difference';
    } else {
      return 'Byarangiye';
    }
  }

  void _viewEventDetails(CommunityEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.description),
              SizedBox(height: AppTheme.spacing16),
              Text('Itariki: ${_formatDate(event.date)}'),
              Text('Aho: ${event.location}'),
              Text('Uwateguye: ${event.organizer}'),
              Text('Abanyamuryango: ${event.currentParticipants}/${event.maxParticipants}'),
              Text('Ubwoko: ${event.isOnline ? 'Online' : 'Ku kibanza'}'),
              Text('Igiciro: ${event.isFree ? 'Ku buntu' : 'Kwishyura'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          if (event.date.isAfter(DateTime.now()) && 
              event.currentParticipants < event.maxParticipants)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _registerForEvent(event);
              },
              child: const Text('Iyandikishe'),
            ),
        ],
      ),
    );
  }

  void _registerForEvent(CommunityEvent event) {
    if (event.currentParticipants >= event.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ikirori cyuzuye!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kwiyandikisha ku kirori'),
        content: Text('Urashaka kwiyandikisha ku kirori "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wiyandikishije ku ${event.title}!')),
              );
            },
            child: const Text('Emeza'),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurema ikirori'),
        content: const Text('Iyi fonctionnalité izaza vuba. Uzashobora kurema ibirori byawe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }
}

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String location;
  final String organizer;
  final int maxParticipants;
  final int currentParticipants;
  final bool isOnline;
  final bool isFree;
  final String imageUrl;
  final List<String> tags;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
    required this.organizer,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isOnline,
    required this.isFree,
    required this.imageUrl,
    required this.tags,
  });
}
