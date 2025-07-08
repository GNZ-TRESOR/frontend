import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class HealthReportsScreen extends StatefulWidget {
  const HealthReportsScreen({super.key});

  @override
  State<HealthReportsScreen> createState() => _HealthReportsScreenState();
}

class _HealthReportsScreenState extends State<HealthReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedPeriod = 'month';

  final List<ReportMetric> _metrics = [
    ReportMetric(
      title: 'Abakiriya bashya',
      value: '1,234',
      change: '+12%',
      isPositive: true,
      icon: Icons.person_add,
      color: AppTheme.primaryColor,
    ),
    ReportMetric(
      title: 'Inama zakoze',
      value: '856',
      change: '+8%',
      isPositive: true,
      icon: Icons.medical_services,
      color: AppTheme.secondaryColor,
    ),
    ReportMetric(
      title: 'Kurinda inda',
      value: '92%',
      change: '+3%',
      isPositive: true,
      icon: Icons.health_and_safety,
      color: AppTheme.accentColor,
    ),
    ReportMetric(
      title: 'Kwishyura',
      value: '78%',
      change: '-2%',
      isPositive: false,
      icon: Icons.trending_down,
      color: AppTheme.warningColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka raporo');
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
    if (lowerCommand.contains('raporo') || lowerCommand.contains('report')) {
      // Handle report commands
    } else if (lowerCommand.contains('gusohora') ||
        lowerCommand.contains('export')) {
      _exportReport();
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gusohora raporo - Izaza vuba...')),
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
            _buildMetricsOverview(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isTablet),
                    _buildFamilyPlanningTab(isTablet),
                    _buildFacilitiesTab(isTablet),
                    _buildFinancialTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'export_report',
            onPressed: _exportReport,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.download, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt:
                'Vuga: "Raporo" kugira ngo ugere ku raporo, cyangwa "Gusohora" kugira ngo usohore raporo',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga raporo',
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
          'Raporo z\'ubuzima',
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.date_range),
          onSelected: (value) => setState(() => _selectedPeriod = value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'week', child: Text('Icyumweru')),
                const PopupMenuItem(value: 'month', child: Text('Ukwezi')),
                const PopupMenuItem(value: 'quarter', child: Text('Igihembwe')),
                const PopupMenuItem(value: 'year', child: Text('Umwaka')),
              ],
        ),
      ],
    );
  }

  Widget _buildMetricsOverview(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: isTablet ? 1.2 : 1.5,
          ),
          itemCount: _metrics.length,
          itemBuilder: (context, index) {
            final metric = _metrics[index];
            return _buildMetricCard(
              metric,
              isTablet,
            ).animate(delay: (index * 100).ms).fadeIn().scale();
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(ReportMetric metric, bool isTablet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  metric.icon,
                  color: metric.color,
                  size: isTablet ? 32 : 24,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        metric.isPositive
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    metric.change,
                    style: AppTheme.bodySmall.copyWith(
                      color:
                          metric.isPositive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: metric.color,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              metric.title,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
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
        isScrollable: true,
        tabs: const [
          Tab(text: 'Rusange', icon: Icon(Icons.dashboard)),
          Tab(text: 'Kurinda inda', icon: Icon(Icons.medical_services)),
          Tab(text: 'Amavuriro', icon: Icon(Icons.domain)),
          Tab(text: 'Amafaranga', icon: Icon(Icons.attach_money)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incamake y\'igihe ${_getPeriodText()}',
            style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Abakiriya bashya buri munsi', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Serivisi zikoreshwa cyane', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildRecentActivities(isTablet),
        ],
      ),
    );
  }

  Widget _buildFamilyPlanningTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
      ),
      child: Column(
        children: [
          _buildChartPlaceholder(
            'Uburyo bwo kurinda inda bukoreshwa',
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Ubwishyure bw\'abakiriya', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Inama zakoze', isTablet),
        ],
      ),
    );
  }

  Widget _buildFacilitiesTab(bool isTablet) {
    return const Center(child: Text('Raporo z\'amavuriro - Izaza vuba...'));
  }

  Widget _buildFinancialTab(bool isTablet) {
    return const Center(child: Text('Raporo z\'amafaranga - Izaza vuba...'));
  }

  Widget _buildChartPlaceholder(String title, bool isTablet) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppTheme.spacing16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Igishushanyo - Izaza vuba...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isTablet) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ibikorwa bya vuba',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppTheme.spacing16),
            ...List.generate(5, (index) => _buildActivityItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      'Umukiriya mushya yiyandikishije',
      'Inama y\'kurinda inda yarangiye',
      'Raporo y\'ukwezi yasohotse',
      'Umukozi mushya yongerewe',
      'Ikigo gishya cyafunguwe',
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              '${index + 1}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(child: Text(activities[index % activities.length])),
          Text(
            '${index + 1}h',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'week':
        return 'cy\'icyumweru';
      case 'month':
        return 'cy\'ukwezi';
      case 'quarter':
        return 'cy\'igihembwe';
      case 'year':
        return 'cy\'umwaka';
      default:
        return 'cy\'ukwezi';
    }
  }
}

class ReportMetric {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  ReportMetric({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}
