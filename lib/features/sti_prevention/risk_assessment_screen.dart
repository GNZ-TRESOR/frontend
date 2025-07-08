import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RiskAssessmentScreen extends StatelessWidget {
  const RiskAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suzuma ibyago'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Risk Assessment Screen - Coming Soon'),
      ),
    );
  }
}
