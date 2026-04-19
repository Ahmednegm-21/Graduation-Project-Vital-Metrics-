import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import '../../../data/models/user_goal.dart';

class GoalCard extends StatelessWidget {
  final UserGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
            width: isSelected ? 2.5.w : 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.shadowLight,
              blurRadius: isSelected ? 12 : 6,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image container
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              child: Container(
                height: 160.h,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Goal image
                    Image.asset(
                      goal.imagePath,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback gradient if image fails
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: goal.type == GoalType.gainWeight
                                  ? [
                                      AppColors.weightGainLight,
                                      AppColors.weightGain,
                                    ]
                                  : [
                                      AppColors.weightLossLight,
                                      AppColors.weightLoss,
                                    ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              goal.type == GoalType.gainWeight
                                  ? Icons.fitness_center
                                  : Icons.directions_run,
                              size: 60.sp,
                              color: AppColors.white.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),

                    // Title overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 14.w,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppConstants.spaceXS),
                            Text(
                              goal.type == GoalType.gainWeight
                                  ? 'Increase Body Weight'
                                  : 'Burn Fat and tone down',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Description section
            Container(
              padding: EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info icon
                  Container(
                    margin: EdgeInsets.only(top: 2.h, right: 8.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: AppConstants.iconXS,
                    ),
                  ),
                  
                  // Description text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why this goal?',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppConstants.spaceXS),
                        Text(
                          goal.description,
                          style: TextStyle(
                            color: AppColors.greyDark,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}