import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class PlanHeroSection extends StatelessWidget {
  final String gender;
  final DateTime targetDate;
  final String Function(DateTime) formatDate;

  const PlanHeroSection({
    super.key,
    required this.gender,
    required this.targetDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingXXL,
        vertical: AppConstants.spaceXL,
      ),
      padding: EdgeInsets.all(AppConstants.paddingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.primaryBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Success icon
          Container(
            padding: EdgeInsets.all(AppConstants.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              size: 56.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: AppConstants.spaceXXL),

          // Title
          Text(
            'Your Personalized Plan',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppConstants.spaceS),

          Text(
            'is Ready!',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppConstants.spaceL),

          // Target date badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXL,
              vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: AppConstants.spaceS),
                Flexible(
                  child: Text(
                    'Target: ${formatDate(targetDate)}',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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