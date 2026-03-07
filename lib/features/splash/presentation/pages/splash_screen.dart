import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool onboardingCompleted =
        prefs.getBool('onboardingCompleted') ?? false;
    final bool? isInfluencer = prefs.getBool('isInfluencer');

    if (!mounted) return;

    if (isLoggedIn && isInfluencer != null) {
      if (isInfluencer) {
        Navigator.pushReplacementNamed(context, '/influencerDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/brandDashboard');
      }
    } else if (!onboardingCompleted) {
      Navigator.pushReplacementNamed(context, '/onboarding1');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
//login vayepaxi next time kholda splash to dashboard

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/splashbg.jpg", fit: BoxFit.cover),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset(
                "assets/images/logo.png",
                width: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
