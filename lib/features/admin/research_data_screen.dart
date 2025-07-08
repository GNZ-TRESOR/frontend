import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class ResearchDataScreen extends StatefulWidget {
  const ResearchDataScreen({super.key});

  @override
  State<ResearchDataScreen> createState() => _ResearchDataScreenState();
}

class _ResearchDataScreenState extends State<ResearchDataScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedPeriod = 'month';

  final List<ResearchMetric> _metrics = [
    ResearchMetric(
      title: 'Abakiriya bose',
      value: '12,456',
      change: '+8.2%',
      isPositive: true,
      icon: Icons.people,
      color: AppTheme.primaryColor,
    ),
    ResearchMetric(
      title: 'Inama zakoze',
      value: '3,789',
      change: '+12.5%',
      isPositive: true,
      icon: Icons.medical_services,
      color: AppTheme.secondaryColor,
    ),
    ResearchMetric(
      title: 'Ubwishyure',
      value: '89.3%',
      change: '+2.1%',
      isPositive: true,
      icon: Icons.trending_up,
      color: AppTheme.successColor,
    ),
    ResearchMetric(
      title: 'Kwishyura',
      value: '76.8%',
      change: '-1.2%',
      isPositive: false,
      icon: Icons.trending_down,
      color: AppTheme.warningColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadResearchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResearchData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru y\'ubushakashatsi');
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
    if (lowerCommand.contains('gusohora') || lowerCommand.contains('export')) {
      _exportData();
    } else if (lowerCommand.contains('raporo') ||
        lowerCommand.contains('report')) {
      _generateReport();
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gusohora amakuru - Izaza vuba...')),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gukora raporo - Izaza vuba...')),
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
                    _buildDemographicsTab(isTablet),
                    _buildTrendsTab(isTablet),
                    _buildInsightsTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'export_data',
            onPressed: _exportData,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.download, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt:
                'Vuga: "Gusohora" kugira ngo usohore amakuru, cyangwa "Raporo" kugira ngo ukore raporo',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga ubushakashatsi',
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
          'Ubushakashatsi',
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

  Widget _buildMetricCard(ResearchMetric metric, bool isTablet) {
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
          Tab(text: 'Abaturage', icon: Icon(Icons.people)),
          Tab(text: 'Imyitwarire', icon: Icon(Icons.trending_up)),
          Tab(text: 'Ubwenge', icon: Icon(Icons.lightbulb)),
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
            'Incamake y\'ubushakashatsi',
            style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Abakiriya bashya buri munsi', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Serivisi zikoreshwa cyane', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildDataTable(isTablet),
        ],
      ),
    );
  }

  Widget _buildDemographicsTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
      ),
      child: Column(
        children: [
          _buildChartPlaceholder('Imyaka y\'abakiriya', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Igitsina cy\'abakiriya', isTablet),
          SizedBox(height: AppTheme.spacing24),
          _buildChartPlaceholder('Ahantu batuye', isTablet),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(bool isTablet) {
    return const Center(
      child: Text('Imyitwarire y\'abakiriya - Izaza vuba...'),
    );
  }

  Widget _buildInsightsTab(bool isTablet) {
    return const Center(child: Text('Ubwenge bw\'amakuru - Izaza vuba...'));
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

  Widget _buildDataTable(bool isTablet) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amakuru y\'ibanze',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppTheme.spacing16),
            Table(
              border: TableBorder.all(color: AppTheme.borderColor),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: AppTheme.surfaceColor),
                  children: [
                    _buildTableCell('Igice', isHeader: true),
                    _buildTableCell('Umubare', isHeader: true),
                    _buildTableCell('Ijanisha', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Abakiriya bashya'),
                    _buildTableCell('1,234'),
                    _buildTableCell('+12%', color: AppTheme.successColor),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Inama zakoze'),
                    _buildTableCell('856'),
                    _buildTableCell('+8%', color: AppTheme.successColor),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Kwishyura'),
                    _buildTableCell('78%'),
                    _buildTableCell('-2%', color: AppTheme.errorColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacing12),
      child: Text(
        text,
        style:
            isHeader
                ? AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTheme.bodyMedium.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ResearchMetric {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  ResearchMetric({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}
