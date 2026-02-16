import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TargetWeightHeader extends StatelessWidget {
  const TargetWeightHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main title
          Text(
            'What is your\ntarget Weight?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          
          // Subtitle
          Text(
            'Set a realistic goal',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}