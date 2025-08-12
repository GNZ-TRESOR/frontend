import 'package:flutter/material.dart';

// Test basic compilation
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('Test')),
      ),
    );
  }
}
