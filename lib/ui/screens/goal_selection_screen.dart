// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vital_metrics/logic/user-goal/user_goal_dart_cubit.dart';
// import 'package:vital_metrics/logic/user-goal/user_goal_dart_state.dart';
// import '../../data/models/user_goal.dart';
// import '../widgets/goal_card.dart';
// import '../widgets/custom_button.dart';

// class GoalSelectionScreen extends StatelessWidget {
//   const GoalSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: BlocConsumer<OnboardingGoalCubit, OnboardingState>(
//           listener: (context, state) {
//             if (state is GoalSaved) {

//               // Navigator.pushNamed(context, '/next-onboarding-screen');

//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Goal saved! (Navigate to next screen)'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             }

//             if (state is OnboardingError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.message),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           builder: (context, state) {
//             final isLoading = state is OnboardingLoading;
//             final selectedGoal = state is GoalSelected
//                 ? state.goal
//                 : state is GoalSaved
//                 ? state.goal
//                 : null;

//             return Column(
//               children: [
//                 // back button
//                 Padding(
//                   padding: EdgeInsets.all(20.w),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => context.pop(),
//                         icon: Icon(
//                           Icons.arrow_back_ios,
//                           color: Colors.black,
//                           size: 24.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Title
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                   child: Text(
//                     'What is your main goal?',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 28.sp,
//                       fontWeight: FontWeight.bold,
//                       height: 0.9,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),

//                 SizedBox(height: 20.h),

//                 // Goal Cards
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Column(
//                       children: UserGoal.allGoals.map((goal) {
//                         return GoalCard(
//                           goal: goal,
//                           isSelected: selectedGoal?.type == goal.type,
//                           onTap: () {
//                             context.read<OnboardingGoalCubit>().selectGoal(
//                               goal,
//                             );
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),

//                 // Continue Button
//                 Padding(
//                   padding: EdgeInsets.all(24.w),
//                   child: CustomButton(
//                     text: 'Continue',
//                     enabled: selectedGoal != null,
//                     onPressed: () {
//                       context.read<OnboardingGoalCubit>().saveGoal();
//                     },
//                     isLoading: isLoading,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import '../../data/models/user_goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/custom_button.dart';

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
              // ✅ Navigate to weight speed screen
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

            // ✅ Get selected goal from OnboardingCubitAllData
            final selectedGoal =
                context.read<OnboardingCubitAllData>().currentData.goal;

            return Column(
              children: [
                // Back Button
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 24.sp,
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
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      height: 0.9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 20.h),

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
                            // ✅ Select goal in OnboardingCubitAllData
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
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: CustomButton(
                    text: 'Continue',
                    enabled: selectedGoal != null,
                    onPressed: () {
                      // ✅ Save goal in OnboardingCubitAllData
                      context.read<OnboardingCubitAllData>().saveGoal();
                    },
                    isLoading: isLoading,
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