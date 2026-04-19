import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_header.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_stats_cards.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_journey_card.dart';
import 'package:vital_metrics/ui/widgets/plan_summary/summary_motivational_card.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<OnboardingCubitAllData>().currentData;

    final isLose        = data.goal?.type.toString().contains('lose') == true;
    final currentWeight = data.weight ?? 0;
    final targetWeight  = data.targetWeight ?? 0;
    final weightDiff    = (targetWeight - currentWeight).abs();
    final targetDate    = data.targetDate ?? DateTime.now();
    final weeklyRate    = data.weightPerWeek ?? 0.75;
    final weeksToGoal   =
        (targetDate.difference(DateTime.now()).inDays / 7).round();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/get-my-plan');
        } else if (state is AuthError) {
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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppConstants.paddingL),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/target-weight'),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.black,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: AppConstants.spaceXXL),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),

                      FadeInDown(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        child: SummaryHeader(
                          isLose: isLose,
                          weightDiff: weightDiff,
                          targetDate: targetDate,
                          formatDate: _formatDate,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: const Duration(milliseconds: 400),
                        child: SummaryStatsCards(
                          weeksToGoal: weeksToGoal,
                          weeklyRate: weeklyRate,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: const Duration(milliseconds: 500),
                        child: SummaryJourneyCard(
                          currentWeight: currentWeight,
                          targetWeight: targetWeight,
                          weightDiff: weightDiff,
                          targetDate: targetDate,
                          formatDate: _formatDate,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXL),

                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: const Duration(milliseconds: 600),
                        child: SummaryMotivationalCard(),
                      ),

                      SizedBox(height: AppConstants.spaceXL),
                    ],
                  ),
                ),
              ),

              // ✅ Fixed: onPressed uses VoidCallback correctly
              FadeInUp(
                duration: Duration(milliseconds: AppConstants.animationSlow),
                delay: const Duration(milliseconds: 700),
                child: Container(
                  padding: EdgeInsets.all(AppConstants.paddingXXL),
                  decoration: AppDecorations.buttonContainer,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final isLoading = authState is AuthLoading;
                      return CustomButton(
                        text: 'Start My Journey',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? () {} // ✅ empty callback instead of null
                            : () => context
                                .read<OnboardingCubitAllData>()
                                .completeSignUp(context.read<AuthCubit>()),
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