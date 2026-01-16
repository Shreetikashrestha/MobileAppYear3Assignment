import 'package:flutter/material.dart';
import 'package:influcollb_app/features/auth/presentation/pages/login_screen.dart';
import 'package:influcollb_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:influcollb_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:influcollb_app/features/home/presentation/pages/home_screen.dart';
import 'package:influcollb_app/features/onboarding/presentation/pages/onboarding1_screen.dart';
import 'package:influcollb_app/features/onboarding/presentation/pages/onboarding2_screen.dart';
import 'package:influcollb_app/features/onboarding/presentation/pages/onboarding3_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding1 = '/onboarding1';
  static const String onboarding2 = '/onboarding2';
  static const String onboarding3 = '/onboarding3';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding1: (context) => const OnboardingScreen1(),
    onboarding2: (context) => const OnboardingScreen2(),
    onboarding3: (context) => const OnboardingScreen3(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    home: (context) => const HomeScreen(),
  };
}
