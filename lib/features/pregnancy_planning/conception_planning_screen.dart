import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ConceptionPlanningScreen extends StatelessWidget {
  const ConceptionPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gahunda yo gushaka inda'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Conception Planning Screen - Coming Soon'),
      ),
    );
  }
}
