import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryJourneyCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double weightDiff;
  final DateTime targetDate;
  final String Function(DateTime) formatDate;

  const SummaryJourneyCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightDiff,
    required this.targetDate,
    required this.formatDate,
  });

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
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF005EBD).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Journey',
            style: TextStyle(
              color: const Color(0xFF005EBD),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              // Current Weight
              _buildWeightPoint(
                weight: currentWeight,
                label: 'Today',
                isStart: true,
              ),

              // Progress Line
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF005EBD),
                            Color(0xFF00A3FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${weightDiff.toStringAsFixed(0)} kg',
                      style: TextStyle(
                        color: const Color(0xFF005EBD),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Target Weight
              _buildWeightPoint(
                weight: targetWeight,
                label: formatDate(targetDate),
                isStart: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPoint({
    required double weight,
    required String label,
    required bool isStart,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isStart ? Colors.grey.shade200 : const Color(0xFF005EBD),
            shape: BoxShape.circle,
            border: Border.all(
              color: isStart ? Colors.grey.shade400 : const Color(0xFF005EBD),
              width: 2,
            ),
          ),
          child: Icon(
            isStart ? Icons.play_arrow : Icons.flag,
            color: isStart ? Colors.grey.shade700 : Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${weight.toStringAsFixed(0)} kg',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}