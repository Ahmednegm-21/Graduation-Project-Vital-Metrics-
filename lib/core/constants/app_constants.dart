import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppConstants {
  AppConstants._();

  // Padding & Margins
  static double get paddingXS => 4.w;
  static double get paddingS => 8.w;
  static double get paddingM => 12.w;
  static double get paddingL => 16.w;
  static double get paddingXL => 20.w;
  static double get paddingXXL => 24.w;

  // Border radius
  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 20.r;
  static double get radiusRound => 30.r;

  // Icon sizes
  static double get iconXS => 16.sp;
  static double get iconS => 20.sp;
  static double get iconM => 24.sp;
  static double get iconL => 32.sp;
  static double get iconXL => 48.sp;

  // Button heights
  static double get buttonHeightS => 32.h;
  static double get buttonHeightM => 38.h;
  static double get buttonHeightL => 42.h;

  // Spacing
  static double get spaceXS => 4.h;
  static double get spaceS => 8.h;
  static double get spaceM => 12.h;
  static double get spaceL => 16.h;
  static double get spaceXL => 20.h;
  static double get spaceXXL => 24.h;
  static double get spaceXXXL => 32.h;

  // Animation durations (milliseconds)
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 600;
  
  // Splash screen animation durations
  static const int splashLogoDuration = 2000;
  static const int splashTextDuration = 1000;
  static const int splashTextDelay = 1500;
  static const int splashNavigationDelay = 4000;
  
  // Auth navigation delay
  static const int authNavigationDelay = 800;

  // App specific constants
  static const double minDailyCaloriesMale = 1500;
  static const double minDailyCaloriesFemale = 1200;
  static const double caloriesPerKg = 1100;
  static const double waterPerKg = 33;
  static const double activityMultiplier = 1.55;

  // Onboarding progress values
  static const double progressGender = 0.20;
  static const double progressHeight = 0.40;
  static const double progressWeight = 0.60;
  static const double progressAge = 0.90;

  // Height range
  static const double minHeight = 120;
  static const double maxHeight = 220;
  static const int heightDivisions = 100;

  // Weight range
  static const double minWeight = 30;
  static const double maxWeight = 150;
  static const int weightDivisions = 120;

  // Age range
  static const double minAge = 10;
  static const double maxAge = 100;
  static const int ageDivisions = 90;

  // Gender toggle dimensions
  static const double genderToggleWidth = 340;
  static const double genderToggleHeight = 86;
  static const double genderTogglePadding = 6;

  // Preview card dimensions
  static const double previewWidthRatio = 0.92;
  static const double previewHeightRatioGender = 0.40;
  static const double previewHeightRatioOther = 0.48;
  
  // Splash screen image sizes
  static const double splashLogoWidth = 250;
  static const double splashTextWidth = 240;
  
  // Social auth button sizes
  static const double socialButtonSize = 60;
  static const double socialIconSizeGoogle = 50;
  static const double socialIconSizeFacebook = 70;
  static const double socialButtonPadding = 12;
}