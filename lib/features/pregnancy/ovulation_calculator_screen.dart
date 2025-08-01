import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Ovulation Calculator Screen for predicting fertile days
class OvulationCalculatorScreen extends ConsumerStatefulWidget {
  const OvulationCalculatorScreen({super.key});

  @override
  ConsumerState<OvulationCalculatorScreen> createState() =>
      _OvulationCalculatorScreenState();
}

class _OvulationCalculatorScreenState
    extends ConsumerState<OvulationCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  bool _isLoading = false;
  OvulationResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ovulation Calculator'),
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
          Icon(Icons.calculate, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ovulation Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Predict your most fertile days',
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

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Your Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildLastPeriodField(),
        const SizedBox(height: 16),
        _buildCycleLengthField(),
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
              'This calculator estimates your fertile window based on a typical 28-day cycle. Results may vary.',
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _lastPeriodDate != null ? _calculateOvulation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pregnancyPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Calculate Ovulation',
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
          'Your Fertile Window',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          'Ovulation Day',
          _formatDate(_result!.ovulationDate),
          Icons.favorite,
          AppColors.error,
          'Most likely day of ovulation',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Fertile Window',
          '${_formatDate(_result!.fertileStart)} - ${_formatDate(_result!.fertileEnd)}',
          Icons.calendar_month,
          AppColors.success,
          'Best days to try to conceive',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Next Period',
          _formatDate(_result!.nextPeriodDate),
          Icons.schedule,
          AppColors.primary,
          'Expected start of next period',
        ),
        const SizedBox(height: 16),
        _buildCalendarView(),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String date,
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
                    date,
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

  Widget _buildCalendarView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar View',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCalendarLegend(),
            const SizedBox(height: 12),
            Text(
              'Mark these dates on your calendar for the best chance of conception.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Column(
      children: [
        _buildLegendItem('Ovulation Day', AppColors.error),
        _buildLegendItem('Fertile Window', AppColors.success),
        _buildLegendItem('Next Period', AppColors.primary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLastPeriodDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      helpText: 'Select first day of last period',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (selectedDate != null) {
      setState(() {
        _lastPeriodDate = selectedDate;
        _result = null; // Clear previous results
      });
    }
  }

  void _calculateOvulation() {
    if (_lastPeriodDate == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate calculation delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final ovulationDate = _lastPeriodDate!.add(Duration(days: _cycleLength - 14));
      final fertileStart = ovulationDate.subtract(const Duration(days: 5));
      final fertileEnd = ovulationDate.add(const Duration(days: 1));
      final nextPeriodDate = _lastPeriodDate!.add(Duration(days: _cycleLength));

      setState(() {
        _result = OvulationResult(
          ovulationDate: ovulationDate,
          fertileStart: fertileStart,
          fertileEnd: fertileEnd,
          nextPeriodDate: nextPeriodDate,
        );
        _isLoading = false;
      });
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Ovulation calculation result
class OvulationResult {
  final DateTime ovulationDate;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final DateTime nextPeriodDate;

  OvulationResult({
    required this.ovulationDate,
    required this.fertileStart,
    required this.fertileEnd,
    required this.nextPeriodDate,
  });
}
