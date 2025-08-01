import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Feature messaging utility for handling role-based feature availability
class FeatureMessaging {
  
  /// Show feature availability dialog
  static void showFeatureDialog(
    BuildContext context, {
    required String featureName,
    String? userRole,
    String? customMessage,
    VoidCallback? onRequestFeature,
  }) {
    final message = customMessage ?? _getFeatureMessage(featureName, userRole);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getFeatureIcon(featureName),
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(featureName)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage(featureName),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRequestFeature != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRequestFeature();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Request Feature',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// Show simple snackbar message
  static void showSnackbarMessage(
    BuildContext context, {
    required String featureName,
    String? userRole,
    String? customMessage,
  }) {
    final message = customMessage ?? _getSimpleMessage(featureName, userRole);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getFeatureIcon(featureName),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Details',
          textColor: Colors.white,
          onPressed: () => showFeatureDialog(context, featureName: featureName, userRole: userRole),
        ),
      ),
    );
  }

  /// Get feature-specific message
  static String _getFeatureMessage(String featureName, String? userRole) {
    switch (featureName.toLowerCase()) {
      case 'voice interface':
      case 'voice assistant':
        return 'Voice-based interaction will be available in the next major update. This feature will support Kinyarwanda, French, and English.';
      
      case 'ai assistant':
      case 'ai chat':
        return 'AI-powered health assistant is currently in development. It will provide personalized health guidance and answer questions.';
      
      case 'video consultation':
      case 'video call':
        return 'Video consultation with health workers will be available soon. This will enable remote consultations and follow-ups.';
      
      case 'advanced analytics':
      case 'analytics':
        return 'Advanced health analytics and insights are being developed. This will provide detailed health trends and recommendations.';
      
      case 'medication reminders':
        return 'Enhanced medication reminder features are in development. Basic reminders are currently available.';
      
      case 'call':
      case 'phone call':
        return 'Direct calling functionality will be integrated with your device\'s phone app in a future update.';
      
      case 'share':
      case 'sharing':
        return 'Content sharing features are being developed to help you share health information with family and healthcare providers.';
      
      case 'feedback':
        return 'Enhanced feedback and rating system is in development to improve service quality.';
      
      default:
        return 'This feature is currently in development and will be available in a future update.';
    }
  }

  /// Get simple message for snackbar
  static String _getSimpleMessage(String featureName, String? userRole) {
    return '$featureName is coming soon!';
  }

  /// Get status message
  static String _getStatusMessage(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'voice interface':
        return 'Status: In development • Expected: Next major release';
      case 'ai assistant':
        return 'Status: Testing phase • Expected: Coming soon';
      case 'video consultation':
        return 'Status: Integration phase • Expected: Next update';
      case 'advanced analytics':
        return 'Status: Data modeling • Expected: Future release';
      default:
        return 'Status: Planned • Expected: Future update';
    }
  }

  /// Get feature icon
  static IconData _getFeatureIcon(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'voice interface':
      case 'voice assistant':
        return Icons.mic;
      case 'ai assistant':
      case 'ai chat':
        return Icons.smart_toy;
      case 'video consultation':
      case 'video call':
        return Icons.video_call;
      case 'advanced analytics':
      case 'analytics':
        return Icons.analytics;
      case 'medication reminders':
        return Icons.medication;
      case 'call':
      case 'phone call':
        return Icons.phone;
      case 'share':
      case 'sharing':
        return Icons.share;
      case 'feedback':
        return Icons.feedback;
      default:
        return Icons.construction;
    }
  }

  /// Check if feature is available for role
  static bool isFeatureAvailable(String featureName, String? userRole) {
    // Most features are available for all roles in basic form
    // This can be expanded based on specific role requirements
    return true;
  }

  /// Get role-specific feature description
  static String getRoleFeatureDescription(String featureName, String? userRole) {
    if (userRole == null) return _getFeatureMessage(featureName, userRole);
    
    switch (userRole.toLowerCase()) {
      case 'admin':
        return 'As an admin, you will have full access to this feature including management and configuration options.';
      case 'health_worker':
      case 'healthworker':
        return 'As a health worker, this feature will help you provide better care and manage your clients more effectively.';
      case 'client':
      case 'user':
        return 'This feature will help you better manage your health and stay connected with your healthcare providers.';
      default:
        return _getFeatureMessage(featureName, userRole);
    }
  }
}

/// Extension for easy access to feature messaging
extension FeatureMessagingExtension on BuildContext {
  void showFeatureDialog(String featureName, {String? userRole}) {
    FeatureMessaging.showFeatureDialog(
      this,
      featureName: featureName,
      userRole: userRole,
    );
  }

  void showFeatureSnackbar(String featureName, {String? userRole}) {
    FeatureMessaging.showSnackbarMessage(
      this,
      featureName: featureName,
      userRole: userRole,
    );
  }
}
