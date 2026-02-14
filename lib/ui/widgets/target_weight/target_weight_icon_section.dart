import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TargetWeightIconSection extends StatelessWidget {
  final bool isLose;

  const TargetWeightIconSection({
    super.key,
    required this.isLose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF005EBD).withOpacity(0.1),
            const Color(0xFF005EBD).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF005EBD).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLose ? Icons.trending_down : Icons.trending_up,
            size: 60.sp,
            color: const Color(0xFF005EBD),
          ),
          SizedBox(height: 8.h),
          Text(
            isLose ? 'Weight Loss Goal' : 'Weight Gain Goal',
            style: TextStyle(
              color: const Color(0xFF005EBD),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}