import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

class TrackedActivityCard extends StatefulWidget {
  final ActivityModel activity;
  final VoidCallback onDelete;

  const TrackedActivityCard({
    super.key,
    required this.activity,
    required this.onDelete,
  });

  @override
  State<TrackedActivityCard> createState() => _TrackedActivityCardState();
}

class _TrackedActivityCardState extends State<TrackedActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ActivityMeta _getMeta(String type) {
    switch (type.toLowerCase()) {
      case 'tennis':
        return _ActivityMeta(Icons.sports_tennis_rounded, const Color(0xFFFFCC00));
      case 'running':
        return _ActivityMeta(Icons.directions_run_rounded, const Color(0xFFFF3B30));
      case 'cycling':
        return _ActivityMeta(Icons.directions_bike_rounded, const Color(0xFF32ADE6));
      case 'walking':
        return _ActivityMeta(Icons.directions_walk_rounded, const Color(0xFF34C759));
      case 'swimming':
        return _ActivityMeta(Icons.pool_rounded, const Color(0xFF5AC8FA));
      case 'yoga':
        return _ActivityMeta(Icons.self_improvement_rounded, const Color(0xFFAF52DE));
      default:
        return _ActivityMeta(Icons.fitness_center_rounded, const Color(0xFF4361EE));
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getMeta(widget.activity.type);
    final isDark = context.isDark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXXL,
            vertical: AppConstants.spaceS,
          ),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : meta.color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Colored left accent bar
              Container(
                width: 4.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: meta.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusL),
                    bottomLeft: Radius.circular(AppConstants.radiusL),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: meta.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  meta.icon,
                  color: meta.color,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.type,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.text,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        _chip(
                          Icons.timer_outlined,
                          '${widget.activity.durationMinutes} mins',
                          context.colors.subText,
                        ),
                        SizedBox(width: 8.w),
                        _chip(
                          Icons.local_fire_department_rounded,
                          '${widget.activity.caloriesBurned} kcal',
                          const Color(0xFFFF9500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFFF3B30).withOpacity(0.7),
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActivityMeta {
  final IconData icon;
  final Color color;
  _ActivityMeta(this.icon, this.color);
}