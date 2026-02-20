import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import 'package:vital_metrics/ui/widgets/weight_speed/speed_header.dart';
import 'package:vital_metrics/ui/widgets/weight_speed/speed_display_card.dart';
import 'package:vital_metrics/ui/widgets/weight_speed/speed_slider_section.dart';
import 'package:vital_metrics/ui/widgets/weight_speed/speed_info_card.dart';

class WeightSpeedScreen extends StatefulWidget {
  const WeightSpeedScreen({super.key});

  @override
  State<WeightSpeedScreen> createState() => _WeightSpeedScreenState();
}

class _WeightSpeedScreenState extends State<WeightSpeedScreen> {
  double _selectedSpeed = 0.75;
  final List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    // Check if goal is weight loss
    final isLose = context
            .read<OnboardingCubitAllData>()
            .currentData
            .goal
            ?.type
            .toString()
            .contains('lose') ==
        true;

    return BlocListener<OnboardingCubitAllData, OnboardingState>(
      listener: (context, state) {},
      child: Scaffold(
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
                    onPressed: () => context.go('/goal-selection'),
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
                        child: SpeedHeader(),
                      ),

                      SizedBox(height: AppConstants.spaceXXL),

                      // Speed display card
                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: Duration(milliseconds: AppConstants.animationFast),
                        child: SpeedDisplayCard(
                          selectedSpeed: _selectedSpeed,
                          isLose: isLose,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXL),

                      // Speed slider
                      FadeInUp(
                        duration: Duration(milliseconds: AppConstants.animationSlow),
                        delay: Duration(milliseconds: 400),
                        child: SpeedSliderSection(
                          selectedSpeed: _selectedSpeed,
                          speeds: _speeds,
                          onSpeedChanged: (value) {
                            setState(() {
                              _selectedSpeed = value;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceL),

                      // Info message
                      SpeedInfoCard(),

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
                      // Save speed and navigate
                      context
                          .read<OnboardingCubitAllData>()
                          .setWeightPerWeek(_selectedSpeed);
                      context.go('/target-weight');
                    },
                    backgroundColor: AppColors.primary,
                    height: AppConstants.buttonHeightXL,
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