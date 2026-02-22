import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class TargetWeightIconSection extends StatelessWidget {
  final bool isLose;

  const TargetWeightIconSection({super.key, required this.isLose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLose ? Icons.trending_down : Icons.trending_up,
            size: 50.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: AppConstants.spaceS),

          Text(
            isLose ? 'Weight Loss Goal' : 'Weight Gain Goal',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
