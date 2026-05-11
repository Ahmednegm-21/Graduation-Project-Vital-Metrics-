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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: AppConstants.spaceXL),
                child: Column(
                  children: [
                    FadeInDown(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      child: TargetWeightHeader(),
                    ),

                    SizedBox(height: AppConstants.spaceXXL),

                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: Duration(milliseconds: AppConstants.animationFast),
                      child: TargetWeightIconSection(isLose: isLose),
                    ),

                    SizedBox(height: AppConstants.spaceXXL),

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

                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animationSlow),
                      delay: const Duration(milliseconds: 400),
                      child: TargetWeightSliderSection(
                        targetWeight: _targetWeight,
                        minWeight: minWeight,
                        maxWeight: maxWeight,
                        onWeightChanged: (value) {
                          setState(() => _targetWeight = value);
                        },
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceL),
                  ],
                ),
              ),
            ),

            FadeInUp(
              duration: Duration(milliseconds: AppConstants.animationSlow),
              delay: Duration(milliseconds: AppConstants.animationSlow),
              child: Container(
                padding: EdgeInsets.all(AppConstants.paddingXL),
                decoration: AppDecorations.buttonContainer,
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
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

// ══════════════════════════════════════════════════════════════════════════════
// TargetWeightIconSection
// ══════════════════════════════════════════════════════════════════════════════
class TargetWeightIconSection extends StatelessWidget {
  final bool isLose;

  const TargetWeightIconSection({super.key, required this.isLose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLose ? Icons.trending_down : Icons.trending_up,
            size: 50.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            isLose ? 'Weight Loss Goal' : 'Weight Gain Goal',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}