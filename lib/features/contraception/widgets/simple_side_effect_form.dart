import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';

import '../../../core/models/contraception_method.dart';
import '../../../core/providers/contraception_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/contraception_service.dart';
import '../../../core/theme/app_colors.dart';

class SimpleSideEffectForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const SimpleSideEffectForm({super.key, this.onSuccess});

  @override
  ConsumerState<SimpleSideEffectForm> createState() =>
      _SimpleSideEffectFormState();
}

class _SimpleSideEffectFormState extends ConsumerState<SimpleSideEffectForm> {
  final _formKey = GlobalKey<FormState>();
  final _sideEffectController = TextEditingController();

  ContraceptionMethod? _selectedMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load contraception methods when form opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final isHealthWorker = ref.read(isHealthWorkerProvider);

      if (isHealthWorker) {
        ref.read(contraceptionProvider.notifier).initializeForHealthWorker();
      } else if (user != null && user.id != null) {
        ref
            .read(contraceptionProvider.notifier)
            .initializeForUser(userId: user.id!);
      }
    });
  }

  @override
  void dispose() {
    _sideEffectController.dispose();
    super.dispose();
  }

  Future<void> _submitSideEffect() async {
    if (!_formKey.currentState!.validate() || _selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectMethod),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final contraceptionService = ref.read(contraceptionServiceProvider);

      // Use the actual method ID from the database
      final sideEffectData = {
        'contraception_id': _selectedMethod!.id,
        'side_effect': _sideEffectController.text.trim(),
      };

      // Call API to create side effect
      // We'll make a direct HTTP call using the service's internal API
      // For now, we'll create a simple method call
      await _createSideEffect(contraceptionService, sideEffectData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sideEffectReported),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createSideEffect(
    ContraceptionService service,
    Map<String, dynamic> data,
  ) async {
    // Create a simple HTTP request to the side effects endpoint
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8080/api/v1';
    dio.options.headers = {'Content-Type': 'application/json'};

    await dio.post('/contraception-side-effects', data: data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contraceptionState = ref.watch(contraceptionProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.contraceptionOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.report_problem,
                        color: AppColors.contraceptionOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.reportSideEffect,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contraception Method Dropdown
                DropdownButtonFormField<ContraceptionMethod>(
                  value: _selectedMethod,
                  decoration: InputDecoration(
                    labelText: l10n.contraceptiveMethods,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  items:
                      contraceptionState.activeMethods.map((method) {
                        return DropdownMenuItem<ContraceptionMethod>(
                          value: method,
                          child: Text(method.name),
                        );
                      }).toList(),
                  onChanged: (ContraceptionMethod? value) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return l10n.pleaseSelectMethod;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Side Effect Name
                TextFormField(
                  controller: _sideEffectController,
                  decoration: InputDecoration(
                    labelText: l10n.sideEffectName,
                    hintText: 'e.g., Nausea, Headache, Mood changes...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.warning),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterSideEffect;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitSideEffect(),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitSideEffect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.contraceptionOrange,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(l10n.reportSideEffect),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
