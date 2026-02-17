import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get h1 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        height: 1.2,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        height: 1.2,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        height: 1.2,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.3,
      );

  static TextStyle get h5 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.3,
      );

  // Auth screen titles
  static TextStyle get authTitle => TextStyle(
        fontSize: 40.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      );

  static TextStyle get authSubtitle => TextStyle(
        fontSize: 18.sp,
        color: AppColors.white70,
      );

  static TextStyle get authLink => TextStyle(
        fontSize: 14.sp,
        color: AppColors.linkBlue,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get authText => TextStyle(
        fontSize: 14.sp,
        color: AppColors.white70,
      );

  // Body text
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.black,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.black,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
        height: 1.4,
      );

  // Subtitles
  static TextStyle get subtitle1 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.greyDark,
      );

  static TextStyle get subtitle2 => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  // Caption
  static TextStyle get caption => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
      );

  // Button text
  static TextStyle get button => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // Special styles
  static TextStyle get label => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle get value => TextStyle(
        fontSize: 48.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get unit => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle get badge => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // Link style
  static TextStyle get link => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      );

  // Error style
  static TextStyle get error => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.error,
      );
}