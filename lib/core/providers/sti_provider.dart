import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sti_test_record.dart';
import '../services/api_service.dart';

/// STI Test Records State
class StiState {
  final List<StiTestRecord> testRecords;
  final bool isLoading;
  final String? error;

  const StiState({
    this.testRecords = const [],
    this.isLoading = false,
    this.error,
  });

  StiState copyWith({
    List<StiTestRecord>? testRecords,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StiState(
      testRecords: testRecords ?? this.testRecords,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Get recent test records (within last 6 months)
  List<StiTestRecord> get recentTestRecords {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return testRecords
        .where((record) => record.testDate.isAfter(sixMonthsAgo))
        .toList();
  }

  /// Get test records that need follow-up
  List<StiTestRecord> get followUpRecords {
    return testRecords
        .where(
          (record) => record.followUpRequired && record.followUpDate != null,
        )
        .toList();
  }

  /// Get overdue follow-up records
  List<StiTestRecord> get overdueFollowUps {
    return testRecords.where((record) => record.isFollowUpOverdue).toList();
  }

  /// Get test records by type
  List<StiTestRecord> getRecordsByType(String testType) {
    return testRecords
        .where(
          (record) => record.testType.toUpperCase() == testType.toUpperCase(),
        )
        .toList();
  }

  /// Get latest test record for a specific type
  StiTestRecord? getLatestRecordByType(String testType) {
    final records = getRecordsByType(testType);
    if (records.isEmpty) return null;

    records.sort((a, b) => b.testDate.compareTo(a.testDate));
    return records.first;
  }

  /// Get test statistics
  Map<String, dynamic> get statistics {
    final totalTests = testRecords.length;
    final recentTests = recentTestRecords.length;
    final pendingResults =
        testRecords.where((r) => r.resultStatus == 'PENDING').length;
    final followUpsNeeded = followUpRecords.length;
    final overdueFollowUps = this.overdueFollowUps.length;

    return {
      'totalTests': totalTests,
      'recentTests': recentTests,
      'pendingResults': pendingResults,
      'followUpsNeeded': followUpsNeeded,
      'overdueFollowUps': overdueFollowUps,
    };
  }
}

/// STI Provider
class StiNotifier extends StateNotifier<StiState> {
  StiNotifier() : super(const StiState());

  final ApiService _apiService = ApiService.instance;

  /// Load all STI test records
  Future<void> loadStiTestRecords() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.getStiTestRecords();

      print('DEBUG STI Provider: Response success: ${response.success}');
      print('DEBUG STI Provider: Response data: ${response.data}');
      print('DEBUG STI Provider: Response message: ${response.message}');

      if (response.success) {
        List<StiTestRecord> records = [];

        // The backend returns the response directly without wrapping in ApiResponse format
        // We need to parse the raw response data
        if (response.data != null) {
          // Check if data is already parsed as Map
          if (response.data is Map<String, dynamic>) {
            final dataMap = response.data as Map<String, dynamic>;
            print(
              'DEBUG STI Provider: Data is Map, contains records: ${dataMap.containsKey('records')}',
            );

            if (dataMap.containsKey('records') && dataMap['records'] is List) {
              final recordsList = dataMap['records'] as List<dynamic>;
              print(
                'DEBUG STI Provider: Records list length: ${recordsList.length}',
              );

              // Parse each record with error handling
              for (var i = 0; i < recordsList.length; i++) {
                try {
                  final recordJson = recordsList[i] as Map<String, dynamic>;
                  print(
                    'DEBUG STI Provider: Parsing record $i: ${recordJson['id']} - ${recordJson['testType']}',
                  );
                  final record = StiTestRecord.fromJson(recordJson);
                  records.add(record);
                  print(
                    'DEBUG STI Provider: Successfully parsed record ${record.id}',
                  );
                } catch (e) {
                  print('DEBUG STI Provider: Error parsing record $i: $e');
                }
              }
            }
          } else if (response.data is List) {
            // Direct array format: [...]
            print(
              'DEBUG STI Provider: Data is List, length: ${(response.data as List).length}',
            );
            records =
                (response.data as List<dynamic>)
                    .map((json) => StiTestRecord.fromJson(json))
                    .toList();
          } else {
            print(
              'DEBUG STI Provider: Data type: ${response.data.runtimeType}',
            );
            print('DEBUG STI Provider: Data content: ${response.data}');
          }
        } else {
          print(
            'DEBUG STI Provider: Response data is null, checking raw response',
          );
          // If data is null, the response might not be parsed correctly
          // This suggests the backend response format doesn't match ApiResponse expectations
        }

        // Sort by test date (most recent first)
        if (records.isNotEmpty) {
          records.sort((a, b) => b.testDate.compareTo(a.testDate));
        }

        print('DEBUG STI Provider: Final records count: ${records.length}');
        state = state.copyWith(testRecords: records, isLoading: false);
      } else {
        print('DEBUG STI Provider: Response not successful');
        state = state.copyWith(
          testRecords: [],
          isLoading: false,
          error: response.message ?? 'Failed to load STI test records',
        );
      }
    } catch (e) {
      print('DEBUG STI Provider: Exception occurred: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading STI test records: $e',
      );
    }
  }

  /// Create a new STI test record
  Future<bool> createStiTestRecord(StiTestRecord record) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createStiTestRecord(record.toJson());

      if (response.success) {
        // Reload records to get the updated list
        await loadStiTestRecords();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create STI test record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating STI test record: $e',
      );
      return false;
    }
  }

  /// Update an existing STI test record
  Future<bool> updateStiTestRecord(StiTestRecord record) async {
    if (record.id == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.updateStiTestRecord(
        record.id!,
        record.toJson(),
      );

      if (response.success) {
        // Reload records to get the updated list
        await loadStiTestRecords();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update STI test record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error updating STI test record: $e',
      );
      return false;
    }
  }

  /// Delete an STI test record
  Future<bool> deleteStiTestRecord(int recordId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.deleteStiTestRecord(recordId);

      if (response.success) {
        // Remove the record from the current state
        final updatedRecords =
            state.testRecords.where((record) => record.id != recordId).toList();

        state = state.copyWith(testRecords: updatedRecords, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete STI test record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting STI test record: $e',
      );
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadStiTestRecords();
  }
}

/// STI Provider instance
final stiProvider = StateNotifierProvider<StiNotifier, StiState>((ref) {
  return StiNotifier();
});

/// Convenience providers for specific data
final stiTestRecordsProvider = Provider<List<StiTestRecord>>((ref) {
  return ref.watch(stiProvider).testRecords;
});

final recentStiTestsProvider = Provider<List<StiTestRecord>>((ref) {
  return ref.watch(stiProvider).recentTestRecords;
});

final stiFollowUpsProvider = Provider<List<StiTestRecord>>((ref) {
  return ref.watch(stiProvider).followUpRecords;
});

final stiStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(stiProvider).statistics;
});
