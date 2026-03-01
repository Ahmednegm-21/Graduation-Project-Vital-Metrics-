import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF005EBD);
  static const Color primaryLight = Color(0xFF0077ED);
  static const Color primaryDark  = Color(0xFF003D7A);

  // ── Gender ────────────────────────────────────────────────────────────────
  static const Color maleBlue   = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary      = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF4C4DDC);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const Color authGradientTop    = Color(0xFF041374);
  static const Color authGradientBottom = Color(0xFF01010E);

  // ── Splash ────────────────────────────────────────────────────────────────
  static const Color splashBackground = Color(0xFF090432);

  // ── Goal ──────────────────────────────────────────────────────────────────
  static const Color weightLoss      = Color(0xFF81D4FA);
  static const Color weightLossLight = Color(0xFFB3E5FC);
  static const Color weightGain      = Color(0xFFFFCC80);
  static const Color weightGainLight = Color(0xFFFFE0B2);

  // ── Speed ─────────────────────────────────────────────────────────────────
  static const Color slow     = Colors.green;
  static const Color moderate = Colors.orange;
  static const Color fast     = Colors.red;

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color white     = Colors.white;
  static const Color black     = Colors.black;
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark  = Color(0xFF616161);
  static const Color white70   = Colors.white70;

  // ── Background ────────────────────────────────────────────────────────────
  static const Color background      = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackground  = Colors.white;

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF4CAF50);
  static const Color error    = Color(0xFFF44336);
  static const Color warning  = Color(0xFFFFC107);
  static const Color info     = Color(0xFF2196F3);
  static const Color linkBlue = Colors.blue;

  // ── Macros ────────────────────────────────────────────────────────────────
  static const Color protein = Color(0xFFFFA94D);
  static const Color carbs   = Color(0xFF63E6BE);
  static const Color fat     = Color(0xFFFF8787);

  // ── BMI ───────────────────────────────────────────────────────────────────
  static const Color bmiUnderweight = Color(0xFF4CC9F0);
  static const Color bmiNormal      = Color(0xFF63E6BE);
  static const Color bmiOverweight  = Color(0xFFFFA94D);
  static const Color bmiObese       = Color(0xFFFF8787);

  // ── Light Mode ────────────────────────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF6F8FF);
  static const Color lightCard    = Colors.white;
  static const Color lightText    = Color(0xFF2D3142);
  static const Color lightSubText = Color(0xFF9E9E9E);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF1A1A2E);
  static const Color darkCard    = Color(0xFF16213E);
  static const Color darkText    = Colors.white;
  static const Color darkSubText = Color(0x8AFFFFFF);

  // ── Gradients ───────────────────────────────────────────────
  static List<Color> get primaryGradient => [
        primary.withOpacity(0.1),
        primary.withOpacity(0.05),
      ];

  static List<Color> get cardGradient => [
        primary.withOpacity(0.08),
        white,
      ];

  static List<Color> get authGradient => [
        authGradientTop,
        authGradientBottom,
      ];

  // ── Full Gradient Objects ─────────────────────────────────────────────────
  static const LinearGradient primaryGradientFull = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient femaleGradient = LinearGradient(
    colors: [Color(0xFF7B5EA7), Color(0xFFF72585)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Borders ───────────────────────────────────────────────────────────────
  static Color get borderLight   => grey.withOpacity(0.3);
  static Color get borderDark    => grey.withOpacity(0.5);
  static Color get primaryBorder => primary.withOpacity(0.2);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static Color get shadowLight => black.withOpacity(0.05);
  static Color get shadowDark  => black.withOpacity(0.1);

  // ── Theme Helpers ─────────────────────────────────────────────────────────
  static Color bg(bool isDark)      => isDark ? darkBg      : lightBg;
  static Color card(bool isDark)    => isDark ? darkCard    : lightCard;
  static Color text(bool isDark)    => isDark ? darkText    : lightText;
  static Color subText(bool isDark) => isDark ? darkSubText : lightSubText;
  static Color shadow(bool isDark)  =>
      isDark ? Colors.black45 : black.withOpacity(0.07);

  static Color getGenderColor(String gender) =>
      gender.toLowerCase() == 'male' ? maleBlue : femalePink;

  // ── Food Swap Feature ─────────────────────────────────────────────────────
  static const Color swapGreen      = Color(0xFF34C759);
  static const Color swapGreenLight = Color(0xFF30D158);
  static const Color swapBlue       = Color(0xFF4361EE);
  static const Color swapBlueLight  = Color(0xFF4CC9F0);
  static const Color swapOrange     = Color(0xFFFF9500);
  static const Color swapOrangeLight = Color(0xFFFFCC02);
  static const Color swapRed        = Color(0xFFFF3B30);
  static const Color swapRedLight   = Color(0xFFFF6B6B);
  static const Color swapPurple     = Colors.purple;

  /// 4 gradients swap
  static const List<List<Color>> swapGradients = [
    [Color(0xFF34C759), Color(0xFF30D158)],
    [Color(0xFF4361EE), Color(0xFF4CC9F0)],
    [Color(0xFFFF9500), Color(0xFFFFCC02)],
    [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
  ];

  static List<Color> swapGradient(int index) =>
      swapGradients[index % swapGradients.length];

  // ── Favorites Feature ─────────────────────────────────────────────────────
  static const Color favoriteOrange  = Color(0xFFFF9500);
  static const Color favoriteYellow  = Color(0xFFFFCC02);
  static LinearGradient get favoriteGradient => const LinearGradient(
        colors: [favoriteOrange, favoriteYellow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}