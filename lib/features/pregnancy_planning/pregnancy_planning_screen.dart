import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';
import 'conception_planning_screen.dart';
import 'preconception_health_screen.dart';

class PregnancyPlanningScreen extends StatefulWidget {
  const PregnancyPlanningScreen({super.key});

  @override
  State<PregnancyPlanningScreen> createState() =>
      _PregnancyPlanningScreenState();
}

class _PregnancyPlanningScreenState extends State<PregnancyPlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PregnancyPlan? _currentPlan;
  List<PregnancyPlan> _planHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPregnancyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPregnancyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      _currentPlan = PregnancyPlan(
        id: '1',
        userId: 'current_user_id',
        targetConceptionDate: DateTime.now().add(const Duration(days: 365)),
        status: PregnancyPlanStatus.planning,
        preparationSteps: [
          'Gusuzuma ubuzima',
          'Gufata vitamini',
          'Guhindura imyitwarire',
          'Gutegura amafaranga',
        ],
        healthChecks: {
          'general_health': true,
          'dental_health': false,
          'vaccinations': true,
          'nutrition_assessment': false,
        },
        notes: 'Dushaka gutegura neza mbere yo gushaka inda',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      _planHistory = [_currentPlan!];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gahunda') || lowerCommand.contains('plan')) {
      _navigateToConceptionPlanning();
    } else if (lowerCommand.contains('ubuzima') ||
        lowerCommand.contains('health')) {
      _navigateToPreconceptionHealth();
    } else if (lowerCommand.contains('gushya') ||
        lowerCommand.contains('new')) {
      _createNewPlan();
    } else if (lowerCommand.contains('amateka') ||
        lowerCommand.contains('history')) {
      _tabController.animateTo(2);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
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
            _buildPlanStatusCard(isTablet),
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
                    _buildPreparationTab(isTablet),
                    _buildHistoryTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Gahunda" kugira ngo ugere ku gahunda, "Ubuzima" kugira ngo ugere ku buzima, cyangwa "Gushya" kugira ngo ukore gahunda nshya',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga gahunda y\'inda',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: const Text('Gahunda yo gushaka inda'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: _createNewPlan,
          tooltip: 'Gahunda nshya',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'conception_planning':
                _navigateToConceptionPlanning();
                break;
              case 'health_checks':
                _navigateToPreconceptionHealth();
                break;
              case 'fertility_tracking':
                _navigateToFertilityTracking();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'conception_planning',
                  child: Text('Gahunda yo gushaka inda'),
                ),
                const PopupMenuItem(
                  value: 'health_checks',
                  child: Text('Gusuzuma ubuzima'),
                ),
                const PopupMenuItem(
                  value: 'fertility_tracking',
                  child: Text('Gukurikirana ubushobozi'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildPlanStatusCard(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child:
              _currentPlan != null
                  ? _buildPlanInfo(_currentPlan!, isTablet)
                  : _buildNoPlanCard(isTablet),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),
    );
  }

  Widget _buildPlanInfo(PregnancyPlan plan, bool isTablet) {
    final daysUntilTarget =
        plan.targetConceptionDate.difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Icon(
                Icons.pregnant_woman_rounded,
                color: Colors.white,
                size: isTablet ? 32 : 24,
              ),
            ),
            SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gahunda yo gushaka inda',
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Intego: ${DateFormat('MMM d, y').format(plan.targetConceptionDate)}',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        plan.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.spacing4),
                    ),
                    child: Text(
                      _getStatusLabel(plan.status),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing24),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Iminsi isigaye',
                daysUntilTarget > 0 ? '$daysUntilTarget' : 'Yarangiye',
                Icons.calendar_today_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Intambwe',
                '${plan.preparationSteps.length}',
                Icons.check_box_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Ubuzima',
                '${plan.healthChecks.values.where((v) => v).length}/${plan.healthChecks.length}',
                Icons.health_and_safety_rounded,
                isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoPlanCard(bool isTablet) {
    return Column(
      children: [
        Icon(
          Icons.pregnant_woman_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: isTablet ? 64 : 48,
        ),
        SizedBox(height: AppTheme.spacing16),
        Text(
          'Nta gahunda yo gushaka inda',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 20 : 18,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          'Kora gahunda yo gushaka inda kugira ngo utegure neza',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing24),
        ElevatedButton.icon(
          onPressed: _createNewPlan,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Kora gahunda'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
              vertical: isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
          SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isTablet ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 14 : 12,
          ),
          unselectedLabelStyle: AppTheme.labelMedium.copyWith(
            fontSize: isTablet ? 14 : 12,
          ),
          tabs: const [
            Tab(text: 'Incamake'),
            Tab(text: 'Gutegura'),
            Tab(text: 'Amateka'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ibikorwa byihuse', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildQuickActions(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Uko bigenda', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildProgressCard(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Inama z\'ingenzi', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPregnancyTips(isTablet),
        ],
      ),
    );
  }

  Widget _buildPreparationTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Intambwe zo gutegura', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPreparationSteps(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Gusuzuma ubuzima', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildHealthChecks(isTablet),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _planHistory.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Amateka y\'amahugurwa', isTablet),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final plan = _planHistory[index - 1];
        return _buildPlanHistoryCard(plan, isTablet);
      },
    );
  }

  // Helper methods and widgets would continue here...
  // Due to length constraints, I'll create the remaining methods as placeholders

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.headingMedium.copyWith(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getStatusColor(PregnancyPlanStatus status) {
    switch (status) {
      case PregnancyPlanStatus.planning:
        return AppTheme.infoColor;
      case PregnancyPlanStatus.trying:
        return AppTheme.warningColor;
      case PregnancyPlanStatus.conceived:
        return AppTheme.successColor;
      case PregnancyPlanStatus.postponed:
        return AppTheme.textSecondary;
      case PregnancyPlanStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  String _getStatusLabel(PregnancyPlanStatus status) {
    switch (status) {
      case PregnancyPlanStatus.planning:
        return 'Gutegura';
      case PregnancyPlanStatus.trying:
        return 'Gushaka';
      case PregnancyPlanStatus.conceived:
        return 'Yabonetse';
      case PregnancyPlanStatus.postponed:
        return 'Yahagaritswe';
      case PregnancyPlanStatus.cancelled:
        return 'Yahagaritswe burundu';
    }
  }

  // Action methods
  void _navigateToConceptionPlanning() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ConceptionPlanningScreen()),
    );
  }

  void _navigateToPreconceptionHealth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PreconceptionHealthScreen(),
      ),
    );
  }

  void _navigateToFertilityTracking() {
    _showErrorSnackBar('Gukurikirana ubushobozi - Izaza vuba');
  }

  void _createNewPlan() {
    _showErrorSnackBar('Gahunda nshya - Izaza vuba');
  }

  // Placeholder methods for remaining widgets
  Widget _buildQuickActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Ibikorwa byihuse...'),
    );
  }

  Widget _buildProgressCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Uko bigenda...'),
    );
  }

  Widget _buildPregnancyTips(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Inama z\'ingenzi...'),
    );
  }

  Widget _buildPreparationSteps(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Intambwe zo gutegura...'),
    );
  }

  Widget _buildHealthChecks(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Gusuzuma ubuzima...'),
    );
  }

  Widget _buildPlanHistoryCard(PregnancyPlan plan, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Gahunda: ${DateFormat('MMM d, y').format(plan.createdAt)}'),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
