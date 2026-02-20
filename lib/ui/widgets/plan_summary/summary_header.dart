import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SummaryHeader extends StatelessWidget {
  final bool isLose;
  final double weightDiff;
  final DateTime targetDate;
  final String Function(DateTime) formatDate;

  const SummaryHeader({
    super.key,
    required this.isLose,
    required this.weightDiff,
    required this.targetDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Success icon
        Container(
          padding: EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 48.sp,
            color: AppColors.success,
          ),
        ),

        SizedBox(height: AppConstants.spaceL),

        // Achievable text
        Text(
          "It's totally achievable!",
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: AppConstants.paddingM),

        // Summary text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
              children: [
                TextSpan(text: isLose ? 'Lose ' : 'Gain '),
                TextSpan(
                  text: '${weightDiff.toStringAsFixed(0)} kg',
                  style: TextStyle(color: AppColors.primary),
                ),
                const TextSpan(text: ' by '),
                TextSpan(
                  text: formatDate(targetDate),
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}