import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/ui/widgets/custom_button.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_header.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_stats_cards.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_journey_card.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_motivational_card.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<OnboardingCubitAllData>().currentData;

    final isLose = data.goal?.type.toString().contains('lose') == true;
    final currentWeight = data.weight ?? 0;
    final targetWeight = data.targetWeight ?? 0;
    final weightDiff = (targetWeight - currentWeight).abs();
    final targetDate = data.targetDate ?? DateTime.now();
    final weeklyRate = data.weightPerWeek ?? 0.75;

    final weeksToGoal =
        (targetDate.difference(DateTime.now()).inDays / 7).round();

    return BlocListener<OnboardingCubitAllData, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          context.go('/get-my-plan');
        }
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/target-weight'),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),

                      // Header
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: SummaryHeader(
                          isLose: isLose,
                          weightDiff: weightDiff,
                          targetDate: targetDate,
                          formatDate: _formatDate,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Stats Cards
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: SummaryStatsCards(
                          weeksToGoal: weeksToGoal,
                          weeklyRate: weeklyRate,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Journey Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: SummaryJourneyCard(
                          currentWeight: currentWeight,
                          targetWeight: targetWeight,
                          weightDiff: weightDiff,
                          targetDate: targetDate,
                          formatDate: _formatDate,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Motivational Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: SummaryMotivationalCard(),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Next Button
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 700),
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
                    text: 'Start My Journey',
                    onPressed: () {
                      context
                          .read<OnboardingCubitAllData>()
                          .saveOnboardingData();
                    },
                    backgroundColor: const Color(0xFF005EBD),
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