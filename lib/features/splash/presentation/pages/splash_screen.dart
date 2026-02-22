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
    final String? role = prefs.getString('userRole');

    if (!mounted) return;

    if (isLoggedIn && role != null) {
      if (role == 'influencer') {
        Navigator.pushReplacementNamed(context, '/influencerDashboard');
      } else if (role == 'brand') {
        Navigator.pushReplacementNamed(context, '/brandDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
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
