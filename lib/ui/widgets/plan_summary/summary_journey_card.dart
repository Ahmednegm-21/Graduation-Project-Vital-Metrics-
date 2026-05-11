import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SummaryJourneyCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double weightDiff;
  final DateTime targetDate;
  final String Function(DateTime) formatDate;

  const SummaryJourneyCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightDiff,
    required this.targetDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        children: [
          Text(
            'Your Journey',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.spaceXL),
          Row(
            children: [
              _buildWeightPoint(
                  weight: currentWeight, label: 'Today', isStart: true),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondaryLight],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceS),
                    Text(
                      '${weightDiff.toStringAsFixed(0)} kg',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildWeightPoint(
                  weight: targetWeight,
                  label: formatDate(targetDate),
                  isStart: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPoint({
    required double weight,
    required String label,
    required bool isStart,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: isStart ? AppColors.greyLight : AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isStart ? AppColors.grey : AppColors.primary,
              width: 2,
            ),
          ),
          child: Icon(
            isStart ? Icons.play_arrow : Icons.flag,
            color: isStart ? AppColors.greyDark : AppColors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(height: AppConstants.spaceS),
        Text(
          '${weight.toStringAsFixed(0)} kg',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppConstants.spaceXS),
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: TextStyle(color: AppColors.greyDark, fontSize: 10.sp),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}