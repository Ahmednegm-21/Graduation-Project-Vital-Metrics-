import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
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
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is OnboardingLoading;

            // Get selected goal from OnboardingCubitAllData
            final selectedGoal =
                context.read<OnboardingCubitAllData>().currentData.goal;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    'What is your main goal?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16.h),

                // Goal Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
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

                // Continue Button
                Container(
                  padding: EdgeInsets.all(15.w),
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