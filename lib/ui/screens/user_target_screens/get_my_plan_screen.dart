import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_hero_section.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_progress_card.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_daily_goals_grid.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_success_rate_card.dart';

class GetMyPlanScreen extends StatelessWidget {
  const GetMyPlanScreen({super.key});

  // Format date helper
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Calculate BMR using Mifflin-St Jeor equation
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

  // Calculate daily calories
  int _calculateDailyCalories({
    required double bmr,
    required String goalType,
    required double weightPerWeek,
  }) {
    final tdee = bmr * AppConstants.activityMultiplier;

    if (goalType.contains('lose')) {
      final deficit = weightPerWeek * AppConstants.caloriesPerKg;
      return (tdee - deficit).round();
    } else if (goalType.contains('gain')) {
      final surplus = weightPerWeek * AppConstants.caloriesPerKg;
      return (tdee + surplus).round();
    } else {
      return tdee.round();
    }
  }

  // Calculate water intake
  int _calculateWaterIntake(double weight) {
    return (weight * AppConstants.waterPerKg).round();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<OnboardingCubitAllData>().currentData;

    // Extract data
    final gender = data.gender ?? 'male';
    final currentWeight = data.weight ?? 70.0;
    final targetWeight = data.targetWeight ?? 70.0;
    final height = data.height ?? 170.0;
    final age = data.age ?? 25.0;
    final targetDate = data.targetDate ?? DateTime.now().add(const Duration(days: 90));
    final goalType = data.goal?.type.toString() ?? 'maintain';
    final weightPerWeek = data.weightPerWeek ?? 0.5;

    // Calculate metrics
    final bmr = _calculateBMR(
      gender: gender,
      weight: currentWeight,
      height: height,
      age: age,
    );

    final dailyCalories = _calculateDailyCalories(
      bmr: bmr,
      goalType: goalType,
      weightPerWeek: weightPerWeek,
    );

    final waterIntake = _calculateWaterIntake(currentWeight);

    // Determine workout frequency
    final workoutFrequency = goalType.contains('lose')
        ? 5
        : goalType.contains('gain')
            ? 4
            : 3;

    // Goal label
    final goalLabel = goalType.contains('lose')
        ? 'Lose Weight'
        : goalType.contains('gain')
            ? 'Gain Weight'
            : 'Maintain Weight';

    final weightDiff = (targetWeight - currentWeight).abs();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero section
                    FadeInDown(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      child: PlanHeroSection(
                        gender: gender,
                        targetDate: targetDate,
                        formatDate: _formatDate,
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceXL),

                    // Progress card
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

                    // Success rate card
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: AppConstants.animationNormal),
                      child: PlanSuccessRateCard(),
                    ),

                    SizedBox(height: AppConstants.spaceXL),

                    // Daily goals grid
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: 400),
                      child: PlanDailyGoalsGrid(
                        goalLabel: goalLabel,
                        dailyCalories: dailyCalories,
                        workoutFrequency: workoutFrequency,
                        waterIntake: waterIntake,
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),

            // Get plan button
            FadeInUp(
              duration: Duration(milliseconds: AppConstants.animationSlow),
              delay: Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.all(AppConstants.paddingXXL),
                decoration: AppDecorations.buttonContainer,
                child: CustomButton(
                  text: 'Get Your Plan',
                  onPressed: () {
                    context.go('/home');
                  },
                  backgroundColor: AppColors.primary,
                  height: AppConstants.buttonHeightXL,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}