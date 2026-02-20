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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go('/weight-speed'),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.black,
                    size: 22.sp,
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: AppConstants.spaceXL),
                child: Column(
                  children: [
                    // Title section
                    FadeInDown(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      child: TargetWeightHeader(),
                    ),

                    SizedBox(height: AppConstants.spaceXXL),

                    // Goal icon section
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: AppConstants.animationFast),
                      child: TargetWeightIconSection(isLose: isLose),
                    ),

                    SizedBox(height: AppConstants.spaceXXL),

                    // Weight display card
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: AppConstants.animationNormal),
                      child: TargetWeightDisplayCard(
                        targetWeight: _targetWeight,
                        difference: difference,
                        isLose: isLose,
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceXXL),

                    // Weight slider
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: 400),
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

                    SizedBox(height: AppConstants.spaceL),
                  ],
                ),
              ),
            ),

            // Next button
            FadeInUp(
              duration: Duration(milliseconds: AppConstants.animationSlow),
              delay: Duration(milliseconds: AppConstants.animationSlow),
              child: Container(
                padding: EdgeInsets.all(AppConstants.paddingXL),
                decoration: AppDecorations.buttonContainer,
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    // Save target weight and navigate
                    context
                        .read<OnboardingCubitAllData>()
                        .setTargetWeight(_targetWeight);
                    context.go('/plan-summary');
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