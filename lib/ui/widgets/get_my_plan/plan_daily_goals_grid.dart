import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class PlanDailyGoalsGrid extends StatelessWidget {
  final String goalLabel;
  final int dailyCalories;
  final int workoutFrequency;
  final int waterIntake;

  const PlanDailyGoalsGrid({
    super.key,
    required this.goalLabel,
    required this.dailyCalories,
    required this.workoutFrequency,
    required this.waterIntake,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Your Daily Targets',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppConstants.spaceL),
          
          // Goals grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.paddingM,
            mainAxisSpacing: AppConstants.paddingM,
            childAspectRatio: 0.95,
            children: [
              _buildGoalCard(
                icon: Icons.track_changes,
                iconColor: AppColors.fast,
                label: 'Goal',
                value: goalLabel,
                unit: '',
                gradientColors: [Colors.red.shade50, Colors.pink.shade50],
              ),
              _buildGoalCard(
                icon: Icons.local_fire_department,
                iconColor: AppColors.moderate,
                label: 'Calories',
                value: '$dailyCalories',
                unit: 'kcal',
                gradientColors: [Colors.orange.shade50, Colors.amber.shade50],
              ),
              _buildGoalCard(
                icon: Icons.fitness_center,
                iconColor: Colors.purple,
                label: 'Workout',
                value: '$workoutFrequency days',
                unit: '/week',
                gradientColors: [Colors.purple.shade50, Colors.deepPurple.shade50],
              ),
              _buildGoalCard(
                icon: Icons.water_drop,
                iconColor: AppColors.info,
                label: 'Water',
                value: '$waterIntake',
                unit: 'ml',
                gradientColors: [Colors.blue.shade50, Colors.cyan.shade50],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppConstants.spaceS),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22.sp,
            ),
          ),
          
          // Label and value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}