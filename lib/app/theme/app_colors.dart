import 'package:flutter/material.dart';

class AppColors {
  //lavender shades
  static const Color primary = Color(0xFF9F7AEA);
  static const Color primaryLight = Color(0xFFB798F0);
  static const Color primaryDark = Color(0xFF6B4FB8);

  // Background Colors
  static const Color backgroundColor = Color(0xFFE8E4F3);
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Colors.white;

  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color textLight = Color(0xFF999999);

  // Status Colors
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // Utility Colors
  static const Color shadowColor = Colors.black;
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFB798F0), Color(0xFF9F7AEA)],
  );
}
