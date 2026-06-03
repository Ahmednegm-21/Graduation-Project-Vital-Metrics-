import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';

class ActivityLevelCard extends StatelessWidget {
  final ActivityLevel activityLevel;
  final VoidCallback onTap;

  const ActivityLevelCard({
    super.key,
    required this.activityLevel,
    required this.onTap,
  });

  IconData get _icon {
    switch (activityLevel) {
      case ActivityLevel.low:
        return Icons.directions_walk_rounded;
      case ActivityLevel.moderate:
        return Icons.directions_run_rounded;
      case ActivityLevel.high:
        return Icons.fitness_center_rounded;
    }
  }

  Color get _color {
    switch (activityLevel) {
      case ActivityLevel.low:
        return const Color(0xFF63E6BE);
      case ActivityLevel.moderate:
        return const Color(0xFF4361EE);
      case ActivityLevel.high:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: context.colors.shadow, blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(_icon, color: _color, size: 26.sp),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Activity Level',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colors.subText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    activityLevel.label,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Real targets calculated from user profile via DailyStats
                  BlocBuilder<ActivityCubit, ActivityState>(
                    builder: (context, activityState) {
                      if (activityState is TodayLoaded) {
                        final stats = activityState.stats;
                        final burn = stats.caloriesGoal;
                        final steps = stats.stepsGoal;
                        final workout = stats.workoutGoal;
                        final water = stats.waterGoalL;
                        final stepsLabel = steps >= 1000
                            ? '${(steps / 1000).toStringAsFixed(0)}k'
                            : '$steps';
                        return Text(
                          'Burn $burn kcal · $stepsLabel steps · $workout min · ${water}L',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.colors.subText,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.subText,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// Detail sheet shown when the user taps the activity level card

class ActivityLevelDetailSheet extends StatefulWidget {
  final ActivityLevel currentLevel;
  final ValueChanged<ActivityLevel> onLevelSelected;

  const ActivityLevelDetailSheet({
    super.key,
    required this.currentLevel,
    required this.onLevelSelected,
  });

  @override
  State<ActivityLevelDetailSheet> createState() =>
      _ActivityLevelDetailSheetState();
}

class _ActivityLevelDetailSheetState extends State<ActivityLevelDetailSheet> {
  late ActivityLevel _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLevel;
  }

  Color _colorFor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.low:
        return const Color(0xFF63E6BE);
      case ActivityLevel.moderate:
        return const Color(0xFF4361EE);
      case ActivityLevel.high:
        return const Color(0xFFFF6B6B);
    }
  }

  IconData _iconFor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.low:
        return Icons.directions_walk_rounded;
      case ActivityLevel.moderate:
        return Icons.directions_run_rounded;
      case ActivityLevel.high:
        return Icons.fitness_center_rounded;
    }
  }

  // Reads user profile from DailyStats so all goal calculations
  // use the exact same weight/height/age/gender as the home screen.
  // Falls back to safe defaults only if the cubit has not loaded yet.
  _UserProfile _resolveProfile(BuildContext context) {
    final activityState = context.read<ActivityCubit>().state;
    if (activityState is TodayLoaded) {
      final stats = activityState.stats;
      return _UserProfile(
        weight: stats.userWeight,
        height: stats.userHeight,
        age: stats.userAge,
        gender: stats.userGender,
      );
    }
    return const _UserProfile(
      weight: 70,
      height: 170,
      age: 25,
      gender: 'male',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(_selected);

    // Read the user profile from ActivityCubit DailyStats.
    // This guarantees the same weight is used here and on the home screen,
    // so water/calorie goals are always consistent across the app.
    final profile = _resolveProfile(context);

    final int burnGoal = _selected.caloriesGoalFor(
      weight: profile.weight,
      height: profile.height,
      age: profile.age,
      gender: profile.gender,
    );
    final int waterGoalMl = _selected.waterGoalMl(weight: profile.weight);
    final String waterGoalL = (waterGoalMl / 1000).toStringAsFixed(1);
    final int stepsGoal = _selected.stepsGoal;
    final int workoutGoal = _selected.workoutGoal;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.subText.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: context.colors.text,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Choose your level — your daily targets update automatically',
              style: TextStyle(
                fontSize: 12.sp,
                color: context.colors.subText,
              ),
            ),

            SizedBox(height: 20.h),

            // Level selector row
            Row(
              children: ActivityLevel.values.map((level) {
                final isSelected = level == _selected;
                final c = _colorFor(level);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selected = level);
                      widget.onLevelSelected(level);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: level != ActivityLevel.high ? 8.w : 0,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? c.withOpacity(0.12)
                            : context.colors.bg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? c
                              : context.colors.subText.withOpacity(0.15),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _iconFor(level),
                            color: isSelected ? c : context.colors.subText,
                            size: 22.sp,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            level.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? c : context.colors.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // Daily targets header
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Your Daily Targets',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.text,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Based on your profile',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Targets grid
            Row(
              children: [
                Expanded(
                  child: _TargetTile(
                    emoji: '🔥',
                    label: 'Burn',
                    value: '$burnGoal kcal',
                    color: color,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _TargetTile(
                    emoji: '👟',
                    label: 'Steps',
                    value: stepsGoal >= 1000
                        ? '${(stepsGoal / 1000).toStringAsFixed(0)}k'
                        : '$stepsGoal',
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _TargetTile(
                    emoji: '⏱',
                    label: 'Workout',
                    value: '$workoutGoal min',
                    color: color,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _TargetTile(
                    emoji: '💧',
                    label: 'Water',
                    value: '${waterGoalL}L',
                    color: color,
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}

// Target tile widget shown in the 2x2 grid inside the detail sheet

class _TargetTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _TargetTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.colors.subText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Internal helper to carry resolved user profile data

class _UserProfile {
  final double weight;
  final double height;
  final double age;
  final String gender;

  const _UserProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
  });
}