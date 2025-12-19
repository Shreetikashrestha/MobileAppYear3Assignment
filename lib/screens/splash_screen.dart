import 'package:flutter/material.dart';
import 'dart:async';
import 'onboardingscreens/onboarding1_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen1()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("/Users/shreetikashrestha/Desktop/influcollab_app/assets/images/splashbg.jpg", fit: BoxFit.cover),

          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset(
                "/Users/shreetikashrestha/Desktop/influcollab_app/assets/images/logo.png",
                width: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
