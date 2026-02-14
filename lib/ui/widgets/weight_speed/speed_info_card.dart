import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpeedInfoCard extends StatelessWidget {
  const SpeedInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.blue.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: const Color(0xFF005EBD),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Slower pace is healthier and more sustainable',
                style: TextStyle(
                  color: const Color(0xFF005EBD),
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}