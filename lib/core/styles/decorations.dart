import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

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
        color: AppColors.white,
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
        color: AppColors.white,
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
        color: AppColors.white,
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

  // ───────────── GRADIENT DECORATIONS ─────────────
  static BoxDecoration get primaryGradient => BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

  // ───────────── BADGE DECORATIONS ─────────────
  static BoxDecoration badge({required Color color}) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      );

  // ───────────── INFO CARD DECORATIONS ─────────────
  // ✅ دمجنا التعريفين — استخدام ألوان AppColors مع primary tint
  static BoxDecoration get infoCard => BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      );

  static BoxDecoration get successCard => BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      );

  static BoxDecoration get warningCard => BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.shade100,
        ),
      );

  // ───────────── BUTTON CONTAINER ─────────────
  // ✅ دمجنا التعريفين — استخدام AppColors.lightCard مع shadow محسوب
  static BoxDecoration get buttonContainer => BoxDecoration(
        color: AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      );

  // ───────────── INPUT DECORATIONS ─────────────
  static BoxDecoration get input => BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.5,
        ),
      );

  static BoxDecoration get inputFocused => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      );

  // ───────────── ICON CONTAINER DECORATIONS ─────────────
  static BoxDecoration iconContainer({required Color color}) => BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      );

  static BoxDecoration get iconContainerPrimary => BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      );
}