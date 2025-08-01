import 'package:flutter/material.dart';
import '../../../core/models/health_worker_reports.dart';
import '../../../core/widgets/auto_translate_widget.dart';

class ComplianceStatsCard extends StatelessWidget {
  final ComplianceData stats;

  const ComplianceStatsCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

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
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                AutoTranslateWidget(
                  'Compliance Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              context,
              'Overall Compliance Rate',
              '${stats.overallComplianceRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              _getComplianceColor(stats.overallComplianceRate),
            ),
            const SizedBox(height: 12),
            
            _buildStatItem(
              context,
              'Users with High Compliance',
              stats.highComplianceUsers.toString(),
              Icons.star,
              Colors.green,
            ),
            const SizedBox(height: 12),
            
            _buildStatItem(
              context,
              'Users Needing Follow-up',
              stats.lowComplianceUsers.toString(),
              Icons.warning,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            
            AutoTranslateWidget(
              'Compliance by Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ...stats.complianceByMethod.take(3).map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          method.methodName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${method.complianceRate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getComplianceColor(method.complianceRate),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: method.complianceRate / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getComplianceColor(method.complianceRate),
                    ),
                  ),
                ],
              ),
            )),
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

  Color _getComplianceColor(double rate) {
    if (rate >= 80) {
      return Colors.green;
    } else if (rate >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
