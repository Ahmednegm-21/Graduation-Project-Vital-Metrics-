import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class AppDecorations {
  AppDecorations._();

  //Auth screen gradient background
  static BoxDecoration get authGradientBackground => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.authGradient,
        ),
      );

  // Card decorations
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

  // Gradient decorations
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
      );

  // Badge decorations
  static BoxDecoration badge({required Color color}) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      );

  // Info card decorations
  static BoxDecoration get infoCard => BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.shade100,
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

  // Button container decoration
  static BoxDecoration get buttonContainer => BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      );

  // Input decorations
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

  // Icon container decorations
  static BoxDecoration iconContainer({required Color color}) => BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      );

  static BoxDecoration get iconContainerPrimary => BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      );
}