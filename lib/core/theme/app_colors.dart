import 'package:flutter/material.dart';

/// Centralized color scheme for the app
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryPurple = Color(0xFF6B46C1); // Deep Purple
  static const Color darkPurple = Color(0xFF553C9A);
  static const Color lightPurple = Color(0xFF9F7AEA);
  static const Color purpleAccent = Color(0xFFB794F4);

  // Text Colors
  static const Color textOnLight = Color(0xFF553C9A); // Deep purple for light backgrounds
  static const Color textOnDark = Color(0xFFE2E8F0); // Light grey for dark backgrounds
  static const Color textSecondaryOnLight = Color(0xFF6B46C1);
  static const Color textSecondaryOnDark = Color(0xFFCBD5E0);

  // Icon Colors
  static const Color iconOnLight = Color(0xFF553C9A); // Deep purple for light backgrounds
  static const Color iconOnDark = Color(0xFFE2E8F0); // Light grey for dark backgrounds
  static const Color iconSecondaryOnLight = Color(0xFF6B46C1);
  static const Color iconSecondaryOnDark = Color(0xFFCBD5E0);

  // Background Colors
  static const Color lightBackground = Color(0xFFF7FAFC);
  static const Color whiteBackground = Colors.white;
  static const Color darkBackground = Color(0xFF2D3748);
  static const Color purpleBackground = Color(0xFF6B46C1);

  // Neutral Colors
  static const Color grey50 = Color(0xFFF7FAFC);
  static const Color grey100 = Color(0xFFEDF2F7);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E0);
  static const Color grey400 = Color(0xFFA0AEC0);
  static const Color grey500 = Color(0xFF718096);
  static const Color grey600 = Color(0xFF4A5568);
  static const Color grey700 = Color(0xFF2D3748);
  static const Color grey800 = Color(0xFF1A202C);
  static const Color grey900 = Color(0xFF171923);

  // Accent Colors
  static const Color blue = Color(0xFF4299E1);
  static const Color green = Color(0xFF48BB78);
  static const Color red = Color(0xFFF56565);
  static const Color orange = Color(0xFFED8936);
  static const Color yellow = Color(0xFFECC94B);

  /// Get text color based on background brightness
  static Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    // If background is light (luminance > 0.5), use deep purple
    // If background is dark (luminance <= 0.5), use light grey
    return luminance > 0.5 ? textOnLight : textOnDark;
  }

  /// Get secondary text color based on background brightness
  static Color getSecondaryTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textSecondaryOnLight : textSecondaryOnDark;
  }

  /// Get icon color based on background brightness
  static Color getIconColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    // If background is light (luminance > 0.5), use deep purple
    // If background is dark (luminance <= 0.5), use light grey
    return luminance > 0.5 ? iconOnLight : iconOnDark;
  }

  /// Get secondary icon color based on background brightness
  static Color getSecondaryIconColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? iconSecondaryOnLight : iconSecondaryOnDark;
  }

  /// Check if background is light
  static bool isLightBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5;
  }
}

/// Text styles with automatic color adaptation
class AppTextStyles {
  AppTextStyles._();

  /// Get text style with color adapted to background
  static TextStyle getHeading1(Color backgroundColor) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.getTextColor(backgroundColor),
    );
  }

  static TextStyle getHeading2(Color backgroundColor) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.getTextColor(backgroundColor),
    );
  }

  static TextStyle getHeading3(Color backgroundColor) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.getTextColor(backgroundColor),
    );
  }

  static TextStyle getBodyLarge(Color backgroundColor) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.getTextColor(backgroundColor),
    );
  }

  static TextStyle getBodyMedium(Color backgroundColor) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.getTextColor(backgroundColor),
    );
  }

  static TextStyle getBodySmall(Color backgroundColor) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.getSecondaryTextColor(backgroundColor),
    );
  }

  static TextStyle getCaption(Color backgroundColor) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.getSecondaryTextColor(backgroundColor),
    );
  }
}

/// Icon theme with automatic color adaptation
class AppIconTheme {
  AppIconTheme._();

  /// Get icon theme data adapted to background
  static IconThemeData getIconTheme(Color backgroundColor) {
    return IconThemeData(
      color: AppColors.getIconColor(backgroundColor),
      size: 24,
    );
  }

  /// Get small icon theme
  static IconThemeData getSmallIconTheme(Color backgroundColor) {
    return IconThemeData(
      color: AppColors.getIconColor(backgroundColor),
      size: 20,
    );
  }

  /// Get large icon theme
  static IconThemeData getLargeIconTheme(Color backgroundColor) {
    return IconThemeData(
      color: AppColors.getIconColor(backgroundColor),
      size: 32,
    );
  }

  /// Get secondary icon theme (lighter/muted)
  static IconThemeData getSecondaryIconTheme(Color backgroundColor) {
    return IconThemeData(
      color: AppColors.getSecondaryIconColor(backgroundColor),
      size: 24,
    );
  }
}

