import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TargetWeightDisplayCard extends StatelessWidget {
  final double targetWeight;
  final double difference;
  final bool isLose;

  const TargetWeightDisplayCard({
    super.key,
    required this.targetWeight,
    required this.difference,
    required this.isLose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label
          Text(
            'Target Weight',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          
          // Animated weight value
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Row(
              key: ValueKey(targetWeight),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  targetWeight.toStringAsFixed(0),
                  style: TextStyle(
                    color: const Color(0xFF005EBD),
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Difference badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 7.h,
            ),
            decoration: BoxDecoration(
              color: isLose
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLose ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 15.sp,
                  color: isLose ? Colors.green : Colors.blue,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${difference.toStringAsFixed(0)} kg ${isLose ? 'to lose' : 'to gain'}',
                  style: TextStyle(
                    color: isLose ? Colors.green : Colors.blue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
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