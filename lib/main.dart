import 'package:flutter/material.dart';
import 'core/services/hive_service.dart';
import 'features/home/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding1_screen.dart';
import 'features/onboarding/presentation/pages/onboarding2_screen.dart';
import 'features/onboarding/presentation/pages/onboarding3_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Influcollab App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding1': (context) => const OnboardingScreen1(),
        '/onboarding2': (context) => const OnboardingScreen2(),
        '/onboarding3': (context) => const OnboardingScreen3(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
