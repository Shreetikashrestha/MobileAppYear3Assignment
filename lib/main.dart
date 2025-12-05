import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboardingscreens/onboarding1_screen.dart';
import 'screens/onboardingscreens/onboarding2_screen.dart';
import 'screens/onboardingscreens/onboarding3_screen.dart';
// import 'screens/onboarding/onboarding_screen3.dart'; // Add when you create it
import 'screens/loginSignup/signup_screen.dart';

import 'screens/home/home_screen.dart';
void main() {
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
      // Set splash screen as the initial route
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