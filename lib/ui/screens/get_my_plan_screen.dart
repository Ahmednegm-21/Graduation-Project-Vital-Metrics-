import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_hero_section.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_progress_card.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_daily_goals_grid.dart';
import 'package:vital_metrics/ui/widgets/get_my_plan/plan_success_rate_card.dart';

class GetMyPlanScreen extends StatelessWidget {
  const GetMyPlanScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Calculate BMR
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

  // Calculate Daily Calories
  int _calculateDailyCalories({
    required double bmr,
    required String goalType,
    required double weightPerWeek,
  }) {
    final tdee = bmr * 1.55;

    if (goalType.contains('lose')) {
      final deficit = weightPerWeek * 1100;
      return (tdee - deficit).round();
    } else if (goalType.contains('gain')) {
      final surplus = weightPerWeek * 1100;
      return (tdee + surplus).round();
    } else {
      return tdee.round();
    }
  }

  // Calculate Water Intake
  int _calculateWaterIntake(double weight) {
    return (weight * 33).round();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<OnboardingCubitAllData>().currentData;

    final gender = data.gender ?? 'male';
    final currentWeight = data.weight ?? 70.0;
    final targetWeight = data.targetWeight ?? 70.0;
    final height = data.height ?? 170.0;
    final age = data.age ?? 25.0;
    final targetDate = data.targetDate ?? DateTime.now().add(const Duration(days: 90));
    final goalType = data.goal?.type.toString() ?? 'maintain';
    final weightPerWeek = data.weightPerWeek ?? 0.5;

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

    final workoutFrequency = goalType.contains('lose')
        ? 5
        : goalType.contains('gain')
            ? 4
            : 3;

    final goalLabel = goalType.contains('lose')
        ? 'Lose Weight'
        : goalType.contains('gain')
            ? 'Gain Weight'
            : 'Maintain Weight';

    final weightDiff = (targetWeight - currentWeight).abs();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: PlanHeroSection(
                        gender: gender,
                        targetDate: targetDate,
                        formatDate: _formatDate,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Progress Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: PlanProgressCard(
                        currentWeight: currentWeight,
                        targetWeight: targetWeight,
                        weightDiff: weightDiff,
                        goalType: goalType,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Success Rate Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: PlanSuccessRateCard(),
                    ),

                    SizedBox(height: 20.h),

                    // Daily Goals
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
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

            // Get My Plan Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: 'Get Your Plan',
                  onPressed: () {
                    context.go('/home');
                  },
                  backgroundColor: const Color(0xFF005EBD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
