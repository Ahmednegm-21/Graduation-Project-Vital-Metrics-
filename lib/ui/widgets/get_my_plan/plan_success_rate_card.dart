import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class PlanSuccessRateCard extends StatelessWidget {
  const PlanSuccessRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Verified icon
          Container(
            padding: EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified,
              color: AppColors.moderate,
              size: 32.sp,
            ),
          ),
          SizedBox(width: AppConstants.paddingL),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '90% Success Rate',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppConstants.spaceXS),
                Text(
                  'Users achieve their goals with this plan',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12.sp,
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