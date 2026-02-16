import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/target_weight/target_weight_header.dart';
import 'package:vital_metrics/ui/widgets/target_weight/target_weight_icon_section.dart';
import 'package:vital_metrics/ui/widgets/target_weight/target_weight_display_card.dart';
import 'package:vital_metrics/ui/widgets/target_weight/target_weight_slider_section.dart';

class TargetWeightScreen extends StatefulWidget {
  const TargetWeightScreen({super.key});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  double _targetWeight = 90.0;

  @override
  Widget build(BuildContext context) {
    // Get current weight from cubit
    final currentWeight =
        context.read<OnboardingCubitAllData>().currentData.weight ?? 70.0;

    // Check if goal is weight loss
    final isLose = context
            .read<OnboardingCubitAllData>()
            .currentData
            .goal
            ?.type
            .toString()
            .contains('lose') ==
        true;

    // Calculate min/max weight range
    final double minWeight = isLose ? currentWeight - 50 : currentWeight;
    final double maxWeight = isLose ? currentWeight : currentWeight + 50;

    // Ensure target weight is within range
    if (_targetWeight < minWeight) _targetWeight = minWeight;
    if (_targetWeight > maxWeight) _targetWeight = maxWeight;

    // Calculate weight difference
    final difference = (_targetWeight - currentWeight).abs();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go('/weight-speed'),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 22.sp,
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  children: [
                    // Title section
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: TargetWeightHeader(),
                    ),

                    SizedBox(height: 24.h),

                    // Goal icon section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: TargetWeightIconSection(isLose: isLose),
                    ),

                    SizedBox(height: 24.h),

                    // Weight display card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: TargetWeightDisplayCard(
                        targetWeight: _targetWeight,
                        difference: difference,
                        isLose: isLose,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Weight slider
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: TargetWeightSliderSection(
                        targetWeight: _targetWeight,
                        minWeight: minWeight,
                        maxWeight: maxWeight,
                        onWeightChanged: (value) {
                          setState(() {
                            _targetWeight = value;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Next button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: EdgeInsets.all(20.w),
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
                  text: 'Next',
                  onPressed: () {
                    // Save target weight and navigate
                    context
                        .read<OnboardingCubitAllData>()
                        .setTargetWeight(_targetWeight);
                    context.go('/plan-summary');
                  },
                  backgroundColor: const Color(0xFF005EBD),
                  height: 50.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}