import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanProgressCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double weightDiff;
  final String goalType;

  const PlanProgressCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightDiff,
    required this.goalType,
  });

  @override
  Widget build(BuildContext context) {
    final isLose = goalType.contains('lose');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF005EBD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.timeline,
                  color: const Color(0xFF005EBD),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  'Your Progress Journey',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Weight Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightInfo(
                label: 'Current',
                weight: currentWeight,
                icon: Icons.play_circle_outline,
                color: Colors.grey,
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.grey.shade300,
              ),
              _buildWeightInfo(
                label: 'Target',
                weight: targetWeight,
                icon: Icons.flag_outlined,
                color: const Color(0xFF005EBD),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Difference Badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLose
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLose ? Icons.trending_down : Icons.trending_up,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${weightDiff.toStringAsFixed(1)} kg to ${isLose ? 'lose' : 'gain'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfo({
    required String label,
    required double weight,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weight.toStringAsFixed(0),
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'kg',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}