import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpeedSliderSection extends StatelessWidget {
  final double selectedSpeed;
  final List<double> speeds;
  final ValueChanged<double> onSpeedChanged;

  const SpeedSliderSection({
    super.key,
    required this.selectedSpeed,
    required this.speeds,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Speed indicator icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: speeds.map((speed) {
              final isSelected = speed == selectedSpeed;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF005EBD).withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_run,
                  color: isSelected
                      ? const Color(0xFF005EBD)
                      : Colors.grey.shade400,
                  size: isSelected ? 26.sp : 20.sp,
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 14.h),

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
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: selectedSpeed,
              min: 0.25,
              max: 1.5,
              divisions: 5,
              onChanged: onSpeedChanged,
            ),
          ),

          SizedBox(height: 8.h),

          // Speed value labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: speeds.map((speed) {
              final isSelected = speed == selectedSpeed;
              return Text(
                '${speed}kg',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF005EBD)
                      : Colors.grey.shade500,
                  fontSize: isSelected ? 11.sp : 10.sp,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}