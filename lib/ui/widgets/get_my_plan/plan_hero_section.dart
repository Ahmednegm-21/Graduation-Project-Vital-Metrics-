import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      padding: EdgeInsets.all(24.w),
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
        children: [
          // Success Icon
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005EBD).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              size: 56.sp,
              color: const Color(0xFF005EBD),
            ),
          ),

          SizedBox(height: 24.h),

          // Title
          Text(
            'Your Personalized Plan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            'is Ready!',
            style: TextStyle(
              color: const Color(0xFF005EBD),
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Target Info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag,
                  color: const Color(0xFF005EBD),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Target: ${formatDate(targetDate)}',
                    style: TextStyle(
                      color: Colors.black,
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