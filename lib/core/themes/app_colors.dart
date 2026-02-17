import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF005EBD);
  static const Color primaryLight = Color(0xFF0077ED);
  static const Color primaryDark = Color(0xFF003D7A);

  // Gender colors
  static const Color maleBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  // Secondary colors
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // Accent colors
  static const Color accent = Color(0xFF4C4DDC);
  
  // Auth screen colors
  static const Color authGradientTop = Color(0xFF041374);
  static const Color authGradientBottom = Color(0xFF01010E);
  
  // Splash screen color
  static const Color splashBackground = Color(0xFF090432);
  
  // Goal colors
  static const Color weightLoss = Color(0xFF81D4FA);
  static const Color weightLossLight = Color(0xFFB3E5FC);
  static const Color weightGain = Color(0xFFFFCC80);
  static const Color weightGainLight = Color(0xFFFFE0B2);

  // Speed category colors
  static const Color slow = Colors.green;
  static const Color moderate = Colors.orange;
  static const Color fast = Colors.red;

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  static const Color white70 = Colors.white70;

  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;

  // Success/Error/Warning/Info
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color linkBlue = Colors.blue;

  // Gradient colors
  static List<Color> get primaryGradient => [
        primary.withOpacity(0.1),
        primary.withOpacity(0.05),
      ];

  static List<Color> get cardGradient => [
        primary.withOpacity(0.08),
        white,
      ];

  // Auth gradient
  static List<Color> get authGradient => [
        authGradientTop,
        authGradientBottom,
      ];

  // Border colors
  static Color get borderLight => grey.withOpacity(0.3);
  static Color get borderDark => grey.withOpacity(0.5);
  static Color get primaryBorder => primary.withOpacity(0.2);

  // Shadow colors
  static Color get shadowLight => black.withOpacity(0.05);
  static Color get shadowDark => black.withOpacity(0.1);

  // Helper method to get color by gender
  static Color getGenderColor(String gender) {
    return gender.toLowerCase() == 'male' ? maleBlue : femalePink;
  }
}