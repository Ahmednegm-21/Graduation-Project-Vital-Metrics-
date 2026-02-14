import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        // Success Icon
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 48.sp,
            color: Colors.green,
          ),
        ),

        SizedBox(height: 16.h),

        // Achievable text
        Text(
          "It's totally achievable!",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 12.h),

        // Summary text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
              children: [
                TextSpan(text: isLose ? 'Lose ' : 'Gain '),
                TextSpan(
                  text: '${weightDiff.toStringAsFixed(0)} kg',
                  style: const TextStyle(color: Color(0xFF005EBD)),
                ),
                const TextSpan(text: ' by '),
                TextSpan(
                  text: formatDate(targetDate),
                  style: const TextStyle(color: Color(0xFF005EBD)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}