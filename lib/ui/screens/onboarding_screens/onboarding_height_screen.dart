import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/onboarding_config.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding/height_cubit.dart';
import 'package:vital_metrics/logic/onboarding/height_state.dart';

class OnboardingHeight extends StatelessWidget {
  const OnboardingHeight({super.key});

  @override
  Widget build(BuildContext context) {
    // Get gender from OnboardingCubitAllData
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';

    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = AppColors.getGenderColor(gender);
    final imagePath = AppAssets.getGenderImage(gender);

    final TextEditingController heightController = TextEditingController();

    return BlocProvider(
      create: (_) => HeightCubit(),
      child: BlocBuilder<HeightCubit, HeightState>(
        builder: (context, state) {
          heightController.text = state.height.toInt().toString();

          return Scaffold(
            backgroundColor: AppColors.white,

            // AppBar with back button and progress
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: AppConstants.iconS.sp,
                    ),
                    color: accent,
                    onPressed: () => context.pop(),
                  ),

                  // Progress bar
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: AppConstants.paddingL.w),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM.r),
                        child: LinearProgressIndicator(
                          value: OnboardingConfig.getProgressValue('height'),
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
              child: Column(
                children: [
                  SizedBox(height: AppConstants.spaceS.h),

                  // Title
                  Text(
                    'What is your height?',
                    style: AppTextStyles.h3,
                  ),

                  SizedBox(height: AppConstants.spaceS.h),

                  // Subtitle
                  Text(
                    'Choose or write your current height',
                    style: AppTextStyles.subtitle2,
                  ),

                  SizedBox(height: AppConstants.spaceM.h),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL.w,
                          vertical: AppConstants.spaceS.h,
                        ),
                        child: Column(
                          children: [
                            // Preview image
                            SizedBox(
                              width: OnboardingConfig.previewWidthRatio.sw,
                              height: OnboardingConfig.previewHeightRatioOther.sh,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rotated background
                                  Transform.rotate(
                                    angle: -0.06,
                                    child: Container(
                                      width: 0.83.sw,
                                      height: 0.39.sh,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.radiusL.r),
                                      ),
                                    ),
                                  ),

                                  // Image
                                  Container(
                                    width: 0.83.sw,
                                    height: 0.41.sh,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.radiusL.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(AppConstants.paddingM.w),
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(
                                          isMale ? Icons.man : Icons.woman,
                                          size: AppConstants.iconXL * 3,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppConstants.spaceL.h),

                            // Height controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Decrease button
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: accent,
                                  iconSize: AppConstants.iconM.sp,
                                  onPressed: () {
                                    double newHeight = (state.height - 1).clamp(
                                      OnboardingConfig.heightConfig['min']!,
                                      OnboardingConfig.heightConfig['max']!,
                                    );
                                    context
                                        .read<HeightCubit>()
                                        .updateHeight(newHeight);
                                  },
                                ),

                                // Text input
                                Container(
                                  width: 100.w,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingM.w,
                                    vertical: AppConstants.spaceS.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusM.r),
                                  ),
                                  child: TextField(
                                    controller: heightController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      double? v = double.tryParse(value);
                                      if (v != null &&
                                          v >= OnboardingConfig.heightConfig['min']! &&
                                          v <= OnboardingConfig.heightConfig['max']!) {
                                        context
                                            .read<HeightCubit>()
                                            .updateHeight(v);
                                      } else {
                                        heightController.text =
                                            state.height.toInt().toString();
                                      }
                                    },
                                  ),
                                ),

                                // Increase button
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: accent,
                                  iconSize: AppConstants.iconM.sp,
                                  onPressed: () {
                                    double newHeight = (state.height + 1).clamp(
                                      OnboardingConfig.heightConfig['min']!,
                                      OnboardingConfig.heightConfig['max']!,
                                    );
                                    context
                                        .read<HeightCubit>()
                                        .updateHeight(newHeight);
                                  },
                                ),

                                SizedBox(width: AppConstants.spaceS.w),

                                // Unit label
                                Text(
                                  'cm',
                                  style: AppTextStyles.value.copyWith(
                                    fontSize: 28.sp,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppConstants.spaceM.h),

                            // Slider with labels
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.spaceS.w,
                              ),
                              child: Column(
                                children: [
                                  // Min/Max labels
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${OnboardingConfig.heightConfig['min']!.toInt()} cm',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        '${OnboardingConfig.heightConfig['max']!.toInt()} cm',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: AppConstants.spaceS.h),

                                  // Slider
                                  Slider(
                                    value: state.height,
                                    min: OnboardingConfig.heightConfig['min']!,
                                    max: OnboardingConfig.heightConfig['max']!,
                                    divisions: OnboardingConfig.heightDivisions,
                                    activeColor: accent,
                                    inactiveColor: accent.withOpacity(0.3),
                                    onChanged: (v) => context
                                        .read<HeightCubit>()
                                        .updateHeight(v),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppConstants.spaceM.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Next button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL.w,
                      vertical: AppConstants.spaceM.h,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightL.h,
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<OnboardingCubitAllData>()
                              .setHeight(state.height);
                          context.push('/weight');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM.r),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}