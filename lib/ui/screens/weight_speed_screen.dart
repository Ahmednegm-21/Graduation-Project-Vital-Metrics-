import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/ui/widgets/custom_button.dart';
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
              // Back Button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/goal-selection'),
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
                        child: SpeedHeader(),
                      ),

                      SizedBox(height: 30.h),

                      // Display Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: SpeedDisplayCard(
                          selectedSpeed: _selectedSpeed,
                          isLose: isLose,
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Slider Section
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

                      SizedBox(height: 20.h),

                      // Info Card
                      SpeedInfoCard(),

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
                          .setWeightPerWeek(_selectedSpeed);
                      context.go('/target-weight');
                    },
                    backgroundColor: const Color(0xFF005EBD),
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