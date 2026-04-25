import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_hero_section.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_progress_card.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_daily_goals_grid.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_success_rate_card.dart';

class GetMyPlanScreen extends StatelessWidget {
  const GetMyPlanScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  double _calculateBMR({
    required String gender,
    required double weight,
    required double height,
    required double age,
  }) {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  int _calculateDailyCalories({
    required double bmr,
    required String goalType,
    required double weightPerWeek,
  }) {
    final tdee = bmr * AppConstants.activityMultiplier;
    if (goalType.contains('lose')) {
      return (tdee - weightPerWeek * AppConstants.caloriesPerKg).round();
    } else if (goalType.contains('gain')) {
      return (tdee + weightPerWeek * AppConstants.caloriesPerKg).round();
    }
    return tdee.round();
  }

  int _calculateWaterIntake(double weight) =>
      (weight * AppConstants.waterPerKg).round();

  @override
  Widget build(BuildContext context) {
    final data          = context.read<OnboardingCubitAllData>().currentData;
    final gender        = data.gender ?? 'male';
    final currentWeight = data.weight ?? 70.0;
    final targetWeight  = data.targetWeight ?? 70.0;
    final height        = data.height ?? 170.0;
    final age           = data.age ?? 25.0;
    final targetDate    = data.targetDate ?? DateTime.now().add(const Duration(days: 90));
    final goalType      = data.goal?.type.toString() ?? 'maintain';
    final weightPerWeek = data.weightPerWeek ?? 0.5;

    final bmr           = _calculateBMR(gender: gender, weight: currentWeight, height: height, age: age);
    final dailyCalories = _calculateDailyCalories(bmr: bmr, goalType: goalType, weightPerWeek: weightPerWeek);
    final waterIntake   = _calculateWaterIntake(currentWeight);
    final weightDiff    = (targetWeight - currentWeight).abs();

    final workoutFrequency = goalType.contains('lose') ? 5 : goalType.contains('gain') ? 4 : 3;
    final goalLabel = goalType.contains('lose') ? 'Lose Weight' : goalType.contains('gain') ? 'Gain Weight' : 'Maintain Weight';

    return BlocListener<OnboardingCubitAllData, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          // Onboarding done → go to home
          context.go('/home');
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppConstants.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        child: PlanHeroSection(
                          gender: gender,
                          targetDate: targetDate,
                          formatDate: _formatDate,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: Duration(milliseconds: AppConstants.animationFast),
                        child: PlanProgressCard(
                          currentWeight: currentWeight,
                          targetWeight: targetWeight,
                          weightDiff: weightDiff,
                          goalType: goalType,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: Duration(milliseconds: AppConstants.animationNormal),
                        child: PlanSuccessRateCard(),
                      ),

                      SizedBox(height: AppConstants.spaceXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: const Duration(milliseconds: 400),
                        child: PlanDailyGoalsGrid(
                          goalLabel:         goalLabel,
                          dailyCalories:     dailyCalories,
                          workoutFrequency:  workoutFrequency,
                          waterIntake:       waterIntake,
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              // "Get Your Plan" button → completeOnboarding
              FadeInUp(
                duration: Duration(milliseconds: AppConstants.animationSlow),
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.all(AppConstants.paddingXXL),
                  decoration: AppDecorations.buttonContainer,
                  child: BlocBuilder<OnboardingCubitAllData, OnboardingState>(
                    builder: (context, state) {
                      final isLoading = state is OnboardingLoading;
                      return CustomButton(
                        text: 'Get Your Plan',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? () {}
                            : () => context
                                .read<OnboardingCubitAllData>()
                                .completeOnboarding(),
                        backgroundColor: AppColors.primary,
                        height: AppConstants.buttonHeightXL,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}