import 'package:flutter/material.dart';
import '../../../core/models/health_worker_reports.dart';
import '../../../core/widgets/auto_translate_widget.dart';

class UsageStatsCard extends StatelessWidget {
  final UsageStats stats;

  const UsageStatsCard({
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
                  Icons.bar_chart,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                AutoTranslateWidget(
                  'Usage Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              context,
              'Total Active Users',
              stats.totalActiveUsers.toString(),
              Icons.people,
              Colors.green,
            ),
            const SizedBox(height: 12),
            
            _buildStatItem(
              context,
              'Total Methods in Use',
              stats.totalMethodsInUse.toString(),
              Icons.medical_services,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            
            _buildStatItem(
              context,
              'Average Usage Duration',
              '${stats.averageUsageDuration.toStringAsFixed(1)} days',
              Icons.schedule,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            
            AutoTranslateWidget(
              'Most Popular Methods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ...stats.popularMethods.take(3).map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(method.methodName),
                  Text(
                    '${method.userCount} users',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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
}
