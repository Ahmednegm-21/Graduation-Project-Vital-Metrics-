import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';

class SummaryMotivationalCard extends StatelessWidget {
  const SummaryMotivationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          // Trophy icon
          Icon(
            Icons.emoji_events,
            color: Colors.amber.shade700,
            size: 28.sp,
          ),
          SizedBox(width: AppConstants.paddingM),
          
          // Motivational text
          Expanded(
            child: Text(
              'Stay consistent and you\'ll reach your goal!',
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}