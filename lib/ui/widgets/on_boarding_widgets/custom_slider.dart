import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accent;
  final ValueChanged<double> onChanged;
  final bool showLabel;

  const CustomSlider({
    super.key,
    required this.value,
    this.min = 10,
    this.max = 100,
    required this.divisions,
    required this.accent,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8.h,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16.r),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24.r),
        activeTrackColor: accent,
        inactiveTrackColor: accent.withOpacity(0.3),
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.2),
        valueIndicatorColor: accent,
        valueIndicatorTextStyle: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: showLabel ? value.toInt().toString() : null,
        onChanged: onChanged,
      ),
    );
  }
}