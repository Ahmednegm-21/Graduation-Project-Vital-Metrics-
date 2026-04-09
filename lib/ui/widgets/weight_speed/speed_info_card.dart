import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SpeedInfoCard extends StatelessWidget {
  const SpeedInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: AppDecorations.infoCard,
        child: Row(
          children: [
            // Info icon
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 22.sp,
            ),
            SizedBox(width: AppConstants.paddingM),
            
            // Info message
            Expanded(
              child: Text(
                'Slower pace is healthier and more sustainable',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}