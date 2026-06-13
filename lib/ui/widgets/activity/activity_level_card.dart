import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/activity_level.dart';

class ActivityLevelCard extends StatefulWidget {
  final ActivityLevel activityLevel;
  final VoidCallback onTap;

  const ActivityLevelCard({
    super.key,
    required this.activityLevel,
    required this.onTap,
  });

  @override
  State<ActivityLevelCard> createState() => _ActivityLevelCardState();
}

class _ActivityLevelCardState extends State<ActivityLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGradientStart(bool isDark) {
    switch (widget.activityLevel) {
      case ActivityLevel.low:
        return isDark
            ? const Color(0xFF7B5EA7).withOpacity(0.3)
            : const Color(0xFFE8D5F2);
      case ActivityLevel.moderate:
        return isDark
            ? const Color(0xFF4361EE).withOpacity(0.3)
            : const Color(0xFFD4E8F7);
      case ActivityLevel.high:
        return isDark
            ? const Color(0xFFFF9500).withOpacity(0.3)
            : const Color(0xFFFCE8D5);
    }
  }

  Color _getGradientEnd(bool isDark) {
    switch (widget.activityLevel) {
      case ActivityLevel.low:
        return isDark
            ? const Color(0xFF7B5EA7).withOpacity(0.15)
            : const Color(0xFFF5E8FF);
      case ActivityLevel.moderate:
        return isDark
            ? const Color(0xFF4361EE).withOpacity(0.15)
            : const Color(0xFFE8F4FF);
      case ActivityLevel.high:
        return isDark
            ? const Color(0xFFFF9500).withOpacity(0.15)
            : const Color(0xFFFFEED5);
    }
  }

  IconData _getActivityIcon() {
    switch (widget.activityLevel) {
      case ActivityLevel.low:
        return Icons.self_improvement_rounded;
      case ActivityLevel.moderate:
        return Icons.directions_walk_rounded;
      case ActivityLevel.high:
        return Icons.directions_run_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXXL,
            vertical: AppConstants.spaceL,
          ),
          padding: EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getGradientStart(isDark),
                _getGradientEnd(isDark),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated Icon Container
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 90.w,
                      height: 90.h,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4361EE).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getActivityIcon(),
                          size: 45.sp,
                          color: const Color(0xFF4361EE),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: AppConstants.paddingL),

              // Text content
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity level label
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFF4361EE).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4361EE),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4361EE).withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Activity Level',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isDark
                                    ? Colors.white.withOpacity(0.9)
                                    : const Color(0xFF4361EE),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceS),

                      // Activity level name
                      Text(
                        widget.activityLevel.label,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: context.colors.text,
                          letterSpacing: 0.3,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXS),

                      // Description
                      Text(
                        widget.activityLevel.description,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colors.subText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow indicator
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(10 * (1 - value), 0),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18.sp,
                        color: context.colors.subText.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}