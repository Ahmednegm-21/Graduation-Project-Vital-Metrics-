import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import '../../../data/models/user_goal.dart';
import '../../widgets/goal_selction/goal_card.dart';
import '../../widgets/goal_selction/custom_button.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<OnboardingCubitAllData, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingDataUpdated) {
              context.go('/weight-speed');
            }

            if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is OnboardingLoading;

            // Get selected goal
            final selectedGoal =
                context.read<OnboardingCubitAllData>().currentData.goal;

            return Column(
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                    vertical: AppConstants.paddingM,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.black,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
                  child: Text(
                    'What is your main goal?',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppConstants.spaceL),

                // Goal cards list
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
                    child: Column(
                      children: UserGoal.allGoals.map((goal) {
                        return GoalCard(
                          goal: goal,
                          isSelected: selectedGoal?.type == goal.type,
                          onTap: () {
                            context
                                .read<OnboardingCubitAllData>()
                                .selectGoal(goal);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Continue button
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: AppDecorations.buttonContainer,
                  child: CustomButton(
                    text: 'Continue',
                    enabled: selectedGoal != null,
                    onPressed: () {
                      context.read<OnboardingCubitAllData>().saveGoal();
                    },
                    isLoading: isLoading,
                    height: 45.h,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}