import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpeedHeader extends StatelessWidget {
  const SpeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main title
          Text(
            'How fast you want to\nreach your goal?',
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
            'Choose your pace wisely',
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