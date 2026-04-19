import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

class OnboardingThankYou extends StatelessWidget {
  const OnboardingThankYou({super.key});

  @override
  Widget build(BuildContext context) {
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';
    final Color accent = AppColors.getGenderColor(gender);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: AppConstants.iconS.sp),
              color: accent,
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: AppConstants.paddingL.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 4.h,
                    backgroundColor: AppColors.greyLight,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              SizedBox(
                height: 0.28.sh,
                child: Image.asset(
                  AppAssets.thanksImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.verified_user,
                    size: 0.28.sh * 0.7,
                    color: accent,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              Text(
                'Thank you for\ntrusting us!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2,
              ),

              SizedBox(height: AppConstants.spaceL.h),

              Text(
                'Your privacy and security matter to us.\n'
                'We promise to always keep your personal information\n'
                'private and secure.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(height: 1.5),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeightL.h,
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ Just navigate - no API call here
                    context.push('/goal-selection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM.r),
                    ),
                  ),
                  child: Text('Continue', style: AppTextStyles.button),
                ),
              ),

              SizedBox(height: AppConstants.paddingXXL.h),
            ],
          ),
        ),
      ),
    );
  }
}