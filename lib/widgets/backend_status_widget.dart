import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/language_service.dart';
import '../core/services/backend_sync_service_simple.dart';
import '../core/services/http_client.dart';

class BackendStatusWidget extends StatefulWidget {
  const BackendStatusWidget({super.key});

  @override
  State<BackendStatusWidget> createState() => _BackendStatusWidgetState();
}

class _BackendStatusWidgetState extends State<BackendStatusWidget> {
  bool _isOnline = false;
  bool _isBackendHealthy = false;
  DateTime? _lastSyncTime;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final syncService = BackendSyncService();
      final httpClient = HttpClient();

      // Check internet connectivity
      _isOnline = await syncService.isOnline();

      // Check backend health
      if (_isOnline) {
        _isBackendHealthy = await httpClient.checkBackendHealth();
      } else {
        _isBackendHealthy = false;
      }

      // Get last sync time
      _lastSyncTime = syncService.lastSyncTime;
    } catch (e) {
      debugPrint('Status check error: $e');
      _isOnline = false;
      _isBackendHealthy = false;
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _performSync() async {
    final syncService = BackendSyncService();

    setState(() {
      _isChecking = true;
    });

    try {
      await syncService.startSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync completed successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );

        // Update last sync time
        _lastSyncTime = DateTime.now();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync error: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
      await _checkStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusTitle(
                        languageService.currentLocale.languageCode,
                      ),
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                    const Spacer(),
                    if (_isChecking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _checkStatus,
                        tooltip: _getRefreshTooltip(
                          languageService.currentLocale.languageCode,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusDescription(
                    languageService.currentLocale.languageCode,
                  ),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (_lastSyncTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getLastSyncText(
                      languageService.currentLocale.languageCode,
                    ),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
                if (_isOnline && _isBackendHealthy) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _performSync,
                      icon: const Icon(Icons.sync, size: 16),
                      label: Text(
                        _getSyncButtonText(
                          languageService.currentLocale.languageCode,
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
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

  IconData _getStatusIcon() {
    if (!_isOnline) return Icons.wifi_off;
    if (!_isBackendHealthy) return Icons.error_outline;
    return Icons.cloud_done;
  }

  Color _getStatusColor() {
    if (!_isOnline) return AppTheme.warningColor;
    if (!_isBackendHealthy) return AppTheme.errorColor;
    return AppTheme.successColor;
  }

  String _getStatusTitle(String language) {
    if (!_isOnline) {
      switch (language) {
        case 'rw':
          return 'Nta murandasi';
        case 'fr':
          return 'Hors ligne';
        default:
          return 'Offline';
      }
    }

    if (!_isBackendHealthy) {
      switch (language) {
        case 'rw':
          return 'Seriveri ntiboneka';
        case 'fr':
          return 'Serveur indisponible';
        default:
          return 'Server Unavailable';
      }
    }

    switch (language) {
      case 'rw':
        return 'Byunze';
      case 'fr':
        return 'Connecté';
      default:
        return 'Connected';
    }
  }

  String _getStatusDescription(String language) {
    if (!_isOnline) {
      switch (language) {
        case 'rw':
          return 'Reba ko ufite internet';
        case 'fr':
          return 'Vérifiez votre connexion internet';
        default:
          return 'Check your internet connection';
      }
    }

    if (!_isBackendHealthy) {
      switch (language) {
        case 'rw':
          return 'Seriveri ntiboneka. Ongera ugerageze nyuma';
        case 'fr':
          return 'Serveur indisponible. Réessayez plus tard';
        default:
          return 'Server unavailable. Try again later';
      }
    }

    switch (language) {
      case 'rw':
        return 'Byose birakora neza';
      case 'fr':
        return 'Tout fonctionne correctement';
      default:
        return 'Everything is working properly';
    }
  }

  String _getLastSyncText(String language) {
    if (_lastSyncTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo =
          language == 'rw'
              ? 'vuba aha'
              : language == 'fr'
              ? 'à l\'instant'
              : 'just now';
    } else if (difference.inHours < 1) {
      timeAgo =
          language == 'rw'
              ? '${difference.inMinutes} iminota ishize'
              : language == 'fr'
              ? 'il y a ${difference.inMinutes} minutes'
              : '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      timeAgo =
          language == 'rw'
              ? '${difference.inHours} amasaha ashize'
              : language == 'fr'
              ? 'il y a ${difference.inHours} heures'
              : '${difference.inHours} hours ago';
    } else {
      timeAgo =
          language == 'rw'
              ? '${difference.inDays} iminsi ishize'
              : language == 'fr'
              ? 'il y a ${difference.inDays} jours'
              : '${difference.inDays} days ago';
    }

    switch (language) {
      case 'rw':
        return 'Byahurijwe: $timeAgo';
      case 'fr':
        return 'Dernière sync: $timeAgo';
      default:
        return 'Last synced: $timeAgo';
    }
  }

  String _getRefreshTooltip(String language) {
    switch (language) {
      case 'rw':
        return 'Reba uko bimeze';
      case 'fr':
        return 'Vérifier le statut';
      default:
        return 'Check status';
    }
  }

  String _getSyncButtonText(String language) {
    switch (language) {
      case 'rw':
        return 'Huza amakuru';
      case 'fr':
        return 'Synchroniser';
      default:
        return 'Sync Now';
    }
  }

  String _getSyncSuccessMessage(int count) {
    final language =
        Provider.of<LanguageService>(
          context,
          listen: false,
        ).currentLocale.languageCode;

    switch (language) {
      case 'rw':
        return 'Byahurijwe neza: $count ibintu';
      case 'fr':
        return 'Synchronisation réussie: $count éléments';
      default:
        return 'Sync successful: $count items';
    }
  }
}
