import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/audio_content_service.dart';
import '../../core/services/health_tracking_service.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/ai_assistant_fab.dart';
import '../../core/models/health_record_model.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  int _selectedTab = 0;
  final DateTime _selectedDate = DateTime.now();
  final HealthTrackingService _healthService = HealthTrackingService();

  List<HealthRecord> _healthRecords = [];
  Map<String, dynamic>? _healthStatistics;
  Map<String, dynamic>? _currentCycle;
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;

  final List<String> _tabs = ['Imihango', 'Ubuzima', 'Imiti', 'Raporo'];

  // Sample cycle data
  final List<CycleDay> _cycleData = [
    CycleDay(
      date: DateTime.now().subtract(const Duration(days: 28)),
      type: CycleDayType.period,
      flow: FlowLevel.heavy,
    ),
    CycleDay(
      date: DateTime.now().subtract(const Duration(days: 27)),
      type: CycleDayType.period,
      flow: FlowLevel.heavy,
    ),
    CycleDay(
      date: DateTime.now().subtract(const Duration(days: 26)),
      type: CycleDayType.period,
      flow: FlowLevel.medium,
    ),
    CycleDay(
      date: DateTime.now().subtract(const Duration(days: 25)),
      type: CycleDayType.period,
      flow: FlowLevel.light,
    ),
    CycleDay(
      date: DateTime.now().subtract(const Duration(days: 14)),
      type: CycleDayType.ovulation,
    ),
    CycleDay(date: DateTime.now(), type: CycleDayType.today),
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load health records
      _healthRecords = await _healthService.getHealthRecords(limit: 50);

      // Load health statistics
      _healthStatistics = await _healthService.getHealthStatistics();

      // Load current cycle
      _currentCycle = await _healthService.getCurrentCycle();

      // Load medications
      _medications = await _healthService.getMedications();
    } catch (e) {
      print('Error loading health data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('imihango') || lowerCommand.contains('cycle')) {
      setState(() {
        _selectedTab = 0;
      });
    } else if (lowerCommand.contains('ubuzima') ||
        lowerCommand.contains('health')) {
      setState(() {
        _selectedTab = 1;
      });
    } else if (lowerCommand.contains('imiti') ||
        lowerCommand.contains('medication')) {
      setState(() {
        _selectedTab = 2;
      });
    } else if (lowerCommand.contains('raporo') ||
        lowerCommand.contains('report')) {
      setState(() {
        _selectedTab = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildAppBar(isTablet),

          // Tab Navigation
          SliverToBoxAdapter(child: _buildTabNavigation(isTablet)),

          // Tab Content
          SliverToBoxAdapter(child: _buildTabContent(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: const AIAssistantFAB(
        contextualPrompt: 'Baza ibibazo ku buzima bw\'ababyeyi',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 200 : 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.secondaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 30 : 25,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gukurikirana Ubuzima',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 24,
                              ),
                            ),
                            Text(
                              'Koresha ubuzima bwawe buri munsi',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical:
                        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    _tabs[index],
                    style: AppTheme.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildTabContent(bool isTablet) {
    switch (_selectedTab) {
      case 0:
        return _buildCycleTracking(isTablet);
      case 1:
        return _buildHealthMetrics(isTablet);
      case 2:
        return _buildMedicationTracking(isTablet);
      case 3:
        return _buildReports(isTablet);
      default:
        return _buildCycleTracking(isTablet);
    }
  }

  Widget _buildCycleTracking(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle Overview Card
          Container(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Umunsi wa 14',
                          style: AppTheme.headingLarge.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        Text(
                          'mu mihango yawe',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: isTablet ? 80 : 70,
                      height: isTablet ? 80 : 70,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 40 : 35),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 14 / 28,
                            strokeWidth: 4,
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '50%',
                            style: AppTheme.labelLarge.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCycleInfo(
                        'Imihango ishize',
                        '14 iminsi',
                        Icons.calendar_today_rounded,
                        AppTheme.primaryColor,
                        isTablet,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: _buildCycleInfo(
                        'Imihango itaha',
                        '14 iminsi',
                        Icons.schedule_rounded,
                        AppTheme.secondaryColor,
                        isTablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.spacing24),

          // Calendar View
          Text(
            'Kalindari y\'imihango',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),

          Container(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                // Month Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {},
                    ),
                    Text(
                      'Ukwakira 2024',
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {},
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing16),

                // Calendar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 35,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isToday = day == DateTime.now().day;
                    final isPeriod = [1, 2, 3, 4].contains(day);
                    final isOvulation = day == 14;

                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? AppTheme.primaryColor
                                : isPeriod
                                ? AppTheme.errorColor.withValues(alpha: 0.2)
                                : isOvulation
                                ? AppTheme.successColor.withValues(alpha: 0.2)
                                : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          day <= 31 ? '$day' : '',
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                isToday ? Colors.white : AppTheme.textPrimary,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: AppTheme.spacing16),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('Imihango', AppTheme.errorColor, isTablet),
                    _buildLegendItem('Gusama', AppTheme.successColor, isTablet),
                    _buildLegendItem(
                      'Uyu munsi',
                      AppTheme.primaryColor,
                      isTablet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildCycleInfo(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 24 : 20),
          SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: AppTheme.spacing4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHealthMetrics(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Metrics Overview
          Text(
            'Ubuzima bwawe',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),

          // Quick Add Health Data Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    'Ongeraho amakuru y\'ubuzima',
                    style: AppTheme.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
                VoiceButton(
                  prompt:
                      'Vuga amakuru y\'ubuzima wawe - urugero: "Ibiro byanjye ni 65 kg"',
                  onResult: _handleHealthDataVoiceInput,
                  tooltip: 'Koresha ijwi kongeraho amakuru y\'ubuzima',
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing24),

          // Health Metrics Cards
          _buildMetricCard(
            'Umuvuduko w\'umutima',
            '72 bpm',
            'Mwiza',
            Icons.favorite_rounded,
            AppTheme.errorColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildMetricCard(
            'Ibiro',
            '65 kg',
            'Bisanzwe',
            Icons.monitor_weight_rounded,
            AppTheme.primaryColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildMetricCard(
            'Umuvuduko w\'amaraso',
            '120/80 mmHg',
            'Mwiza',
            Icons.bloodtype_rounded,
            AppTheme.successColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildMetricCard(
            'Ubushyuhe bw\'umubiri',
            '36.5°C',
            'Bisanzwe',
            Icons.thermostat_rounded,
            AppTheme.secondaryColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing24),

          // Health Trends Chart
          _buildHealthTrendsChart(isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildHealthTrendsChart(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryColor),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Imihindagurikire y\'ubuzima',
                style: AppTheme.headingSmall.copyWith(
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 64),
                      FlSpot(1, 65),
                      FlSpot(2, 66),
                      FlSpot(3, 65),
                      FlSpot(4, 67),
                      FlSpot(5, 65),
                      FlSpot(6, 66),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Ibiro byawe mu cyumweru gishize',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleHealthDataVoiceInput(String input) {
    // Process voice input for health data
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains('ibiro') || lowerInput.contains('weight')) {
      _showHealthDataDialog('Ibiro', 'kg', Icons.monitor_weight_rounded);
    } else if (lowerInput.contains('umuvuduko') ||
        lowerInput.contains('heart')) {
      _showHealthDataDialog(
        'Umuvuduko w\'umutima',
        'bpm',
        Icons.favorite_rounded,
      );
    } else if (lowerInput.contains('amaraso') ||
        lowerInput.contains('pressure')) {
      _showHealthDataDialog(
        'Umuvuduko w\'amaraso',
        'mmHg',
        Icons.bloodtype_rounded,
      );
    } else if (lowerInput.contains('ubushyuhe') ||
        lowerInput.contains('temperature')) {
      _showHealthDataDialog(
        'Ubushyuhe bw\'umubiri',
        '°C',
        Icons.thermostat_rounded,
      );
    } else {
      // Show general health data input dialog
      _showGeneralHealthDataDialog();
    }
  }

  void _showHealthDataDialog(String metric, String unit, IconData icon) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                SizedBox(width: AppTheme.spacing8),
                Text('Ongeraho $metric'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Agaciro ($unit)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppTheme.spacing16),
                VoiceButton(
                  prompt: 'Vuga agaciro ka $metric',
                  onResult: (result) {
                    Navigator.pop(context);
                    _saveHealthData(metric, result);
                  },
                  tooltip: 'Koresha ijwi',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Save data logic here
                },
                child: Text('Bika'),
              ),
            ],
          ),
    );
  }

  void _showGeneralHealthDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Ongeraho amakuru y\'ubuzima'),
            content: Text('Hitamo icyo ushaka kongeraho:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHealthDataDialog(
                    'Ibiro',
                    'kg',
                    Icons.monitor_weight_rounded,
                  );
                },
                child: Text('Ibiro'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHealthDataDialog(
                    'Umuvuduko w\'umutima',
                    'bpm',
                    Icons.favorite_rounded,
                  );
                },
                child: Text('Umutima'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHealthDataDialog(
                    'Umuvuduko w\'amaraso',
                    'mmHg',
                    Icons.bloodtype_rounded,
                  );
                },
                child: Text('Amaraso'),
              ),
            ],
          ),
    );
  }

  void _saveHealthData(String metric, String value) {
    // Save health data to local database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$metric: $value yabitswe neza'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String status,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
            ),
            child: Icon(icon, color: color, size: isTablet ? 28 : 24),
          ),
          SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.headingSmall.copyWith(
                    color: color,
                    fontSize: isTablet ? 20 : 18,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              status,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTracking(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imiti yawe',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildMedicationCard(
            'Paracetamol',
            '500mg - 2x ku munsi',
            'Saa 8:00 & 20:00',
            true,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildMedicationCard(
            'Vitamini D',
            '1000IU - rimwe ku munsi',
            'Saa 8:00',
            false,
            isTablet,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildMedicationCard(
    String name,
    String dosage,
    String schedule,
    bool taken,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color:
              taken
                  ? AppTheme.successColor.withValues(alpha: 0.3)
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 40,
            height: isTablet ? 50 : 40,
            decoration: BoxDecoration(
              color:
                  taken
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: taken ? AppTheme.successColor : AppTheme.primaryColor,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                Text(
                  dosage,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  schedule,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: taken,
            onChanged: (value) {
              // Handle medication taken
            },
            activeColor: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildReports(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raporo z\'ubuzima',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          Container(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Text(
                  'Raporo y\'uku kwezi gushize',
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
                SizedBox(height: AppTheme.spacing16),
                Text(
                  'Imihango yawe yagenze neza. Imihango yawe ni ya bisanzwe kandi ifite iminsi 28.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacing20),
                ElevatedButton(
                  onPressed: () {
                    // Generate report
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: Text(
                    'Kora raporo nshya',
                    style: AppTheme.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }
}

enum CycleDayType { period, ovulation, fertile, today, normal }

enum FlowLevel { light, medium, heavy }

class CycleDay {
  final DateTime date;
  final CycleDayType type;
  final FlowLevel? flow;

  CycleDay({required this.date, required this.type, this.flow});
}
