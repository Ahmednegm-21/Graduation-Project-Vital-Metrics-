import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularProgressRings extends StatefulWidget {
  final double caloriesProgress;
  final double stepsProgress;
  final double workoutProgress;

  const CircularProgressRings({
    super.key,
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.workoutProgress,
  });

  @override
  State<CircularProgressRings> createState() => _CircularProgressRingsState();
}

class _CircularProgressRingsState extends State<CircularProgressRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220.w,
      height: 220.h,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _RingsPainter(
              caloriesProgress: widget.caloriesProgress * _animation.value,
              stepsProgress: widget.stepsProgress * _animation.value,
              workoutProgress: widget.workoutProgress * _animation.value,
            ),
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double workoutProgress;

  _RingsPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.workoutProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ring settings with glow effect
    final rings = [
      _RingData(
        progress: caloriesProgress,
        color: const Color(0xFFFF9500),
        strokeWidth: 16,
        radius: size.width / 2 - 8,
      ),
      _RingData(
        progress: stepsProgress,
        color: const Color(0xFF34C759),
        strokeWidth: 14,
        radius: size.width / 2 - 30,
      ),
      _RingData(
        progress: workoutProgress,
        color: const Color(0xFF32ADE6),
        strokeWidth: 12,
        radius: size.width / 2 - 50,
      ),
    ];

    // Draw each ring with shadow/glow
    for (final ring in rings) {
      // Background ring
      final bgPaint = Paint()
        ..color = ring.color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, ring.radius, bgPaint);

      // Glow effect
      final glowPaint = Paint()
        ..color = ring.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final sweepAngle = 2 * pi * ring.progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ring.radius),
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );

      // Progress ring
      final progressPaint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ring.radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RingData {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double radius;

  _RingData({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });
}