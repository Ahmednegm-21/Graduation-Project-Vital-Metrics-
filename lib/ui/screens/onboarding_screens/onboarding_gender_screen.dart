import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/onboarding_config.dart';
import 'package:vital_metrics/logic/onboarding/gender_cubit.dart';
import 'package:vital_metrics/logic/onboarding/gender_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _handleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConstants.animationNormal),
    );

    _handleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewW = 0.78.sw;
    final previewH = 0.40.sh;

    return BlocProvider(
      create: (_) => GenderCubit(animCtrl: _animCtrl),
      child: BlocBuilder<GenderCubit, GenderState>(
        builder: (context, state) {
          final cubit = context.read<GenderCubit>();

          return Scaffold(
            backgroundColor: AppColors.white,

            // AppBar with progress indicator
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingL.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM.r),
                  child: LinearProgressIndicator(
                    value: OnboardingConfig.getProgressValue('gender'),
                    minHeight: 4.h,
                    backgroundColor: AppColors.greyLight,
                    valueColor: AlwaysStoppedAnimation(state.accent),
                  ),
                ),
              ),
            ),

            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: AppConstants.spaceS.h),

                  // Title
                  Text(
                    'What is your gender?',
                    style: AppTextStyles.h4,
                  ),

                  SizedBox(height: AppConstants.spaceS.h),

                  // Subtitle
                  Text(
                    'Pick your gender',
                    style: AppTextStyles.subtitle2,
                  ),

                  SizedBox(height: AppConstants.spaceL.h),

                  // Gender toggle
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;

                      if (details.primaryVelocity! < 0) {
                        cubit.selectGender('female');
                        context
                            .read<OnboardingCubitAllData>()
                            .setGender('female');
                      } else {
                        cubit.selectGender('male');
                        context
                            .read<OnboardingCubitAllData>()
                            .setGender('male');
                      }
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background
                        Container(
                          width: AppConstants.genderToggleWidth.w,
                          height: AppConstants.genderToggleHeight.h,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(
                              (AppConstants.genderToggleHeight / 2).r,
                            ),
                          ),
                        ),

                        // Animated handle
                        AnimatedBuilder(
                          animation: _handleAnim,
                          builder: (_, child) {
                            final t = _handleAnim.value;
                            final left = AppConstants.genderTogglePadding.w +
                                t *
                                    (AppConstants.genderToggleWidth.w / 2 -
                                        AppConstants.genderTogglePadding.w * 2);

                            return Positioned(
                              left: left,
                              top: AppConstants.genderTogglePadding.h,
                              child: child!,
                            );
                          },
                          child: Container(
                            width: AppConstants.genderToggleWidth.w / 2 -
                                AppConstants.genderTogglePadding.w * 2,
                            height: AppConstants.genderToggleHeight.h -
                                AppConstants.genderTogglePadding.h * 2,
                            decoration: BoxDecoration(
                              color: state.accent,
                              borderRadius: BorderRadius.circular(
                                ((AppConstants.genderToggleHeight -
                                            AppConstants.genderTogglePadding *
                                                2) /
                                        2)
                                    .r,
                              ),
                            ),
                          ),
                        ),

                        // Male/Female labels
                        SizedBox(
                          width: AppConstants.genderToggleWidth.w,
                          height: AppConstants.genderToggleHeight.h,
                          child: Row(
                            children: [
                              // Male button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    cubit.selectGender('male');
                                    context
                                        .read<OnboardingCubitAllData>()
                                        .setGender('male');
                                  },
                                  child: Center(
                                    child: Text(
                                      'Male',
                                      style: AppTextStyles.button.copyWith(
                                        color: state.selectedGender == 'male'
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Female button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    cubit.selectGender('female');
                                    context
                                        .read<OnboardingCubitAllData>()
                                        .setGender('female');
                                  },
                                  child: Center(
                                    child: Text(
                                      'Female',
                                      style: AppTextStyles.button.copyWith(
                                        color: state.selectedGender == 'female'
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppConstants.spaceXL.h),

                  // Preview image with animation
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: AppConstants.animationNormal),
                      child: state.selectedGender == null
                          ? const SizedBox()
                          : Container(
                              key: ValueKey(state.selectedGender),
                              width: previewW,
                              height: previewH,
                              child: Image.asset(
                                AppAssets.getGenderImage(state.selectedGender!),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  state.selectedGender == 'male'
                                      ? Icons.man
                                      : Icons.woman,
                                  size: AppConstants.iconXL * 3,
                                  color: state.accent,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Next button
                  Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightL.h,
                      child: ElevatedButton(
                        onPressed: state.selectedGender == null
                            ? null
                            : () {
                                context
                                    .read<OnboardingCubitAllData>()
                                    .setGender(state.selectedGender!);
                                context.push('/height');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.accent,
                          disabledBackgroundColor: AppColors.greyLight,
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