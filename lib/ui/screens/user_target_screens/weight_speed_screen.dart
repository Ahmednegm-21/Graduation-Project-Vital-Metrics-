import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
                    onPressed: () => context.go('/goal-selection'),
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
                        child: SpeedHeader(),
                      ),

                      SizedBox(height: 24.h),

                      // Speed display card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: SpeedDisplayCard(
                          selectedSpeed: _selectedSpeed,
                          isLose: isLose,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Speed slider
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
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

                      SizedBox(height: 16.h),

                      // Info message
                      SpeedInfoCard(),

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
                      // Save speed and navigate
                      context
                          .read<OnboardingCubitAllData>()
                          .setWeightPerWeek(_selectedSpeed);
                      context.go('/target-weight');
                    },
                    backgroundColor: const Color(0xFF005EBD),
                    height: 50.h,
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