import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/custom_button.dart';
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
    final currentWeight =
        context.read<OnboardingCubitAllData>().currentData.weight ?? 70.0;

    final isLose = context
            .read<OnboardingCubitAllData>()
            .currentData
            .goal
            ?.type
            .toString()
            .contains('lose') ==
        true;

    final double minWeight = isLose ? currentWeight - 50 : currentWeight;
    final double maxWeight = isLose ? currentWeight : currentWeight + 50;

    if (_targetWeight < minWeight) _targetWeight = minWeight;
    if (_targetWeight > maxWeight) _targetWeight = maxWeight;

    final difference = (_targetWeight - currentWeight).abs();

    return Scaffold(
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
                  onPressed: () => context.go('/weight-speed'),
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
                    // Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: TargetWeightHeader(),
                    ),

                    SizedBox(height: 30.h),

                    // Icon Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: TargetWeightIconSection(isLose: isLose),
                    ),

                    SizedBox(height: 30.h),

                    // Display Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: TargetWeightDisplayCard(
                        targetWeight: _targetWeight,
                        difference: difference,
                        isLose: isLose,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Slider Section
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

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Next Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
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
                  text: 'Next',
                  onPressed: () {
                    context
                        .read<OnboardingCubitAllData>()
                        .setTargetWeight(_targetWeight);
                    context.go('/plan-summary');
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