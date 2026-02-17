import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Daily Targets',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.95,
            children: [
              _buildGoalCard(
                icon: Icons.track_changes,
                iconColor: Colors.red,
                label: 'Goal',
                value: goalLabel,
                unit: '',
                gradientColors: [Colors.red.shade50, Colors.pink.shade50],
              ),
              _buildGoalCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
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
                iconColor: Colors.blue,
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
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22.sp,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp, //
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
                    color: Colors.grey.shade600,
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