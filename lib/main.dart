import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';
import 'providers/app_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await StorageService.init();
  await NotificationService.init();
  await PreferencesService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final bool isOnboardingCompleted = PreferencesService.isOnboardingCompleted();

          return MaterialApp(
            title: 'Miui',
            debugShowCheckedModeBanner: false,
            theme: appProvider.currentThemeData,
            home: isOnboardingCompleted ? const MainNavigation() : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
