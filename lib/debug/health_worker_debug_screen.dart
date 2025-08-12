import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

class HealthWorkerDebugScreen extends ConsumerStatefulWidget {
  const HealthWorkerDebugScreen({super.key});

  @override
  ConsumerState<HealthWorkerDebugScreen> createState() =>
      _HealthWorkerDebugScreenState();
}

class _HealthWorkerDebugScreenState
    extends ConsumerState<HealthWorkerDebugScreen> {
  String _debugOutput = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Running diagnostics...\n\n';
    });

    try {
      // Check authentication status
      _addOutput('=== AUTHENTICATION STATUS ===');
      final authState = ref.read(authProvider);
      _addOutput('Is Authenticated: ${authState.isAuthenticated}');
      _addOutput('User: ${authState.user?.toJson()}');

      // Check stored token
      final token = await StorageService.getAuthToken();
      _addOutput(
        'Stored Token: ${token != null ? 'Present (${token.length} chars)' : 'None'}',
      );

      // Check current user
      final user = ref.read(currentUserProvider);
      _addOutput('Current User ID: ${user?.id}');
      _addOutput('Current User Role: ${user?.role}');
      _addOutput('Current User Email: ${user?.email}');

      if (user?.id != null) {
        _addOutput('\n=== API TESTS ===');

        // Test dashboard stats
        _addOutput('Testing dashboard stats...');
        try {
          final statsResponse = await ApiService.instance
              .getHealthWorkerDashboardStats(user!.id!);
          _addOutput('Dashboard Stats Response:');
          _addOutput('  Success: ${statsResponse.success}');
          _addOutput('  Message: ${statsResponse.message}');
          _addOutput('  Data: ${statsResponse.data}');
        } catch (e) {
          _addOutput('Dashboard Stats Error: $e');
        }

        // Test clients
        _addOutput('\nTesting clients...');
        try {
          final clientsResponse = await ApiService.instance
              .getHealthWorkerClients(user!.id!);
          _addOutput('Clients Response:');
          _addOutput('  Success: ${clientsResponse.success}');
          _addOutput('  Message: ${clientsResponse.message}');
          _addOutput('  Data: ${clientsResponse.data}');
        } catch (e) {
          _addOutput('Clients Error: $e');
        }

        // Test appointments
        _addOutput('\nTesting appointments...');
        try {
          final appointmentsResponse = await ApiService.instance
              .getHealthWorkerAppointments(user!.id!);
          _addOutput('Appointments Response:');
          _addOutput('  Success: ${appointmentsResponse.success}');
          _addOutput('  Message: ${appointmentsResponse.message}');
          _addOutput('  Data: ${appointmentsResponse.data}');
        } catch (e) {
          _addOutput('Appointments Error: $e');
        }
      } else {
        _addOutput('No user ID available for API tests');
      }
    } catch (e) {
      _addOutput('Diagnostics Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addOutput(String text) {
    setState(() {
      _debugOutput += '$text\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Worker Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runDiagnostics,
                    child: const Text('Run Diagnostics'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Test login with health worker credentials
                      setState(() {
                        _debugOutput = 'Testing login...\n';
                      });

                      try {
                        final success = await ref
                            .read(authProvider.notifier)
                            .login(
                              'healthworker@ubuzima.rw',
                              'healthworker123',
                            );
                        _addOutput('Login Success: $success');
                        if (success) {
                          await _runDiagnostics();
                        }
                      } catch (e) {
                        _addOutput('Login Error: $e');
                      }
                    },
                    child: const Text('Test Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
