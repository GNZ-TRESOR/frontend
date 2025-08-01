import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Due Date Calculator Screen for estimating pregnancy due date
class DueDateCalculatorScreen extends ConsumerStatefulWidget {
  const DueDateCalculatorScreen({super.key});

  @override
  ConsumerState<DueDateCalculatorScreen> createState() =>
      _DueDateCalculatorScreenState();
}

class _DueDateCalculatorScreenState
    extends ConsumerState<DueDateCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriodDate;
  DateTime? _conceptionDate;
  int _cycleLength = 28;
  bool _isLoading = false;
  DueDateResult? _result;
  CalculationMethod _method = CalculationMethod.lastPeriod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Due Date Calculator'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildMethodSelection(),
                const SizedBox(height: 24),
                _buildInputSection(),
                const SizedBox(height: 24),
                _buildCalculateButton(),
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  _buildResultsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pregnancyPurple,
            AppColors.pregnancyPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pregnancyPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Estimate your baby\'s due date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculation Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                'Last Period',
                'Based on first day of last menstrual period',
                Icons.calendar_today,
                CalculationMethod.lastPeriod,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                'Conception Date',
                'Based on known conception date',
                Icons.favorite,
                CalculationMethod.conception,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    String title,
    String description,
    IconData icon,
    CalculationMethod method,
  ) {
    final isSelected = _method == method;
    return InkWell(
      onTap: () {
        setState(() {
          _method = method;
          _result = null; // Clear previous results
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pregnancyPurple.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.pregnancyPurple : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.pregnancyPurple : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.pregnancyPurple : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_method == CalculationMethod.lastPeriod) ...[
          _buildLastPeriodField(),
          const SizedBox(height: 16),
          _buildCycleLengthField(),
        ] else ...[
          _buildConceptionDateField(),
        ],
        const SizedBox(height: 16),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildLastPeriodField() {
    return InkWell(
      onTap: _selectLastPeriodDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'First Day of Last Period *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.pregnancyPurple),
        ),
        child: Text(
          _lastPeriodDate != null
              ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
              : 'Select the first day of your last period',
          style: TextStyle(
            color: _lastPeriodDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildConceptionDateField() {
    return InkWell(
      onTap: _selectConceptionDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Conception Date *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(Icons.favorite, color: AppColors.pregnancyPurple),
        ),
        child: Text(
          _conceptionDate != null
              ? '${_conceptionDate!.day}/${_conceptionDate!.month}/${_conceptionDate!.year}'
              : 'Select the conception date',
          style: TextStyle(
            color: _conceptionDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCycleLengthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Cycle Length: $_cycleLength days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _cycleLength.toDouble(),
          min: 21,
          max: 35,
          divisions: 14,
          activeColor: AppColors.pregnancyPurple,
          label: '$_cycleLength days',
          onChanged: (value) {
            setState(() {
              _cycleLength = value.round();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('21 days', style: TextStyle(color: AppColors.textSecondary)),
            Text('35 days', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Due dates are estimates. Only about 5% of babies are born on their exact due date.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    final canCalculate = _method == CalculationMethod.lastPeriod
        ? _lastPeriodDate != null
        : _conceptionDate != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canCalculate ? _calculateDueDate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pregnancyPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Calculate Due Date',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Pregnancy Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          'Due Date',
          _formatDate(_result!.dueDate),
          Icons.baby_changing_station,
          AppColors.pregnancyPurple,
          'Estimated delivery date (40 weeks)',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Current Week',
          'Week ${_result!.currentWeek}',
          Icons.schedule,
          AppColors.primary,
          '${_result!.daysPregnant} days pregnant',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Trimester',
          _result!.trimester,
          Icons.timeline,
          AppColors.success,
          _result!.trimesterDescription,
        ),
        const SizedBox(height: 16),
        _buildMilestonesCard(),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important Milestones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildMilestone('First Trimester Ends', _result!.firstTrimesterEnd),
            _buildMilestone('Second Trimester Ends', _result!.secondTrimesterEnd),
            _buildMilestone('Full Term (37 weeks)', _result!.fullTermDate),
            _buildMilestone('Due Date (40 weeks)', _result!.dueDate),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(String title, DateTime date) {
    final isPast = date.isBefore(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              if (isPast)
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPast ? AppColors.success : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectLastPeriodDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
      helpText: 'Select first day of last period',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (selectedDate != null) {
      setState(() {
        _lastPeriodDate = selectedDate;
        _result = null;
      });
    }
  }

  Future<void> _selectConceptionDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _conceptionDate ?? DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'Select conception date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (selectedDate != null) {
      setState(() {
        _conceptionDate = selectedDate;
        _result = null;
      });
    }
  }

  void _calculateDueDate() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      DateTime conceptionDate;
      
      if (_method == CalculationMethod.lastPeriod) {
        // Calculate conception date from last period (typically 14 days after LMP)
        conceptionDate = _lastPeriodDate!.add(Duration(days: _cycleLength - 14));
      } else {
        conceptionDate = _conceptionDate!;
      }

      // Due date is 280 days (40 weeks) from LMP or 266 days (38 weeks) from conception
      final dueDate = conceptionDate.add(const Duration(days: 266));
      final now = DateTime.now();
      final daysPregnant = now.difference(conceptionDate).inDays;
      final currentWeek = (daysPregnant / 7).floor();

      setState(() {
        _result = DueDateResult(
          dueDate: dueDate,
          conceptionDate: conceptionDate,
          currentWeek: currentWeek,
          daysPregnant: daysPregnant,
        );
        _isLoading = false;
      });
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum CalculationMethod { lastPeriod, conception }

/// Due date calculation result
class DueDateResult {
  final DateTime dueDate;
  final DateTime conceptionDate;
  final int currentWeek;
  final int daysPregnant;

  DueDateResult({
    required this.dueDate,
    required this.conceptionDate,
    required this.currentWeek,
    required this.daysPregnant,
  });

  String get trimester {
    if (currentWeek <= 12) return 'First Trimester';
    if (currentWeek <= 27) return 'Second Trimester';
    return 'Third Trimester';
  }

  String get trimesterDescription {
    if (currentWeek <= 12) return 'Weeks 1-12 of pregnancy';
    if (currentWeek <= 27) return 'Weeks 13-27 of pregnancy';
    return 'Weeks 28-40 of pregnancy';
  }

  DateTime get firstTrimesterEnd => conceptionDate.add(const Duration(days: 84)); // 12 weeks
  DateTime get secondTrimesterEnd => conceptionDate.add(const Duration(days: 189)); // 27 weeks
  DateTime get fullTermDate => conceptionDate.add(const Duration(days: 259)); // 37 weeks
}
