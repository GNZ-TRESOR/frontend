import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';
import 'contraception_method_selector.dart';
import 'emergency_contraception_screen.dart';

class ContraceptionManagementScreen extends StatefulWidget {
  const ContraceptionManagementScreen({super.key});

  @override
  State<ContraceptionManagementScreen> createState() =>
      _ContraceptionManagementScreenState();
}

class _ContraceptionManagementScreenState
    extends State<ContraceptionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ContraceptionMethod? _currentMethod;
  List<ContraceptionReminder> _reminders = [];
  List<ContraceptionHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContraceptionData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContraceptionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      _currentMethod = ContraceptionMethod(
        id: '1',
        type: ContraceptionType.pill,
        name: 'Combined Oral Contraceptive',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        effectiveness: 99.7,
        sideEffects: ['Nausea', 'Headache', 'Breast tenderness'],
        instructions: 'Take one pill daily at the same time',
        nextAppointment: DateTime.now().add(const Duration(days: 60)),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      _reminders = [
        ContraceptionReminder(
          id: '1',
          methodId: '1',
          type: ReminderType.dailyPill,
          time: TimeOfDay(hour: 8, minute: 0),
          isActive: true,
          message: 'Igihe cyo gufata imiti y\'kurinda inda',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ContraceptionReminder(
          id: '2',
          methodId: '1',
          type: ReminderType.appointment,
          scheduledDate: DateTime.now().add(const Duration(days: 60)),
          isActive: true,
          message: 'Gahunda y\'inama yo gukurikirana',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _history = [
        ContraceptionHistory(
          id: '1',
          methodType: ContraceptionType.pill,
          methodName: 'Combined Oral Contraceptive',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: null,
          reason: 'Family planning',
          effectiveness: 99.7,
          sideEffectsExperienced: ['Mild nausea'],
          satisfaction: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
      ];
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
    if (lowerCommand.contains('ihutirwa') ||
        lowerCommand.contains('emergency')) {
      _navigateToEmergencyContraception();
    } else if (lowerCommand.contains('guhindura') ||
        lowerCommand.contains('change')) {
      _changeMethod();
    } else if (lowerCommand.contains('ikwibutsa') ||
        lowerCommand.contains('reminder')) {
      _tabController.animateTo(1);
    } else if (lowerCommand.contains('amateka') ||
        lowerCommand.contains('history')) {
      _tabController.animateTo(3);
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
            _buildCurrentMethodCard(isTablet),
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
                    _buildRemindersTab(isTablet),
                    _buildEducationTab(isTablet),
                    _buildHistoryTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Ihutirwa" kugira ngo ugere ku kurinda inda mu ihutirwa, "Guhindura" kugira ngo uhindure uburyo, cyangwa "Ikwibutsa" kugira ngo ugere ku kwibutsa',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga kurinda inda',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: const Text('Gukumira inda'),
      actions: [
        IconButton(
          icon: const Icon(Icons.emergency_rounded),
          onPressed: _navigateToEmergencyContraception,
          tooltip: 'Kurinda inda mu ihutirwa',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'change_method':
                _changeMethod();
                break;
              case 'side_effects':
                _reportSideEffects();
                break;
              case 'effectiveness':
                _checkEffectiveness();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'change_method',
                  child: Text('Hindura uburyo'),
                ),
                const PopupMenuItem(
                  value: 'side_effects',
                  child: Text('Raporo ingaruka'),
                ),
                const PopupMenuItem(
                  value: 'effectiveness',
                  child: Text('Reba ubushobozi'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildCurrentMethodCard(bool isTablet) {
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
              _currentMethod != null
                  ? _buildMethodInfo(_currentMethod!, isTablet)
                  : _buildNoMethodCard(isTablet),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),
    );
  }

  Widget _buildMethodInfo(ContraceptionMethod method, bool isTablet) {
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
                _getMethodIcon(method.type),
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
                    method.name,
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Ubushobozi: ${method.effectiveness}%',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Watangiye: ${DateFormat('MMM d, y').format(method.startDate)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
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
                'Iminsi',
                '${DateTime.now().difference(method.startDate).inDays}',
                Icons.calendar_today_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Ubushobozi',
                '${method.effectiveness}%',
                Icons.shield_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Inama',
                method.nextAppointment != null
                    ? '${DateTime.now().difference(method.nextAppointment!).inDays.abs()} days'
                    : 'N/A',
                Icons.event_rounded,
                isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoMethodCard(bool isTablet) {
    return Column(
      children: [
        Icon(
          Icons.health_and_safety_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: isTablet ? 64 : 48,
        ),
        SizedBox(height: AppTheme.spacing16),
        Text(
          'Nta buryo bwo kurinda inda bukoresha',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 20 : 18,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          'Hitamo uburyo bukwiye bwo kurinda inda',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing24),
        ElevatedButton.icon(
          onPressed: _changeMethod,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Hitamo uburyo'),
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
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isTablet ? 12 : 10,
            ),
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
            Tab(text: 'Ikwibutsa'),
            Tab(text: 'Amasomo'),
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
          _buildSectionTitle('Amakuru y\'uburyo bukoresha', isTablet),
          SizedBox(height: AppTheme.spacing16),
          if (_currentMethod != null)
            _buildMethodDetailsCard(_currentMethod!, isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Ibikorwa byihuse', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildQuickActions(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Ubumenyi bw\'ingenzi', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildEducationalTips(isTablet),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _reminders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Ikwibutsa', isTablet),
                  ElevatedButton.icon(
                    onPressed: _addReminder,
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

        final reminder = _reminders[index - 1];
        return _buildReminderCard(reminder, isTablet);
      },
    );
  }

  Widget _buildEducationTab(bool isTablet) {
    final educationTopics = [
      'Uburyo bwo kurinda inda',
      'Ingaruka z\'imiti',
      'Gukoresha neza',
      'Igihe cyo guhindura uburyo',
      'Ibibazo bikunze kubaho',
    ];

    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: educationTopics.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Amasomo ku kurinda inda', isTablet),
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
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _history.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'Amateka y\'uburyo bwo kurinda inda',
                isTablet,
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final historyItem = _history[index - 1];
        return _buildHistoryCard(historyItem, isTablet);
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.headingMedium.copyWith(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMethodDetailsCard(ContraceptionMethod method, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amakuru y\'uburyo',
            style: AppTheme.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            'Ubwoko:',
            method.name,
            Icons.category_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing8),
          _buildInfoRow(
            'Ubushobozi:',
            '${method.effectiveness}%',
            Icons.shield_rounded,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing8),
          _buildInfoRow(
            'Amabwiriza:',
            method.instructions,
            Icons.info_rounded,
            isTablet,
          ),
          if (method.nextAppointment != null) ...[
            SizedBox(height: AppTheme.spacing8),
            _buildInfoRow(
              'Inama ikurikira:',
              DateFormat('MMM d, y').format(method.nextAppointment!),
              Icons.event_rounded,
              isTablet,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isTablet ? 16 : 14, color: AppTheme.primaryColor),
        SizedBox(width: AppTheme.spacing8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(flex: 3, child: Text(value, style: AppTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    final actions = [
      {
        'title': 'Hindura uburyo',
        'icon': Icons.swap_horiz_rounded,
        'color': AppTheme.primaryColor,
        'action': 'change',
      },
      {
        'title': 'Raporo ingaruka',
        'icon': Icons.report_rounded,
        'color': AppTheme.warningColor,
        'action': 'side_effects',
      },
      {
        'title': 'Shyiraho ikwibutsa',
        'icon': Icons.alarm_rounded,
        'color': AppTheme.accentColor,
        'action': 'reminder',
      },
      {
        'title': 'Inama y\'ihutirwa',
        'icon': Icons.emergency_rounded,
        'color': AppTheme.errorColor,
        'action': 'emergency',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: AppTheme.spacing12,
        mainAxisSpacing: AppTheme.spacing12,
        childAspectRatio: isTablet ? 1.2 : 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleQuickAction(action['action'] as String),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: isTablet ? 32 : 24,
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      action['title'] as String,
                      style: AppTheme.labelMedium.copyWith(
                        fontSize: isTablet ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationalTips(bool isTablet) {
    final tips = [
      'Koresha uburyo nk\'uko byasabwe kugira ngo bukore neza',
      'Reba umuganga niba ufite ibibazo cyangwa ingaruka',
      'Ntugire ubwoba gusaba inama ku buzima bwawe',
      'Menya igihe cyo guhindura uburyo',
    ];

    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: AppTheme.warningColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Inama z\'ingenzi',
                style: AppTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          ...tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTablet ? 6 : 4,
                    height: isTablet ? 6 : 4,
                    margin: EdgeInsets.only(
                      top: isTablet ? 8 : 6,
                      right: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
                    ),
                  ),
                  Expanded(child: Text(tip, style: AppTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ContraceptionReminder reminder, bool isTablet) {
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
      child: Row(
        children: [
          Icon(
            _getReminderIcon(reminder.type),
            color: AppTheme.primaryColor,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.message,
                  style: AppTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  _getReminderTimeText(reminder),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isActive,
            onChanged: (value) => _toggleReminder(reminder.id, value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
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
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
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

  Widget _buildHistoryCard(ContraceptionHistory historyItem, bool isTablet) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMethodIcon(historyItem.methodType),
                color: AppTheme.primaryColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  historyItem.methodName,
                  style: AppTheme.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color:
                      historyItem.endDate == null
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.spacing4),
                ),
                child: Text(
                  historyItem.endDate == null ? 'Akora' : 'Yahagaritswe',
                  style: AppTheme.bodySmall.copyWith(
                    color:
                        historyItem.endDate == null
                            ? AppTheme.successColor
                            : AppTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Watangiye: ${DateFormat('MMM d, y').format(historyItem.startDate)}',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          if (historyItem.endDate != null) ...[
            SizedBox(height: AppTheme.spacing4),
            Text(
              'Wahagaritse: ${DateFormat('MMM d, y').format(historyItem.endDate!)}',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
          SizedBox(height: AppTheme.spacing8),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppTheme.warningColor,
                size: isTablet ? 16 : 14,
              ),
              SizedBox(width: AppTheme.spacing4),
              Text(
                'Ubwoba: ${historyItem.satisfaction}/5',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getMethodIcon(ContraceptionType type) {
    switch (type) {
      case ContraceptionType.pill:
        return Icons.medication_rounded;
      case ContraceptionType.iud:
        return Icons.device_hub_rounded;
      case ContraceptionType.implant:
        return Icons.linear_scale_rounded;
      case ContraceptionType.injection:
        return Icons.vaccines_rounded;
      case ContraceptionType.patch:
        return Icons.square_rounded;
      case ContraceptionType.ring:
        return Icons.circle_rounded;
      case ContraceptionType.condom:
        return Icons.shield_rounded;
      case ContraceptionType.diaphragm:
        return Icons.circle_outlined;
      case ContraceptionType.spermicide:
        return Icons.water_drop_rounded;
      case ContraceptionType.naturalFamilyPlanning:
        return Icons.nature_rounded;
      case ContraceptionType.sterilization:
        return Icons.block_rounded;
      case ContraceptionType.emergency:
        return Icons.emergency_rounded;
    }
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.dailyPill:
        return Icons.medication_rounded;
      case ReminderType.weeklyPatch:
        return Icons.square_rounded;
      case ReminderType.monthlyRing:
        return Icons.circle_rounded;
      case ReminderType.quarterlyInjection:
        return Icons.vaccines_rounded;
      case ReminderType.appointment:
        return Icons.event_rounded;
      case ReminderType.refill:
        return Icons.refresh_rounded;
      case ReminderType.sideEffectCheck:
        return Icons.health_and_safety_rounded;
    }
  }

  String _getReminderTimeText(ContraceptionReminder reminder) {
    if (reminder.time != null) {
      return 'Buri munsi saa ${reminder.time!.hour}:${reminder.time!.minute.toString().padLeft(2, '0')}';
    } else if (reminder.scheduledDate != null) {
      return DateFormat('MMM d, y').format(reminder.scheduledDate!);
    }
    return 'Igihe kitazwi';
  }

  // Action methods
  void _navigateToEmergencyContraception() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmergencyContraceptionScreen(),
      ),
    );
  }

  void _changeMethod() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ContraceptionMethodSelector(
              currentMethod: _currentMethod,
              onMethodSelected: (method) {
                setState(() {
                  _currentMethod = method;
                });
              },
            ),
      ),
    );
  }

  void _reportSideEffects() {
    _showErrorSnackBar('Raporo ingaruka - Izaza vuba');
  }

  void _checkEffectiveness() {
    _showErrorSnackBar('Reba ubushobozi - Izaza vuba');
  }

  void _addReminder() {
    _showErrorSnackBar('Ongeraho ikwibutsa - Izaza vuba');
  }

  void _toggleReminder(String reminderId, bool isActive) {
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        // TODO: Update reminder status
      }
    });
  }

  void _openEducationTopic(String topic) {
    _showErrorSnackBar('$topic - Izaza vuba');
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'change':
        _changeMethod();
        break;
      case 'side_effects':
        _reportSideEffects();
        break;
      case 'reminder':
        _addReminder();
        break;
      case 'emergency':
        _navigateToEmergencyContraception();
        break;
    }
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
