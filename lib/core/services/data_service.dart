import 'package:flutter/foundation.dart';
import '../models/health_facility.dart';

/// Temporary DataService to resolve import errors
/// This will be removed once all references are cleaned up
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  /// Get health facilities (placeholder)
  Future<List<HealthFacility>> getHealthFacilities() async {
    try {
      // Return empty list for now
      return [];
    } catch (e) {
      debugPrint('Error fetching health facilities: $e');
      return [];
    }
  }
}
