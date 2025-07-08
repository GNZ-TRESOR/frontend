import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class STIEducationScreen extends StatelessWidget {
  const STIEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amasomo ku indwara zandurira'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('STI Education Screen - Coming Soon'),
      ),
    );
  }
}
