import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accent;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.value,
    this.min = 10,   
    this.max = 100,  
    required this.divisions,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        activeTrackColor: accent,
        inactiveTrackColor: accent.withOpacity(0.3),
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.2),
        valueIndicatorColor: accent,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: value.toInt().toString(),
        onChanged: onChanged,
      ),
    );
  }
}
