import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/providers/health_provider.dart';
import '../../core/widgets/loading_overlay.dart';

/// Professional Menstrual Cycle Tracking Screen
class MenstrualCycleScreen extends ConsumerStatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  ConsumerState<MenstrualCycleScreen> createState() =>
      _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends ConsumerState<MenstrualCycleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  MenstrualCycle? _selectedCycleForSymptoms;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDay = DateTime.now();

    // Load menstrual cycles when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadMenstrualCycles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);
    final menstrualCycles = ref.watch(menstrualCyclesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menstrual Cycle'),
        backgroundColor: AppColors.menstrualRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Cycles'),
            Tab(text: 'Symptoms'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: healthState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCalendarTab(menstrualCycles),
            _buildCyclesTab(menstrualCycles),
            _buildSymptomsTab(menstrualCycles),
            _buildInsightsTab(menstrualCycles),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCycleDialog,
        backgroundColor: AppColors.menstrualRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarTab(List<MenstrualCycle> cycles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentCycleCard(cycles),
          const SizedBox(height: 16),
          _buildCalendarWidget(cycles),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildCurrentCycleCard(List<MenstrualCycle> cycles) {
    final currentCycle = cycles.isNotEmpty ? cycles.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.menstrualRed,
            AppColors.menstrualRed.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.menstrualRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Current Cycle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (currentCycle != null) ...[
            _buildCycleInfo('Cycle Day', _calculateCycleDay(currentCycle)),
            const SizedBox(height: 8),
            _buildCycleInfo('Phase', currentCycle.cyclePhase),
            const SizedBox(height: 8),
            _buildCycleInfo('Next Period', _formatNextPeriod(currentCycle)),
          ] else ...[
            Text(
              'No cycle data yet. Start tracking your cycle!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCycleInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarWidget(List<MenstrualCycle> cycles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar<MenstrualCycle>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          return cycles
              .where(
                (cycle) =>
                    isSameDay(cycle.startDate, day) ||
                    (cycle.endDate != null &&
                        day.isAfter(cycle.startDate) &&
                        day.isBefore(
                          cycle.endDate!.add(const Duration(days: 1)),
                        )),
              )
              .toList();
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppColors.textSecondary),
          holidayTextStyle: TextStyle(color: AppColors.menstrualRed),
          markerDecoration: BoxDecoration(
            color: AppColors.menstrualRed,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.menstrualRed,
            borderRadius: BorderRadius.circular(12.0),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Log Period',
            Icons.water_drop,
            AppColors.menstrualRed,
            () => _showLogPeriodDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Add Symptoms',
            Icons.sick,
            AppColors.warning,
            () => _showSymptomsDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclesTab(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) {
      return _buildEmptyState(
        'No cycles recorded yet',
        'Start tracking your menstrual cycle',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(healthProvider.notifier).loadMenstrualCycles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cycles.length,
        itemBuilder: (context, index) {
          final cycle = cycles[index];
          return _buildCycleCard(cycle, cycles);
        },
      ),
    );
  }

  Widget _buildCycleCard(MenstrualCycle cycle, List<MenstrualCycle> cycles) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.menstrualRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: AppColors.menstrualRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cycle ${cycles.indexOf(cycle) + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cycle.formattedStartDate} - ${cycle.formattedEndDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCycleStatusColor(
                      cycle.cycleStatus,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cycle.cycleStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCycleStatusColor(cycle.cycleStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCycleDetail(
                  'Length',
                  '${cycle.effectiveCycleLength} days',
                ),
                const SizedBox(width: 24),
                _buildCycleDetail('Flow', cycle.flowDisplay),
                const SizedBox(width: 24),
                _buildCycleDetail('Phase', cycle.cyclePhase),
              ],
            ),
            if (cycle.symptoms != null && cycle.symptoms!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Symptoms: ${cycle.symptomsString}',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCycleDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsTab(List<MenstrualCycle> cycles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle Selection
          Text(
            'Select Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildCycleSelector(cycles),
          const SizedBox(height: 24),

          // Common Symptoms Grid
          Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSymptomsGrid(),
          const SizedBox(height: 24),

          // Recent Symptoms
          Text(
            'Recent Symptoms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSymptoms(cycles),
        ],
      ),
    );
  }

  Widget _buildCycleSelector(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No cycles available. Add a cycle first.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MenstrualCycle>(
          value: _selectedCycleForSymptoms,
          hint: Text(
            'Select a cycle to add symptoms',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          items:
              cycles.map((cycle) {
                return DropdownMenuItem<MenstrualCycle>(
                  value: cycle,
                  child: Text(
                    '${cycle.formattedStartDate} - ${cycle.endDate != null ? cycle.formattedEndDate : 'Ongoing'}',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
          onChanged: (MenstrualCycle? newValue) {
            setState(() {
              _selectedCycleForSymptoms = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSymptomsGrid() {
    final symptoms = [
      'Cramps',
      'Headache',
      'Bloating',
      'Mood swings',
      'Fatigue',
      'Back pain',
      'Breast tenderness',
      'Nausea',
      'Acne',
      'Food cravings',
      'Irritability',
      'Sleep issues',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final symptom = symptoms[index];
        final isSelected =
            _selectedCycleForSymptoms?.symptoms?.contains(symptom) ?? false;

        return InkWell(
          onTap: () => _logSymptom(symptom),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.menstrualRed.withOpacity(0.1)
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.menstrualRed : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                symptom,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected
                          ? AppColors.menstrualRed
                          : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSymptoms(List<MenstrualCycle> cycles) {
    final recentCycles = cycles.take(3).toList();

    if (recentCycles.isEmpty) {
      return Text(
        'No recent symptoms recorded',
        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      );
    }

    return Column(
      children:
          recentCycles.map((cycle) {
            if (cycle.symptoms == null || cycle.symptoms!.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cycle.formattedStartDate,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        cycle.symptoms!.map((symptom) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.menstrualRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              symptom,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.menstrualRed,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildInsightsTab(List<MenstrualCycle> cycles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCards(cycles),
          const SizedBox(height: 24),
          _buildPredictions(cycles),
        ],
      ),
    );
  }

  Widget _buildInsightCards(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) {
      return _buildEmptyState(
        'No data for insights',
        'Track more cycles to see patterns',
      );
    }

    final avgCycleLength = _calculateAverageCycleLength(cycles);
    final avgPeriodLength = _calculateAveragePeriodLength(cycles);
    final mostCommonSymptoms = _getMostCommonSymptoms(cycles);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Avg Cycle',
                '${avgCycleLength.toStringAsFixed(0)} days',
                Icons.calendar_today,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                'Avg Period',
                '${avgPeriodLength.toStringAsFixed(0)} days',
                Icons.water_drop,
                AppColors.menstrualRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Common Symptoms',
          mostCommonSymptoms.take(3).join(', '),
          Icons.sick,
          AppColors.warning,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictions(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) return const SizedBox.shrink();

    final nextPeriod = ref.read(healthProvider.notifier).nextPeriodPrediction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predictions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                AppColors.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Next Period Prediction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextPeriod != null
                    ? 'Expected on ${_formatDate(nextPeriod)}'
                    : 'Need more data for accurate predictions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (nextPeriod != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${nextPeriod.difference(DateTime.now()).inDays} days from now',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _calculateCycleDay(MenstrualCycle cycle) {
    final daysSinceStart =
        DateTime.now().difference(cycle.startDate).inDays + 1;
    return daysSinceStart.toString();
  }

  String _formatNextPeriod(MenstrualCycle cycle) {
    final nextPeriod = ref.read(healthProvider.notifier).nextPeriodPrediction;
    if (nextPeriod == null) return 'Unknown';

    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
    if (daysUntil <= 0) return 'Due now';
    return 'In $daysUntil days';
  }

  Color _getCycleStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.menstrualRed;
      case 'completed':
        return AppColors.success;
      case 'predicted':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateAverageCycleLength(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) return 28.0;
    final lengths = cycles.map((c) => c.effectiveCycleLength).toList();
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  double _calculateAveragePeriodLength(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) return 5.0;
    final lengths = cycles.map((c) => c.effectivePeriodLength).toList();
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  List<String> _getMostCommonSymptoms(List<MenstrualCycle> cycles) {
    final symptomCounts = <String, int>{};

    for (final cycle in cycles) {
      if (cycle.symptoms != null) {
        for (final symptom in cycle.symptoms!) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }

    final sortedSymptoms =
        symptomCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSymptoms.map((e) => e.key).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _logSymptom(String symptom) async {
    if (_selectedCycleForSymptoms == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a cycle first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cycleId = _selectedCycleForSymptoms!.id;
    if (cycleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid cycle selected'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final isCurrentlySelected =
        _selectedCycleForSymptoms!.symptoms?.contains(symptom) ?? false;

    bool success;
    if (isCurrentlySelected) {
      // Remove symptom
      success = await ref
          .read(healthProvider.notifier)
          .removeSymptomFromCycle(cycleId, symptom);
    } else {
      // Add symptom
      success = await ref
          .read(healthProvider.notifier)
          .addSymptomToCycle(cycleId, symptom);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlySelected
                ? 'Removed symptom: $symptom'
                : 'Added symptom: $symptom',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      // Update the selected cycle to reflect the changes
      final updatedCycles = ref.read(healthProvider).menstrualCycles;
      final updatedCycle = updatedCycles.firstWhere(
        (cycle) => cycle.id == cycleId,
      );
      setState(() {
        _selectedCycleForSymptoms = updatedCycle;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isCurrentlySelected ? 'remove' : 'add'} symptom',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddCycleDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddCycleDialog(
            onCycleAdded: () {
              ref.read(healthProvider.notifier).loadMenstrualCycles();
            },
          ),
    );
  }

  void _showLogPeriodDialog() {
    showDialog(
      context: context,
      builder:
          (context) => LogPeriodDialog(
            onPeriodLogged: () {
              ref.read(healthProvider.notifier).loadMenstrualCycles();
            },
          ),
    );
  }

  void _showSymptomsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => SymptomsDialog(
            onSymptomsLogged: () {
              ref.read(healthProvider.notifier).loadMenstrualCycles();
            },
          ),
    );
  }
}

// Dialog widgets for adding cycles and logging data
class AddCycleDialog extends ConsumerStatefulWidget {
  final VoidCallback onCycleAdded;

  const AddCycleDialog({super.key, required this.onCycleAdded});

  @override
  ConsumerState<AddCycleDialog> createState() => _AddCycleDialogState();
}

class _AddCycleDialogState extends ConsumerState<AddCycleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime? _ovulationDate;
  DateTime? _fertileWindowStart;
  DateTime? _fertileWindowEnd;
  String _flowIntensity = 'NORMAL';
  int? _cycleLength;
  int? _flowDuration;
  bool _isPredicted = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Menstrual Cycle'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Start Date (Required)
                ListTile(
                  title: const Text('Start Date *'),
                  subtitle: Text(_formatDate(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectStartDate(),
                ),
                const Divider(),

                // End Date (Optional)
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    _endDate != null ? _formatDate(_endDate!) : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectEndDate(),
                ),
                const Divider(),

                // Flow Intensity (Required)
                DropdownButtonFormField<String>(
                  value: _flowIntensity,
                  decoration: const InputDecoration(
                    labelText: 'Flow Intensity *',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ['LIGHT', 'NORMAL', 'HEAVY']
                          .map(
                            (intensity) => DropdownMenuItem(
                              value: intensity,
                              child: Text(
                                intensity.toLowerCase().replaceFirst(
                                  intensity[0],
                                  intensity[0].toUpperCase(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _flowIntensity = value!),
                  validator:
                      (value) =>
                          value == null ? 'Please select flow intensity' : null,
                ),
                const SizedBox(height: 16),

                // Flow Duration
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Flow Duration (days)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 5',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _flowDuration = int.tryParse(value);
                    });
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final duration = int.tryParse(value);
                      if (duration == null || duration < 1 || duration > 15) {
                        return 'Please enter a valid duration (1-15 days)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cycle Length
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Cycle Length (days)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 28',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _cycleLength = int.tryParse(value);
                    });
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final length = int.tryParse(value);
                      if (length == null || length < 15 || length > 45) {
                        return 'Please enter a valid cycle length (15-45 days)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ovulation Date (Optional)
                ListTile(
                  title: const Text('Ovulation Date'),
                  subtitle: Text(
                    _ovulationDate != null
                        ? _formatDate(_ovulationDate!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectOvulationDate(),
                ),
                const Divider(),

                // Fertile Window Start (Optional)
                ListTile(
                  title: const Text('Fertile Window Start'),
                  subtitle: Text(
                    _fertileWindowStart != null
                        ? _formatDate(_fertileWindowStart!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectFertileWindowStart(),
                ),
                const Divider(),

                // Fertile Window End (Optional)
                ListTile(
                  title: const Text('Fertile Window End'),
                  subtitle: Text(
                    _fertileWindowEnd != null
                        ? _formatDate(_fertileWindowEnd!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectFertileWindowEnd(),
                ),
                const Divider(),

                // Is Predicted
                SwitchListTile(
                  title: const Text('Predicted Cycle'),
                  subtitle: const Text('Mark this as a predicted cycle'),
                  value: _isPredicted,
                  onChanged: (value) => setState(() => _isPredicted = value),
                ),
                const Divider(),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    hintText: 'Any additional notes about this cycle...',
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveCycle, child: const Text('Save')),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 5)),
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _selectOvulationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _ovulationDate ?? _startDate.add(const Duration(days: 14)),
      firstDate: _startDate.subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _ovulationDate = date);
    }
  }

  void _selectFertileWindowStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _fertileWindowStart ?? _startDate.add(const Duration(days: 10)),
      firstDate: _startDate.subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _fertileWindowStart = date);
    }
  }

  void _selectFertileWindowEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _fertileWindowEnd ?? _startDate.add(const Duration(days: 16)),
      firstDate:
          _fertileWindowStart ?? _startDate.subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _fertileWindowEnd = date);
    }
  }

  void _saveCycle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create menstrual cycle object
    final cycle = MenstrualCycle(
      startDate: _startDate,
      endDate: _endDate,
      cycleLength: _cycleLength,
      periodLength: _flowDuration, // Map flow_duration to periodLength
      flow: _flowIntensity, // Map flow_intensity to flow
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isPredicted: _isPredicted,
      ovulationDate: _ovulationDate,
      // Note: fertile window dates are not in the frontend model but are in the backend
      // They will be handled by the backend when processing the cycle
    );

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Save to backend via provider
      final success = await ref
          .read(healthProvider.notifier)
          .createMenstrualCycle(cycle);

      // Hide loading
      if (mounted) Navigator.pop(context);

      if (success) {
        widget.onCycleAdded();
        if (mounted) Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cycle added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add cycle. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading if still showing
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class LogPeriodDialog extends StatelessWidget {
  final VoidCallback onPeriodLogged;

  const LogPeriodDialog({super.key, required this.onPeriodLogged});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Period'),
      content: const Text('Quick log your period for today'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onPeriodLogged();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Period logged successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: const Text('Log Period'),
        ),
      ],
    );
  }
}

class SymptomsDialog extends StatelessWidget {
  final VoidCallback onSymptomsLogged;

  const SymptomsDialog({super.key, required this.onSymptomsLogged});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Symptoms'),
      content: const Text('Track your symptoms for today'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onSymptomsLogged();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Symptoms logged successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: const Text('Log Symptoms'),
        ),
      ],
    );
  }
}
