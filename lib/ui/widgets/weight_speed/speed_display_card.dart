import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpeedDisplayCard extends StatelessWidget {
  final double selectedSpeed;
  final bool isLose;

  const SpeedDisplayCard({
    super.key,
    required this.selectedSpeed,
    required this.isLose,
  });

  String _getSpeedLabel(double speed) {
    if (speed <= 0.5) return 'Slow & Steady';
    if (speed <= 1.0) return 'Moderate';
    return 'Fast Track';
  }

  Color _getSpeedColor(double speed) {
    if (speed <= 0.5) return Colors.green;
    if (speed <= 1.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
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
          Text(
            isLose ? 'Loss weight per week' : 'Gain weight per week',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 12.h),

          // Selected Speed Value with Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Row(
              key: ValueKey(selectedSpeed),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  selectedSpeed.toStringAsFixed(2),
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
                    color: Colors.grey.shade600,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Speed Label 
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: _getSpeedColor(selectedSpeed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _getSpeedColor(selectedSpeed).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getSpeedLabel(selectedSpeed),
              style: TextStyle(
                color: _getSpeedColor(selectedSpeed),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}