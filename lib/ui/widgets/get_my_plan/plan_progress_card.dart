import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class PlanProgressCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double weightDiff;
  final String goalType;

  const PlanProgressCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightDiff,
    required this.goalType,
  });

  @override
  Widget build(BuildContext context) {
    final isLose = goalType.contains('lose');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(AppConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.timeline,
                  color: AppColors.primary,
                  size: AppConstants.iconM,
                ),
              ),
              SizedBox(width: AppConstants.paddingM),
              Flexible(
                child: Text(
                  'Your Progress Journey',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),

          SizedBox(height: AppConstants.spaceXXL),

          // Weight info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightInfo(
                label: 'Current',
                weight: currentWeight,
                icon: Icons.play_circle_outline,
                color: AppColors.grey,
              ),
              Container(
                width: 1,
                height: 50.h,
                color: AppColors.greyLight,
              ),
              _buildWeightInfo(
                label: 'Target',
                weight: targetWeight,
                icon: Icons.flag_outlined,
                color: AppColors.primary,
              ),
            ],
          ),

          SizedBox(height: AppConstants.spaceXL),

          // Difference badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLose
                      ? [AppColors.success.withOpacity(0.8), AppColors.success]
                      : [AppColors.info.withOpacity(0.8), AppColors.info],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLose ? Icons.trending_down : Icons.trending_up,
                    color: AppColors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: AppConstants.spaceS),
                  Text(
                    '${weightDiff.toStringAsFixed(1)} kg to ${isLose ? 'lose' : 'gain'}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfo({
    required String label,
    required double weight,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: AppConstants.spaceS),
        Text(
          label,
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: AppConstants.spaceXS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weight.toStringAsFixed(0),
              style: TextStyle(
                color: AppColors.black,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'kg',
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}