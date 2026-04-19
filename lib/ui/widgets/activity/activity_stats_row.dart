import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class ActivityStatsRow extends StatelessWidget {
  final int caloriesBurned;
  final int caloriesGoal;
  final int steps;
  final int stepsGoal;
  final int workoutMinutes;
  final int workoutGoal;

  const ActivityStatsRow({
    super.key,
    required this.caloriesBurned,
    required this.caloriesGoal,
    required this.steps,
    required this.stepsGoal,
    required this.workoutMinutes,
    required this.workoutGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Calories Burned',
            value: caloriesBurned.toString(),
            goal: '$caloriesGoal Kcals',
            color: const Color(0xFFFF9500),
            glowColor: const Color(0xFFFF9500),
          ),
          _Divider(),
          _StatItem(
            icon: Icons.directions_walk_rounded,
            label: 'Steps',
            value: steps.toString(),
            goal: '$stepsGoal steps',
            color: const Color(0xFF34C759),
            glowColor: const Color(0xFF34C759),
          ),
          _Divider(),
          _StatItem(
            icon: Icons.fitness_center_rounded,
            label: 'Workout Duration',
            value: workoutMinutes.toString(),
            goal: '$workoutGoal mins',
            color: const Color(0xFF32ADE6),
            glowColor: const Color(0xFF32ADE6),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            context.colors.subText.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String goal;
  final Color color;
  final Color glowColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.glowColor,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    return ScaleTransition(
      scale: _scaleAnim,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: 22.sp,
            ),
          ),

          SizedBox(height: 8.h),

          // Label
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 9.5.sp,
              color: context.colors.subText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          SizedBox(height: 4.h),

          // Value – big bold number
          Text(
            widget.value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.text,
              height: 1,
            ),
          ),


        ],
      ),
    );
  }
}