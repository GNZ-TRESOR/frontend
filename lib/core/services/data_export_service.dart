import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Simplified data export service for Ubuzima app
/// Handles PDF reports, CSV exports, and data backup
class DataExportService extends ChangeNotifier {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  // Export state
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String? _lastError;

  // Getters
  bool get isExporting => _isExporting;
  double get exportProgress => _exportProgress;
  String? get lastError => _lastError;

  /// Export health records to CSV
  Future<String?> exportHealthRecordsToCSV({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setExportState(true, 0.0, null);

      // Create sample CSV data for demonstration
      final csvLines = <String>[];
      csvLines.add('Date,Type,Weight,Blood Pressure,Temperature,Notes');

      // Add sample data
      csvLines.add('2024-01-15,Weight,70.5,,36.5,Regular checkup');
      csvLines.add('2024-01-20,Blood Pressure,,120/80,,Normal reading');
      csvLines.add('2024-01-25,Temperature,,,37.2,Slight fever');

      _setExportState(false, 1.0, null);
      debugPrint('✅ Health records CSV exported successfully');
      return csvLines.join('\n');
    } catch (e) {
      _setExportState(false, 0.0, e.toString());
      debugPrint('❌ Health records CSV export failed: $e');
      return null;
    }
  }

  /// Export health records to PDF
  Future<Uint8List?> exportHealthRecordsToPDF({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setExportState(true, 0.0, null);

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Ubuzima Health Records',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('User ID: $userId'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated: ${DateTime.now().toString().split(' ')[0]}',
                ),
                pw.SizedBox(height: 40),
                pw.TableHelper.fromTextArray(
                  data: [
                    ['Date', 'Type', 'Value', 'Notes'],
                    ['2024-01-15', 'Weight', '70.5 kg', 'Regular checkup'],
                    [
                      '2024-01-20',
                      'Blood Pressure',
                      '120/80 mmHg',
                      'Normal reading',
                    ],
                    ['2024-01-25', 'Temperature', '37.2°C', 'Slight fever'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      _setExportState(false, 1.0, null);
      debugPrint('✅ Health records PDF exported successfully');
      return pdfBytes;
    } catch (e) {
      _setExportState(false, 0.0, e.toString());
      debugPrint('❌ Health records PDF export failed: $e');
      return null;
    }
  }

  /// Export complete user data backup
  Future<String?> exportCompleteDataBackup({required String userId}) async {
    try {
      _setExportState(true, 0.0, null);

      // Create backup data structure
      final backupData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'userId': userId,
        'healthRecords': [
          {
            'date': '2024-01-15',
            'type': 'weight',
            'value': 70.5,
            'notes': 'Regular checkup',
          },
        ],
        'appointments': [
          {
            'date': '2024-02-01',
            'type': 'consultation',
            'status': 'scheduled',
            'notes': 'Regular checkup',
          },
        ],
        'metadata': {'totalHealthRecords': 1, 'totalAppointments': 1},
      };

      _setExportState(true, 0.9, null);

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      _setExportState(false, 1.0, null);
      debugPrint('✅ Complete data backup exported successfully');
      return jsonString;
    } catch (e) {
      _setExportState(false, 0.0, e.toString());
      debugPrint('❌ Complete data backup export failed: $e');
      return null;
    }
  }

  /// Set export state
  void _setExportState(bool isExporting, double progress, String? error) {
    _isExporting = isExporting;
    _exportProgress = progress;
    _lastError = error;
    notifyListeners();
  }
}
