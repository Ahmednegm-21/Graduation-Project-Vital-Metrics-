import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/user_goal.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
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

  // =====================================================
  // نفس المعادلة اللي في CalorieCubit.calculateAndSetBudget
  // =====================================================
  int _calculateDailyCalories({
    required double weight,
    required double height,
    required double age,
    required String gender,
    required String goalType,
    required ActivityLevel activityLevel,
  }) {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double multiplier;
    switch (activityLevel) {
      case ActivityLevel.low:
        multiplier = 1.2;
        break;
      case ActivityLevel.moderate:
        multiplier = 1.55;
        break;
      case ActivityLevel.high:
        multiplier = 1.75;
        break;
    }

    double targetCalories = bmr * multiplier;

    if (goalType.contains('lose')) {
      targetCalories -= 500;
    } else if (goalType.contains('gain')) {
      targetCalories += 300;
    }

    if (targetCalories < 1200) targetCalories = 1200;

    return targetCalories.round();
  }

  // =====================================================
  // نفس المعادلة اللي في ActivityLevel.waterGoalMl
  // =====================================================
  int _calculateWaterMl({
    required double weight,
    required ActivityLevel activityLevel,
  }) {
    return activityLevel.waterGoalMl(weight: weight);
  }

  String _goalTypeString(UserGoal? goal) {
    if (goal == null) return 'maintain';
    switch (goal.type) {
      case GoalType.loseWeight:
        return 'lose_weight';
      case GoalType.gainWeight:
        return 'gain_weight';
    }
  }

  void _applyPlanToCubits(
    BuildContext context, {
    required double weight,
    required double height,
    required double age,
    required String gender,
    required String goalType,
    required ActivityLevel activityLevel,
  }) {
    context.read<CalorieCubit>().calculateAndSetBudget(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      goal: goalType,
      activityLevel: activityLevel.name,
    );

    context.read<WaterCubit>().setGoalFromProfile(
      weight: weight,
      activityLevel: activityLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data          = context.read<OnboardingCubitAllData>().currentData;
    final gender        = data.gender ?? 'male';
    final currentWeight = data.weight ?? 70.0;
    final targetWeight  = data.targetWeight ?? 70.0;
    final height        = data.height ?? 170.0;
    final age           = data.age ?? 25.0;
    final targetDate    = data.targetDate ?? DateTime.now().add(const Duration(days: 90));
    final activityLevel = data.activityLevel ?? ActivityLevel.moderate;
    final goalType      = _goalTypeString(data.goal);
    final weightDiff    = (targetWeight - currentWeight).abs();

    // ← نفس الحسابات اللي هتروح للهوم
    final dailyCalories = _calculateDailyCalories(
      weight: currentWeight,
      height: height,
      age: age,
      gender: gender,
      goalType: goalType,
      activityLevel: activityLevel,
    );

    final waterMl = _calculateWaterMl(
      weight: currentWeight,
      activityLevel: activityLevel,
    );

    // Workout frequency من الـ activityLevel
    final workoutFrequency = activityLevel == ActivityLevel.low
        ? 3
        : activityLevel == ActivityLevel.moderate
            ? 4
            : 5;

    final goalLabel = goalType.contains('lose')
        ? 'Lose Weight'
        : goalType.contains('gain')
            ? 'Gain Weight'
            : 'Maintain Weight';

    return BlocListener<OnboardingCubitAllData, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          _applyPlanToCubits(
            context,
            weight: currentWeight,
            height: height,
            age: age,
            gender: gender,
            goalType: goalType,
            activityLevel: activityLevel,
          );
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
                          goalLabel:        goalLabel,
                          dailyCalories:    dailyCalories,
                          workoutFrequency: workoutFrequency,
                          waterIntake:      waterMl,
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

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