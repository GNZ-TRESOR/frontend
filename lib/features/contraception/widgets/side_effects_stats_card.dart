import 'package:flutter/material.dart';
import '../../../core/models/health_worker_reports.dart';
import '../../../core/widgets/auto_translate_widget.dart';

class SideEffectsStatsCard extends StatelessWidget {
  final EnhancedSideEffectsStats stats;

  const SideEffectsStatsCard({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                AutoTranslateWidget(
                  'Side Effects Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildStatItem(
              context,
              'Total Reports',
              stats.totalReports.toString(),
              Icons.report,
              Colors.red,
            ),
            const SizedBox(height: 12),

            _buildStatItem(
              context,
              'Reports This Month',
              stats.reportsThisMonth.toString(),
              Icons.calendar_month,
              Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildStatItem(
              context,
              'Severe Cases',
              stats.severeCases.toString(),
              Icons.priority_high,
              Colors.red,
            ),
            const SizedBox(height: 16),

            AutoTranslateWidget(
              'Most Common Side Effects',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            ...stats.commonSideEffects
                .take(3)
                .map(
                  (effect) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            effect.sideEffectType,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(
                              effect.severity,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${effect.count} reports',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: _getSeverityColor(effect.severity),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoTranslateWidget(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
