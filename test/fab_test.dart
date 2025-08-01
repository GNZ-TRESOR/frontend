import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuzima_app/features/medications/medications_screen.dart';
import 'package:ubuzima_app/features/health_records/health_records_screen.dart';

void main() {
  group('Floating Action Button Tests', () {
    testWidgets('Medications screen should have floating action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const MedicationsScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if floating action buttons exist
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
      
      // Check for specific icons
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.volume_up), findsWidgets);
    });

    testWidgets('Health Records screen should have floating action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HealthRecordsScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if floating action buttons exist
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
      
      // Check for specific icons
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.volume_up), findsWidgets);
    });
  });
}
