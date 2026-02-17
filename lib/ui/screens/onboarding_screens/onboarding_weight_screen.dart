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
import 'package:vital_metrics/logic/onboarding/weight_cubit.dart';
import 'package:vital_metrics/logic/onboarding/weight_state.dart';

class OnboardingWeight extends StatelessWidget {
  const OnboardingWeight({super.key});

  @override
  Widget build(BuildContext context) {
    // Get gender from OnboardingCubitAllData
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';

    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = AppColors.getGenderColor(gender);
    final imagePath = AppAssets.getGenderImage(gender);

    final TextEditingController weightController = TextEditingController();

    return BlocProvider(
      create: (_) => WeightCubit(),
      child: BlocBuilder<WeightCubit, WeightState>(
        builder: (context, state) {
          weightController.text = state.weight.toInt().toString();

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
                          value: OnboardingConfig.getProgressValue('weight'),
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
                    'What is your weight?',
                    style: AppTextStyles.h3,
                  ),

                  SizedBox(height: AppConstants.spaceS.h),

                  // Subtitle
                  Text(
                    'Choose or write your current weight',
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
                              height: 0.46.sh,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rotated background
                                  Transform.rotate(
                                    angle: -0.05,
                                    child: Container(
                                      width: 0.9.sw,
                                      height: 0.88.sh * 0.5,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.radiusL.r),
                                      ),
                                    ),
                                  ),

                                  // Image
                                  Container(
                                    width: 0.9.sw,
                                    height: 0.94.sh * 0.5,
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

                            // Weight controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Decrease button
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: accent,
                                  iconSize: AppConstants.iconM.sp,
                                  onPressed: () {
                                    double newWeight = (state.weight - 1).clamp(
                                      OnboardingConfig.weightConfig['min']!,
                                      OnboardingConfig.weightConfig['max']!,
                                    );
                                    context
                                        .read<WeightCubit>()
                                        .updateWeight(newWeight);
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
                                    controller: weightController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      double? v = double.tryParse(value);
                                      if (v != null &&
                                          v >= OnboardingConfig.weightConfig['min']! &&
                                          v <= OnboardingConfig.weightConfig['max']!) {
                                        context
                                            .read<WeightCubit>()
                                            .updateWeight(v);
                                      } else {
                                        weightController.text =
                                            state.weight.toInt().toString();
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
                                    double newWeight = (state.weight + 1).clamp(
                                      OnboardingConfig.weightConfig['min']!,
                                      OnboardingConfig.weightConfig['max']!,
                                    );
                                    context
                                        .read<WeightCubit>()
                                        .updateWeight(newWeight);
                                  },
                                ),

                                SizedBox(width: AppConstants.spaceS.w),

                                // Unit label
                                Text(
                                  'kg',
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
                                        '${OnboardingConfig.weightConfig['min']!.toInt()} kg',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        '${OnboardingConfig.weightConfig['max']!.toInt()} kg',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: AppConstants.spaceS.h),

                                  // Slider
                                  Slider(
                                    value: state.weight,
                                    min: OnboardingConfig.weightConfig['min']!,
                                    max: OnboardingConfig.weightConfig['max']!,
                                    divisions: OnboardingConfig.weightDivisions,
                                    activeColor: accent,
                                    inactiveColor: accent.withOpacity(0.3),
                                    onChanged: (v) => context
                                        .read<WeightCubit>()
                                        .updateWeight(v),
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
                              .setWeight(state.weight);
                          context.push('/age');
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