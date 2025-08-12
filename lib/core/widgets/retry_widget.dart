import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable widget for displaying error states with retry functionality
class RetryWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;
  final bool isLoading;
  final Widget? customContent;

  const RetryWidget({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
    this.iconColor,
    this.isLoading = false,
    this.customContent,
  });

  /// Factory constructor for API connection errors
  factory RetryWidget.apiError({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return RetryWidget(
      key: key,
      title: title ?? 'Connection Error',
      message: message ?? 'Unable to connect to server. Please check your internet connection and try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for general errors
  factory RetryWidget.generalError({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return RetryWidget(
      key: key,
      title: title ?? 'Something went wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for no data states
  factory RetryWidget.noData({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return RetryWidget(
      key: key,
      title: title ?? 'No Data Available',
      message: message ?? 'No data found. Pull down to refresh or try again.',
      buttonText: 'Refresh',
      onRetry: onRetry,
      icon: Icons.inbox_outlined,
      iconColor: Colors.grey,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for timeout errors
  factory RetryWidget.timeout({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return RetryWidget(
      key: key,
      title: title ?? 'Request Timeout',
      message: message ?? 'The request took too long to complete. Please try again.',
      buttonText: 'Try Again',
      onRetry: onRetry,
      icon: Icons.access_time,
      iconColor: Colors.orange,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customContent != null) ...[
              customContent!,
            ] else ...[
              // Error icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.grey).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline,
                  size: 48,
                  color: iconColor ?? Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              // Message
              if (message != null) ...[
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ],

            // Retry button
            if (onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onRetry,
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(Icons.refresh),
                  label: Text(
                    isLoading ? 'Loading...' : (buttonText ?? 'Retry'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact retry widget for use in smaller spaces like list items
class CompactRetryWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isLoading;

  const CompactRetryWidget({
    super.key,
    this.message,
    this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Failed to load data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: isLoading ? null : onRetry,
              icon: isLoading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.refresh, size: 16),
              label: Text(
                isLoading ? 'Loading...' : 'Retry',
                style: const TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A banner retry widget for use at the top of screens
class RetryBanner extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isLoading;
  final bool isVisible;

  const RetryBanner({
    super.key,
    this.message,
    this.onRetry,
    this.isLoading = false,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[800],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Connection error',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: isLoading ? null : onRetry,
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange[800]!,
                        ),
                      ),
                    )
                  : Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
