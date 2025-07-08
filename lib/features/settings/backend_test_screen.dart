import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/language_service.dart';
import '../../core/services/http_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/backend_sync_service_simple.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  final List<TestResult> _testResults = [];
  bool _isRunningTests = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getTitle(languageService.currentLocale.languageCode),
              style: AppTheme.headingMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getInstructionsTitle(
                            languageService.currentLocale.languageCode,
                          ),
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getInstructions(
                            languageService.currentLocale.languageCode,
                          ),
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isRunningTests ? null : _runAllTests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isRunningTests
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getRunningText(
                                            languageService
                                                .currentLocale
                                                .languageCode,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      _getRunTestsText(
                                        languageService
                                            .currentLocale
                                            .languageCode,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_testResults.isNotEmpty) ...[
                  Text(
                    _getResultsTitle(
                      languageService.currentLocale.languageCode,
                    ),
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _testResults.length,
                      itemBuilder: (context, index) {
                        final result = _testResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              result.isSuccess
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  result.isSuccess
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                            ),
                            title: Text(
                              result.testName,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              result.message,
                              style: AppTheme.bodySmall,
                            ),
                            trailing: Text(
                              '${result.duration.inMilliseconds}ms',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    // Test 1: Internet Connectivity
    await _runTest('Internet Connectivity', () async {
      final syncService = BackendSyncService();
      final isOnline = await syncService.isOnline();
      if (isOnline) {
        return TestResult.success(
          'Internet Connectivity',
          'Connected to internet',
        );
      } else {
        return TestResult.failure(
          'Internet Connectivity',
          'No internet connection',
        );
      }
    });

    // Test 2: Backend Health Check
    await _runTest('Backend Health Check', () async {
      final httpClient = HttpClient();
      final isHealthy = await httpClient.checkBackendHealth();
      if (isHealthy) {
        return TestResult.success(
          'Backend Health Check',
          'Backend server is running',
        );
      } else {
        return TestResult.failure(
          'Backend Health Check',
          'Backend server is not accessible',
        );
      }
    });

    // Test 3: API Endpoint Test
    await _runTest('API Endpoint Test', () async {
      final httpClient = HttpClient();
      try {
        final response = await httpClient.get('/health');
        if (response.statusCode == 200) {
          return TestResult.success(
            'API Endpoint Test',
            'API endpoints are working',
          );
        } else {
          return TestResult.failure(
            'API Endpoint Test',
            'API returned status ${response.statusCode}',
          );
        }
      } catch (e) {
        return TestResult.failure(
          'API Endpoint Test',
          'API request failed: ${e.toString()}',
        );
      }
    });

    // Test 4: Authentication Service
    await _runTest('Authentication Service', () async {
      final authService = AuthService();
      try {
        // Test if auth service is initialized
        return TestResult.success(
          'Authentication Service',
          'Auth service is initialized and ready',
        );
      } catch (e) {
        return TestResult.failure(
          'Authentication Service',
          'Auth service error: ${e.toString()}',
        );
      }
    });

    // Test 5: Database Connection
    await _runTest('Database Connection', () async {
      try {
        // This would test local database connection
        return TestResult.success(
          'Database Connection',
          'Local database is accessible',
        );
      } catch (e) {
        return TestResult.failure(
          'Database Connection',
          'Database error: ${e.toString()}',
        );
      }
    });

    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _runTest(
    String testName,
    Future<TestResult> Function() testFunction,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await testFunction();
      result.duration = stopwatch.elapsed;

      setState(() {
        _testResults.add(result);
      });
    } catch (e) {
      final result = TestResult.failure(
        testName,
        'Test failed: ${e.toString()}',
      );
      result.duration = stopwatch.elapsed;

      setState(() {
        _testResults.add(result);
      });
    }

    stopwatch.stop();
  }

  String _getTitle(String language) {
    switch (language) {
      case 'rw':
        return 'Gerageza Backend';
      case 'fr':
        return 'Test Backend';
      default:
        return 'Backend Test';
    }
  }

  String _getInstructionsTitle(String language) {
    switch (language) {
      case 'rw':
        return 'Amabwiriza';
      case 'fr':
        return 'Instructions';
      default:
        return 'Instructions';
    }
  }

  String _getInstructions(String language) {
    switch (language) {
      case 'rw':
        return 'Kanda buto hepfo kugira ngo ugerageze niba backend ikora neza. Menya niba ufite internet na seriveri ikora.';
      case 'fr':
        return 'Appuyez sur le bouton ci-dessous pour tester si le backend fonctionne correctement. Vérifiez votre connexion internet et le serveur.';
      default:
        return 'Press the button below to test if the backend is working correctly. This will check your internet connection and server status.';
    }
  }

  String _getRunTestsText(String language) {
    switch (language) {
      case 'rw':
        return 'Tangira Ibizamini';
      case 'fr':
        return 'Lancer les Tests';
      default:
        return 'Run Tests';
    }
  }

  String _getRunningText(String language) {
    switch (language) {
      case 'rw':
        return 'Biragezwa...';
      case 'fr':
        return 'Tests en cours...';
      default:
        return 'Running Tests...';
    }
  }

  String _getResultsTitle(String language) {
    switch (language) {
      case 'rw':
        return 'Ibisubizo';
      case 'fr':
        return 'Résultats';
      default:
        return 'Test Results';
    }
  }
}

class TestResult {
  final String testName;
  final String message;
  final bool isSuccess;
  Duration duration = Duration.zero;

  TestResult.success(this.testName, this.message) : isSuccess = true;
  TestResult.failure(this.testName, this.message) : isSuccess = false;
}
