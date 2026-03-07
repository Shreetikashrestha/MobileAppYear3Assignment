import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/app/routes/app_routes.dart';
import 'package:influcollb_app/app/theme/app_theme.dart';
import 'package:influcollb_app/core/providers/theme_provider.dart';
import 'package:influcollb_app/core/services/sensor/shake_detector_service.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final ShakeDetectorService _shakeService = ShakeDetectorService();

  @override
  void initState() {
    super.initState();
    _initShakeDetection();
  }

  void _initShakeDetection() {
    _shakeService.startListening(
      onShake: () {
        _onShakeDetected();
      },
      minimumShakeCount: 3, // Shake 3 times to toggle dark mode
      shakeCountResetTime: 2000, // Must shake 3 times within 2 seconds
    );
  }

  void _onShakeDetected() {
    // Get current theme BEFORE toggling to know what we're switching TO
    final wasLight = ref.read(themeModeProvider) == ThemeMode.light;
    ref.read(themeModeProvider.notifier).toggleTheme();

    // After toggle: if it was light, now it's dark (and vice versa)
    final isNowDark = wasLight;

    // Show a visual feedback
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNowDark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              isNowDark ? '🌙 Dark Mode Enabled' : '☀️ Light Mode Enabled',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor:
            isNowDark ? const Color(0xFF7B2CBF) : const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _shakeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'InfluCollab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

/// Global navigator key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
