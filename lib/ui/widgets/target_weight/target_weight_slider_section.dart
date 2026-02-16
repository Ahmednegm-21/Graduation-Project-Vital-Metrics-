import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TargetWeightSliderSection extends StatelessWidget {
  final double targetWeight;
  final double minWeight;
  final double maxWeight;
  final ValueChanged<double> onWeightChanged;

  const TargetWeightSliderSection({
    super.key,
    required this.targetWeight,
    required this.minWeight,
    required this.maxWeight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF005EBD),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12.r,
                elevation: 4,
              ),
              overlayColor: const Color(0xFF005EBD).withOpacity(0.2),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: 22.r,
              ),
              trackHeight: 5.h,
            ),
            child: Slider(
              value: targetWeight,
              min: minWeight,
              max: maxWeight,
              onChanged: onWeightChanged,
            ),
          ),

          SizedBox(height: 8.h),

          // Min/Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minimum weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${minWeight.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Minimum',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
              
              // Maximum weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${maxWeight.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Maximum',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}