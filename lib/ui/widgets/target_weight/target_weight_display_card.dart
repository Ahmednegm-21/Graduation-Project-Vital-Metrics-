import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class TargetWeightDisplayCard extends StatelessWidget {
  final double targetWeight;
  final double difference;
  final bool isLose;

  const TargetWeightDisplayCard({
    super.key,
    required this.targetWeight,
    required this.difference,
    required this.isLose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label
          Text(
            'Target Weight',
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          
          // Animated weight value
          AnimatedSwitcher(
            duration: Duration(milliseconds: AppConstants.animationNormal),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Row(
              key: ValueKey(targetWeight),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  targetWeight.toStringAsFixed(0),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: AppConstants.spaceS),
                Text(
                  'kg',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppConstants.paddingM),
          
          // Difference badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 7.h,
            ),
            decoration: BoxDecoration(
              color: isLose
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLose ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 15.sp,
                  color: isLose ? AppColors.success : AppColors.info,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${difference.toStringAsFixed(0)} kg ${isLose ? 'to lose' : 'to gain'}',
                  style: TextStyle(
                    color: isLose ? AppColors.success : AppColors.info,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}