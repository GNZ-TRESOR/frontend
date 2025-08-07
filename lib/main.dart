import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Core imports
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'core/utils/app_constants.dart';

// Feature imports
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/dashboard/role_dashboard.dart';
import 'features/dashboard/admin_dashboard.dart';
import 'features/dashboard/health_worker_dashboard.dart';
import 'features/dashboard/client_dashboard.dart';
import 'features/health_worker/health_worker_main_screen.dart';

// Admin screens
import 'features/admin/user_management_screen.dart';
import 'features/admin/client_management_screen.dart';
import 'features/admin/analytics_screen.dart';
import 'features/admin/reports_screen.dart';
import 'features/admin/content_management_screen.dart';
import 'features/admin/health_facilities_screen.dart' as admin_facilities;
import 'features/admin/system_settings_screen.dart';
import 'features/admin/file_management_screen.dart';

// Common feature screens
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/advanced_settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/messages/messages_tab.dart';
import 'features/appointments/appointments_screen.dart';
import 'features/health_records/health_records_screen.dart';
import 'features/medications/medications_screen.dart';
import 'features/contraception/contraception_screen.dart';
import 'features/menstrual_cycle/menstrual_cycle_screen.dart';
import 'features/sti_testing/sti_testing_screen.dart';
import 'features/education/education_screen.dart';
import 'features/support_groups/support_groups_screen.dart';
import 'features/community_events/community_events_screen.dart';
import 'features/feedback/feedback_screen.dart';
import 'features/health_facilities/health_facilities_screen.dart';

// Family Planning screens
import 'features/pregnancy/pregnancy_planning_screen.dart';
import 'features/pregnancy/due_date_calculator_screen.dart';
import 'features/pregnancy/ovulation_calculator_screen.dart';
import 'features/pregnancy/health_checklist_screen.dart';
import 'features/pregnancy/partner_management_screen.dart';
import 'features/pregnancy/partner_decisions_screen.dart';

// AI Chat
import 'features/ai_chat/screens/chat_assistant_screen.dart';

// Clinic Finder
import 'features/clinic_finder/clinic_finder_screen.dart';

// Providers
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await _initializeServices();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for family planning theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: UbuzimaFamilyPlanningApp()));
}

Future<void> _initializeServices() async {
  try {
    // Initialize app configuration
    await AppConfig.initialize();

    // Initialize storage service
    await StorageService.initialize();

    // Initialize API service
    ApiService.instance.initialize();

    // Initialize TTS service (non-blocking) and set to English
    TTSService()
        .initialize()
        .then((_) {
          // Set TTS to English as requested by user
          TTSService().setEnglish().catchError((e) {
            print('⚠️ TTS English setup failed: $e');
          });
        })
        .catchError((e) {
          print('⚠️ TTS initialization failed: $e');
        });

    print('✅ Ubuzima Family Planning Platform initialized successfully');
  } catch (e) {
    print('❌ Service initialization failed: $e');
  }
}

/// Main application widget for Ubuzima Family Planning Platform
class UbuzimaFamilyPlanningApp extends ConsumerWidget {
  const UbuzimaFamilyPlanningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization support
      locale:
          currentLocale.languageCode == 'rw'
              ? const Locale('en')
              : currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        // Locale('rw'), // Kinyarwanda - temporarily disabled due to MaterialLocalizations support
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Force English for Kinyarwanda until MaterialLocalizations support is added
        if (locale?.languageCode == 'rw') {
          return const Locale('en');
        }

        // If the current device locale is supported, use it
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }

        // Fallback to English for any unsupported locale
        return const Locale('en');
      },

      // Professional family planning theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light theme for family planning
      // Navigation
      initialRoute: '/splash',

      // Route configuration
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const RoleDashboard(),

        // Admin routes
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/admin/users': (context) => const UserManagementScreen(),
        '/admin/clients': (context) => const ClientManagementScreen(),
        '/admin/analytics': (context) => const AnalyticsScreen(),
        '/admin/reports': (context) => const ReportsScreen(),
        '/admin/content': (context) => const ContentManagementScreen(),
        '/admin/facilities':
            (context) => const admin_facilities.HealthFacilitiesScreen(),
        '/admin/settings': (context) => const SystemSettingsScreen(),
        '/admin/files': (context) => const FileManagementScreen(),

        // Health Worker routes
        '/health-worker/dashboard': (context) => const HealthWorkerDashboard(),
        '/health-worker/main': (context) => const HealthWorkerMainScreen(),

        // Client routes
        '/client/dashboard': (context) => const ClientDashboard(),

        // Common feature routes
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/advanced-settings': (context) => const AdvancedSettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/messages': (context) => const MessagesTab(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/health-records': (context) => const HealthRecordsScreen(),
        '/medications': (context) => const MedicationsScreen(),
        '/contraception': (context) => const ContraceptionScreen(),
        '/menstrual-cycle': (context) => const MenstrualCycleScreen(),
        '/sti-testing': (context) => const StiTestingScreen(),
        '/education': (context) => const EducationScreen(),
        '/support-groups': (context) => const SupportGroupsScreen(),
        '/community-events': (context) => const CommunityEventsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/health-facilities': (context) => const HealthFacilitiesScreen(),

        // Family Planning routes
        '/pregnancy-planning': (context) => const PregnancyPlanningScreen(),
        '/due-date-calculator': (context) => const DueDateCalculatorScreen(),
        '/ovulation-calculator': (context) => const OvulationCalculatorScreen(),
        '/health-checklist': (context) => const HealthChecklistScreen(),
        '/partner-management': (context) => const PartnerManagementScreen(),
        '/partner-decisions': (context) => const PartnerDecisionsScreen(),

        // AI Chat
        '/ai-chat': (context) => const ChatAssistantScreen(),

        // Clinic Finder
        '/clinic-finder': (context) => const ClinicFinderScreen(),
      },

      // Error handling
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child,
        );
      },
    );
  }
}

