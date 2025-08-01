import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ubuzima Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ubuzima Test'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 100, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Ubuzima Family Planning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Test App Running Successfully!',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
