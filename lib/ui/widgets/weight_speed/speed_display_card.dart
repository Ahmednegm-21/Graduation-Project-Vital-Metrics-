import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SpeedDisplayCard extends StatelessWidget {
  final double selectedSpeed;
  final bool isLose;

  const SpeedDisplayCard({
    super.key,
    required this.selectedSpeed,
    required this.isLose,
  });

  String _getSpeedLabel(double speed) {
    if (speed <= 0.5) return 'Slow & Steady';
    if (speed <= 1.0) return 'Moderate';
    return 'Fast Track';
  }

  Color _getSpeedColor(double speed) {
    if (speed <= 0.5) return AppColors.slow;
    if (speed <= 1.0) return AppColors.moderate;
    return AppColors.fast;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradientList,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            isLose ? 'Loss weight per week' : 'Gain weight per week',
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: AppConstants.paddingM),

          AnimatedSwitcher(
            duration: Duration(milliseconds: AppConstants.animationNormal),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Row(
              key: ValueKey(selectedSpeed),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  selectedSpeed.toStringAsFixed(2),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: AppConstants.spaceS),
                Text(
                  'kg',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.spaceS),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _getSpeedColor(selectedSpeed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(
                color: _getSpeedColor(selectedSpeed).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getSpeedLabel(selectedSpeed),
              style: TextStyle(
                color: _getSpeedColor(selectedSpeed),
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