/// Global error handler for family planning app
class FamilyPlanningErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };
  }

  static void _logError(String type, dynamic error, StackTrace? stackTrace) {
    debugPrint('🔴 $type: $error');
    if (stackTrace != null) {
      debugPrint('Stack Trace: $stackTrace');
    }

    // TODO: Send to crash reporting service
  }
}

/// App lifecycle handler for family planning features
class FamilyPlanningLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleAppResumed() {
    debugPrint('📱 Family Planning App resumed - refreshing health data');
    // TODO: Refresh critical health data
  }

  void _handleAppPaused() {
    debugPrint('📱 Family Planning App paused - saving health state');
    // TODO: Save current health tracking state
  }

  void _handleAppDetached() {
    debugPrint('📱 Family Planning App detached - cleanup');
    // TODO: Cleanup resources
  }
}

/// Development wrapper for Health Worker Dashboard testing
/// TODO: Remove this in production
class DevelopmentHealthWorkerWrapper extends ConsumerWidget {
  const DevelopmentHealthWorkerWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a mock health worker user for development
    // Using ID 2 to match the actual health worker in the database
    final mockUser = User(
      id: 2,
      firstName: 'Dr. Marie',
      lastName: 'Uwimana',
      email: 'healthworker@ubuzima.rw',
      role: 'HEALTH_WORKER',
      status: 'ACTIVE',
      phoneNumber: '+250788000002',
      gender: 'FEMALE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Override the auth provider with mock data for development
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) {
          return MockAuthNotifier(mockUser);
        }),
      ],
      child: const HealthWorkerMainScreen(),
    );
  }
}

/// Mock auth notifier for development
/// TODO: Remove this in production
class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(User mockUser) : super() {
    // Override the state with mock authenticated user
    state = AuthState(isAuthenticated: true, isLoading: false, user: mockUser);
  }
}

/// Performance monitoring for family planning features
class FamilyPlanningPerformanceMonitor {
  static void trackHealthAction(
    String action,
    Map<String, dynamic>? parameters,
  ) {
    debugPrint('🩺 Health Action: $action with parameters: $parameters');
    // TODO: Send to analytics service
  }

  static void trackEducationProgress(String lessonId, double progress) {
    debugPrint(
      '📚 Education Progress: Lesson $lessonId - ${(progress * 100).toInt()}%',
    );
    // TODO: Send to analytics service
  }

  static void trackCycleEvent(String event, Map<String, dynamic>? data) {
    debugPrint('🩷 Cycle Event: $event with data: $data');
    // TODO: Send to analytics service
  }
}

/// Security handler for sensitive health data
class HealthDataSecurityHandler {
  static bool _isAppInBackground = false;

  static void initialize() {
    // Initialize health data security monitoring
  }

  static void handleSensitiveHealthOperation() {
    if (_isAppInBackground) {
      throw HealthSecurityException(
        'Cannot access sensitive health data while app is in background',
      );
    }
  }

  static void setAppBackgroundState(bool isInBackground) {
    _isAppInBackground = isInBackground;
  }
}

/// Custom exception for health data security violations
class HealthSecurityException implements Exception {
  final String message;

  HealthSecurityException(this.message);

  @override
  String toString() => 'HealthSecurityException: $message';
}

/// Memory management for health data
class HealthDataMemoryManager {
  static void clearHealthCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static void optimizeHealthDataMemory() {
    // Trigger garbage collection for health data if needed
  }
}

/// Family planning app constants
class FamilyPlanningConstants {
  // Health tracking intervals
  static const Duration cycleReminderInterval = Duration(hours: 24);
  static const Duration medicationReminderInterval = Duration(hours: 8);
  static const Duration appointmentReminderInterval = Duration(hours: 2);

  // Data sync intervals
  static const Duration healthDataSyncInterval = Duration(minutes: 15);
  static const Duration educationProgressSyncInterval = Duration(minutes: 30);

  // Cache durations
  static const Duration healthRecordsCacheDuration = Duration(hours: 1);
  static const Duration educationContentCacheDuration = Duration(hours: 6);
  static const Duration supportGroupsCacheDuration = Duration(minutes: 30);
}
