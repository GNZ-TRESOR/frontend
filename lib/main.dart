import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/language_service.dart';
import 'core/services/voice_service.dart';
import 'core/services/rural_optimization_service.dart';
import 'core/services/http_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/backend_sync_service_simple.dart' as sync;
import 'core/localization/custom_material_localizations.dart';
import 'l10n/app_localizations_delegate.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize backend services
  await _initializeServices();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageService()),
        ChangeNotifierProvider(create: (context) => VoiceService()),
        ChangeNotifierProvider(create: (context) => RuralOptimizationService()),
      ],
      child: const UbuzimaApp(),
    ),
  );
}

// Initialize all backend services
Future<void> _initializeServices() async {
  try {
    // Initialize HTTP client
    HttpClient().initialize();

    // Initialize auth service
    await AuthService().initialize();

    // Initialize sync service (will check connectivity)
    final syncService = sync.BackendSyncService();

    // Try to sync if online
    if (await syncService.isOnline()) {
      syncService
          .startSync()
          .then((_) {
            debugPrint('✅ Initial sync completed');
          })
          .catchError((error) {
            debugPrint('❌ Initial sync error: $error');
          });
    }
  } catch (e) {
    debugPrint('❌ Service initialization error: $e');
  }
}

class UbuzimaApp extends StatelessWidget {
  const UbuzimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Localization support
          locale: languageService.currentLocale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            CustomMaterialLocalizationsDelegate(),
            CustomCupertinoLocalizationsDelegate(),
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizationsDelegate.supportedLocales,

          // Fallback locale for unsupported locales
          localeResolutionCallback: (locale, supportedLocales) {
            // If the current locale is supported by our app, use it
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }

            // Fallback to English for other unsupported locales
            return const Locale('en', '');
          },

          home: const SplashScreen(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(
                  1.0,
                ), // Prevent text scaling
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
