import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SpeedHeader extends StatelessWidget {
  const SpeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main title
          Text(
            'How fast you want to\nreach your goal?',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.spaceS),
          
          // Subtitle
          Text(
            'Choose your pace wisely',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}