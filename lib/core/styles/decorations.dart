import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart'; // عدّل المسار حسب مشروعك

class AppDecorations {
  AppDecorations._();

  // ───────────── AUTH SCREEN ─────────────
  static BoxDecoration get authGradientBackground => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.authGradient,
        ),
      );

  // ───────────── CARD DECORATIONS ─────────────
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get cardWithBorder => BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardSelected({Color? color}) => BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color ?? AppColors.primary,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.primary).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      );

  // ───────────── GRADIENT CARDS ─────────────
  static BoxDecoration get primaryGradient => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryBorder,
          width: 1.5,
        ),
      );

  static BoxDecoration get cardGradient => BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16.r),
      );

  // ───────────── HOME DECORATIONS ─────────────
  static BoxDecoration homeCard({bool isDark = false}) => BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static BoxDecoration homeRoundedCard({
    bool isDark = false,
    double radius = 20,
  }) =>
      BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration homePrimaryGradient({double radius = 20}) =>
      BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration iconButton({bool isDark = false}) => BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.07),
            blurRadius: 10,
          ),
        ],
      );

  static BoxDecoration outlinedChip({
    bool isSelected = false,
    bool isDark = false,
  }) =>
      BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      );

  static BoxDecoration progressTrack({
    required Color color,
    bool isDark = false,
  }) =>
      BoxDecoration(
        color: isDark ? Colors.white12 : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      );

  static BoxDecoration progressFill({required Color color}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
        ],
      );
}