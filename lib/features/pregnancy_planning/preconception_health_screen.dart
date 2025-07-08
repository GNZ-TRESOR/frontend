import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PreconceptionHealthScreen extends StatelessWidget {
  const PreconceptionHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubuzima mbere y\'inda'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Preconception Health Screen - Coming Soon'),
      ),
    );
  }
}
