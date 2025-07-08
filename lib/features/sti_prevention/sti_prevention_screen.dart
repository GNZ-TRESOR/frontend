import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';
import 'sti_testing_screen.dart';
import 'sti_education_screen.dart';
import 'risk_assessment_screen.dart';

class STIPreventionScreen extends StatefulWidget {
  const STIPreventionScreen({super.key});

  @override
  State<STIPreventionScreen> createState() => _STIPreventionScreenState();
}

class _STIPreventionScreenState extends State<STIPreventionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<STIPreventionRecord> _testRecords = [];
  DateTime? _lastTestDate;
  DateTime? _nextTestDate;
  String _riskLevel = 'low';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSTIData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSTIData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
      
      _testRecords = [
        STIPreventionRecord(
          id: '1',
          userId: 'current_user_id',
          testDate: DateTime.now().subtract(const Duration(days: 90)),
          testType: STITestType.routine,
          result: STITestResult.negative,
          testedFor: ['HIV', 'Syphilis', 'Gonorrhea', 'Chlamydia'],
          notes: 'Routine testing - all negative',
          nextTestDate: DateTime.now().add(const Duration(days: 90)),
          isConfidential: true,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        ),
      ];

      _lastTestDate = _testRecords.isNotEmpty ? _testRecords.first.testDate : null;
      _nextTestDate = _testRecords.isNotEmpty ? _testRecords.first.nextTestDate : null;
      _riskLevel = 'low'; // TODO: Calculate based on risk assessment
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
    if (lowerCommand.contains('isuzuma') || lowerCommand.contains('test')) {
      _navigateToTesting();
    } else if (lowerCommand.contains('amasomo') || lowerCommand.contains('education')) {
      _navigateToEducation();
    } else if (lowerCommand.contains('ibyago') || lowerCommand.contains('risk')) {
      _navigateToRiskAssessment();
    } else if (lowerCommand.contains('amateka') || lowerCommand.contains('history')) {
      _tabController.animateTo(3);
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
            _buildStatusCard(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(isTablet),
                  _buildPreventionTab(isTablet),
                  _buildEducationTab(isTablet),
                  _buildHistoryTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Isuzuma" kugira ngo ugere ku isuzuma, "Amasomo" kugira ngo ugere ku masomo, cyangwa "Ibyago" kugira ngo ugere ku byago',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga kurinda indwara',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: const Text('Kurinda indwara zandurira'),
      actions: [
        IconButton(
          icon: const Icon(Icons.medical_services_rounded),
          onPressed: _navigateToTesting,
          tooltip: 'Isuzuma',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'schedule_test':
                _scheduleTest();
                break;
              case 'risk_assessment':
                _navigateToRiskAssessment();
                break;
              case 'education':
                _navigateToEducation();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'schedule_test',
              child: Text('Shyiraho isuzuma'),
            ),
            const PopupMenuItem(
              value: 'risk_assessment',
              child: Text('Suzuma ibyago'),
            ),
            const PopupMenuItem(
              value: 'education',
              child: Text('Amasomo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool isTablet) {
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
          padding: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    child: Icon(
                      Icons.health_and_safety_rounded,
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
                          'Ubuzima bw\'indwara zandurira',
                          style: AppTheme.headingLarge.copyWith(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Urwego rw\'ibyago: ${_getRiskLevelLabel(_riskLevel)}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
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
                      'Isuzuma rya nyuma',
                      _lastTestDate != null 
                          ? DateFormat('MMM d, y').format(_lastTestDate!)
                          : 'Nta na rimwe',
                      Icons.history_rounded,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildInfoCard(
                      'Isuzuma rikurikira',
                      _nextTestDate != null 
                          ? DateFormat('MMM d, y').format(_nextTestDate!)
                          : 'Ntishyizweho',
                      Icons.schedule_rounded,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildInfoCard(
                      'Ibyago',
                      _getRiskLevelLabel(_riskLevel),
                      Icons.warning_rounded,
                      isTablet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(
        begin: 0.3,
        duration: 600.ms,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isTablet ? 10 : 8,
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
            Tab(text: 'Kurinda'),
            Tab(text: 'Amasomo'),
            Tab(text: 'Amateka'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ibikorwa byihuse', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildQuickActions(isTablet),
          
          SizedBox(height: AppTheme.spacing24),
          
          _buildSectionTitle('Isuzuma riheruka', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildLastTestCard(isTablet),
          
          SizedBox(height: AppTheme.spacing24),
          
          _buildSectionTitle('Inama z\'ingenzi', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPreventionTips(isTablet),
        ],
      ),
    );
  }

  Widget _buildPreventionTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Uburyo bwo kwirinda', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPreventionMethods(isTablet),
          
          SizedBox(height: AppTheme.spacing24),
          
          _buildSectionTitle('Suzuma ibyago', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildRiskAssessmentCard(isTablet),
          
          SizedBox(height: AppTheme.spacing24),
          
          _buildSectionTitle('Gahunda y\'isuzuma', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildTestingSchedule(isTablet),
        ],
      ),
    );
  }

  Widget _buildEducationTab(bool isTablet) {
    final educationTopics = [
      'Indwara zandurira mu mibonano - ibanze',
      'Uburyo bwo kwirinda indwara',
      'Ibimenyetso by\'indwara zandurira',
      'Isuzuma n\'ubuvuzi',
      'Ubuzima bw\'abagore n\'abagabo',
    ];

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      itemCount: educationTopics.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Amasomo ku indwara zandurira', isTablet),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }
        
        final topic = educationTopics[index - 1];
        return _buildEducationCard(topic, isTablet);
      },
    );
  }

  Widget _buildHistoryTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      itemCount: _testRecords.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Amateka y\'isuzuma', isTablet),
                  ElevatedButton.icon(
                    onPressed: _navigateToTesting,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Ongeraho'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }
        
        final record = _testRecords[index - 1];
        return _buildTestRecordCard(record, isTablet);
      },
    );
  }

  // Helper methods and widgets would continue here...
  // Due to length constraints, I'll create the remaining methods in the next part

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.headingMedium.copyWith(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getRiskLevelLabel(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'Bike';
      case 'medium':
        return 'Hagati';
      case 'high':
        return 'Byinshi';
      default:
        return 'Bitazwi';
    }
  }

  // Action methods
  void _navigateToTesting() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const STITestingScreen(),
      ),
    );
  }

  void _navigateToEducation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const STIEducationScreen(),
      ),
    );
  }

  void _navigateToRiskAssessment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RiskAssessmentScreen(),
      ),
    );
  }

  void _scheduleTest() {
    _showErrorSnackBar('Shyiraho isuzuma - Izaza vuba');
  }

  // Placeholder methods for remaining widgets
  Widget _buildQuickActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Ibikorwa byihuse...'),
    );
  }

  Widget _buildLastTestCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Isuzuma riheruka...'),
    );
  }

  Widget _buildPreventionTips(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Inama z\'ingenzi...'),
    );
  }

  Widget _buildPreventionMethods(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Uburyo bwo kwirinda...'),
    );
  }

  Widget _buildRiskAssessmentCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Suzuma ibyago...'),
    );
  }

  Widget _buildTestingSchedule(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Gahunda y\'isuzuma...'),
    );
  }

  Widget _buildEducationCard(String topic, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEducationTopic(topic),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AppTheme.accentColor,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    topic,
                    style: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textTertiary,
                  size: isTablet ? 16 : 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestRecordCard(STIPreventionRecord record, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Isuzuma: ${DateFormat('MMM d, y').format(record.testDate)}'),
    );
  }

  void _openEducationTopic(String topic) {
    _showErrorSnackBar('$topic - Izaza vuba');
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
