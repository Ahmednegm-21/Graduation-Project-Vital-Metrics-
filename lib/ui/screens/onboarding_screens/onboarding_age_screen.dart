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
import 'package:vital_metrics/logic/onboarding/age_cubit.dart';
import 'package:vital_metrics/logic/onboarding/age_state.dart';

class OnboardingAge extends StatelessWidget {
  const OnboardingAge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgeCubit(),
      child: const _OnboardingAgeView(),
    );
  }
}

class _OnboardingAgeView extends StatefulWidget {
  const _OnboardingAgeView();

  @override
  State<_OnboardingAgeView> createState() => _OnboardingAgeViewState();
}

class _OnboardingAgeViewState extends State<_OnboardingAgeView> {
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get gender from OnboardingCubitAllData
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';

    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = AppColors.getGenderColor(gender);
    final imagePath = AppAssets.getGenderImage(gender);

    return BlocBuilder<AgeCubit, AgeState>(
      builder: (context, state) {
        // Update text controller if not composing
        if (!_ageController.value.composing.isValid) {
          _ageController.text = state.age.toInt().toString();
        }

        return Scaffold(
          backgroundColor: AppColors.white,

          // AppBar with back button and progress
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            foregroundColor: AppColors.black,
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
                        value: OnboardingConfig.getProgressValue('age'),
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
                  'What is your birth date?',
                  style: AppTextStyles.h3,
                ),

                SizedBox(height: AppConstants.spaceS.h),

                // Subtitle
                Text(
                  'Pick your age or your birth date',
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
                          // Preview image with rotation effect
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

                                // Image container
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

                          // Age controls with birth date picker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Decrease button
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: accent,
                                iconSize: AppConstants.iconM.sp,
                                onPressed: () {
                                  double newAge = (state.age - 1).clamp(
                                    OnboardingConfig.ageConfig['min']!,
                                    OnboardingConfig.ageConfig['max']!,
                                  );
                                  context.read<AgeCubit>().updateAge(newAge);
                                },
                              ),

                              // Text input
                              Container(
                                width: 110.w,
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
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (value) {
                                    double? v = double.tryParse(value);
                                    if (v != null &&
                                        v >= OnboardingConfig.ageConfig['min']! &&
                                        v <= OnboardingConfig.ageConfig['max']!) {
                                      context.read<AgeCubit>().updateAge(v);
                                    } else {
                                      _ageController.text =
                                          state.age.toInt().toString();
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
                                  double newAge = (state.age + 1).clamp(
                                    OnboardingConfig.ageConfig['min']!,
                                    OnboardingConfig.ageConfig['max']!,
                                  );
                                  context.read<AgeCubit>().updateAge(newAge);
                                },
                              ),

                              SizedBox(width: AppConstants.spaceS.w),

                              // Birth date picker button
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().subtract(
                                        Duration(days: 365 * state.age.toInt()),
                                      ),
                                      firstDate: DateTime(1920),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null) {
                                      final today = DateTime.now();
                                      int calculatedAge = today.year - pickedDate.year;

                                      // Adjust if birthday hasn't occurred this year
                                      if (today.month < pickedDate.month ||
                                          (today.month == pickedDate.month &&
                                              today.day < pickedDate.day)) {
                                        calculatedAge--;
                                      }

                                      // ignore: use_build_context_synchronously
                                      context.read<AgeCubit>().updateAge(
                                            calculatedAge.toDouble(),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingM.w,
                                      vertical: AppConstants.spaceM.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.radiusL.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Birth Date',
                                    style: AppTextStyles.buttonSmall,
                                  ),
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
                                      '${OnboardingConfig.ageConfig['min']!.toInt()} yrs',
                                      style: AppTextStyles.caption,
                                    ),
                                    Text(
                                      '${OnboardingConfig.ageConfig['max']!.toInt()} yrs',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),

                                SizedBox(height: AppConstants.spaceS.h),

                                // Slider
                                Slider(
                                  value: state.age.clamp(
                                    OnboardingConfig.ageConfig['min']!,
                                    OnboardingConfig.ageConfig['max']!,
                                  ),
                                  min: OnboardingConfig.ageConfig['min']!,
                                  max: OnboardingConfig.ageConfig['max']!,
                                  divisions: OnboardingConfig.ageDivisions,
                                  activeColor: accent,
                                  inactiveColor: accent.withOpacity(0.3),
                                  onChanged: (v) =>
                                      context.read<AgeCubit>().updateAge(v),
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
                            .setAge(state.age);
                        context.push('/thank-you');
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
    );
  }
}