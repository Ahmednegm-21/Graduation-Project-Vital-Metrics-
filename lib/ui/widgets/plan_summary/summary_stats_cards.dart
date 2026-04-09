import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SummaryStatsCards extends StatelessWidget {
  final int weeksToGoal;
  final double weeklyRate;

  const SummaryStatsCards({
    super.key,
    required this.weeksToGoal,
    required this.weeklyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      child: Row(
        children: [
          // Duration card
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today,
              label: 'Duration',
              value: '$weeksToGoal weeks',
              color: Colors.purple,
            ),
          ),
          SizedBox(width: AppConstants.paddingM),
          
          // Weekly rate card
          Expanded(
            child: _buildStatCard(
              icon: Icons.speed,
              label: 'Weekly Rate',
              value: '${weeklyRate.toStringAsFixed(2)} kg',
              color: AppColors.moderate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppConstants.iconM),
          SizedBox(height: AppConstants.spaceS),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppConstants.spaceXS),
          Text(
            label,
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}