import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';

/// Beta Feedback Screen for collecting user feedback
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'bug';
  String _selectedPriority = 'medium';
  bool _isLoading = false;
  bool _includeDeviceInfo = true;

  final List<Map<String, String>> _categories = [
    {'value': 'bug', 'label': 'Bug Report', 'icon': '🐛'},
    {'value': 'feature', 'label': 'Feature Request', 'icon': '💡'},
    {'value': 'improvement', 'label': 'Improvement', 'icon': '⚡'},
    {'value': 'ui', 'label': 'UI/UX Issue', 'icon': '🎨'},
    {'value': 'performance', 'label': 'Performance', 'icon': '🚀'},
    {'value': 'other', 'label': 'Other', 'icon': '💬'},
  ];

  final List<Map<String, String>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': '0xFF4CAF50'},
    {'value': 'medium', 'label': 'Medium', 'color': '0xFFFF9800'},
    {'value': 'high', 'label': 'High', 'color': '0xFFF44336'},
    {'value': 'critical', 'label': 'Critical', 'color': '0xFF9C27B0'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCategorySelection(),
                const SizedBox(height: 24),
                _buildPrioritySelection(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildDeviceInfoToggle(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildBetaInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Beta Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Help us improve Ubuzima by sharing your feedback, reporting bugs, or suggesting new features.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['value']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category['icon']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['label']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              _priorities.map((priority) {
                final isSelected = _selectedPriority == priority['value'];
                final color = Color(int.parse(priority['color']!));
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPriority = priority['value']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? color.withValues(alpha: 0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          priority['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? color : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'Brief summary of your feedback',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 5) {
          return 'Title must be at least 5 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: 'Description *',
        hintText: 'Provide detailed information about your feedback...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        if (value.trim().length < 10) {
          return 'Description must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email (Optional)',
        hintText: 'your.email@example.com',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.email),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDeviceInfoToggle() {
    return Row(
      children: [
        Checkbox(
          value: _includeDeviceInfo,
          onChanged: (value) {
            setState(() {
              _includeDeviceInfo = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Text(
            'Include device information (helps with debugging)',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Send Feedback',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildBetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Beta Testing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You are using a beta version of Ubuzima. Your feedback is valuable in helping us improve the app before the official release.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final feedbackData = await _prepareFeedbackData();

      // Submit feedback to backend API
      final apiService = ApiService.instance;
      final response = await apiService.submitFeedback(feedbackData);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to send feedback'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback: $e'),
            backgroundColor: AppColors.error,
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

  Future<Map<String, dynamic>> _prepareFeedbackData() async {
    final feedbackData = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'priority': _selectedPriority,
      'email':
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (_includeDeviceInfo) {
      feedbackData['deviceInfo'] = await _getDeviceInfo();
    }

    return feedbackData;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final platform = Theme.of(context).platform;
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      Map<String, dynamic> deviceData = {
        'appName': packageInfo.appName,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
      };

      // Add platform-specific device info
      if (platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'Android',
          'androidVersion': androidInfo.version.release,
          'device': '${androidInfo.manufacturer} ${androidInfo.model}',
          'sdkInt': androidInfo.version.sdkInt,
        });
      } else if (platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'iOS',
          'iosVersion': iosInfo.systemVersion,
          'device': '${iosInfo.name} ${iosInfo.model}',
        });
      }

      return deviceData;
    } catch (e) {
      return {'error': 'Failed to collect device info: $e'};
    }
  }
}
