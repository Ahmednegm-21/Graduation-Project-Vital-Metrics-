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

  // Get speed category label
  String _getSpeedLabel(double speed) {
    if (speed <= 0.5) return 'Slow & Steady';
    if (speed <= 1.0) return 'Moderate';
    return 'Fast Track';
  }

  // Get speed category color
  Color _getSpeedColor(double speed) {
    if (speed <= 0.5) return Colors.green;
    if (speed <= 1.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF005EBD).withOpacity(0.1),
            const Color(0xFF005EBD).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF005EBD).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Label text
          Text(
            isLose ? 'Loss weight per week' : 'Gain weight per week',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 12.h),

          // Animated speed value
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
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Speed category badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 5.h,
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
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}